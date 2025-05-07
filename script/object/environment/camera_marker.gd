extends Marker3D
class_name CameraMarker

@export var camera_mode: CameraModes = CameraModes.FOLLOW

enum CameraModes {
	COPY, 
	FOLLOW, 
	POV,
	LERP,
	PEN_PIANO,
	NO_CODE,
	STATIC_CAMERA,
	FREE
}

var shake_amount: float = 0.1
var shake_progress: float = 0.0
var quake_enabled: float = 0.0:
	set(value):
		quake_enabled = value
		
		if value < 0.25:
			shake_amount = 0.1
var shake_speed: float = 1.0

var focus_node: Node3D
var marker_rotation: float = 0.0
var camera_rotation: float = 0.0
var camera_distance: Vector2 = Vector2.ZERO
var limits: Array = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var distance_limit: Vector3 = Vector3.ZERO
var can_move: Array = [true, true, true]
var camera_speed: float = 0.0

@onready var shake_offset: Marker3D = %ShakeOffset


func _ready() -> void:
	if focus_node != null:
		global_position = focus_node.global_position
	
	EventBus.camera_spawned.emit(self)
	EventBus.camera_zone_spawned.connect(_on_camera_zone_spawned)
	EventBus.camera_placer_spawned.connect(_on_camera_placer_spawned)
	EventBus.camera_earthquake.connect(do_earthquake)
	EventBus.camera_shake_amount.connect(set_shake_amount)
	EventBus.camera_shake_speed.connect(set_shake_speed)
	Console.set_camera.connect(set_mode)


func _anchor_camera() -> void:
	get_child(0).get_child(0).position = Vector3(0.0, camera_distance.y, camera_distance.x)
	get_child(0).get_child(0).rotation.x = deg_to_rad(camera_rotation)
	rotation.y = deg_to_rad(marker_rotation)


func _process(delta: float) -> void:
	if quake_enabled:
		shake_progress += 100.0 * delta
		shake_offset.position.y = (sin(shake_progress * shake_speed) + cos(shake_progress * shake_speed)) * shake_amount * quake_enabled
	
	if focus_node != null:
		match camera_mode:
			CameraModes.COPY:
				_anchor_camera()
				
				if focus_node != null:
					global_position = focus_node.global_position
			
			CameraModes.FOLLOW:
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
			
			CameraModes.POV:
				get_child(0).get_child(0).position = Vector3.ZERO
				get_child(0).get_child(0).rotation.x = 0.0
				
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
			
			CameraModes.LERP:
				_anchor_camera()
				
				if focus_node != null:
					global_position.z = lerp(
												global_position.z, 
												focus_node.global_position, 
												camera_speed * delta
											)
			CameraModes.FREE:
				if Input.is_action_pressed("shift"):
					if Input.is_action_pressed("ui_up"):
						get_child(0).get_child(0).global_rotation.x -= 0.1
					
					if Input.is_action_pressed("ui_down"):
						get_child(0).get_child(0).global_rotation.x += 0.1
					
					if Input.is_action_pressed("ui_left"):
						get_child(0).get_child(0).global_rotation.y += 0.1
					
					if Input.is_action_pressed("ui_right"):
						get_child(0).get_child(0).global_rotation.y -= 0.1
				else:
					if Input.is_action_pressed("ui_up"):
						get_child(0).get_child(0).global_position.z -= 0.1
					
					if Input.is_action_pressed("ui_down"):
						get_child(0).get_child(0).global_position.z += 0.1
					
					if Input.is_action_pressed("ui_left"):
						get_child(0).get_child(0).global_position.x -= 0.1
					
					if Input.is_action_pressed("ui_right"):
						get_child(0).get_child(0).global_position.x += 0.1
					
					if Input.is_action_pressed("ui_page_up"):
						get_child(0).get_child(0).global_position.y += 0.1
					
					if Input.is_action_pressed("ui_page_down"):
						get_child(0).get_child(0).global_position.y -= 0.1


func set_top_level(value: bool) -> void:
	get_child(0).get_child(0).set_as_top_level(value)


func set_focus(node: Node3D) -> void:
	focus_node = node


func set_mode(mode: CameraModes) -> void:
	camera_mode = mode


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


func _on_camera_zone_spawned(zone: Node3D) -> void:
	zone.camera_marker = self


func _on_camera_placer_spawned(zone: Node3D) -> void:
	zone.camera_marker = self


func do_earthquake(enable: bool) -> void:
	if enable:
		create_tween().tween_property(self, "quake_enabled", 1.0, 0.25)
	else:
		create_tween().tween_property(self, "quake_enabled", 0.0, 0.25)


func set_shake_amount(value: float) -> void:
	shake_amount = value


func set_shake_speed(value: float) -> void:
	shake_speed = value


func get_camera() -> Camera3D:
	return get_child(0).get_child(0)
