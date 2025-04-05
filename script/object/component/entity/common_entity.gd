extends Node
class_name EntityComponent

@export var entity: Entity
@export var entity_sprite: Sprite3D


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

	if Global.global_data.gen > 2:
		entity_sprite.frame_coords = Vector2(entity.direction, floor(entity._current_frame))
	
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
	
	if entity.player_stats != null:
		entity_sprite.get_material_override().set_shader_parameter(
												"modulate_color", 
												Color(
														entity.player_stats.brightness, 
														entity.player_stats.brightness, 
														entity.player_stats.brightness
													)
												)
	
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
			if entity._v != 0.0 and entity.target_velocity.y == 0.0:
				entity.target_velocity.y = entity._v
				print("RESET VELOCITY")
			
			entity.target_velocity.y = lerp(
								entity.target_velocity.y, 
								0.0, 
								delta * entity._ACCELERATION
							)
			
			entity.velocity.z = 0.0
		
		if entity.player_stats != null && entity.player_stats.character_id == 2:
			entity.target_velocity.x = lerp(
										entity.target_velocity.x, 
										normalized_h_v.x * -1.0 * entity._movement_speed, 
										delta * entity._ACCELERATION
									)
		else:
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
	
	entity.move_and_slide()
	
	#if entity._treadmill:
		#entity.global_position.z = clamp(entity.global_position.z, entity.global_position.z, entity._treadmill_z)
