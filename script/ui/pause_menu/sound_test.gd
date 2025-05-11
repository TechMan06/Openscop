extends Control

const SECRET_MENU: PackedScene = preload("res://scene/ui/secret_menu/secret_menu.tscn")
const BUTTON_ANIM: int = 5
const ANIM_SPEED: float = 0.75

var sound_id: int = 0:
	set(value):
		load_sound(value)
		sound_id = value
var in_menu: bool = false
var returning: bool = false
var bye_bye_counter: int = 0

@onready var sound_test_icon: TextureRect = %SoundTestIcon
@onready var sound_name: Label = %SoundName
@onready var sound_player: AudioStreamPlayer = %SoundPlayer
@onready var button_anim: AnimationPlayer = $ButtonAnim
@onready var button_right: AnimatedSprite2D = %ButtonRight
@onready var button_left: AnimatedSprite2D = %ButtonLeft
@onready var sub_menu: Control = %SubMenu


@export var sounds: Array[SoundResource]


func _ready() -> void:
	load_sound(sound_id)
	
	var button_anim_0: Tween = create_tween().set_loops()
	
	button_anim_0.tween_property(button_right, "position:x", -BUTTON_ANIM, ANIM_SPEED).as_relative()
	button_anim_0.tween_property(button_right, "position:x", BUTTON_ANIM, ANIM_SPEED).as_relative()
	
	var button_anim_1: Tween = create_tween().set_loops()
	
	button_anim_1.tween_property(button_left, "position:x", BUTTON_ANIM, ANIM_SPEED).as_relative()
	button_anim_1.tween_property(button_left, "position:x", -BUTTON_ANIM, ANIM_SPEED).as_relative()


func _process(_delta: float) -> void:
	if !in_menu:
		if !returning:
			if Input.is_action_just_pressed("pressed_left"):
				if sound_id < sounds.size() - 1:
					sound_id += 1
				
				button_left.play(&"pressed")
			
			if Input.is_action_just_pressed("pressed_right"):
				if sound_id > 0:
					sound_id -= 1
				
				button_right.play(&"pressed")
			
			if Input.is_action_just_pressed("pressed_action"):
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
	
	HUD.fade_animation(Color(0.97, 0.27, 0.07))

	await HUD.transition_middle

	sub_menu.add_child(SECRET_MENU.instantiate())


func load_sound(id: int) -> void:
	if id > -1 and id < sounds.size():
		if SaveManager.get_data().sounds.find(sounds[id].sound.get_path()) != -1:
			sound_name.text = hex(id).pad_zeros(2) + ". " + sounds[id].name
			sound_player.volume_db = 0.0
			sound_player.stream = sounds[id].sound
		else:
			sound_name.text = str(id).pad_zeros(2) + ". ?????"
			sound_player.volume_db = -80.0


func hex(number: int) -> String:
	var string: String = String.num_int64(number, 16 ,true)
	
	return string
