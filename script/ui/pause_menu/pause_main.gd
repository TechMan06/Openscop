extends Control

const BUTTON_ANIM_SPEED: float = 1
const BUTTON_OFFSET: float = 10
const SCREEN_ANIM_TIME: float = 1.0
const MINI_SCREEN_SIZE: float = 0.5
const PETS_MENU: PackedScene = preload("res://scene/ui/pause_menu/pets_menu.tscn")
const OPTIONS_MENU: PackedScene = preload("res://scene/ui/pause_menu/options_menu.tscn")
const QUIT_MENU: PackedScene = preload("res://scene/ui/pause_menu/quit_buttons.tscn")

var level_slogan: String = ""
var _in_menu: bool = false
var _selected_option: int = 0:
	set(value):
		button_sound.play()
		_selected_option = value
var allow_input: bool = true
var secret_code: bool = true
var current_key: int = 0
var code_array: Array[String] = [
									"pressed_down", 
									"pressed_down", 
									"pressed_down",
									"pressed_down",
									"pressed_down",
									"pressed_right",
									"pressed_start"
								]
var unlocked_nmp: bool = false

@onready var main_menu: Control = %Main
@onready var buttons_origin: Marker2D = %ButtonsOrigin
@onready var button_sound: AudioStreamPlayer = $ButtonSound
@onready var screenshot: Sprite2D = %Screenshot
@onready var counter_label: Label = %CounterLabel
@onready var slogan_label: Label = %SloganLabel
@onready var fade_overlay: Sprite2D = %FadeOverlay
@onready var piece: AnimatedSprite2D = %Piece
@onready var cross_button: AnimatedSprite2D = %CrossButton
@onready var start_button: AnimatedSprite2D = %StartButton
@onready var sub_menu: Control = %SubMenu


func _ready() -> void:
	if RecordingManager.replay:
		buttons_origin.get_child(4).queue_free()
	
	EventBus.destroy_hud.connect(_on_destruction)
	EventBus.destroy_pause.connect(_on_destruction)
	EventBus.return_to_pause.connect(_on_return_to_pause)
	EventBus.crash_game.connect(crash_pause_menu)
	
	Global.can_unpause = false
	get_tree().paused = true
	
	visible = false
	
	counter_label.text = str(SaveManager.get_data().player_data.piece_amount).pad_zeros(5)
	slogan_label.text = level_slogan
	fade_overlay.modulate.a = 0.0

	if Global.global_data.gen == 6:
		button_sound.move_stream(0, 1)
	
	screenshot.z_index = 2
	screenshot.set_texture(get_screen())
	visible = true
	
	var shrink: Tween = create_tween()
	
	shrink.tween_property(
								screenshot, 
								"scale", 
								Vector2(
											MINI_SCREEN_SIZE, 
											MINI_SCREEN_SIZE
										), 
								SCREEN_ANIM_TIME
							).set_trans(Tween.TRANS_SINE)
	
	await shrink.finished
	
	screenshot.z_index = 0
	Global.can_unpause = true
	Global.is_game_paused = true


func _process(_delta: float) -> void:
	if !_in_menu && Global.can_unpause:
		
		if (
			Input.is_action_just_pressed("pressed_l2") 
			or Input.is_action_just_pressed("pressed_l1") 
			or Input.is_action_just_pressed("pressed_r2") 
			or Input.is_action_just_pressed("pressed_r1")
			or Input.is_action_just_pressed("pressed_up")
			or Input.is_action_just_pressed("pressed_down")
			or Input.is_action_just_pressed("pressed_left")
			or Input.is_action_just_pressed("pressed_right")
			or Input.is_action_just_pressed("pressed_start")
			or Input.is_action_just_pressed("pressed_select")
			or Input.is_action_just_pressed("pressed_action")
			or Input.is_action_just_pressed("pressed_triangle")
			or Input.is_action_just_pressed("pressed_square")
			or Input.is_action_just_pressed("pressed_circle")
		):
			if Input.is_action_just_pressed(code_array[current_key]):
				if current_key < code_array.size() - 1:
					current_key += 1
				else:
					unlocked_nmp = true
			else:
				current_key = 0
		
		if Input.is_action_just_pressed("pressed_start") && Global.can_unpause:
			unpause_game()
		
		if Input.is_action_just_pressed("pressed_up") && _selected_option > 0 && allow_input:
			_selected_option -= 1
				
		if (
				Input.is_action_just_pressed("pressed_down") 
				and _selected_option < buttons_origin.get_child_count() - 1
				and allow_input
			):
			_selected_option += 1
		
		if Input.is_action_just_pressed("pressed_action"):
			if _selected_option == 0:
				unpause_game()
			elif _selected_option < 4:
				allow_input = false
				$SelectSound.play()
				fade_overlay.frame_coords.x = _selected_option - 1
				create_tween().tween_property(fade_overlay, "modulate:a", 1.0, HUD.FADE_SPEED)
				HUD.fade_animation(Color(1.0, 0.85, 1.0))
				
				await HUD.transition_middle
				
				main_menu.visible = false
				
				match _selected_option:
					1:
						sub_menu.add_child(OPTIONS_MENU.instantiate())
					
					2:
						sub_menu.add_child(PETS_MENU.instantiate())
						
				_in_menu = true
			else:
				buttons_origin.visible = false
				_in_menu = true
				var _menu_instance: Marker2D = QUIT_MENU.instantiate()
				_menu_instance.position = Vector2(16., 134.)
				add_child(_menu_instance)
	else:
		if _selected_option == 4:
			if Input.is_action_just_pressed("pressed_action"):
				$SelectSound.play()
			
				
	for button in buttons_origin.get_children():
		if button.get_index() != _selected_option:
			button.frame_coords.x = 0
			
			if button.position.x > 0:
				button.position.x-=BUTTON_ANIM_SPEED
		else:
			button.frame_coords.x = 1
			if button.position.x < BUTTON_OFFSET:
				button.position.x += BUTTON_ANIM_SPEED


func get_screen() -> Texture2D:
	var viewport_feed: Viewport =  get_tree().root.get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	var screen_image: Image = screen_texture.get_image()
	var screen: Texture2D = ImageTexture.create_from_image(screen_image)
	
	return screen


func unpause_game() -> void:
	Global.can_unpause = false
	screenshot.z_index = 2
	
	if unlocked_nmp:
		BGMusic.stream_paused = true
		$NMPUnlock.play()
	
	var grow: Tween = create_tween()

	grow.tween_property(
								screenshot, 
								"scale", 
								Vector2(
											1.0, 
											1.0
										), 
								SCREEN_ANIM_TIME
							).set_trans(Tween.TRANS_SINE)
	
	await grow.finished
	
	Global.is_game_paused = false
	Global.can_pause = true
	Global.can_unpause = true
	get_tree().paused = false
	
	if unlocked_nmp:
		SaveManager.get_data().unlocked_nmp = true
		EventBus.unlock_nmp.emit()
	
	queue_free()


func _on_return_to_pause() -> void:
	_in_menu = false
	allow_input = true
	main_menu.visible = true
	buttons_origin.visible = true
	
	if _selected_option < 4:
		create_tween().tween_property(fade_overlay, "modulate:a", 0.0, HUD.FADE_SPEED)


func _on_destruction() -> void:
	Global.is_game_paused = false
	Global.can_pause = true
	Global.can_unpause = false
	queue_free()


func crash_pause_menu() -> void:
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)
