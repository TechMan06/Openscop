extends Marker3D

@export var treadmill_min: int = 0
@export var treadmill_max: int = 0

@onready var treadmill_top = $TreadmillTop

var entity_array: Array[Entity]

func _physics_process(_delta: float) -> void:
	for entity in entity_array:
		if !treadmill_top.is_playing():
			if entity.target_velocity.y > entity._ANIMATION_THRESHOLD:
				treadmill_top.play(&"default")
			elif entity.target_velocity.y < -entity._ANIMATION_THRESHOLD:
				treadmill_top.play_backwards(&"default")


func _on_treadmill_entered_front(body) -> void:
	if body is Entity and body.direction == 0:
		_place_player_on_treadmill(body)


func _on_treadmill_entered_rear(body):
	if body is Entity and body.direction == 3:
		_place_player_on_treadmill(body)


func _on_treadmill_entered(body):
	if body is Entity:
		body.player_stats.entity_y = 0.125


func _on_treadmill_exited(body):
	if body is Entity:
		body.player_stats.entity_y = 0.0
		body._treadmill = false
		entity_array.erase(body)


func _place_player_on_treadmill(body: Entity) -> void:
	entity_array.push_back(body)
	body._treadmill = true
	body.target_velocity.y = 0.0
	body.global_position.z = global_position.z
