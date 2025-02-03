extends CharacterBody3D
class_name Bucket

const ACCELERATION: int = 8
const BUCKET_HITBOX: float = 1.1

var player: Player
var direction_vector: Vector3
var collider_iterator

@onready var bucket_sound = %BucketSound
@onready var bucket_wall_collision = %BucketWallCollision



func _ready() -> void:
	await self.tree_entered
	SaveManager.get_data().has_bucket = false


func _physics_process(delta: float) -> void:
	if player != null:
		if is_near_bucket():
			if (
					self.global_position.x - player.global_position.x <= BUCKET_HITBOX and
					self.global_position.x > player.global_position.x and
					player.velocity.x > 0.0
				):
				Console.console_log("[color=yellow]BUCKET MOVING X+[/color]")
				move("x", delta)
			elif (
					player.global_position.x - self.global_position.x <= BUCKET_HITBOX and
					self.global_position.x < player.global_position.x and
					player.velocity.x < 0.0
				):
				Console.console_log("[color=yellow]BUCKET MOVING X-[/color]")
				move("x", delta)
			elif (
					self.global_position.z - player.global_position.z <= BUCKET_HITBOX and
					self.global_position.z > player.global_position.z and
					player.velocity.z > 0.0
				):
				Console.console_log("[color=yellow]BUCKET MOVING Z+[/color]")
				move("z", delta)
			elif (
					player.global_position.z - self.global_position.z <= BUCKET_HITBOX and
					self.global_position.z < player.global_position.z and
					player.velocity.z < 0.0
				):
				Console.console_log("[color=yellow]BUCKET MOVING Z-[/color]")
				move("z", delta)
			else:
				stop_bucket(delta)
		
		else:
			stop_bucket(delta)
		
		if player.global_position.z < self.global_position.z:
			bucket_wall_collision.disabled = false
		else:
			bucket_wall_collision.disabled = true
	
	move_and_slide()
	
	if velocity.length() > 1.5:
		if !bucket_sound.playing:
			bucket_sound.play()
	else:
		bucket_sound.stop()


func stop_bucket(delta: float) -> void:
	self.velocity.x = lerp(self.velocity.x, 0.0, ACCELERATION * delta)
	self.velocity.z = lerp(self.velocity.z, 0.0, ACCELERATION * delta)
	bucket_sound.stop()


func move(axis: String, delta: float):
	match axis:
		"x":
			self.velocity.z = lerp(self.velocity.z, 0.0, ACCELERATION * delta)
			self.velocity.x = player.velocity.x * direction_vector.x
		"z":
			self.velocity.x = lerp(self.velocity.x, 0.0, ACCELERATION * delta)
			self.velocity.z = player.velocity.z * direction_vector.z


func is_near_bucket() -> bool:
	if (
			self.global_position.x - player.global_position.x <= (BUCKET_HITBOX) and
			player.global_position.x - self.global_position.x <= (BUCKET_HITBOX )
		):
			return true
	if (
			self.global_position.z - player.global_position.z <= (BUCKET_HITBOX) and
			player.global_position.z - self.global_position.z <= (BUCKET_HITBOX)
	):
			return true

	return false


func _on_bucket_area_body_entered(body):
	if body is Player:
		player = body


func _on_front_area_entered(body):
	if body is Player:
		direction_vector.z = 1.0


func _on_front_area_exited(body):
	if body is Player:
		direction_vector.z = 0.0


func _on_side_area_entered(body):
	if body is Player:
		direction_vector.x = 1.0


func _on_side_area_exited(body):
	if body is Player:
		direction_vector.x = 0.0
