@icon("res://icon/treadmill.png")
extends Marker3D
class_name Treadmill

signal add_number(backwards: bool)

var entity_array: Array[Entity]
var backwards: bool = false

@export var treadmill_min: int = 0
@export var treadmill_max: int = 0

@onready var treadmill_top: AnimatedSprite3D = $TreadmillTop
@onready var treadmill_sound: AudioStreamPlayer3D = $TreadmillSound


func _ready() -> void:
	treadmill_top.animation_finished.connect(_add_number)


func _physics_process(_delta: float) -> void:
	for entity in entity_array:
		if entity is Player:
			if !treadmill_top.is_playing():
				if entity.target_velocity.y > entity._ANIMATION_THRESHOLD:
					treadmill_top.play(&"default")
				
				elif entity.target_velocity.y < -entity._ANIMATION_THRESHOLD:
					treadmill_top.play_backwards(&"default")

			if abs(entity.target_velocity.y) > entity._ANIMATION_THRESHOLD:
				if !treadmill_sound.playing:
					treadmill_sound.play()
			else:
				treadmill_sound.stop()


func _on_treadmill_entered_front(body) -> void:
	if body is Entity and body.direction == 0:
		_place_player_on_treadmill(body)


func _on_treadmill_entered_rear(body):
	if body is Entity and body.direction == 3:
		_place_player_on_treadmill(body)


func _on_treadmill_entered(body):
	if body is Entity:
		entity_array.push_back(body)
		body.player_stats.entity_y = 0.125


func _on_treadmill_exited(body):
	if body is Entity:
		treadmill_sound.stop()
		body.player_stats.entity_y = 0.0
		body._treadmill = false
		entity_array.erase(body)


func _place_player_on_treadmill(body: Entity) -> void:
	body._treadmill = true
	body.global_position.z = global_position.z


func _add_number() -> void:
	for entity in entity_array:
		if entity is Player:
			if entity.target_velocity.y > entity._ANIMATION_THRESHOLD:
				backwards = false
			
			elif entity.target_velocity.y < -entity._ANIMATION_THRESHOLD:
				backwards = true
	
			if snapped(entity.target_velocity.y, 0.1) != 0.0:
				add_number.emit(backwards)
