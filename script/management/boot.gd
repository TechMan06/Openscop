extends Control

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			get_tree().change_scene_to_file("res://scene/title/garalina.tscn")
			Global.boot_game.emit()
