extends CharacterBody3D

const ACCELERATION: int = 9
const BUCKET_HITBOX: float = 1.2

var player: Player
var direction_vector: Vector3
var collider_iterator

@onready var bucket_sound = %BucketSound


func _physics_process(delta: float) -> void:
	if player != null:
		#if is_near_bucket():
		if (	
				player.global_position.x < self.global_position.x + BUCKET_HITBOX and
				player.velocity.x < 0.0 and 
				player.global_position.x > self.global_position.x or
				player.global_position.x > self.global_position.x - BUCKET_HITBOX and
				player.velocity.x > 0.0 and 
				player.global_position.x < self.global_position.x
			):
			self.velocity.x = player.velocity.x * direction_vector.x
		elif (
				player.global_position.z < self.global_position.z + BUCKET_HITBOX and
				player.velocity.z < 0.0 and 
				player.global_position.z > self.global_position.z or
				player.global_position.z > self.global_position.z - BUCKET_HITBOX and
				player.velocity.z > 0.0 and 
				player.global_position.z < self.global_position.z
			):
			self.velocity.z = player.velocity.z * direction_vector.z
		else:
			self.velocity.x = lerp(self.velocity.x, 0.0, ACCELERATION * delta)
			self.velocity.z = lerp(self.velocity.z, 0.0, ACCELERATION * delta)
			bucket_sound.stop()
	
	if velocity.length() > 1.5:
		if !bucket_sound.playing:
			bucket_sound.play()
	else:
		bucket_sound.stop()
	
	move_and_slide()


func is_near_bucket() -> bool:
	if (
			player.global_position.x < self.global_position.x + BUCKET_HITBOX and
			player.global_position.x > self.global_position.x - BUCKET_HITBOX
		):
			return true
	return false


func _on_bucket_area_body_entered(body):
	if body is Player:
		player = body


func _on_front_area_entered(body):
	if body is Player && direction_vector.x == 0.0:
		direction_vector.z = 1.0


func _on_front_area_exited(body):
	if body is Player:
		direction_vector.z = 0.0


func _on_side_area_entered(body):
	if body is Player && direction_vector.z == 0.0:
		direction_vector.x = 1.0


func _on_side_area_exited(body):
	if body is Player:
		direction_vector.x = 0.0
