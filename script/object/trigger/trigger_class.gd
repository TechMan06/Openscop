@icon("res://icon/interaction.png")
extends Marker3D
class_name TriggerClass

signal triggered

const TRIGGER_SCENE: PackedScene = preload("res://scene/object/interactive/common/interaction_symbol.tscn")

@export_category("General Properties")
@export var destroy_after_interaction: bool = false
@export_category("Symbol Properties")
@export var height_offset: float = 2.0
@export var min_distance: float = 2.5


func _ready() -> void:
	var _trigger: Marker3D = TRIGGER_SCENE.instantiate()
	
	_trigger.height_offset = height_offset
	_trigger.min_distance = min_distance
	_trigger.triggered.connect(_on_trigger)
	_trigger.triggered.connect(_destruction_check)
	_trigger.triggered.connect(emit_trigger)
	
	add_child(_trigger)


func _on_trigger() -> void:
	pass


func emit_trigger() -> void:
	triggered.emit()


func _destruction_check() -> void:
	if destroy_after_interaction:
		get_child(0).deactivate()
