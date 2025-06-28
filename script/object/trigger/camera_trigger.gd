extends TriggerClass
class_name CameraTrigger

var screen: TextureRect

@export var camera_viewport: SubViewport


func _physics_process(_delta: float) -> void:
	if  Input.is_action_just_pressed("pressed_triangle") and screen != null and screen.visible:
		screen.visible = false
		SaveManager.get_data().player_data.input_enabled = true


func _on_trigger() -> void:
	if screen == null:
		screen = TextureRect.new()
		screen.visible = false
		screen.size = Vector2i(320, 240)
		screen.texture = ViewportTexture.new()
		screen.texture = camera_viewport.get_texture()
		
		add_child(screen)
	
	screen.visible = true
	SaveManager.get_data().player_data.input_enabled = false
