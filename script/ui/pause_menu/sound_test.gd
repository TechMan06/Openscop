extends Control

# SHOUTOUTS TO JAMES9270 FROM THE GIFTSCOP DEVELOPMENT TEAM!
# JUNE 13TH 2025

const SECRET_MENU: PackedScene = preload("res://scene/ui/secret_menu/secret_menu.tscn")
const BUTTON_ANIM: int = 5
const ANIM_SPEED: float = 0.75

var sound_id: int = 0:
	set(value):
		update_sound_tag(value)
		sound_id = value
var in_menu: bool = false
var returning: bool = false
var bye_bye_counter: int = 0
var button_anim_0: Tween
var button_anim_1: Tween

@onready var sound_test_icon: TextureRect = %SoundTestIcon
@onready var sound_name: Label = %SoundName
@onready var sound_player: AudioStreamPlayer = %SoundPlayer
@onready var button_anim: AnimationPlayer = $ButtonAnim
@onready var button_right: AnimatedSprite2D = %ButtonRight
@onready var button_left: AnimatedSprite2D = %ButtonLeft
@onready var sub_menu: Control = %SubMenu


@export var sounds: Array[SoundResource]


func _ready() -> void:
	EventBus.return_to_sound_test.connect(_on_return)
	
	load_sound(sound_id)
	update_sound_tag(sound_id)
	
	button_anim_0 = create_tween().set_loops()
	
	button_anim_0.tween_property(button_right, "position:x", -BUTTON_ANIM, ANIM_SPEED).as_relative()
	button_anim_0.tween_property(button_right, "position:x", BUTTON_ANIM, ANIM_SPEED).as_relative()
	
	button_anim_1 = create_tween().set_loops()
	
	button_anim_1.tween_property(button_left, "position:x", BUTTON_ANIM, ANIM_SPEED).as_relative()
	button_anim_1.tween_property(button_left, "position:x", -BUTTON_ANIM, ANIM_SPEED).as_relative()


func _process(_delta: float) -> void:
	if in_menu:
		if returning:
			return
		return
	
	if Input.is_action_just_pressed("pressed_left"):
		if sound_id < sounds.size() - 1:
			sound_id += 1
		
		button_left.play(&"pressed")
	
	if Input.is_action_just_pressed("pressed_right"):
		if sound_id > 0:
			sound_id -= 1
		
		button_right.play(&"pressed")
	
	if Input.is_action_just_pressed("pressed_action"):
		load_sound(sound_id)
		
		if sounds[sound_id] != null:
			if sounds[sound_id].sound.get_path() == "res://sfx/pets/care_bye_bye.wav":
				bye_bye_counter += 1
			else:
				if (
						sounds[sound_id].sound.get_path() == "res://sfx/pets/care_uh_oh.wav" and
						bye_bye_counter > 360
					):
					recording_menu()
				else:
					bye_bye_counter = 0
		
		if !button_anim.is_playing():
			button_anim.play(&"button_anim")
		else:
			button_anim.stop()
			button_anim.play(&"button_anim")
		
		sound_player.play()
	
	if Input.is_action_just_pressed("pressed_triangle"):
		returning = true
		
		HUD.fade_animation(Color(1.0, 0.85, 1.0))
		
		await HUD.transition_middle
		
		EventBus.return_to_options.emit()
		BGMusic.unmute()
		
		queue_free()
	
	if Input.is_action_just_pressed("pressed_square"):
		recording_menu()


func recording_menu() -> void:
	in_menu = true
	BGMusic.unmute()
	button_anim_0.pause()
	button_anim_1.pause()
	
	HUD.fade_animation(Color(0.97, 0.27, 0.07))

	await HUD.transition_middle

	sub_menu.add_child(SECRET_MENU.instantiate())


func update_sound_tag(id: int) -> void:
	if is_sound_available(id):
		sound_name.text = ("%02X. " % id) + sounds[id].name
	else:
		sound_name.text = "%02X. ?????" % id


func load_sound(id: int) -> void:
	if is_sound_available(id):
		sound_player.volume_db = 0.0
		sound_player.stream = sounds[id].sound
	else:
		sound_player.volume_db = -80.0


func is_sound_available(id: int) -> bool:
	return (
				sounds[id] != null and 
				SaveManager.get_data().sounds.find(sounds[id].sound.get_path()) != -1
			)


func _on_return() -> void:
	in_menu = false
	button_anim_0.play()
	button_anim_1.play()
