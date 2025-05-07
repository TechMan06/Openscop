extends Node
class_name ZoneSwitcher

@export_enum("X:0", "Y:1", "Z:2") var compare_pos: int = 0

var player: Player

func _ready():
	if get_child_count() > 2:
		printerr("You can only have 2 camera zones here, deleting object!")
		queue_free()
	else:
		if get_child_count() < 2:
			printerr("You need to have 2 camera zones here, deleting object!")
			queue_free()
		else:
			if not get_child(0) is CameraZone or not get_child(1) is CameraZone:
				printerr("One of the children isn't a CameraZone, deleting object!")
				queue_free()
			else:
				get_child(0).enabled = true
				get_child(1).enabled = false
				get_child(0).body_entered.connect(_on_zone_entered)


func _process(_delta: float) -> void:
	match compare_pos:
		0:
			if player != null:
				get_child(0).enabled = player.global_position.x < average(
																				get_child(0).global_position.x, 
																				get_child(1).global_position.x
																			)
	get_child(1).enabled = !get_child(0).enabled


func average(x: float, y: float) -> float:
	return (x + y) / 2.0


func _on_zone_entered(body: Player) -> void:
	player = body
