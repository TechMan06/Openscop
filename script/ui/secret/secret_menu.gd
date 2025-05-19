extends Control

const RECORDING_MENU: PackedScene = preload("res://scene/ui/secret_menu/recording_menu.tscn")
const CURSOR_PIXELS: int = 8.0
const CURSOR_SPEED: float = 0.5

var selected_option: int = 0:
	set(value):
		button_sound.play()
		selected_option = value
var in_menu: bool = false
var returning: bool = false
var cursor_tween: Tween

@onready var cursor: Sprite2D = %Cursor
@onready var cursor_pos: Marker2D = $CursorPos
@onready var option_buttons: Marker2D = $OptionButtons
@onready var sub_menu: Control = %SubMenu
@onready var button_sound: AudioStreamPlayer = $ButtonSound


func _ready() -> void:
	EventBus.return_to_secret.connect(unfreeze)
	RecordingManager.stop_recording()
	
	cursor_tween = create_tween().set_loops()
	cursor_tween.tween_property(cursor, "position:x", -CURSOR_PIXELS, CURSOR_SPEED).set_trans(Tween.TRANS_SINE).as_relative()
	cursor_tween.tween_property(cursor, "position:x", CURSOR_PIXELS, CURSOR_SPEED).set_trans(Tween.TRANS_SINE).as_relative()


func _process(delta: float) -> void:
	if !in_menu:
		if !returning:
			cursor_pos.global_position.y = lerp(
													cursor_pos.global_position.y, 
													float(selected_option * 30), 
													8.0 * delta
												)
			cursor.frame = selected_option
			
			if (
					Input.is_action_just_pressed("pressed_down") and 
					selected_option < option_buttons.get_child_count() - 1
				):
					selected_option += 1
			
			if Input.is_action_just_pressed("pressed_up") and selected_option > 0:
				selected_option -= 1
			
			for button in option_buttons.get_children():
				if button.get_index() == selected_option:
					button.frame_coords.x = 1
				else:
					button.frame_coords.x = 0
			
			if Input.is_action_just_pressed("pressed_action"):
				in_menu = true
				$SelectSound.play()
				
				HUD.fade_animation(Color(0.97, 0.27, 0.07))
			
				await HUD.transition_middle
				
				cursor_tween.pause()
				
				match selected_option:
					0:
						sub_menu.add_child(RECORDING_MENU.instantiate())
			
			if Input.is_action_just_pressed("pressed_triangle"):
				returning = true
				
				HUD.fade_animation(Color(0.97, 0.27, 0.07))
				
				await HUD.transition_middle
				
				BGMusic.unmute()
				
				EventBus.return_to_sound_test.emit()
				
				queue_free()


func unfreeze() -> void:
	in_menu = false
	cursor_tween.play()
