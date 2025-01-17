@icon("res://icon/entity.png")
class_name Entity
extends CharacterBody3D

const _ACCELERATION: int = 8
const _ANIMATION_SPEED: int = 8
const _ANIMATION_THRESHOLD: float = 1.5

#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# PUBLIC VARIABLES
var control_mode: int = 0
var entity_min: float = 0.0
var p2talk_word: String = "":
	set(value):
		_p2talk_button_sound.play()
		p2talk_word = value
		EventBus.p2talk_key.emit(value, _p2talk_text.text)

# MOVEMENT VARIABLES
var is_walking: bool = false
var _v: float = 0.0
var _h: float = 0.0
var _angle: float = 0.0
var _movement_speed: float = 5.0
#ANIMATION PROPERTIES
var direction: int = 0
var _current_frame: float = 0.0
var _sprite: Sprite3D
var _sprite_material: ShaderMaterial
#P2TALK VARIABLES
var _can_submit: bool = true
var _last_press: String = ""
var _p2talk_origin: Marker3D
var _p2talk_text: Label3D
var _p2talk_button_sound: AudioStreamPlayer3D
