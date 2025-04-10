@icon("res://icon/gen.png")
extends Node
class_name GenSpecific

var performed_check: bool = false

@export var gens: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
@export var demo_exclusive: bool = false
@export var non_demo_exclusive: bool = false
@export var odd_care_exclusive: bool = false
@export var non_odd_care_exclusive: bool = false


func _ready() -> void:
	if gens.find(Global.global_data.gen) == -1:
		queue_free()
		
	if demo_exclusive && !RecordingManager.demo:
		queue_free()
	
	if non_demo_exclusive && RecordingManager.demo:
		queue_free()


func _process(_delta: float) -> void:
	if !performed_check:
		EventBus.gen_specific_object_spawned.emit(self)
		performed_check = true
