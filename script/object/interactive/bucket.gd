extends RigidBody3D

var touched_body: Entity
var touching: bool = false

func _on_body_entered(body):
	if body is Player:
		touching = true
		touched_body = body
		
		if body.direction == 0 || body.direction == 3:
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, true)
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)
		else:
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)


func _on_body_exited(body):
	touching = false
	touched_body = null


func _physics_process(_delta):
	if touched_body != null:
		apply_central_impulse(touched_body.velocity)
