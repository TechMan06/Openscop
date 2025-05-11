extends Marker2D

const RECORDING_BUTTON: PackedScene = preload("res://scene/ui/secret_menu/recording_button.tscn")

var recording_list: PackedStringArray
var recording_files: Array[RecordingData]
var selected_option: int = 0
var selected_gen: int = 0:
	set(value):
		gen_number.text = str(value).pad_zeros(2)
		
		selected_gen = value

var selected_rot: bool = false:
	set(value):
		if value:
			rot_toggle.text = "ON"
		else:
			rot_toggle.text = "OFF"
		
		selected_rot = value

var options_selected_option: int = 0:
	set(value):
		match value:
			0:
				outline_buttons.position.y = 95
				button_right_offset.position.x = 0
				outline_buttons.visible = true
			1:
				outline_buttons.visible = true
				outline_buttons.position.y = 130
				button_right_offset.position.x = -11
			2:
				outline_buttons.visible = false
		
		options_selected_option = value
		
var triangle_allowed: bool = false
var action_allowed: bool = true
var checking_recording: bool
var original_button_y: float
var returning: bool = false


@onready var recording_buttons: Marker2D = %RecordingButtons
@onready var recording_options: Marker2D = %RecordingOptions
@onready var outline_buttons: Marker2D = %OutlineButtons
@onready var button_right_offset = %ButtonRightOffset
@onready var cursor_sound: AudioStreamPlayer = %CursorSound
@onready var gen_number: Label = %GenNumber
@onready var rot_toggle: Label = %RotToggle
@onready var button_left: AnimatedSprite2D = %ButtonLeft
@onready var button_right: AnimatedSprite2D = %ButtonRight


func _ready() -> void:
	recording_list = DirAccess.get_files_at("user://recordings")
	
	var _left_button_tween: Tween = create_tween().set_loops()
	
	_left_button_tween.tween_property(
									button_left, 
									"offset:x",
									2,
									0.2,
								).as_relative()
	_left_button_tween.tween_interval(0.2)
	_left_button_tween.tween_property(
									button_left, 
									"offset:x",
									-2,
									0.2,
								).as_relative()
	
	var _right_button_tween: Tween = create_tween().set_loops()
	
	_right_button_tween.tween_property(
									button_right, 
									"offset:x",
									-2,
									0.2,
								).as_relative()
	_right_button_tween.tween_interval(0.2)
	_right_button_tween.tween_property(
									button_right, 
									"offset:x",
									2,
									0.2,
								).as_relative()
	
	var _date_array: Array
	var _final_array: RecordingData
	
	for recording in recording_list:
		var _recording_file: RecordingData

		_recording_file = load("user://recordings/" + recording)
		_date_array.push_back([_recording_file.creation_date, recording])
		_date_array.sort_custom(Global.sort_descending)
	
	for recording in _date_array:
		recording_files.push_back(load("user://recordings/" + recording[1]))
	
	var _button_offset: int = 0
	
	for file in recording_files:
		var _button_instance: Marker2D = RECORDING_BUTTON.instantiate()
		
		_button_instance.recording_resource = file
		
		if recording_files.find(file) % 3 == 0 && recording_files.find(file) != 0:
			_button_offset += 1
		
		_button_instance.position.y = 63 * recording_files.find(file) + (_button_offset * 53)
		
		recording_buttons.add_child(_button_instance)
		
	recording_options.visible = false
	outline_buttons.visible = false


func _process(_delta: float) -> void:
	if !checking_recording:
		if action_allowed:
			if Input.is_action_just_pressed("pressed_up") && selected_option != 0:
				selected_option-=1
				cursor_sound.play()
			
			if Input.is_action_just_pressed("pressed_down") && selected_option < recording_files.size()-1:
				selected_option+=1
				cursor_sound.play()
		
		selected_option = clamp(selected_option, 0, recording_files.size() - 1)
		
		recording_buttons.position.y = 33 + (selected_option / 3 * -240)
		
		for button in recording_buttons.get_children():
			button.focused = recording_buttons.get_child(selected_option) == button
		
		if Input.is_action_just_pressed("pressed_action") && action_allowed:
			action_allowed = false
			
			for button in recording_buttons.get_children():
				if recording_buttons.get_child(selected_option) != button:
					if button.get_index() % 2:
						create_tween().tween_property(
														button, 
														"position:x", 
														-288, 
														1.0
													).set_trans(Tween.TRANS_SINE)
					else:
						create_tween().tween_property(
														button, 
														"position:x", 
														295, 
														1.0
													).set_trans(Tween.TRANS_SINE)
			
			await get_tree().create_timer(1.0, true).timeout
			
			var _selected_button: Marker2D = recording_buttons.get_child(selected_option)
			
			original_button_y = _selected_button.global_position.y
			
			if _selected_button.get_index() % 3 != 0 && _selected_button.get_index() != 0:
				$PetSelected.play()
				
				var _button_tween: Tween = create_tween()
				
				_button_tween.tween_property(
												_selected_button, 
												"global_position:y", 
												33, 
												1.0
											).set_trans(Tween.TRANS_SINE)
				
				await _button_tween.finished
			
			checking_recording = true
			triangle_allowed = true
			outline_buttons.visible = true
			recording_options.visible = true
			selected_gen = _selected_button.recording_resource.gen
			selected_rot = _selected_button.recording_resource.rotation
		
		if Input.is_action_just_pressed("pressed_triangle"):
			returning = true
				
			HUD.fade_animation(Color(0.97, 0.27, 0.07))
			
			await HUD.transition_middle
			
			EventBus.return_to_secret.emit()
			
			queue_free()
		
	else:
		if Input.is_action_just_pressed("pressed_triangle") and triangle_allowed:
			triangle_allowed = false
			
			for button in recording_buttons.get_children():
				if recording_buttons.get_child(selected_option)!=button:
					create_tween().tween_property(
													button, 
													"position:x", 
													0, 
													1.0
												).set_trans(Tween.TRANS_SINE)
			
			await get_tree().create_timer(1.0, true).timeout
			
			recording_options.visible=false
			
			var _button_tween = create_tween()
			_button_tween.tween_property(
											recording_buttons.get_child(selected_option), 
											"global_position:y", 
											original_button_y, 
											1.0
										).set_trans(Tween.TRANS_SINE)
			await _button_tween.finished
			
			options_selected_option = 0
			outline_buttons.visible = false
			checking_recording = false
			triangle_allowed = true
			action_allowed = true
	
	if recording_options.visible:
		if Input.is_action_just_pressed("pressed_right"):
			button_right.play("pressed")
		
		if Input.is_action_just_pressed("pressed_left"):
			button_left.play("pressed")
			
		if Input.is_action_just_pressed("pressed_up"):
			options_selected_option -= 1
		
		if Input.is_action_just_pressed("pressed_down"):
			options_selected_option += 1
		
		options_selected_option = clamp(options_selected_option, 0, 2)
	
		if options_selected_option == 0:
			if Input.is_action_just_pressed("pressed_right") && selected_gen > 1:
				selected_gen += 1
			
			if Input.is_action_just_pressed("pressed_left") && selected_gen <= 14:
				selected_gen -= 1

		if options_selected_option == 1:
			if Input.is_action_just_pressed("pressed_right") || Input.is_action_just_pressed("pressed_left"):
				var _recording_data: RecordingData = recording_buttons.get_child(
																					selected_option
																				).recording_resource
				
				_recording_data.rotation = !_recording_data.rotation
				
				selected_rot = _recording_data.rotation
				
				ResourceSaver.save(
										_recording_data, 
										"user://recordings/" + _recording_data.name + ".tres"
									)
		
		if options_selected_option == 2:
			if Input.is_action_just_pressed("pressed_action"):
				var _recording_data: RecordingData = recording_buttons.get_child(
																					selected_option
																				).recording_resource
				
				get_tree().paused = false
				
				var pause_menu_submenu: Control = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
				
				if pause_menu_submenu is Control:
					pause_menu_submenu.get_child(0).queue_free()
					
					self.reparent(pause_menu_submenu)
					
					EventBus.return_to_pause.emit()
					
					pause_menu_submenu.get_parent().unpause_game()
					
					await get_tree().create_timer(0.5).timeout
				
				RecordingManager.load_recording(_recording_data.name, selected_gen)
				#$recording_header.text="Name: "+Global.recording_name+"\nGen: "+str(Global.global_data.gen)
		
		for option in recording_options.get_children():
			if option.get_index() == options_selected_option:
				option.get_child(0).label_settings.set_font_color(Color.WHITE)
			else:
				option.get_child(0).label_settings.set_font_color(Color.BLACK)
