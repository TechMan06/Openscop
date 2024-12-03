extends Node3D
#GRASS SIZE
const TILE_SIZE: int = 29

var _camera_object: CameraMarker


func _ready() -> void:
	EventBus.camera_spawned.connect(_on_camera_spawn)


#FOLLOWS CAMERA WHILE MAKING SNAPPED MOVEMENT, GIVING ILLUSION OF BEING INFINITE
func _process(_delta) -> void:
	if _camera_object != null:
		position = Vector3(
						round(_camera_object.position.x / TILE_SIZE) * TILE_SIZE,
						0,
						round(_camera_object.position.z / TILE_SIZE) * TILE_SIZE
					)


func _on_camera_spawn(camera: CameraMarker) -> void:
	_camera_object = camera
