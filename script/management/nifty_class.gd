@icon("res://icon/pencil.png")
extends MeshInstance3D
class_name NiftyMesh



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if visible && get_surface_override_material(0).get_shader_parameter("per_quad_depth"):
		self.mesh = Global.sort_mesh(self)
		print("REBUILDING")

	EventBus.nifty_finished.connect(_update_textures)
	
	await get_tree().process_frame
	
	var texture: CompressedTexture2D = get_surface_override_material(0).get_shader_parameter("albedoTex")
	var _texture_image: Image = texture.get_image()
	
	EventBus.nifty_upload.emit(_texture_image)


func _update_textures(room_texture: Image, _background_texture: Image, pixel_array: Array[Vector2i]) -> void:
	get_surface_override_material(0).set_shader_parameter(
															"albedoTex", 
															ImageTexture.create_from_image(room_texture)
														)
