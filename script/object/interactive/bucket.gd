extends RigidBody3D

var touched_body: Entity
var touching: bool = false

func _on_body_entered(body):
	if body is Player:
		touching = true
		touched_body = body
		
		if body.direction == 0 || body.direction == 3:
			print("WORK!!!!!")
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)
		else:
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, true)
			set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)


func _on_body_exited(body):
	touching = false
	touched_body = null


func _integrate_forces(state):
	if touched_body != null:
		if touched_body.move_and_slide(): # true if collided
			for i in touched_body.get_slide_collision_count():
				var col = touched_body.get_slide_collision(i)
				if col.get_collider() is RigidBody2D:
					col.get_collider().apply_force(col.get_normal() * -touched_body.velocity)
