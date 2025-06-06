@tool
extends Area3D
class_name CameraZone

@export_category("General Properties")
@export var target_pos_start: Vector3 = Vector3.ZERO
@export var anim_speed_start: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var target_pos_end: Vector3 = Vector3.ZERO
@export var anim_speed_end: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var reset_camera_on_end: bool = false
@export var undo_on_reentrance: bool = false
@export_category("Parallel Animations")
@export var move_parallel_start: bool = false
@export var move_parallel_end: bool = false
@export_category("Movement Permissions")
@export var move_x: bool = true
@export var move_y: bool = true
@export var move_z: bool = true

var triggered: bool = false
var enabled: bool = true
var _original_pos: Vector3
var _animation_flags = [false, false, false]
var camera_marker: CameraMarker

@onready var camera_focus: Marker3D = $CameraFocus


func _ready() -> void:
	if !Engine.is_editor_hint():
		
		await get_tree().physics_frame
		
		EventBus.camera_zone_spawned.emit(self)
		
		visible = GameManager.debug_settings.debug


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$CamTarget1.global_position = target_pos_start
		$CamTarget2.global_position = target_pos_end


func get_anim_speed(target_pos: Vector3) -> float:
	var percentage: float = (
								100.0 - 
								(100 / camera_focus.global_position.distance_to(target_pos))
							) * 0.01
	return percentage


func _on_body_entered(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		if body is Player && camera_marker.camera_mode != 0 and enabled:
			_original_pos = camera_marker.global_position
			camera_focus.global_position = _original_pos
			camera_marker.camera_mode = camera_marker.CameraModes.COPY
			camera_marker.set_focus(camera_focus)
			_animation_flags = [false, false, false]
			
			if !move_parallel_start:
				if _original_pos.x != target_pos_start.x && move_x:
					var _x_animation: Tween = create_tween()
					
					_x_animation.tween_property(
													camera_focus, 
													"global_position:x", 
													target_pos_start.x,
													anim_speed_start.x * get_anim_speed(target_pos_start)
												).set_trans(Tween.TRANS_SINE)
					
					
					await _x_animation.finished
					
					_animation_flags[0] = true
				else:
					_animation_flags[0] = true
				
				
				if _original_pos.y != target_pos_start.y && move_y:
					var _y_animation: Tween = create_tween()
					
					_y_animation.tween_property(
													camera_focus, 
													"global_position:y", 
													target_pos_start.y, 
													anim_speed_start.y * get_anim_speed(target_pos_start)
												).set_trans(Tween.TRANS_SINE)
					
					await _y_animation.finished
				
					_animation_flags[1] = true
				else:
					_animation_flags[1] = true
				
				if _original_pos.z != target_pos_start.z && move_z:
					var _z_animation: Tween = create_tween()

					_z_animation.tween_property(
													camera_focus, 
													"global_position:z", 
													target_pos_start.z, 
													anim_speed_start.z * get_anim_speed(target_pos_start)
												).set_trans(Tween.TRANS_SINE)
			
					await _z_animation.finished
					
					_animation_flags[2] = true
				else:
					_animation_flags[2] = true
				
				var times_array: Array[float] = [
													anim_speed_start.x * get_anim_speed(target_pos_start),
													anim_speed_start.y * get_anim_speed(target_pos_start),
													anim_speed_start.z * get_anim_speed(target_pos_start)
												]
				
				if reset_camera_on_end:
					await get_tree().create_timer(times_array.max()).timeout
				
					reset_camera(body)
			
			else:
				var _move_parallel: Tween = create_tween()
				
				_move_parallel.tween_property(
												camera_focus, 
												"global_position", 
												target_pos_start,
												anim_speed_start.x * get_anim_speed(target_pos_start)
											).set_trans(Tween.TRANS_SINE)
				
				await _move_parallel.finished
				
				_animation_flags = [true, true, true]
				
				if reset_camera_on_end:
					reset_camera(body)


func _on_body_exited(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		if body is Player and not get_parent() is ZoneSwitcher:
			
			while _animation_flags != [true, true, true]:
				await get_tree().create_timer(1.0, false).timeout
			
			if !move_parallel_end:
				if _original_pos.x != target_pos_start.x:
					var _x_animation: Tween = create_tween()
					
					_x_animation.tween_property(
													camera_focus, 
													"global_position:x", 
													target_pos_end.x, 
													anim_speed_end.x * get_anim_speed(target_pos_end)
												).set_trans(Tween.TRANS_SINE)
					
					if !move_parallel_start:
						await _x_animation.finished
				
				if _original_pos.y != target_pos_start.y:
					var _y_animation: Tween = create_tween()
					
					_y_animation.tween_property(
													camera_focus, 
													"global_position:y", 
													target_pos_end.y, 
													anim_speed_end.y * get_anim_speed(target_pos_end)
												).set_trans(Tween.TRANS_SINE)
					
					if !move_parallel_start:
						await _y_animation.finished
				
				if _original_pos.z != target_pos_start.z:
					var _z_animation: Tween = create_tween()

					_z_animation.tween_property(
													camera_focus, 
													"global_position:z", 
													target_pos_end.z, 
													anim_speed_end.z * get_anim_speed(target_pos_end)
												).set_trans(Tween.TRANS_SINE)
					
					await _z_animation.finished
					
					reset_camera(body)
			else:
				var _animation: Tween = create_tween()
				
				_animation.tween_property(
													camera_focus, 
													"global_position", 
													target_pos_end,
													anim_speed_end.x * get_anim_speed(target_pos_end)
												).set_trans(Tween.TRANS_SINE)
				
				await _animation.finished

				reset_camera(body)


func reset_camera(body: Node3D) -> void:
	camera_marker.set_focus(body)
	camera_marker.camera_mode = camera_marker.CameraModes.FOLLOW
