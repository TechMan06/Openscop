extends Marker3D
class_name CameraMarker

@export_enum("Copy", "Follow", "POV", "Lerp") var camera_mode: int = 0

var focus_node: Node3D
var marker_rotation: float
var camera_rotation: float
var camera_distance: Vector2
var limits: Array = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var distance_limit: Vector3
var can_move: Array = [true, true, true]
var camera_speed: float


func _ready() -> void:
	if focus_node != null:
		global_position = focus_node.global_position
	
	EventBus.camera_spawned.emit(self)
	EventBus.camera_zone_spawned.connect(_on_camera_zone_spawned)

func _anchor_camera() -> void:
	get_child(0).position = Vector3(0.0, camera_distance.y, camera_distance.x)
	get_child(0).rotation.x = deg_to_rad(camera_rotation)
	rotation.y = deg_to_rad(marker_rotation)


func _process(delta) -> void:
	if focus_node != null:
		match camera_mode:
			0:
				_anchor_camera()
				
				if focus_node != null:
					global_position = focus_node.global_position
			
			1:
				_anchor_camera()
				
				
				if focus_node != null:
					if focus_node is CharacterBody3D:
						if (abs(position.x - focus_node.position.x) > distance_limit.x) && can_move[0]:
							position.x -= (
												(position.x - focus_node.position.x) / 
												abs(position.x - focus_node.position.x)
											) * delta * abs(focus_node.velocity.x)
						
						if (abs(position.z - focus_node.position.z) > distance_limit.z) && can_move[2]:
							position.z -= (
												(position.z - focus_node.position.z) / 
												abs(position.z - focus_node.position.z)
											) * delta * abs(focus_node.velocity.z)
						
						if (abs(position.y - focus_node.position.y) > distance_limit.y) && can_move[1]:
							position.y -= (
												(position.y - focus_node.position.y) / 
												abs(position.y - focus_node.position.y)
											) * delta * abs(focus_node.velocity.y)
					else:
						global_position = focus_node.global_position
					
					if limits[0].x != 0.0 || limits[0].y != 0.0:
						global_position.x = clamp(global_position.x, limits[0].x, limits[0].y)
					
					if limits[2].x != 0.0 || limits[2].y != 0.0:
						global_position.z = clamp(global_position.z, limits[2].x, limits[2].y)
					
					if limits[1].x != 0.0 || limits[1].y != 0.0:
						global_position.y = clamp(global_position.y, limits[1].x, limits[1].y)
			
			2:
				get_child(0).position = Vector3.ZERO
				get_child(0).rotation.x = 0.0
				
				if focus_node != null:
					global_rotation.y = focus_node.global_rotation.y + deg_to_rad(180.0)
					
					if focus_node is Entity:
						global_position = Vector3(
													focus_node.global_position.x, 
													focus_node.player_stats.entity_y + 1.0, 
													focus_node.global_position.z
												)
					else:
						global_position = focus_node.global_position
			
			3:
				_anchor_camera()
				
				if focus_node != null:
					global_position.z = lerp(
												global_position.z, 
												focus_node.global_position, 
												camera_speed * delta
											)


func set_focus(node: Node3D) -> void:
	focus_node = node


func set_mode(mode_id: int = 1) -> void:
	camera_mode = mode_id


func get_mode() -> int:
	return camera_mode


func rotate_marker(rotation_y: float = 0.0) -> void:
	global_rotation.y = rotation_y


func setup_camera(distance: Vector2, rotation_x: float) -> void:
	camera_distance = distance
	camera_rotation = rotation_x
	_anchor_camera()


func set_distance(limit: Vector3) -> void:
	distance_limit = limit


func set_limit(axis: int, limit: Vector2) -> void:
	limits[axis] = limit


func set_movement(axis: int, value: bool) -> void:
	can_move[axis] = value


func set_speed(value: float) -> void:
	camera_speed = value


func _on_camera_zone_spawned(camera_zone: CameraZone) -> void:
	camera_zone.camera_marker = self
