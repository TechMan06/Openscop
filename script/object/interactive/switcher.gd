extends Marker3D
class_name SwitcherClass

@export_category("Trigger Properties")
@export var min_distance: float = 2.5
@export_category("Switch Properties")
@export var connect_to: Node
@export var rotate_y: float = 0.0

var turned_on: bool = false:
	set(value):
		$LeverOrigins.get_child(int(value)).visible = value
		$LeverOrigins.get_child(int(!value)).visible = !value
		turned_on = value

var can_trigger: bool = true

@onready var lever_a = $LeverOrigins/LeverA
@onready var lever_b = $LeverOrigins/LeverB
@onready var interaction_symbol = $InteractionSymbol


func _ready() -> void:
	interaction_symbol.height_offset = 1
	
	interaction_symbol.min_distance = min_distance


func _on_interaction_symbol_triggered():
	if can_trigger:
		turned_on = !turned_on
		can_trigger = false
