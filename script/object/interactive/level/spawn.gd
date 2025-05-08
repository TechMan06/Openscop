@tool
@icon("res://icon/spawn.png")
extends Marker3D
class_name SpawnClass

@export_file("*.tscn") var scene_path: String
@export var warp_id: int = 0
@export_range(0,4) var player_direction: int = 0
@export var place_camera: bool = false
@export var place_camera_at: Vector3

func _ready() -> void:
	add_to_group("spawn")
