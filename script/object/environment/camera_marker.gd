extends Marker3D
class_name CameraMarker

@export var camera_mode: CameraModes = CameraModes.FOLLOW

## The CameraMarker Class, it's the camera used for the Player and the object the camera aims at, however it can be used on other objects.


## The camera modes available in Petscop
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

var shake_amount: float = 0.1 ## Amount of camera shake when [member CameraMarker.quake_enabled] is higher than [code]0.0[/code].
var shake_progress: float = 0.0 ## Amount of time the camera is in earthquake mode.
var shake_transition: float = 0.0
var quake_enabled: float = 0.0 ## Enables the camera earthquake.
var shake_speed: float = 1.0 ## Speed of the earthquake effect.
var focus_node: Node3D ## Node the camera should follow or focus at, set by the [Level] node.
var marker_rotation: float = 0.0 ## Rotation of the camera marker set by the [Level] node.
var camera_rotation: float = 0.0 ## Rotation of the camera itself set by the [Level] node.
var camera_distance: Vector2 = Vector2.ZERO ## The vertical and horizontal distance of the camera set by the [Level] node.
var limits: Array = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO] ## Camera movement limits set by the [Level] node.
var distance_limit: Vector3 = Vector3.ZERO ## Distance limit between the Camera Marker and the Player, set by the [Level] node.
var can_move: Array = [true, true, true] ## Set movement limits for the Camera Marker, set by the [Level] node.
var camera_speed: float = 0.0 ## The speed of the camera's movement, set by the CameraZone object.

@onready var shake_offset: Marker3D = %ShakeOffset


func _ready() -> void:
	if focus_node != null:
		global_position = focus_node.global_position
	
	EventBus.camera_spawned.emit(self)
	EventBus.camera_zone_spawned.connect(_on_camera_zone_spawned)
	EventBus.camera_earthquake.connect(do_earthquake)
	EventBus.camera_shake_amount.connect(set_shake_amount)
	EventBus.camera_shake_speed.connect(set_shake_speed)
	EventBus.camera_shake_transition_speed.connect(set_earthquake_transition_speed)
	EventBus.camera_shake_stop.connect(stop_earthquake_abruptly)
	Console.set_camera.connect(set_mode)


func _anchor_camera() -> void: ## Responsible for anchoring the camera object to the marker.
	get_child(0).get_child(0).position = Vector3(0.0, camera_distance.y, camera_distance.x)
	get_child(0).get_child(0).rotation.x = deg_to_rad(camera_rotation)
	rotation.y = deg_to_rad(marker_rotation)


func _process(delta: float) -> void:
	if quake_enabled:
		shake_progress += 100.0 * delta
		shake_offset.position.y = sin(shake_progress * shake_speed) * shake_amount * quake_enabled
	
	if focus_node != null:
		match camera_mode:
			CameraModes.COPY:
				_anchor_camera()
				
				if focus_node != null:
					global_position = focus_node.global_position
			
			CameraModes.FOLLOW:
				_anchor_camera()
				
				if focus_node != null:
					if can_move[0]:
						position.x = clamp(position.x, focus_node.position.x - distance_limit.x, focus_node.position.x + distance_limit.x)
					if can_move[1]:
						position.y = clamp(position.y, focus_node.position.y - distance_limit.y, focus_node.position.y + distance_limit.y)
					if can_move[2]:
						position.z = clamp(position.z, focus_node.position.z - distance_limit.z, focus_node.position.z + distance_limit.z)
					
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


func set_focus(node: Node3D) -> void: ## Sets the camera's focus node.
	focus_node = node


func set_mode(mode: CameraModes) -> void: ## Sets the camera mode using any of the modes available in [member CameraMarker.CameraModes]
	camera_mode = mode


func get_mode() -> int: ## Get the current camera mode, returns [member CameraMarker.CameraMode]
	return camera_mode


func rotate_marker(rotation_y: float = 0.0) -> void: ## Sets the Camera's [code]y[/code] rotation.
	global_rotation.y = rotation_y


func setup_camera(distance: Vector2, rotation_x: float) -> void: ## Sets up the camera height and rotation.
	camera_distance = distance
	camera_rotation = rotation_x
	_anchor_camera()


func set_distance(limit: Vector3) -> void: ## Sets up the camera's maximum distance to the player.
	distance_limit = limit


func set_limit(axis: int, limit: Vector2) -> void: ## Sets the camera movement limits of a specific axis. [code]0[/code] = X axis, [code]1[/code] = Y axis, [code]2[/code] = Z axis
	limits[axis] = limit


func set_movement(axis: int, value: bool) -> void: ## Toggles camera movement on a specific axis. [code]0[/code] = X axis, [code]1[/code] = Y axis, [code]2[/code] = Z axis
	can_move[axis] = value


func set_speed(value: float) -> void: ## Sets the camera speed when in [member CameraMarker.CameraModes] LERP mode.
	camera_speed = value


func _on_camera_zone_spawned(zone: Node3D) -> void: ## Provides self to the [CameraZone] object.
	zone.camera_marker = self


func do_earthquake(enable: bool) -> void: ## Enables the camera earthquake effect.
	if enable:
		if quake_enabled == 0.0:
			create_tween().tween_property(self, "quake_enabled", 1.0, shake_transition)
	else:
		create_tween().tween_property(self, "quake_enabled", 0.0, shake_transition)


func set_shake_amount(value: float) -> void: ## Sets the intensity of the camera earhquake effect.
	shake_amount = value


func set_shake_speed(value: float) -> void: ## Sets the speed of the camera earthquake effect.
	shake_speed = value


func set_earthquake_transition_speed(value: float) -> void: ## Sets the speed of the earthquake effect transition.
	shake_transition = value


func stop_earthquake_abruptly() -> void:
	quake_enabled = 0.0


func get_camera() -> Camera3D: ## Returns the camera [Camrea3D] node.
	return get_child(0).get_child(0)
