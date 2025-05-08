extends Node
class_name ZoneSwitcher

var player: Player
var player_pos: Vector3
var child_0_pos: Vector3
var child_1_pos: Vector3

@export_enum("X:0", "Y:1", "Z:2") var compare_pos: int = 0
@export var detection_radius: float = 10.0

func _ready():
	var switcher_area: Area3D = Area3D.new()
	
	add_child(switcher_area)
	
	child_0_pos = get_child(0).global_position
	child_1_pos = get_child(1).global_position
	
	switcher_area.global_position = vector3_average(child_0_pos, child_1_pos)
	
	var switcher_collision: CollisionShape3D = CollisionShape3D.new()
	
	switcher_area.add_child(switcher_collision)
	
	var switcher_shape: SphereShape3D = SphereShape3D.new()
	
	switcher_shape.radius = detection_radius
	
	switcher_collision.set_shape(switcher_shape)
	switcher_area.body_entered.connect(_on_zone_entered)
	
	if get_child_count() > 3:
		printerr("You can only have 2 camera zones here, deleting object!")
		queue_free()
	else:
		if get_child_count() < 1:
			printerr("You need to have 2 camera zones here, deleting object!")
			queue_free()
		else:
			if not get_child(0) is CameraZone or not get_child(1) is CameraZone:
				printerr("One of the children isn't a CameraZone, deleting object!")
				queue_free()


func _process(_delta: float) -> void:
	if player != null:
		player_pos = player.global_position
	
	match compare_pos:
		0:
			if player != null:
				get_child(0).enabled = player_pos.x < average(child_0_pos.x, child_1_pos.x)
		1:
			if player != null:
				get_child(0).enabled = player_pos.y < average(child_0_pos.y, child_1_pos.y)
		2:
			if player != null:
				get_child(0).enabled = player_pos.z < average(child_0_pos.z, child_1_pos.z)
	
	get_child(1).enabled = !get_child(0).enabled


func _on_zone_entered(body: Node3D) -> void:
	if body is Player:
		player = body


func vector3_average(x: Vector3, y: Vector3) -> Vector3:
	return Vector3(average(x.x, y.x), average(x.y, y.y), average(x.z, y.z))


func average(x: float, y: float) -> float:
	return (x + y) / 2.0
