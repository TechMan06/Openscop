extends Control

var layer0: CompressedTexture2D
var layer1: CompressedTexture2D


func _ready() -> void:
	$Layer0.texture = layer0
	$Layer1.texture = layer1
	SaveManager.get_data().player_data.input_enabled = false
	Global.can_pause = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pressed_triangle"):
		Global.can_pause = true
		SaveManager.get_data().player_data.input_enabled = true
		queue_free()
