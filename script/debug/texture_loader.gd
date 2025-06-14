@tool
#DO NOT TOUCH THIS NODE OR THINGS WILL BREAK ONCE YOU DECIDE TO UPLOAD YOUR REPO.
extends Node
class_name TextureLoader

## Used for replacing placeholder textures on 3D models by textures.com textures generated using the TexBuild program in-game.

## File path of the textures.com texture the placeholder texture should be replaced with.
@export var protected_texture_path: String = ""


## Responsible for loading the texture if the file exists.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if FileAccess.file_exists(protected_texture_path):
		if get_parent() is MeshInstance3D:
			if get_parent().get_surface_override_material(0).get_shader_parameter("albedoTex") != null:
				get_parent().get_surface_override_material(0).set_shader_parameter(
															"albedoTex", 
															load(protected_texture_path)
														)
		else:
			printerr("Parent is not NiftyMesh or MeshInstance3D!")		
	else:
		printerr("Texture file \"" + protected_texture_path + "\" not found!")
