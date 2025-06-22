extends Node

signal boot_game


## The Global Autoload Node, contains global variables related to the game, functions related to creating folders, managing [GlobalData], math and [Array] functions, and crashing the game.


var global_data: GlobalData = load("res://resource/management/global_data.tres") ## The [GlobalData] file used by the game.
var clock_float: float = 0.0 ## The clock used for animating some Shaders.
var custom_sheet: ImageTexture ## Custom spritesheet currently being used by the [Player].
var is_game_paused: bool = false ## Checks whether the game is paused.
var p2talk_dict: Dictionary = JSON.parse_string(
								(FileAccess.open("res://json/p2_talk_data.json", 
								FileAccess.READ)
								).get_as_text()
							) ## JSON dictionary for the P2 to Talk dictionary.
var dialogue_dict: Dictionary = JSON.parse_string(
							(FileAccess.open("res://json/dialogue.json", 
							FileAccess.READ)
							).get_as_text()
						) ## JSON dictionary for the game dialogue.
var can_pause: bool = true ## Checks whether the game can be paused.
var can_unpause: bool = false ## Checks whether the game can be unpaused.
var current_slot: int = 0 ## Current file slot the game will save to.
var current_controller: int = 0 ## Current controller being used by the player.
var draw_mode: bool = false ## Checks whether Draw Mode is currently in use.
var ghost_tracker: Dictionary ## Keeps track of all ghosts spawned within a [Level] Node.
var reading_text: bool = false ## Checks whether a textbox is open.
var demo_timer_multiplier: int = 1 ## Multiplies the demo timer on the title screen depending on how many demos were watched.


@export var level_slogans: Array[SloganResource] ## The slogans used in the Pause Menu, uses [SloganResource].


func _ready() -> void:
	var _directory = DirAccess.open("user://")
	var _directories = ["sheets", "savedata", "screenshots", "recordings"]
	
	for _folder in _directories:
		if !_directory.dir_exists(_folder):
			_directory.make_dir(_folder)
	
	await get_tree().process_frame
	
	if OS.has_feature("movie"):
		get_window().set_size(Vector2i(320, 240))
		get_window().set_flag(Window.FLAG_RESIZE_DISABLED, true)
	
	if GameManager.debug_settings.custom_sheet != "":
		GameManager.file_dialog._on_sheet_selected(GameManager.debug_settings.custom_sheet)
	
	GameManager.file_dialog.set_root_subfolder("user://sheets")
	
	
	if ResourceLoader.exists("user://savedata/global.tres"):
		global_data = load("user://savedata/global.tres")
	else:
		save_global()
	
	boot_game.emit()


func save_global() -> void: ## Saves the [GlobalData] to the user's computer.
	ResourceSaver.save(global_data, "user://savedata/global.tres")


func warp_to(scene_path: String, preset, disable_shadow_monster: bool = false) -> void: ## Sends the game to the scene specified in [code]scene_path[/code] using the [code]preset[/code] [LoadingPreset] and whether to disable the shadow monster man as it does so.
	var _loading_preset: LoadingPreset = null
	
	if preset is String:
		_loading_preset = load(preset)
	else:
		_loading_preset = preset
	
	EventBus.emit_transition.emit(_loading_preset)
	
	await EventBus.start_scene
	
	if disable_shadow_monster:
		SaveManager.get_data().player_data.brightness = 1.0
	
	get_tree().change_scene_to_file(scene_path)


func strip_bbcode(source: String) -> String: ## Strips BBCode from a [String].
	var _regex = RegEx.new()
	_regex.compile("\\[.+?\\]")
	return _regex.sub(source, "", true)


func sort_ascending(a, b) -> bool: ##  Sorts elements in ascending order.
	if a[0] < b[0]:
		return true
	return false


func sort_descending(a, b) -> bool: ##  Sorts elements in descending order.
	if a[0] > b[0]:
		return true
	return false


func sort_mesh(mesh_instance_3d: MeshInstance3D) -> Mesh: ## OBSOLETE, creates sorting values for a [MeshInstance3D] to replicate the per-face sorting method the PSX used.
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


func vector3_average(vector_array: Array[Vector3]) -> Vector3: ## Calculates the average of all [Vector3] values in the [code]vector_array[/code] [Array].
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


func crash_game(stop_music: bool = true, stop_sfx: bool = true) -> void: ## Crashes the game.
	if RecordingManager.recording:
		RecordingManager.stop_recording()
	
	if RecordingManager.replay:
		RecordingManager.cancel_replay()
	else:
		SaveManager.save_odd_care(current_slot)
	
	EventBus.crash_game.emit()
	get_tree().paused = true
	
	if stop_music:
		await get_tree().create_timer(1.0, true).timeout
		
		BGMusic.stop()
	
	if stop_sfx:
		AudioServer.set_bus_mute(1, true)
		AudioServer.set_bus_mute(2, true)


func set_fog_amount(_value: float) -> void: ## Sets the amount of fog to [code]_value[/code].
	RenderingServer.global_shader_parameter_set("fog_size", _value)


func get_frames(_hframes: int, _vframes: int) -> int: ## Gets total frames of a [Sprite2D] or [Sprite3D] Node.
	return _hframes * _vframes


func clamp_frames(_value: int, _hframes: int, _vframes: int) -> int: ## Returns a clamped frame value within a Sprite's [code]hframes[/code] and [code]vframes[/code] values.
	return clamp(_value, 0, get_frames(_hframes, _vframes))
