@tool
extends Area3D
class_name FootstepSound

@export_enum("None", "EvenCare", "Grass", "Cement", "Cement2", "Cement3", "School", "Sand") var sound: String = "None"
@export var area_size: Vector2 = Vector2(1., 1.)

@onready var shape = $Shape
@onready var zone_mesh = %ZoneMesh


func _ready() -> void:
	if !Engine.is_editor_hint():
		shape.get_shape().size = Vector3(area_size.x, 0., area_size.y)
		set_name.call_deferred(sound)
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		visible = GameManager.debug_settings.debug
		

func _process(_delta: float):
	if Engine.is_editor_hint():
		$Shape.get_shape().size = Vector3(area_size.x, 0., area_size.y)
		%ZoneMesh.get_mesh().size = $Shape.get_shape().size
