@tool
extends Marker3D


@export_subgroup("Darkener Settings:")
@export var darkener_width = 1.
@export_range(0, 3) var darkener_direction: int = 0

var entity: Entity
var inside_darkener: bool

@onready var darkener_collision = $DarkenerArea/DarkenerCollision
@onready var darkener_sprite = $DarkenerSprite
@onready var darkener_area = $DarkenerArea


func _process(_delta) -> void:
	darkener_sprite.frame_coords.x = darkener_direction
	
	if !Engine.is_editor_hint():
		visible = GameManager.debug_settings.debug
	
		match darkener_direction:
			0:
				darkener_area.position.x = 0.0
				darkener_area.position.z = 0.75
				darkener_collision.get_shape().size = Vector3(darkener_width, 1.0, 3.0)
			1:
				darkener_area.position.z = 0.0
				darkener_area.position.x = 0.75
				darkener_collision.get_shape().size = Vector3(3.0, 1.0, darkener_width)
			2:
				darkener_area.position.z = 0.0
				darkener_area.position.x = -0.75
				darkener_collision.get_shape().size = Vector3(3.0, 1.0, darkener_width)
			3:
				darkener_area.position.x = 0.0
				darkener_area.position.z = -0.75
				darkener_collision.get_shape().size = Vector3(darkener_width, 1.0, 3.0)

		if inside_darkener:
			match darkener_direction:
				0:
					entity.player_stats.brightness = clamp(
															1.0 - 
															(
																(
																	entity.global_position.z - 
																	self.global_position.z
																) 
																- 0.25
															), 
															0.0, 
															1.0
														)
				1:
					entity.player_stats.brightness = clamp(
															1.0 - 
															(
																(
																	entity.global_position.x - 
																	self.global_position.x
																) 
																- 0.25
															), 
															0.0, 
															1.0
														)
				2:
					entity.player_stats.brightness = clamp(
															1.0 - 
															(
																(
																	self.global_position.x -
																	entity.global_position.x  
																	
																) 
																- 0.25
															), 
															0.0, 
															1.0
														)
				3:
					entity.player_stats.brightness = clamp(
															1.0 - 
															(
																(
																	self.global_position.z -
																	entity.global_position.z
																) 
																- 0.25
															), 
															0.0, 
															1.0
														)


func _on_darkener_area_body_entered(body) -> void:
	if body is Entity && !Engine.is_editor_hint():
		inside_darkener = true
		entity = body


func _on_darkener_area_body_exited(body) -> void:
	if body is Entity && !Engine.is_editor_hint():
		inside_darkener = false
		body.player_stats.brightness = round(body.player_stats.brightness)
