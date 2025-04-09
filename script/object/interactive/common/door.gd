@icon("res://icon/warp.png")
extends Marker3D
class_name Door

@export_enum("Open", "Closed", "Opening", "Closing") var state: String = "Open"
@export var wait_delay: float = 0.0
@export var affect_collision: bool = true

@onready var animation_player = $DoorMesh/DoorAnimations
@onready var collision_animations = $DoorBody/DoorCollision/CollisionAnimations
@onready var door_body = $DoorBody


func _ready() -> void:
	if state == "Open":
		set_opened()
		
	elif state == "Closed":
		set_closed()
		
	elif state == "Opening":
		if wait_delay > 0.0:
			await get_tree().create_timer(wait_delay).timeout
		
		open()
		
	elif state == "Closing":
		if wait_delay > 0.0:
			await get_tree().create_timer(wait_delay).timeout
		
		close()


func set_opened() -> void:
	animation_player.play(&"opened")
	door_body.position = Vector3(-1, 0.0, -1)


func set_closed() -> void:
	animation_player.play(&"closed")
	door_body.position = Vector3.ZERO


func open() -> void:
	if state != "Open" and state != "Opening":
		animation_player.play(&"open")
		state = "Open"
		if affect_collision:
			collision_animations.play(&"open")


func close() -> void:
	if state != "Closed" and state != "Closing":
		animation_player.play_backwards(&"open")
		state = "Closed"
		if affect_collision:
			collision_animations.play_backwards(&"open")
