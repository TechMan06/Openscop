@icon("res://icon/interaction.png")
extends Marker3D
class_name TriggerClass

const TRIGGER_SCENE: PackedScene = preload("res://scene/object/interactive/interaction_symbol.tscn")

@export_category("General Properties")
@export var trigger_area: float = 2.5
@export var destroy_after_interaction: bool = false
@export_category("Symbol Properties")
@export var height_offset: float = 2.0
@export var min_distance: float = 2.5


func _ready() -> void:
	var _trigger: Marker3D = TRIGGER_SCENE.instantiate()
	_trigger.trigger_area = trigger_area
	_trigger.height_offset = height_offset
	_trigger.min_distance = min_distance
	_trigger.triggered.connect(_on_trigger)
	_trigger.triggered.connect(_destruction_check)
	add_child(_trigger)


func _on_trigger() -> void:
	pass


func _destruction_check() -> void:
	if destroy_after_interaction:
		get_child(0).deactivate()