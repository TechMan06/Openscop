extends Marker3D

var player: Player
var bucket_array: Array[Bucket]
var roneth_og_pos: float
var end_point: Vector2
var roneth_min_y: float
var roneth_og_size: float
var enabled: bool = true
var roneth_scale: float

@export var pet_name: String = "roneth"
@export var front: bool = true
@export var horizontal_distance: float = -10.0
@export var vertical_distance: float = 5.0
@export var hitbox_size: float = 2.0
@export var weight: float = 0.25
@export var cry_sound: AudioStream


@onready var roneth_sprite = %RonethSprite
@onready var roneth_shape: CollisionShape3D = %RonethShape
@onready var roneth: Marker3D = %RonethObject
@onready var roneth_path: Path3D = $RonethPath
@onready var roneth_follow: PathFollow3D = $RonethPath/RonethFollow


func _ready() -> void:
	roneth_shape.get_shape().size = Vector3(
												abs(horizontal_distance) * 2., 
												1., 
												abs(horizontal_distance) * 2.
											)
	roneth_og_pos = roneth.global_position.z
	
	roneth_path.get_curve().add_point(Vector3(0.0, 0.0, horizontal_distance))
	roneth_path.get_curve().add_point(Vector3(0.0, vertical_distance, horizontal_distance))
	
	end_point = Vector2(
							self.global_position.x + roneth_path.get_curve().get_point_position(2).x, 
							self.global_position.z + roneth_path.get_curve().get_point_position(2).z
						)
	roneth_min_y = self.global_position.y + roneth_path.get_curve().get_point_position(1).y
	roneth_og_size = roneth_sprite.pixel_size


func _process(_delta: float) -> void:
	roneth_scale = (roneth.global_position.y - roneth_min_y) / vertical_distance
	
	if enabled:
		if player != null:
			if front:
				roneth_follow.progress_ratio = clamp(
														(roneth_og_pos - (player.global_position.z - hitbox_size)) * weight, 
														0., 
														1.
													)
			else:
				roneth_follow.progress_ratio = clamp(
														(roneth_og_pos + (player.global_position.z + hitbox_size)) * weight, 
														0., 
														1.
													)
	
		for bucket in bucket_array:
			if (
					Vector2(
								bucket.global_position.x, 
								bucket.global_position.z
							).distance_to(end_point) < 0.5
				):
				roneth_sprite.pixel_size = roneth_og_size * roneth_scale
				
				if roneth.global_position.y == roneth_min_y:
					bucket.has_pet = pet_name
					bucket.cry_sound.stream = cry_sound
					bucket.jump()
					enabled = false
	else:
		visible = false


func _on_near_roneth(body: Node3D) -> void:
	if body is Player:
		player = body
		
	if body is Bucket:
		bucket_array.append(body)
