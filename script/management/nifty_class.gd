@icon("res://icon/pencil.png")
extends MeshInstance3D
class_name NiftyMesh

var texture: CompressedTexture2D = get_surface_override_material(0).get_shader_parameter("albedoTex")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.nifty_finished.connect(_update_textures)
	
	var _texture_image: Image = texture.get_image()
	
	await get_tree().process_frame
	EventBus.nifty_upload.emit(_texture_image)


func _update_textures(room_texture: Image, _background_texture: Image) -> void:
	get_surface_override_material(0).set_shader_parameter(
															"albedoTex", 
															ImageTexture.create_from_image(room_texture)
														)
