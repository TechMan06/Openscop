extends CharacterBody3D
class_name Bucket

signal caught

const ACCELERATION: int = 8
const BUCKET_HITBOX: float = 1.1
const JUMP_SIZE: float = 0.1
const JUMP_SPEED: float = 0.125
const CAUGHT_SCENE: PackedScene = preload("res://scene/management/caught.tscn")


var player: Player
var direction_vector: Vector3

@export var has_pet: String = ""
@export var disable_collection: bool = false

@onready var meshes: Marker3D = %Meshes
@onready var bucket_sound: AudioStreamPlayer3D = %BucketSound
@onready var bucket_wall_collision: CollisionShape3D = %BucketWallCollision
@onready var bucket_collision: CollisionShape3D = %BucketCollision
@onready var bucket_collection_area: Area3D = %BucketCollectionArea
@onready var cry_sound: AudioStreamPlayer3D = %CrySound


func _ready() -> void:
	await self.tree_entered
	SaveManager.get_data().has_bucket = false


func _physics_process(delta: float) -> void:
	if has_pet == "":
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
						player.global_position.x - self.global_position.x <= (BUCKET_HITBOX) and
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
						player.global_position.z - self.global_position.z <= (BUCKET_HITBOX - 0.1) and
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
			
			if player.global_position.distance_to(self.global_position) > 1.5:
				SaveManager.get_data().has_bucket = false
		
		move_and_slide()
		
		if velocity.length() > 1.5:
			if !bucket_sound.playing:
				bucket_sound.play()
		else:
			bucket_sound.stop()
	else:
		bucket_collision.disabled = true
		bucket_wall_collision.disabled = true


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
			player.global_position.x - self.global_position.x <= (BUCKET_HITBOX)
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


func jump() -> void:
	var jump_tween: Tween = create_tween()
	
	jump_tween.tween_property(
								meshes, 
								"position:y", 
								JUMP_SIZE, 
								JUMP_SPEED
							)
	jump_tween.tween_property(
								meshes, 
								"position:y", 
								0.0, 
								JUMP_SPEED
							)
	jump_tween.tween_property(
								meshes, 
								"position:y", 
								JUMP_SIZE, 
								JUMP_SPEED
							)
	jump_tween.tween_property(
								meshes, 
								"position:y", 
								0.0, 
								JUMP_SPEED
							)


func bump() -> void:
	$BumpSound.play()
	$BucketAnim.play(&"bucket_hit")


func _on_bucket_collected(body: Node3D) -> void:
	if has_pet != "":
		if body is Entity && !disable_collection:
			caught.emit()
			
			if cry_sound.stream != null:
				cry_sound.play()
			
			if body is Player:
				$CaughtTimer.start()
				SaveManager._data.pet.append(has_pet)
			
			create_tween().tween_property(meshes, "scale", Vector3.ZERO, 0.625)
			
			disable_collection = true


func _on_caught_timer_timeout():
	var _caught_instance: Marker2D = CAUGHT_SCENE.instantiate()
	add_child(_caught_instance)
