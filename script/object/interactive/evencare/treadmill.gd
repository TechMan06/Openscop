extends Area3D

@export var treadmill_min: int = 0
@export var treadmill_max: int = 0

@onready var treadmill_origin = $TreadmillOrigin

#func _physics_process(delta: float) -> void:
	

func _on_body_entered(body: Node3D) -> void:
	if body is Entity:
		body.player_stats.entity_y = 0.125
		body._treadmill = true
		body._treadmill_z = float(str(snapped(treadmill_origin.global_position.z, 0.01)).left(-1))


func _on_body_exited(body):
	if body is Entity:
		body.player_stats.entity_y = 0.0
		body._treadmill = false
