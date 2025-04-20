extends AudioStreamPlayer3D

@export var phone_id: int


func _ready() -> void:
	if SaveManager.get_data().anna_phone.find(phone_id) == -1:
		play()
