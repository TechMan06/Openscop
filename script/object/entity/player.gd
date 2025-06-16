@icon("res://icon/player.png")
extends Entity
class_name Player

## The class used for the player object, inherits the [Entity] class.

const SCHOOL_OVERLAY: PackedScene = preload("res://scene/ui/school_ui.tscn") ## The [PackedScene] for the school screen overlay.
const TERRAIN_TYPES: Array[String] = [
			"None",
			"EvenCare", 
			"Grass", 
			"Cement", 
			"Cement2", 
			"Cement3", 
			"School", 
			"Sand"
		] ## The [PackedScene] for the school screen overlay.
const FOOTSTEP_FADEIN_TIMES: Array[float] = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5] ## The fade-in times for each footstep type available in [member Player.TERRAIN_TYPES]
const FOOTSTEP_FADEOUT_TIMES: Array[float] = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05] ## The fade-out times for each footstep type available in [member Player.TERRAIN_TYPES]


var current_footstep: int = 0: ## The current footstep sound from [member Player.TERRAIN_TYPES] currently being used by the player.
	set(value):
		current_footstep = value
		if value != 0:
			var _sound_path: String = "res://sfx/footstep/" + str(
											TERRAIN_TYPES[value]
										).to_lower() + ".wav"
			
			if _footstep_sound.stream.get_path() != _sound_path:
				_footstep_sound.stream = load(_sound_path)
		else:
			_footstep_sound.volume_db = -80.0

var control_device: int = 0 ## Currently controller being used.
var rotation_direction: Vector3 = Vector3.ZERO ## Direction of the player's rotation in the school.
var current_sheet: String = "res://asset/2d/sprite/player/guardian.png" ## Current sprite sheet the player is using.

@export var player_stats: PlayerStats ## Stores the player data.
@export var p2_talk_component: P2TalkComponent ## P2 To Talk Component assigned to the player object.

@onready var _terrain_detector: RayCast3D = $TerrainDetector
@onready var _footstep_sound: AudioStreamPlayer3D = $FootstepSound


func _ready() -> void:
	GameManager.update_sheet.connect(update_sheet)
	EventBus.p2talk_type.connect(_type_p2talk_key)
	
	_sprite = $PlayerSprite
	_sprite_material = $PlayerSprite.get_material_override()
	_terrain_detector = $TerrainDetector
	_footstep_sound = $FootstepSound
	_p2talk_text = $P2TalkOrigin/P2TalkButtons
	_p2talk_origin = $P2TalkOrigin
	_p2talk_button_sound = $ButtonSound
	
	await get_tree().physics_frame
	
	if Global.global_data.gen <= 2:
		set_collision_mask(0)
		current_sheet = "res://asset/2d/sprite/player/gen_1.png"
	
	update_sheet()
	
	if (
			player_stats.character_id == 2 and 
			Global.global_data.gen > 6 and 
			Global.global_data.gen < 9
		):
		_movement_speed = 6.0
	else:
		_movement_speed = 5.0
	
	if control_mode == 1:
		var _school_hud: Marker2D = SCHOOL_OVERLAY.instantiate()
		
		_school_hud.player = self
		
		add_child(_school_hud)
	
	await self.tree_entered
	
	EventBus.player_spawned.emit(self)


func _input(event: InputEvent) -> void:
	event.device = Global.current_controller
	control_device = event.device


func _physics_process(_delta: float) -> void:
	if player_stats.input_enabled:
		_handle_input()
	else:
		_h = 0.0
		_v = 0.0

	if is_walking:
		if _sprite.hframes > 1 && _sprite.vframes > 1:
			if !_treadmill:
				if !_footstep_sound.playing:
					if _footstep_sound.stream_paused:
						_footstep_sound.stream_paused = false
					else:
						_footstep_sound.playing = true
			else:
				_footstep_sound.stream_paused = true
			
			if current_footstep != 0:
				create_tween().tween_property(
												_footstep_sound, 
												"volume_db", 
												80.0, 
												FOOTSTEP_FADEIN_TIMES[current_footstep]
											)
		
		#DETECTS IF PLAYER IS ON FLOOR OR Y0, DEFINES SURFACE TYPE AND SETS FOOTSTEP SOUND
		if position.y == 0.0:
			#CHECKS IF BELOW PLAYER THERE'S MESH WITH THESE NAMES
			if (
				_terrain_detector.get_collider() != null
				and TERRAIN_TYPES.find(
						_terrain_detector.get_collider().name
					) 
				> -1
			):
				current_footstep = TERRAIN_TYPES.find(_terrain_detector.get_collider().name)
	else:
		_current_frame = 0
		
		if current_footstep != 0:
			create_tween().tween_property(
											_footstep_sound, 
											"volume_db", 
											-80.0, 
											FOOTSTEP_FADEOUT_TIMES[current_footstep]
										)
	
	player_stats.player_pos.x = global_position.x
	player_stats.player_pos.y = global_position.y
	player_stats.player_pos.z = global_position.z
	player_stats.player_pos.w = direction


func _handle_input() -> void:
	if (
			Input.is_action_just_pressed("change_mode") 
			and Global.global_data.gen >= 11 
			and player_stats.p2talk_enabled 
			and control_mode == 0
		):
		Global.current_controller = int(!bool(Global.current_controller))
		$P2TalkToggle.play()
		
	if Global.current_controller != 0:
		_h = 0.0
		_v = 0.0
	
	if control_device == 0 && control_mode < 2:
		
		_v = (
				(
					Input.get_action_strength("pressed_down") 
					- Input.get_action_strength("pressed_up")
				)
				* (
					int(!player_stats.retrace_steps) - int(player_stats.retrace_steps)
					)
			)
		
		if player_stats.character_id == 2:
			_h = (
					(
						Input.get_action_strength("pressed_left") 
						- Input.get_action_strength("pressed_right")
					)
					* (
						int(!player_stats.retrace_steps) - int(player_stats.retrace_steps)
						) 
				)
		else:
			_h = (
					(
						Input.get_action_strength("pressed_right") 
						- Input.get_action_strength("pressed_left")
					)
					* (
						int(!player_stats.retrace_steps) - int(player_stats.retrace_steps)
						) 
				)
		
	if control_device != 0 && player_stats.p2talk_enabled && control_mode == 0:
		if Input.is_action_just_pressed("pressed_action"):
			_p2talk_text.text += "5"
			
			if _last_press == "L1":
				p2talk_word += "S "
			elif _last_press == "L2":
				p2talk_word += "M "
			elif _last_press == "R1":
				p2talk_word += "EY "
			elif _last_press == "R2":
				p2talk_word += "UW "
			else:
				p2talk_word += "AA "
			
			_last_press = ""
			
		if Input.is_action_just_pressed("pressed_triangle"):
			_p2talk_text.text+="8"

			if _last_press == "L1":
				p2talk_word += "SH "
			elif _last_press == "L2":
				p2talk_word += "L "
			elif _last_press == "R1":
				p2talk_word += "IH "
			elif _last_press == "R2":
				p2talk_word += "B "
			else:
				p2talk_word += "AO "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_circle"):
			_p2talk_text.text += "7"

			if _last_press == "L1":
				p2talk_word += "ZH "
			elif _last_press == "L2":
				p2talk_word += "R "
			elif _last_press == "R1":
				p2talk_word += "IY "
			elif _last_press == "R2":
				p2talk_word += "T "
			else:
				p2talk_word += "AW "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_square"):
			_p2talk_text.text+="6"

			if _last_press == "L1":
				p2talk_word += "Z "
			elif _last_press == "L2":
				p2talk_word += "N "
			elif _last_press == "R2":
				p2talk_word += "P "
			else:
				p2talk_word += "AE "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_up"):
			_p2talk_text.text += "@"

			if _last_press == "L1":
				p2talk_word += "JH "
			elif _last_press == "L2":
				p2talk_word += "Y "
			elif _last_press == "R1":
				p2talk_word += "OW "
			elif _last_press == "R2":
				p2talk_word += "F "
			else:
				p2talk_word += "AY "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_down"):
			_p2talk_text.text += "#"

			if _last_press == "L1":
				p2talk_word += "K "
			elif _last_press == "L2":
				p2talk_word += "HH "
			elif _last_press == "R1":
				p2talk_word += "OY "
			elif _last_press == "R2":
				p2talk_word += "V "
			else:
				p2talk_word += "AE "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_left"):
			_p2talk_text.text += "9"

			if _last_press == "L1":
				p2talk_word += "NG "
			elif _last_press == "L2":
				p2talk_word += "UH "
			elif _last_press == "R2":
				p2talk_word += "TH "
			else:
				p2talk_word += "EH "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_right"):
			_p2talk_text.text += "!"

			if _last_press == "L1":
				p2talk_word += "G "
			elif _last_press == "R1":
				p2talk_word += "UH "
			elif _last_press == "R2":
				p2talk_word += "DH "
			else:
				p2talk_word += "ER "

			_last_press = ""

		if Input.is_action_just_pressed("pressed_start"):
			_p2talk_text.text += "$"

			if _last_press == "L1":
				p2talk_word += "CH "
			elif _last_press == "L2":
				p2talk_word += "W "
			elif _last_press == "R2":
				p2talk_word += "D "
			else:
				p2talk_word += "AH "

			_last_press = ""
		
		if Input.is_action_just_pressed("pressed_l1"):
			_p2talk_text.text += "4"
			_last_press="L1"

		if Input.is_action_just_pressed("pressed_l2"):
			_p2talk_text.text += "3"
			_last_press="L2"

		if Input.is_action_just_pressed("pressed_r1"):
			_p2talk_text.text += "2"
			_last_press="R1"

		if Input.is_action_just_pressed("pressed_r2"):
			_p2talk_text.text += "1"
			_last_press="R2"
	
	if (Input.is_action_just_pressed("pressed_select") && _p2talk_text.text != "" && _can_submit):
		p2_talk_component._create_word()
		_last_press = ""
		EventBus.p2talk_key.emit(p2talk_word, _p2talk_text.text)
		p2talk_word = ""
		_p2talk_text.text = ""
		_can_submit = false


## Changes the Player's footstep sound to a specific index, check [member Player.TERRAIN_TYPES] for available footstep sounds.
func set_footstep_sound(sound_id: int = 0) -> void:
	current_footstep = sound_id


## Updates the Player's spritesheet.
func update_sheet() -> void:
	if Global.custom_sheet != null:
		load_sheet(Global.custom_sheet)
	else:
		change_sheet(current_sheet)


## Changes the player's spritesheet.
func change_sheet(path: String) -> void:
	_sprite.texture = load(path)
	_sprite.hframes = _sprite.texture.get_width() / 64
	_sprite.vframes = _sprite.texture.get_height() / 64
	_sprite_material.set_shader_parameter("albedoTex", _sprite.texture)


## Loads the player's spritesheet.
func load_sheet(sheet: ImageTexture) -> void:
	_sprite.texture = sheet
	_sprite.hframes = 5
	_sprite.vframes = 5
	_sprite_material.set_shader_parameter("albedoTex", _sprite.texture)


## Types something into P2 to Talk.
func _type_p2talk_key(word: String, buttons: String) -> void:
	p2talk_word = word
	_p2talk_text.text = buttons
	
