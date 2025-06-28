extends Node
class_name ChildBedroomNode

## Node used for managing the bedrooms in the Child Library.
## This node is responsible for generating the textures for the bedroom and displaying objects in the bedroom depending on the face combination.

var bedroom_primary_color: Vector3 = Vector3(1., 1., 1.)
var bedroom_secondary_color: Vector3 = Vector3(1., 1., 1.)
var predefined_bedroom: bool = false ## Triggered when the bedroom generated is a pre-defined bedroom from the [member ChildBedroomNode.predefined_bedrooms] variable.
var rng: RandomNumberGenerator = RandomNumberGenerator.new() ## [RandomNumberGenerator] that generates a bedroom using the number generated out of the [FaceResource] inputted as Seed.
var higher_fog: bool = false ## Whether to use the special bigger fog seen in Lina's room.
var primary_color_on_all_furniture: bool = true ## Whether all furniture will use the [member PredefinedBedroomPreset.color].

@export_category("Bedroom Settings:")
@export var predefined_bedrooms: Array[PredefinedBedroomPreset] ## Array of predefined bedrooms, uses [PredefinedBedroomPreset].
@export var default_colors: Array[BedroomColorPreset] = [] ## The default color presets used for generic bedrooms or some predefined bedrooms, uses [BedroomColorPreset].
@export var allowed_random_floor_tiles: Array[int] = [0] ## Floor tiles that are allowed to be used on generic bedrooms.
@export var allowed_random_wall_tiles: Array[int] = [0] ## Wall tiles that are allowed to be used on generic bedrooms.
@export var floor_texture: CompressedTexture2D ## Floor tiles used in the bedroom.
@export var floor_texture_frames: Vector2i = Vector2i(1, 1) ## Amount of tiles in [member ChildBedroomNode.floor_texture].
@export var wall_texture: CompressedTexture2D ## Wall tiles used in the bedroom.
@export var wall_texture_frames: Vector2i = Vector2i(1, 1) ## Amount of tiles in [member ChildBedroomNode.wall_texture_frames].

@export_category("Table Objects:")
@export var left_side_objects: Array[CompressedTexture2D] ## Graphics used for the objects on the left side of the table.
@export var right_side_objects: Array[CompressedTexture2D] ## Graphics used for the objects on the right side of the table.
@export var use_left_side_for_both: bool = false  ## Whether to use the same graphics as the left object for the right object.

@export_category("Bedroom Objects:")

@export var overworld_face: OverworldFace ## [OverworldFace] object used for the face on the block on the left side of the room.
@export var table_object_left: Sprite3D ## [Sprite3D] object used for the object on the left side of the table.
@export var table_object_right: Sprite3D ## [Sprite3D] object used for the object on the right side of the table.
@export var child: Sprite3D ## [Sprite3D] object used for the child on the bed.
@export var pet_spawner: Marker3D ## [Marker3D] object for setting the position pets should be spawned on.
@export var note_sprite: Node3D  ## [Node3D] object for setting the position pets should be spawned on.
@export var note_trigger: DialogueTrigger ## [DialogueTrigger] object for triggering the dialogue of the note placed on the wall.
@export var entrance_wall: CollisionShape3D ## Wall used to block off the entrance on most rooms.

@export_category("Bedroom Meshes:")

@export var textured_meshes: Array[MeshInstance3D] ## [MeshInstance3D] or [NiftyMesh] Nodes that will use the generated texture.
@export var primary_colored_meshes: Array[MeshInstance3D] ## [MeshInstance3D] or [NiftyMesh] Nodes that will use the primary generated vertex colors.
@export var secondary_colored_meshes: Array[MeshInstance3D] ## [MeshInstance3D] or [NiftyMesh] Nodes that will use the secondary generated vertex colors.

@onready var generated_texture: SubViewport = $Texture ## The generated texture.
@onready var tile: Node = $Texture/Tile ## The [Node] that groups the floor tiles' [Sprite2D]s together.
@onready var wall: Node = $Texture/Wall ## The [Node] that groups the wall tiles' [Sprite2D]s together.
@onready var tint_layer: Node = $Texture/TintLayer ## The [Node] that groups the tint layers' [ColorRect]s together.

@onready var tile_1: Sprite2D = $Texture/Tile/Tile0 ## The [Sprite2D] Node for the first floor tile of the generated texture.
@onready var tile_2: Sprite2D = $Texture/Tile/Tile1 ## The [Sprite2D] Node for the second floor tile of the generated texture.
@onready var tile_3: Sprite2D = $Texture/Tile/Tile2 ## The [Sprite2D] Node for the third floor tile of the generated texture.
@onready var tile_4: Sprite2D = $Texture/Tile/Tile3 ## The [Sprite2D] Node for the fourth floor tile of the generated texture.
@onready var wall_1: Sprite2D = $Texture/Wall/Wall0 ## The [Sprite2D] Node for the first wall tile of the generated texture.
@onready var wall_2: Sprite2D = $Texture/Wall/Wall1 ## The [Sprite2D] node for the second wall tile of the generated texture.
@onready var wall_3: Sprite2D = $Texture/Wall/Wall2 ## The [Sprite2D] node for the third wall tile of the generated texture.
@onready var wall_4: Sprite2D = $Texture/Wall/Wall3 ## The [Sprite2D] node for the fourth wall tile of the generated texture.


func _ready():
	var _save_file_face: FaceResource = SaveManager.get_data().library_face
	
	if allowed_random_floor_tiles.size() < 0:
		allowed_random_floor_tiles.resize(1)
	
	if allowed_random_wall_tiles.size() < 0:
		allowed_random_wall_tiles.resize(1)
	
	if default_colors.size() < 0:
		default_colors.append(Color.WHITE)
	
	if floor_texture_frames.x <= 0:
		floor_texture_frames.x = 1
	
	if floor_texture_frames.y <= 0:
		floor_texture_frames.y = 1
	
	if wall_texture_frames.x <= 0:
		wall_texture_frames.x = 1
	
	if wall_texture_frames.y <= 0:
		wall_texture_frames.y = 1
	
	if floor_texture != null:
		for _floor_tile in $Texture/Tile.get_children():
			_floor_tile.texture = floor_texture
			
			if floor_texture_frames.x > 0 and floor_texture_frames.y > 1:
				_floor_tile.hframes = floor_texture_frames.x
				_floor_tile.vframes = floor_texture_frames.y
	
	if wall_texture != null:
		for _wall_tile in $Texture/Wall.get_children():
			_wall_tile.texture = wall_texture
			
			if wall_texture_frames.x > 0 and wall_texture_frames.y > 1:
				_wall_tile.hframes = wall_texture_frames.x
				_wall_tile.vframes = wall_texture_frames.y
	
	toggle_wall(true)
	
	if SaveManager.get_data().library_face != null:
		for _bedroom in predefined_bedrooms:
			if (
					_bedroom.assigned_face.expression == _save_file_face.expression and
					_bedroom.assigned_face.horizontal_offsets == _save_file_face.horizontal_offsets and
					_bedroom.assigned_face.vertical_offsets == _save_file_face.vertical_offsets
				):
				
				if overworld_face != null:
					overworld_face.gray = !_bedroom.disable_gray_face
					overworld_face.face.update()
				
				tile_1.frame = Global.clamp_frames(
													_bedroom.floor_tile_1_id, 
													floor_texture_frames.x, 
													floor_texture_frames.y
												)
				tile_2.frame = Global.clamp_frames(
													_bedroom.floor_tile_2_id, 
													floor_texture_frames.x, 
													floor_texture_frames.y
												)
				tile_3.frame = Global.clamp_frames(
													_bedroom.floor_tile_3_id, 
													floor_texture_frames.x, 
													floor_texture_frames.y
												)
				tile_4.frame = Global.clamp_frames(
													_bedroom.floor_tile_4_id, 
													floor_texture_frames.x, 
													floor_texture_frames.y
												)
				
				if !_bedroom.only_use_primary_color_on_furniture:
					primary_color_on_all_furniture = false
				
				tile_1.rotation = deg_to_rad(_bedroom.floor_tile_1_rotation)
				tile_2.rotation = deg_to_rad(_bedroom.floor_tile_2_rotation)
				tile_3.rotation = deg_to_rad(_bedroom.floor_tile_3_rotation)
				tile_4.rotation = deg_to_rad(_bedroom.floor_tile_4_rotation)
				
				tile_1.flip_h = _bedroom.flip_floor_tile_1_h
				tile_1.flip_v = _bedroom.flip_floor_tile_1_v
				tile_2.flip_h = _bedroom.flip_floor_tile_2_h
				tile_2.flip_v = _bedroom.flip_floor_tile_2_v
				tile_3.flip_h = _bedroom.flip_floor_tile_3_h
				tile_3.flip_v = _bedroom.flip_floor_tile_3_v
				tile_4.flip_h = _bedroom.flip_floor_tile_4_h
				tile_4.flip_v = _bedroom.flip_floor_tile_4_v
				
				wall_1.frame = Global.clamp_frames(
													_bedroom.wall_tile_1_id, 
													wall_texture_frames.x, 
													wall_texture_frames.y
												)
				wall_2.frame = Global.clamp_frames(
													_bedroom.wall_tile_2_id, 
													wall_texture_frames.x, 
													wall_texture_frames.y
												)
				wall_3.frame = Global.clamp_frames(
													_bedroom.wall_tile_3_id, 
													wall_texture_frames.x, 
													wall_texture_frames.y
												)
				wall_4.frame = Global.clamp_frames(
													_bedroom.wall_tile_4_id, 
													wall_texture_frames.x, 
													wall_texture_frames.y
												)
				
				wall_1.rotation = deg_to_rad(_bedroom.wall_tile_1_rotation)
				wall_2.rotation = deg_to_rad(_bedroom.wall_tile_2_rotation)
				wall_3.rotation = deg_to_rad(_bedroom.wall_tile_3_rotation)
				wall_4.rotation = deg_to_rad(_bedroom.wall_tile_4_rotation)
				
				wall_1.flip_h = _bedroom.flip_wall_tile_1_h
				wall_1.flip_v = _bedroom.flip_wall_tile_1_v
				wall_2.flip_h = _bedroom.flip_wall_tile_2_h
				wall_2.flip_v = _bedroom.flip_wall_tile_2_v
				wall_3.flip_h = _bedroom.flip_wall_tile_3_h
				wall_3.flip_v = _bedroom.flip_wall_tile_3_v
				wall_4.flip_h = _bedroom.flip_wall_tile_4_h
				wall_4.flip_v = _bedroom.flip_wall_tile_4_v
				
				if child != null:
					if _bedroom.child != null:
						child.texture = _bedroom.child
					else:
						child.queue_free()
				
				if _bedroom.has_entrance:
					toggle_wall(false)
				
				if table_object_left != null:
					table_object_left.texture = _bedroom.table_object_left
					
					table_object_left.position += _bedroom.table_object_left_offset
				
				if table_object_right != null:
					table_object_right.texture = _bedroom.table_object_right
					
					table_object_right.position += _bedroom.table_object_right_offset
				
				if _bedroom.higher_fog:
					higher_fog = true
				
				if _bedroom.valid_pets.size() > 0:
					var _library_pets: Array[String] = SaveManager.get_data().library_pet
					
					for _bedroom_pet in _bedroom.valid_pets:
						var _pet_instance: Marker3D = _bedroom_pet.instantiate()
						
						if _bedroom_pet == null:
							break
						
						if (_pet_instance.get_child(0) is Pet):
							if _library_pets.find(_pet_instance.get_child(0).pet_name) != -1:
								pet_spawner.add_child(_pet_instance)
								break
						
						else:
							if _library_pets.find(_pet_instance.pet_name) != -1:
								pet_spawner.add_child(_pet_instance)
								break
				
				if _bedroom.note != "" and note_trigger != null:
					if _bedroom.note_textbox_preset != null:
						note_trigger.textbox_preset = _bedroom.note_textbox_preset
					
					note_trigger.textbox_text = _bedroom.note
				else:
					note_trigger.queue_free()
				
				if note_sprite != null:
					note_sprite.visible = _bedroom.show_note_sprite
				
				if _bedroom.use_default_colors:
					var _primary_color: Color = default_colors[
															clamp(
																		_bedroom.color_id, 
																		0, 
																		default_colors.size() - 1
																)
														].color
					var _secondary_color: Color = default_colors[
															clamp(
																		_bedroom.color_id, 
																		0, 
																		default_colors.size() - 1
																)
														].secondary_color
					
					bedroom_primary_color = Vector3(_primary_color.r, _primary_color.g, _primary_color.b)
					bedroom_secondary_color = Vector3(_secondary_color.r, _secondary_color.g, _secondary_color.b)
				else:
					bedroom_primary_color = Vector3(_bedroom.color.r, _bedroom.color.g, _bedroom.color.b)
				
				
				predefined_bedroom = true
				
				break
		
		if !predefined_bedroom:
			var _face_seed_string: String
			var _face_seed_int: int
			
			if _save_file_face != null:
				for _expression in _save_file_face.expression:
					_face_seed_string += str(_expression)
				
				for _horizontal_offset in _save_file_face.horizontal_offsets:
					_face_seed_string += str(_horizontal_offset)
				
				for _vertical_offset in _save_file_face.vertical_offsets:
					_face_seed_string += str(_vertical_offset)
			else:
				_face_seed_int = randi_range(0, 9999999999)
			
			_face_seed_int = int(_face_seed_string)
			rng.set_seed(_face_seed_int)
			
			
			for _tile in tile.get_children():
				_tile.frame = rand_from_array(allowed_random_floor_tiles)
				_tile.rotation = random_tile_rotation()
				_tile.flip_h = bool(randi_range(0, 1))
				_tile.flip_v = bool(randi_range(0, 1))
			
			for _wall in wall.get_children():
				_wall.frame = rand_from_array(allowed_random_wall_tiles)
				_wall.rotation = random_tile_rotation()
				_wall.flip_h = bool(randi_range(0, 1))
				_wall.flip_v = bool(randi_range(0, 1))
			
			
			if table_object_left != null:
				table_object_left.texture = rand_from_array(left_side_objects)
				
			if table_object_right != null:
				if use_left_side_for_both:
					table_object_right.texture = rand_from_array(left_side_objects)
				else:
					table_object_right.texture = rand_from_array(right_side_objects)
			
			if default_colors.size() > 0:
				var _random_bedroom_color: BedroomColorPreset = rand_from_array(default_colors)
			
				if _random_bedroom_color != null:
					if child != null:
						child.texture = _random_bedroom_color.child
					
					if _random_bedroom_color.primary_color_on_all_furniture:
						primary_color_on_all_furniture = true
					
					bedroom_primary_color = Vector3(
												_random_bedroom_color.color.r,
												_random_bedroom_color.color.g,
												_random_bedroom_color.color.b,
											)
					bedroom_secondary_color = Vector3(
												_random_bedroom_color.secondary_color.r,
												_random_bedroom_color.secondary_color.g,
												_random_bedroom_color.secondary_color.b,
											)
			
			if note_sprite != null:
				note_sprite.queue_free()
			
			if note_trigger != null:
				note_trigger.queue_free()
	
	for _layer in tint_layer.get_children():
		_layer.get_material().set_shader_parameter("primary_color", bedroom_primary_color)
		_layer.get_material().set_shader_parameter("secondary_color", bedroom_secondary_color)
	
	if child != null and child.get_material_override() != null:
		child.get_material_override().set_shader_parameter(
																"albedoTex", 
																child.texture
															)
	
	if table_object_right != null and table_object_left.get_material_override() != null:
		table_object_left.get_material_override().set_shader_parameter(
																		"albedoTex", 
																		table_object_left.texture
																	)
	
	if table_object_right != null and table_object_right.get_material_override() != null:
		table_object_right.get_material_override().set_shader_parameter(
																			"albedoTex", 
																			table_object_right.texture
																		)
	
	for _textured_mesh in textured_meshes:
		if _textured_mesh is MeshInstance3D:
			_textured_mesh.get_surface_override_material(0).set_shader_parameter(
																					"albedoTex", 
																					generated_texture.get_texture()
																				)

	for _colored_mesh in primary_colored_meshes:
		if _colored_mesh is MeshInstance3D:
			_colored_mesh.get_surface_override_material(0).set_shader_parameter(
																					"modulate_color", 
																					bedroom_primary_color
																				)
	
	if !primary_color_on_all_furniture:
		for _colored_mesh in secondary_colored_meshes:
			if _colored_mesh is MeshInstance3D:
				_colored_mesh.get_surface_override_material(0).set_shader_parameter(
																						"modulate_color", 
																						bedroom_secondary_color
																					)
	else:
		for _colored_mesh in secondary_colored_meshes:
			if _colored_mesh is MeshInstance3D:
				_colored_mesh.get_surface_override_material(0).set_shader_parameter(
																						"modulate_color", 
																						bedroom_primary_color
																					)


func _process(_delta: float) -> void:
	if higher_fog:
		Global.set_fog_amount(6.25)
		higher_fog = false


func random_tile_rotation() -> float: ## Rotates a [Node2D] randomly while snapping to 90º angles, use result with [code]deg_to_rad[/code] using the seeded [RandomNumberGenerator] from this node.
	return deg_to_rad(rng.randi_range(1, 3) * 90)


func random_sprite_frame(_hframes: int, _vframes: int) -> int: ## Picks a random frame from a [Sprite2D] or [Sprite3D] using the seeded [RandomNumberGenerator] from this node.
	return rng.randi_range(0, _hframes * _vframes)


func rand_from_array(_array: Array) -> Variant: ## Picks a random value from [code]_array[/code] using the seeded [RandomNumberGenerator] from this node.
	return _array[rng.randi_range(0, _array.size() - 1)]


func toggle_wall(value: bool) -> void:
	if entrance_wall != null:
		entrance_wall.disabled = !value
