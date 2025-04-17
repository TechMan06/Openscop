extends Marker3D
class_name Cage

signal allow_toggle
signal cage_initiated

@export var open: bool = false
@export var flip: bool = false
@export var saveable: bool = false
@export var cage_id: int = 0
@export_range(0, 100) var move_to: float = 3.0

@onready var room_name: String = get_tree().get_current_scene().room_name


func _ready() -> void:
	if SaveManager.get_data().cage.has(room_name):
		if SaveManager.get_data().cage[room_name].has(str(cage_id)):
			open = SaveManager.get_data().cage[room_name][str(cage_id)]
			set_state(open)


func set_state(value: bool) -> void:
	open = value
	
	var negative_or_not: int = int(open) - int(!open)
	var flip_or_not: int = int(!flip) - int(flip)
	self.position.x -= negative_or_not * move_to * flip_or_not


func _on_trigger() -> void:
	var negative_or_not: int = int(open) - int(!open)
	var flip_or_not: int = int(!flip) - int(flip)
	var move_anim: Tween = create_tween()
	
	move_anim.tween_property(
								self, 
								"position:x", 
								negative_or_not * move_to * flip_or_not, 
								abs(move_to) * 0.75
							).as_relative()
	
	await move_anim.finished
	
	open = !open
	
	if saveable:
		if !SaveManager.get_data().cage.has(room_name):
			SaveManager.get_data().cage[room_name] = {
														str(cage_id) : open
													}
		else:
			SaveManager.get_data().cage[room_name][str(cage_id)] = open

	
	allow_toggle.emit()
