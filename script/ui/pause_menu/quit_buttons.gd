extends Marker2D

const BUTTON_ANIM_SPEED = 1
const BUTTON_OFFSET = 10

var _selected_option: int:
	set(value):
		button_sound.play()
		_selected_option = value

@onready var button_sound: AudioStreamPlayer = %ButtonSound


func _ready() -> void:
	if Global.global_data.gen == 6:
		button_sound.move_stream(0, 1)


func _process(_delta) -> void:
	for button in get_children():
		if button is Sprite2D:
			if button.get_index() != _selected_option:
				button.frame_coords.x = 0
				
				if button.position.x > 0:
					button.position.x-=BUTTON_ANIM_SPEED
			else:
				button.frame_coords.x = 1
				if button.position.x < BUTTON_OFFSET:
					button.position.x += BUTTON_ANIM_SPEED
	
	if Input.is_action_just_pressed("pressed_up") && _selected_option > 0:
		_selected_option -= 1
				
	if Input.is_action_just_pressed("pressed_down") && _selected_option < get_child_count() - 2:
		_selected_option += 1

	if Input.is_action_just_pressed("pressed_action"):
		match _selected_option:
			0:
				EventBus.return_to_pause.emit()
				queue_free()
			1:
				SaveManager.save_slot(Global.current_slot)
				await get_tree().process_frame
				await get_tree().process_frame
				RecordingManager.stop_recording()
				GameManager.reset_game()
			2:
				await get_tree().physics_frame
				await get_tree().process_frame
				RecordingManager.stop_recording()
				GameManager.reset_game()
