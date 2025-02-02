extends Control

func _ready() -> void:
	if GameManager.debug_settings.boot_screen:
		get_tree().change_scene_to_file("res://scene/title/garalina.tscn")


func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			get_tree().change_scene_to_file("res://scene/title/garalina.tscn")
