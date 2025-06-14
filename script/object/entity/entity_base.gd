@icon("res://icon/entity.png")
## Base object for all "player", "concurrent player" or "ghost" objects. Inherited by [Player] and [PlaybackPlayer] classes.
class_name Entity
extends CharacterBody3D

## The acceleration value of the player.
const _ACCELERATION: int = 8
## The speed of the player's animation.
const _ANIMATION_SPEED: int = 8
## Minimum speed before the player starts animating
const _ANIMATION_THRESHOLD: float = 1.5

#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# PUBLIC VARIABLES
## Current control mode of the player, [code]0[/code] is the default control mode used in most of the game, allowing the player to move in 4 directions. [code]1[/code] is the control mode used at the school.
var control_mode: int = 0
## Minimum height the player should be placed at.
var entity_min: float = 0.0
## Word currently being typed by the player using P2 TO TALK.
var p2talk_word: String = ""

# MOVEMENT VARIABLES
## This variable detects whether the player is currently walking or not.
var is_walking: bool = false
## Velocity the player is aiming at before it is actually applied to the [member CharacterBody3D]'s [member CharacterBody3D.velocity] value.
var target_velocity: Vector2 = Vector2.ZERO
## Player horizontal axis input.
var _v: float = 0.0
## Player vertical axis input.
var _h: float = 0.0
## Player angle, used exclusively when [member Entity.control_mode] is 1, when the player is at the school.
var _angle: float = 0.0
## Player movement speed.
var _movement_speed: float = 0.0
## Toggles whether the player is inside a [Treadmill] object.
var _treadmill: bool = false
##  Toggles whether the player is in Odd Care
var odd_care: bool = false
##  Toggles whether the player is pushing a bucket.
var pushing_bucket: bool = false:
	set(value):
		pushing_bucket = value

		if SaveManager.get_data().player_data.character_id > 2 && Global.global_data.gen > 6 && Global.global_data.gen < 9:
			if !value:
				if _movement_speed != 6.0:
					_movement_speed = 6.0
			else:
				if _movement_speed != 5.0:
					_movement_speed = 5.0
		else:
			if !value:
				if _movement_speed != 5.0:
					_movement_speed = 5.0
			else:
				if _movement_speed != 4.0:
					_movement_speed = 4.0

#ANIMATION PROPERTIES
##  Value of the current direction the player and the player's animation is facing.
var direction: int = 0
## Current frame of the player's animation.
var _current_frame: float = 0.0
## [Sprite3D] object for the player's sprite.
var _sprite: Sprite3D
## [ShaderMaterial] object applied to the player's sprite.
var _sprite_material: ShaderMaterial

#P2TALK VARIABLES
## Whether the player is allowed to submit a word in P2 to Talk mode.
var _can_submit: bool = true
## Last button pressed in P2 to Talk mode.
var _last_press: String = "":
	set(value):
		_last_press = value
		_p2talk_button_sound.play()
		EventBus.p2talk_key.emit(p2talk_word, _p2talk_text.text)
## The origin point for P2 to Talk's [Label3D] objects.
var _p2talk_origin: Marker3D
## The [Label3D] for the buttons displayed on top of the player.
var _p2talk_text: Label3D
## The [AudioStreamPlayer] object that plays the button sound effect whenever a button is pressed in P2 to Talk mode.
var _p2talk_button_sound: AudioStreamPlayer3D
