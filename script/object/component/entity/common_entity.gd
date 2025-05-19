extends Node
class_name EntityComponent

@export var entity: Entity
@export var entity_sprite: Sprite3D
@export var treadmill_timer: Timer


func _physics_process(delta: float) -> void:
	if Vector3(entity.target_velocity.x, 0,entity.target_velocity.y).length() > entity._ANIMATION_THRESHOLD:
		entity.is_walking = true
	else:
		entity.is_walking = false

	if entity._v > 0:
		entity.direction = 0
	elif entity._v < 0:
		entity.direction = 3

	if entity._h < 0:
		entity.direction = 2
	elif entity._h > 0:
		entity.direction = 1
	
	if entity.player_stats != null:
		entity_sprite.get_material_override().set_shader_parameter(
												"modulate_color", 
												Color(
														entity.player_stats.brightness, 
														entity.player_stats.brightness, 
														entity.player_stats.brightness
													)
												)
		
		if entity.player_stats.entity_y > 0.0:
			entity.player_stats.entity_y -= clamp(entity.player_stats.entity_y, 0.0, 0.5)
		
		entity_sprite.position.y = entity.entity_min + entity.player_stats.entity_y
	
	if entity.control_mode == 0:
		var normalized_h_v: Vector2 = Vector2(entity._h, entity._v).normalized()
		
		if !entity._treadmill:
			entity.target_velocity.y = lerp(
								entity.target_velocity.y, 
								normalized_h_v.y * entity._movement_speed, 
								delta * entity._ACCELERATION
							)
			
			entity.velocity.z = entity.target_velocity.y
		else:
			if entity.odd_care:
				if treadmill_timer.time_left == 0.0:
					if Input.is_action_pressed("pressed_action"):
						entity.target_velocity.y = -entity._movement_speed
						entity.direction = 3
						treadmill_timer.start()
				
					elif Input.is_action_pressed("pressed_triangle"):
						entity.target_velocity.y = entity._movement_speed
						entity.direction = 0
						treadmill_timer.start()
					else:
						if (
								Input.is_action_pressed("pressed_action") or 
								Input.is_action_pressed("pressed_triangle")
							): 
							treadmill_timer.start()
						
						entity.target_velocity.y = 0.0
			else:
				entity.target_velocity.y = lerp(
								entity.target_velocity.y, 
								normalized_h_v.y * entity._movement_speed, 
								delta * entity._ACCELERATION
							)
			
			entity.velocity.z = 0.0
		
		if entity.player_stats != null:
			entity.target_velocity.x = lerp(
										entity.target_velocity.x, 
										normalized_h_v.x * entity._movement_speed, 
										delta * entity._ACCELERATION
									)
			
			entity.velocity.x = entity.target_velocity.x
	
	if entity.control_mode == 1:
		var entity_speed: float = entity._v * entity._movement_speed * -1.0
		
		entity.rotation.y += entity._h * -1/ 25
		entity._angle = entity.rotation.y
		entity.velocity = Vector3(0, 0, entity_speed).rotated(Vector3.UP, entity._angle)
		
		if entity.velocity.length() > entity._ANIMATION_THRESHOLD:
			entity.is_walking = true
		else:
			entity.is_walking = false
	
	if entity.is_walking:
		#DETECTS IF PLAYER IS ON FLOOR OR Y0, DEFINES SURFACE TYPE AND SETS FOOTSTEP SOUND
		if entity_sprite.frame_coords.x != entity_sprite.hframes - 1 && entity_sprite.hframes % 2 > 0:
			entity._current_frame += entity._ANIMATION_SPEED * delta
		else:
			entity._current_frame == 0.0
		
		if entity._current_frame > entity_sprite.vframes:
			entity._current_frame = 1
	else:
		entity._current_frame = 0
	
	if Global.global_data.gen > 2:
		entity_sprite.frame_coords = Vector2(entity.direction, floor(entity._current_frame))
	
	entity.move_and_slide()
