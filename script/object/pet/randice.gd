extends Marker3D
class_name Randice

const WAIT_TIME: float = 1.0

var is_ready: bool = false
var bucket: Bucket

@export var pet_name: String = "randice"
@export var positions: Array[Vector3]
@export var hitbox_size: float = 3.0
#@export var cry_sound: AudioStream = load("randice_cry")

@onready var sprite_anim: AnimationPlayer = $SpriteAnimation
@onready var randice_shape = $RandiceArea/RandiceShape

var possible_positions: Array[Vector3]


func _ready() -> void:
	randice_shape.get_shape().size = Vector3(hitbox_size, 1., hitbox_size)
	sprite_anim.play(&"idle")
	
	if positions.size() == 0:
		positions[0] = global_position
	
	global_position = positions[0]
	
	possible_positions = positions.duplicate(true)
	
	await get_tree().create_timer(0.05).timeout
	is_ready = true
	
	if SaveManager.get_data().pet.find(pet_name) != -1:
		queue_free()


func _on_near_randice(body: Node3D):
	if body is Player and is_ready:
		if sprite_anim.is_playing():
			while sprite_anim.current_animation == "move":
				await get_tree().physics_frame
			
			sprite_anim.play_backwards(&"move")
			
			await sprite_anim.animation_finished
			
			visible = false
			
			await get_tree().create_timer(WAIT_TIME).timeout
			
			visible = true
			update_positions()
			
			sprite_anim.play(&"move")
			
			await sprite_anim.animation_finished
			
			sprite_anim.play(&"idle")
			
	if body is Bucket:
		bucket = body


func update_positions() -> void:
	
	possible_positions = positions.duplicate(true)
	
	var og_size: int = possible_positions.size()
	
	while possible_positions.size() != og_size - 1:
		possible_positions.erase(global_position)
	
	global_position = possible_positions.pick_random()
	
	if bucket != null:
		if (
			bucket.global_position.z < global_position.z + 0.5 and
			bucket.global_position.z > global_position.z - 0.5
			):
			bucket.bump()
			
			if bucket.global_position.z > global_position.z:
				global_position.z += 1
			else:
				global_position.z -= 1
		
