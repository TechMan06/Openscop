@icon("res://icon/treadmill.png")
extends Marker3D
class_name Treadmill

## Class used on Pen's treadmill, this is the physical treadmill object the player walks on.

## This signal is sent to an object of the [TreadmillCounter] class to change the value of the treadmill counter.
signal add_number(backwards: bool)


## Objects of the [Entity] class that are currently on the treadmill.
var entity_array: Array[Entity]
## Direction the treadmill is currently moving to.
var backwards: bool = false


## [AnimatedSprite3D] object used on top of the treadmill.
@onready var treadmill_top: AnimatedSprite3D = $TreadmillTop
## [AudioStreamPlayer3D] object responsible for the sound effects played by the treadmill.
@onready var treadmill_sound: AudioStreamPlayer3D = $TreadmillSound


func _ready() -> void:
	treadmill_top.animation_finished.connect(_add_number)


func _physics_process(_delta: float) -> void:
	for entity in entity_array:
		if entity is Player:
			if (
					entity.global_position.x > self.global_position.x - 0.5 and
					entity.global_position.x < self.global_position.x + 0.5
				):
				
				if entity.direction == 0:
					if entity.global_position.z >= self.global_position.z:
						if !entity._treadmill:
							_place_player_on_treadmill(entity)
					else:
						if entity._treadmill:
							entity._treadmill = false
				elif entity.direction == 3:
					if entity.global_position.z <= self.global_position.z:
						if !entity._treadmill:
							_place_player_on_treadmill(entity)
					else:
						if entity._treadmill:
							entity._treadmill = false
				
				entity.player_stats.entity_y = 0.7
					
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


func _on_treadmill_entered(body):
	if body is Entity:
		entity_array.push_back(body)
		
		if body.direction != 0 and body.direction != 3:
			_place_player_on_treadmill(body)


func _on_treadmill_exited(body):
	if body is Entity:
		treadmill_sound.stop()
		body._treadmill = false
		entity_array.erase(body)


func _place_player_on_treadmill(body: Entity) -> void:
	if body._treadmill:
		return
	
	body._treadmill = true
	body.global_position.z = self.global_position.z


func _add_number() -> void:
	for entity in entity_array:
		if entity is Player:
			if entity.target_velocity.y > entity._ANIMATION_THRESHOLD * 2.0:
				backwards = false
			
			elif entity.target_velocity.y < -entity._ANIMATION_THRESHOLD * 2.0:
				backwards = true
	
			if snapped(entity.target_velocity.y, 0.1) != 0.0:
				add_number.emit(backwards)
