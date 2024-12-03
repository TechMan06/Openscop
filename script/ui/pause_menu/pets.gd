extends Control

const BUTTON_SCENE: PackedScene = preload("res://scene/ui/pause_menu/pet_button.tscn")
const BUTTON_SPEED: float = 1.0
const INFO_SPEED: float = 0.5

@export var pets_array: Array[PetResource]

var selected_option: int = 0
var reading_bio: bool
var original_button_pos: Vector2
var returning: bool
var can_select: bool = true
var can_leave: bool = true
var can_return: bool = false

@onready var cursor_sound: AudioStreamPlayer = $CursorSound
@onready var buttons_origin: Marker2D = %ButtonsOrigin
@onready var info_buttons_origin: Marker2D = %InfoButtonsOrigin
@onready var info_buttons_origin_2: Marker2D = %InfoButtonsOrigin2


func _ready() -> void:
	EventBus.text_finished.connect(leave_bio)
	
	var _row: float = 0
	
	for pet in pets_array:
		var button_instance: Marker2D = BUTTON_SCENE.instantiate()
		
		button_instance.pet_resource = pet
		button_instance.collected = int(SaveManager._data.pet.find(pet.pet_id_name) != -1)
		button_instance.position.x = buttons_origin.position.x + (buttons_origin.get_child_count() % 2) * 132
		button_instance.position.y = buttons_origin.position.y + (int(str(_row)[0])) * 56
		buttons_origin.add_child(button_instance)
		
		if buttons_origin.get_child_count() == 6:
			_row += 2
		
		_row += 0.5


func _process(_delta) -> void:
	if selected_option > 5:
		buttons_origin.position.y = -267.5
	else:
		buttons_origin.position.y = 12.5
	
	if !reading_bio && !returning && can_select:
		if Input.is_action_just_pressed("pressed_up") && selected_option > 1:
			selected_option -= 2
			cursor_sound.play()
		
		if Input.is_action_just_pressed("pressed_down") && selected_option < pets_array.size() - 2:
			selected_option += 2
			cursor_sound.play()
		
		if Input.is_action_just_pressed("pressed_left") && selected_option!=0:
			selected_option -= 1
			cursor_sound.play()
		
		if Input.is_action_just_pressed("pressed_right") && selected_option != pets_array.size() - 1:
			selected_option += 1
			cursor_sound.play()
	
		if (
				Input.is_action_just_pressed("pressed_action") 
				and SaveManager._data.pet.find(pets_array[selected_option].pet_id_name) != -1
			):
			can_select = false
			can_leave = false
			$PetSelected.play()
			
			var _move_buttons: Tween = create_tween().set_trans(Tween.TRANS_SINE)
			
			_move_buttons.tween_property(info_buttons_origin, "position:y", 46.0, INFO_SPEED)
			_move_buttons.tween_property(info_buttons_origin_2, "position:y", 0.0, INFO_SPEED)
			
			for button in buttons_origin.get_children():
				if button.get_index() != selected_option:
					if button.get_index() % 2:
						create_tween().tween_property(
														button, 
														"global_position:x", 
														324, 
														BUTTON_SPEED
													).set_trans(Tween.TRANS_SINE)
					else:
						create_tween().tween_property(
														button, 
														"global_position:x", 
														-128, 
														BUTTON_SPEED
													).set_trans(Tween.TRANS_SINE)
			
			await get_tree().create_timer(BUTTON_SPEED, true).timeout
			
			original_button_pos = buttons_origin.get_child(selected_option).global_position
			
			var _button_tween: Tween = create_tween()
			
			_button_tween.tween_property(
											buttons_origin.get_child(selected_option), 
											"global_position", 
											Vector2(89., 29.), 
											0.5
										).set_trans(Tween.TRANS_SINE)
			
			await _button_tween.finished
			
			HUD.create_textbox(load("res://resource/textbox/pet.tres"), pets_array[selected_option].pet_textbox, true)
			reading_bio = true
			can_return = true
	
	for button in buttons_origin.get_children():
		button.focused = buttons_origin.get_child(selected_option) == button
	
	
	if Input.is_action_just_pressed("pressed_triangle"):
		if reading_bio && can_return:
			leave_bio()
		elif can_leave:
			returning = true
			HUD.fade_animation(Color(1.0, 0.85, 1.0))
			
			await HUD.transition_middle
			
			EventBus.return_to_pause.emit()
			queue_free()


func leave_bio() -> void:
	can_return = false
	
	var _move_buttons: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	
	_move_buttons.tween_property(info_buttons_origin_2, "position:y", 46.0, INFO_SPEED)
	_move_buttons.tween_property(info_buttons_origin, "position:y", 0.0, INFO_SPEED)
	
	var _return_tween: Tween = create_tween()
	
	_return_tween.tween_property(
									buttons_origin.get_child(selected_option), 
									"global_position", 
									Vector2(original_button_pos), 
									BUTTON_SPEED
								).set_trans(Tween.TRANS_SINE)
	
	await _return_tween.finished
	
	for button in buttons_origin.get_children():
		if button.get_index() != selected_option:
			if button.get_index() % 2:
				create_tween().tween_property(
												button, 
												"global_position:x", 
												162, 
												BUTTON_SPEED
											).set_trans(Tween.TRANS_SINE)
			else:
				create_tween().tween_property(
												button,"global_position:x", 
												30, 
												BUTTON_SPEED
											).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(BUTTON_SPEED, true).timeout
	
	reading_bio = false
	can_leave = true
	can_select = true
