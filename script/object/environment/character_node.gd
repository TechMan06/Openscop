@icon("res://icon/gen.png")
extends Node
class_name CharSpecific

@export var characters: Array[int] = [0, 1, 2]
@export var delete_if_found: bool = false

func _ready() -> void:
	if !delete_if_found:
		if characters.find(SaveManager.get_data().player_data.character_id) == -1:
			self.queue_free()
	else:
		if characters.find(SaveManager.get_data().player_data.character_id) != -1:
			self.queue_free()
