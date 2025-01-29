extends Node

signal boot_game

var global_data: GlobalData = load("res://resource/management/global_data.tres")
var custom_sheet: ImageTexture
var is_game_paused: bool = false
var p2talk_dict: Dictionary = JSON.parse_string(
								(FileAccess.open("res://json/p2_talk_data.json", 
								FileAccess.READ)
								).get_as_text()
							)
var dialogue_dict: Dictionary = JSON.parse_string(
							(FileAccess.open("res://json/dialogue.json", 
							FileAccess.READ)
							).get_as_text()
						)
var can_pause: bool = true
var can_unpause: bool = false
var current_slot: int = 0
var current_controller: int = 0


func _ready() -> void:
	var _directory = DirAccess.open("user://")
	var _directories = ["sheets", "savedata", "screenshots", "recordings"]
	for _folder in _directories:
		if !_directory.dir_exists(_folder):
			_directory.make_dir(_folder)
	
	await get_tree().process_frame
	
	if GameManager.debug_settings.custom_sheet != "":
		GameManager.file_dialog._on_sheet_selected(GameManager.debug_settings.custom_sheet)
	
	GameManager.file_dialog.set_root_subfolder("user://sheets")
	
	
	if ResourceLoader.exists("user://savedata/global.tres"):
		global_data = load("user://savedata/global.tres")
	else:
		save_global()

	boot_game.emit()


func save_global() -> void:
	ResourceSaver.save(global_data, "user://savedata/global.tres")


func warp_to(scene_path: String, preset) -> void:
	var _loading_preset: LoadingPreset = null
	
	if preset is String:
		_loading_preset = load(preset)
	else:
		_loading_preset = preset
	
	EventBus.emit_transition.emit(_loading_preset)
	
	await EventBus.start_scene
	
	get_tree().change_scene_to_file(scene_path)


func strip_bbcode(source: String) -> String:
	var _regex = RegEx.new()
	_regex.compile("\\[.+?\\]")
	return _regex.sub(source, "", true)


func sort_ascending(a, b) -> bool:
	if a[0] < b[0]:
		return true
	return false


func sort_descending(a, b) -> bool:
	if a[0] > b[0]:
		return true
	return false


func sort_mesh(mesh_instance_3d: MeshInstance3D) -> Mesh:
	var surface_index: int = 0
	
	var new_mesh: ArrayMesh = ArrayMesh.new()
	
	while surface_index < mesh_instance_3d.mesh.get_surface_count():
		#This is complicated, so this will have plenty of comments
		
		#First we will convert the mesh into an ArrayMesh so we can use it in MeshDataTool
		var meshinstance_array: Array = mesh_instance_3d.mesh.surface_get_arrays(0)
		var arraymesh: ArrayMesh = ArrayMesh.new()
		
		arraymesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshinstance_array)
		
		#Now we can easily read the Mesh's data using MeshDataTool
		var mesh_data: MeshDataTool = MeshDataTool.new()
		
		mesh_data.create_from_surface(arraymesh, surface_index)
		
		#Now we will create a new mesh identical to the original
		#This mesh will contain vertex color attributes (yet to implement)
		#It will also allow for face-based sorting, check sort-test.tscn
		var output_array: Array = []
		output_array.resize(Mesh.ARRAY_MAX)
		
		var verts = PackedVector3Array()
		var uvs = PackedVector2Array()
		var normals = PackedVector3Array()
		var color = PackedColorArray()
		var face_center = PackedFloat32Array()
		
		#So far the new mesh is empty, here we will build the data for it
		var face_count: int = mesh_data.get_face_count()
		var face_iterate: int = 0
		var total_vertex_iterate: int = 0
		var face_vertex_iterate: int = 0
		
		
		while face_iterate < face_count:
			if face_vertex_iterate <= 2:
				verts.push_back(	
								mesh_data.get_vertex(
														mesh_data.get_face_vertex(
																					face_iterate, 
																					face_vertex_iterate
																				)
													)
							)
				
				uvs.push_back(	
								mesh_data.get_vertex_uv(
															mesh_data.get_face_vertex(
																						face_iterate, 
																						face_vertex_iterate
																					)
											)
							)
				
				normals.push_back(	
								mesh_data.get_vertex_normal(
															mesh_data.get_face_vertex(
																						face_iterate, 
																						face_vertex_iterate
																					)
											)
							)
				
				if GameManager.debug_settings.debug:
					if face_iterate == 2 || face_iterate == 3:
						color.push_back(Color(1.0, 0.0, 0.0, 1.0))
					else:
						color.push_back(Color(0.5, 0.5, 0.5, 1.0))
				
				if mesh_instance_3d.mesh.surface_get_arrays(surface_index)[3] && global_data.gen > 3:
					color.push_back(	
									mesh_data.get_vertex_color(
																mesh_data.get_face_vertex(
																							face_iterate, 
																							face_vertex_iterate
																						)
												)
								)
				
				face_vertex_iterate += 1
			else:
				face_iterate += 1
				face_vertex_iterate = 0
		
		var face_iterate_2: int = 0
		var face_vertex_iterate_2: int = 0
		var quad_iterate: int = 0
		
		while face_iterate_2 < face_count:
			if face_vertex_iterate_2 <= 2:
				var vector3_average: Vector3 = vector3_average(
																	[
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2, 
																												0
																											)
																		),
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2, 
																												1
																											)
																		),
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2, 
																												2
																											)
																		)
																	]
																)
				if face_iterate_2 + 1 >= face_count:
					face_center.push_back(vector3_average.x)
					face_center.push_back(vector3_average.y)
					face_center.push_back(vector3_average.z)
					face_center.push_back(1.0)

					face_vertex_iterate_2 += 1
				else:
					var add_or_subtract: int = 0
					
					if face_iterate_2 % 2 != 0:
						add_or_subtract = -1
					else:
						add_or_subtract = 1
					
					var vector3_average_1: Vector3 = vector3_average(
																	[
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2 + add_or_subtract, 
																												0
																											)
																		),
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2 + add_or_subtract, 
																												1
																											)
																		),
																		mesh_data.get_vertex(
																								mesh_data.get_face_vertex(
																												face_iterate_2 + add_or_subtract, 
																												2
																											)
																		)
																	]
																)
					face_center.push_back((vector3_average.x + vector3_average_1.x) / 2)
					face_center.push_back((vector3_average.y + vector3_average_1.y) / 2)
					face_center.push_back((vector3_average.z + vector3_average_1.z) / 2)
					face_center.push_back(1.0)

					face_vertex_iterate_2 += 1
			else:
				face_iterate_2 += 1
				face_vertex_iterate_2 = 0
		
		var vertex_count: int = mesh_data.get_vertex_count()
		var vertex_iterate: int = 0

		output_array[Mesh.ARRAY_VERTEX] = verts
		output_array[Mesh.ARRAY_TEX_UV] = uvs
		output_array[Mesh.ARRAY_NORMAL] = normals
		
		if mesh_instance_3d.mesh.surface_get_arrays(surface_index)[3] && global_data.gen > 3:
			output_array[Mesh.ARRAY_COLOR] = color
		
		if GameManager.debug_settings.debug:
			output_array[Mesh.ARRAY_COLOR] = color
		
		output_array[Mesh.ARRAY_TANGENT] = face_center
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, output_array)
		
		surface_index += 1

	return new_mesh


func vector3_average(vector_array: Array[Vector3]) -> Vector3:
	var x: float = 0.0
	var y: float = 0.0
	var z: float = 0.0
	
	for vector in vector_array:
		x += vector.x
		y += vector.y
		z += vector.z
	
	x = x / vector_array.size() + 1
	y = y / vector_array.size() + 1
	z = z / vector_array.size() + 1
	
	return Vector3(x, y, z)
