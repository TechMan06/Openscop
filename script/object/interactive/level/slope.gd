@tool
extends Marker3D


const DARKENER_SCENE: PackedScene = preload("res://scene/object/interactive/level/darkener.tscn")

var inside_slope: bool = false
var entity: Entity

@export_subgroup("Slope Settings:")
@export var y_offset: float = 0.0
@export var slope_length: float = 1.
@export var slope_width: float = 1.
@export_range(0, 3) var slope_direction: int = 0
@export var slope_up: bool = true
@export var change_brightness: bool = false

@onready var slope_end: Marker3D = $SlopeEnd
@onready var slope_start: Marker3D = $SlopeStart
@onready var slope_area: Area3D = $SlopeArea
@onready var slope_collision: CollisionShape3D = $SlopeArea/SlopeCollision


func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = GameManager.debug_settings.debug
		
		if change_brightness:
			var _darkener_instance: Marker3D = DARKENER_SCENE.instantiate()
			
			_darkener_instance.darkener_direction = slope_direction
			
			add_child(_darkener_instance)


func _process(_delta: float) -> void:
	match slope_direction:
		0:
			slope_end.position.z = slope_length
			slope_end.position.x = 0.0
			slope_area.position.x = 0.0
			slope_area.position.z = slope_length / 2
			slope_collision.get_shape().size = Vector3(slope_width, 1.0, slope_length - 1)
		
		3:
			slope_end.position.z = slope_length * -1
			slope_end.position.x = 0.0
			slope_area.position.x = 0.0
			slope_area.position.z = slope_length / 2 * -1
			slope_collision.get_shape().size = Vector3(slope_width, 1.0, slope_length - 1)
		
		1:
			slope_end.position.x = slope_length
			slope_end.position.z = 0.0
			slope_area.position.z = 0.0
			slope_area.position.x = slope_length / 2
			slope_collision.get_shape().size = Vector3(slope_length - 1, 1.0, slope_width)
		
		2:
			slope_end.position.x = slope_length * -1
			slope_end.position.z = 0.0
			slope_area.position.z = 0.0
			slope_area.position.x = slope_length / 2 * -1
			slope_collision.get_shape().size = Vector3(slope_length - 1, 1.0, slope_width)
	
	if !Engine.is_editor_hint():
		
		if inside_slope:
			match slope_direction:
				0:
					entity.player_stats.entity_y = (
														 abs(
															abs(entity.global_position.z) 
															- slope_start.global_position.z
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				1:
					entity.player_stats.entity_y = (
														abs(
															abs(entity.global_position.x) 
															- slope_start.global_position.x
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				2:
					entity.player_stats.entity_y = (
														abs(
															abs(slope_start.global_position.x) 
															- entity.global_position.x
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				3:
					entity.player_stats.entity_y = (
														abs(
															abs(slope_start.global_position.z) 
															- entity.global_position.z
														) * (1.0 if slope_up else -1.0)
													) + y_offset
		else:
			if entity!= null:
				
				if entity.player_stats.entity_y <= 0.:
					entity.player_stats.entity_y = 0.
				
				if entity.player_stats.entity_y >= 0.:
					if entity.player_stats.entity_y >= 0.5:
						entity.player_stats.entity_y -= 0.5
					else:
						entity.player_stats.entity_y = 0.
	

func _on_slope_area_body_entered(body: Node3D) -> void:
	if body is Entity && !Engine.is_editor_hint():
		inside_slope = true
		entity = body


func _on_slope_area_body_exited(body: Node3D) -> void:
	if body is Entity && !Engine.is_editor_hint():
		inside_slope = false
