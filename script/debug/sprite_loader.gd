#DO NOT TOUCH THIS NODE OR THINGS WILL BREAK ONCE YOU DECIDE TO UPLOAD YOUR REPO.
extends Node
class_name TextureRectLoader

@export var protected_texture_path: String = ""

func _ready() -> void:
	if !Engine.is_editor_hint():
		if FileAccess.file_exists(protected_texture_path):
			if get_parent() is TextureRect:
				if get_parent().texture != null:
					get_parent().texture = load(protected_texture_path)
			else:
				printerr("Parent is not TextureRect")		
		else:
			printerr("Texture file \"" + protected_texture_path + "\" not found!")
