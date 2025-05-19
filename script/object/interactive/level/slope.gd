@tool
@icon("res://icon/slope.png")
extends Marker3D
class_name Slope

const DARKENER_SCENE: PackedScene = preload("res://scene/object/interactive/level/darkener.tscn")

var inside_slope: bool = false
var entities: Array[Entity]

@export_subgroup("Slope Settings:")
@export var y_offset: float = 0.0
@export var slope_length: float = 1.
@export var slope_width: float = 1.
@export_range(0, 3) var slope_direction: int = 0
@export var slope_up: bool = true
@export var change_brightness: bool = false

@onready var slope_top_sprite: Sprite3D = $SlopeStart/SpriteTOP
@onready var slope_end: Marker3D = $SlopeEnd
@onready var slope_start: Marker3D = $SlopeStart
@onready var slope_area: Area3D = $SlopeArea
@onready var slope_collision: CollisionShape3D = $SlopeArea/SlopeCollision
@onready var display_path: Path3D = $Path3D
@onready var display_mesh: CSGPolygon3D = $PathMesh


func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = GameManager.debug_settings.debug
		
		if change_brightness:
			var _darkener_instance: Marker3D = DARKENER_SCENE.instantiate()
			
			_darkener_instance.darkener_direction = slope_direction
			
			add_child(_darkener_instance)

		match slope_direction:
			0:
				slope_end.position.z = slope_length
				slope_end.position.x = 0.0
				slope_area.position.x = 0.0
				slope_area.position.z = slope_length / 2
				slope_collision.get_shape().size = Vector3(slope_width - 0.5, 1.0, slope_length - 1)

			3:
				slope_end.position.z = slope_length * -1
				slope_end.position.x = 0.0
				slope_area.position.x = 0.0
				slope_area.position.z = slope_length / 2 * -1
				slope_collision.get_shape().size = Vector3(slope_width - 0.5, 1.0, slope_length - 1)

			1:
				slope_end.position.x = slope_length
				slope_end.position.z = 0.0
				slope_area.position.z = 0.0
				slope_area.position.x = slope_length / 2
				slope_collision.get_shape().size = Vector3(slope_length - 1, 1.0, slope_width - 0.5)

			2:
				slope_end.position.x = slope_length * -1
				slope_end.position.z = 0.0
				slope_area.position.z = 0.0
				slope_area.position.x = slope_length / 2 * -1
				slope_collision.get_shape().size = Vector3(slope_length - 1, 1.0, slope_width - 0.5)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
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
	
		if display_path and display_path.curve and slope_length > 1: # Ensure path and curve exist
			if display_mesh:
				display_mesh.visible = true
			
			if display_path.curve.get_point_count() >= 2: # Ensure curve has at least 2 points
				# Point 0 should be at the local position of SlopeStart
				display_path.curve.set_point_position(0, slope_start.position + get_direction(slope_direction))

				# Point 1 should be at the local position of SlopeEnd
				display_path.curve.set_point_position(1, Vector3(slope_end.position.x, 
														abs(y_offset + (slope_length - 1.0))
														 * (1.0 if slope_up else -1.0), 
														slope_end.position.z)  - get_direction(slope_direction))
		else:
			if display_mesh:
				display_mesh.visible = false
		
	else:
		for entity in entities:
			if is_inside_slope(entity, slope_direction):
				match slope_direction:
					0:
						entity.player_stats.entity_y = (
															 abs(
																entity.global_position.z
																- slope_start.global_position.z
															) * (1.0 if slope_up else -1.0)
														) + y_offset + entity.entity_min
					1:
						entity.player_stats.entity_y = (
															abs(
																entity.global_position.x
																- slope_start.global_position.x
															) * (1.0 if slope_up else -1.0)
														) + y_offset + entity.entity_min
					2:
						entity.player_stats.entity_y = (
															abs(
																slope_start.global_position.x
																- entity.global_position.x
															) * (1.0 if slope_up else -1.0)
														) + y_offset + entity.entity_min
					3:
						entity.player_stats.entity_y = (
															abs(
																slope_start.global_position.z
																- entity.global_position.z
															) * (1.0 if slope_up else -1.0)
														) + y_offset + entity.entity_min


func get_direction(value: int) -> Vector3:
	match value:
		0:
			return Vector3(0., 0., 0.5)
		1:
			return Vector3(0.5, 0., 0.)
		2:
			return Vector3(-0.5, 0., 0.)
		3:
			return Vector3(0., 0., -0.5)
	
	return Vector3.ZERO


func is_inside_slope(cur_entity: Entity, slope_direction: int) -> bool:
	var slope_start_pos: Vector3 = slope_start.global_position
	
	match slope_direction:
		0:
			if (
						cur_entity != null and
						cur_entity.global_position.x < slope_start_pos.x + (slope_width / 2.0) and
						cur_entity.global_position.x > slope_start_pos.x - (slope_width / 2.0) and
						cur_entity.global_position.z > slope_start_pos.z and
						cur_entity.global_position.z < slope_end.global_position.z
					):
				return true
		1:
			if (
						cur_entity != null and
						cur_entity.global_position.x < slope_end.global_position.x and
						cur_entity.global_position.x > slope_start_pos.x and
						cur_entity.global_position.z > slope_start_pos.z - (slope_width / 2.0) and
						cur_entity.global_position.z < slope_start_pos.z + (slope_width / 2.0)
					):
				return true
		2:
			if (
						cur_entity != null and
						cur_entity.global_position.x > slope_end.global_position.x and
						cur_entity.global_position.x < slope_start_pos.x and
						cur_entity.global_position.z > slope_start_pos.z - (slope_width / 2.0) and
						cur_entity.global_position.z < slope_start_pos.z + (slope_width / 2.0)
					):
				return true
		3:
			if (
						cur_entity != null and
						cur_entity.global_position.x < slope_start_pos.x + (slope_width / 2.0) and
						cur_entity.global_position.x > slope_start_pos.x - (slope_width / 2.0) and
						cur_entity.global_position.z < slope_start_pos.z and
						cur_entity.global_position.z > slope_end.global_position.z
					):
				return true
	
	return false


func _on_slope_area_body_entered(body: Node3D) -> void:
	if body is Entity && !Engine.is_editor_hint():
		entities.append(body)


func _on_slope_area_body_exited(body):
	if entities.find(body) != -1:
		entities.erase(body)

	if !slope_up:
		body.player_stats.entity_y = body.entity_min
