extends TriggerClass
class_name PetTrigger

@export var pet: Node3D


func _on_trigger() -> void:
	if pet != null:
		if (pet.get_child(0) is Pet):
			pet.get_child(0).catch()
		else:
			pet.catch()
