extends TriggerClass
class_name CanvasTrigger

const CANVAS_SCENE: PackedScene = preload("res://scene/ui/canvas.tscn")

@export var id: int = 0


func _on_trigger() -> void:
	var canvas_instance: Node2D = CANVAS_SCENE.instantiate()
	
	canvas_instance.id = id
	
	add_child(canvas_instance)
