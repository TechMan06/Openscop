@tool
@icon("res://icon/slope.png")
extends Marker3D
class_name Slope

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

@onready var slope_up_texture = load("res://asset/2d/ui/editor/slope_up.png")
@onready var slope_down_texture = load("res://asset/2d/ui/editor/slope_down.png")
@onready var slope_top_sprite: Sprite3D = $SlopeStart/SpriteTOP
@onready var slope_bottom_sprite: Sprite3D = $SlopeEnd/SpriteBOTTOM
@onready var slope_end: Marker3D = $SlopeEnd
@onready var slope_start: Marker3D = $SlopeStart
@onready var slope_area: Area3D = $SlopeArea
@onready var slope_collision: CollisionShape3D = $SlopeArea/SlopeCollision
@onready var display_path: Path3D = $Path3D
@onready var display_mesh = $PathMesh

func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = GameManager.debug_settings.debug
		
		if change_brightness:
			var _darkener_instance: Marker3D = DARKENER_SCENE.instantiate()
			
			_darkener_instance.darkener_direction = slope_direction
			
			add_child(_darkener_instance)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if is_instance_valid(slope_down_texture) and is_instance_valid(slope_top_sprite):
			if slope_up:
				if slope_top_sprite.material_override != null and slope_bottom_sprite.material_override != null:
					slope_top_sprite.material_override.set_shader_parameter("albedoTex", slope_up_texture)
					slope_top_sprite.material_override.set_shader_parameter("modulate_color", Color(1, 0.444, 0.445))
			else:
				if slope_top_sprite.material_override != null and slope_bottom_sprite.material_override != null:
					slope_top_sprite.material_override.set_shader_parameter("albedoTex", slope_down_texture)
					slope_top_sprite.material_override.set_shader_parameter("modulate_color", Color(0.471, 0.639, 1))
	

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

	if display_path and display_path.curve: # Ensure path and curve exist
			if display_path.curve.get_point_count() >= 2: # Ensure curve has at least 2 points
				# Point 0 should be at the local position of SlopeStart
				display_path.curve.set_point_position(0, slope_start.position)

				# Point 1 should be at the local position of SlopeEnd
				display_path.curve.set_point_position(1, Vector3(slope_end.position.x, 
														abs(y_offset + slope_length)
														 * (1.0 if slope_up else -1.0), 
														slope_end.position.z))
	
	if !Engine.is_editor_hint():
		if entity != null and entity.inside_slope:
			match slope_direction:
				0:
					entity.player_stats.entity_y = (
														 abs(
															entity.global_position.z
															- slope_start.global_position.z
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				1:
					entity.player_stats.entity_y = (
														abs(
															entity.global_position.x
															- slope_start.global_position.x
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				2:
					entity.player_stats.entity_y = (
														abs(
															slope_start.global_position.x
															- entity.global_position.x
														) * (1.0 if slope_up else -1.0)
													) + y_offset
				3:
					entity.player_stats.entity_y = (
														abs(
															slope_start.global_position.z
															- entity.global_position.z
														) * (1.0 if slope_up else -1.0)
													) + y_offset

func _on_slope_area_body_entered(body: Node3D) -> void:
	if body is Entity && !Engine.is_editor_hint():
		body.inside_slope = true
		entity = body


func _on_slope_area_body_exited(body: Node3D) -> void:
	if body is Entity && !Engine.is_editor_hint():
		body.inside_slope = false
