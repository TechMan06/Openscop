extends Marker2D

@export var collected: bool

var pet_resource: PetResource
var focused: bool:
	set(value):
		if !value:
			$ButtonFace.play(&"RESET")
			$AnimationPlayer.play(&"RESET")
		else:
			$ButtonFace.play(&"focus")
			$AnimationPlayer.play(&"focus")


func _ready() -> void:
	if pet_resource != null:
		$ButtonFace/PetIcon.texture = pet_resource.pet_icon
		$ButtonFace/PetIcon.frame = int(collected)
		
		if pet_resource.pet_name != null && SaveManager._data.pet.find(pet_resource.pet_id_name) != -1:
			$PetName.texture = pet_resource.pet_name
