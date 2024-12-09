extends Marker3D
class_name SwitcherClass

signal switched

@export_category("Trigger Properties")
@export var min_distance: float = 0.25
@export_category("Switch Properties")
@export var connect_to: Node
@export var rotate_y: float = 0.0
@export var height_offset: float = 0.75
@export var turned_on: bool = false

var can_trigger: bool = true

@onready var lever_origins = $LeverOrigins
@onready var lever_a = $LeverOrigins/LeverA
@onready var lever_b = $LeverOrigins/LeverB
@onready var interaction_symbol = $LeverOrigins/InteractionSymbol


func _ready() -> void:
	if connect_to != null:
		connect_to.allow_toggle.connect(allow_toggle)
	
	lever_origins.position.y = height_offset
	lever_origins.rotation.y = deg_to_rad(rotate_y)
	interaction_symbol.min_distance = min_distance
	interaction_symbol.rotation.y = -lever_origins.rotation.y
	interaction_symbol.global_position.y = 0.0
	interaction_symbol.height_offset = 1.75
	
	_update_switch()


func _update_switch() -> void:
	lever_origins.get_child(0).visible = turned_on
	lever_origins.get_child(1).visible = !turned_on


func allow_toggle() -> void:
	can_trigger = true


func _on_interaction_symbol_triggered() -> void:
	if can_trigger:
		turned_on = !turned_on
		can_trigger = false
		
		if connect_to != null:
			connect_to._on_trigger()
		
		_update_switch()
