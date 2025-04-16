extends Node3D
#GRASS SIZE
const TILE_SIZE: int = 29

var _camera_object: CameraMarker
var forbidden_positions: Array[Vector3] = []
	#Vector3(0.0, 0.0, 0.0)
#]

func _ready() -> void:
	EventBus.camera_spawned.connect(_on_camera_spawn)


#FOLLOWS CAMERA WHILE MAKING SNAPPED MOVEMENT, GIVING ILLUSION OF BEING INFINITE
func _process(_delta: float) -> void:
	if _camera_object != null:
		position = Vector3(
						round(_camera_object.position.x / TILE_SIZE) * TILE_SIZE,
						0,
						round(_camera_object.position.z / TILE_SIZE) * TILE_SIZE
					)
	
	for grass_chunk in self.get_children():
		if grass_chunk is NiftyMesh:
			if forbidden_positions.find(grass_chunk.global_position):
				if !grass_chunk.visible:
					grass_chunk.visible = true
			else:
				if grass_chunk.visible:
					grass_chunk.visible = false


func _on_camera_spawn(camera: CameraMarker) -> void:
	_camera_object = camera
