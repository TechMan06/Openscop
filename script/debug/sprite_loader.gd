#DO NOT TOUCH THIS NODE OR THINGS WILL BREAK ONCE YOU DECIDE TO UPLOAD YOUR REPO.
extends TextureLoader
class_name TextureRectLoader

## Used for replacing 2D placeholder textures on by textures.com textures generated using the TexBuild program in-game. Inherits [TextureLoader]


## Responsible for loading the texture if the file exists.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if FileAccess.file_exists(protected_texture_path):
		if get_parent() is TextureRect:
			if get_parent().texture != null:
				get_parent().texture = load(protected_texture_path)
		else:
			printerr("Parent is not TextureRect")		
	else:
		printerr("Texture file \"" + protected_texture_path + "\" not found!")
