extends Marker3D

signal allow_toggle

@export var open: bool = false
@export var flip: bool = false
@export_range(0, 100) var move_to: float = 3.0


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
	allow_toggle.emit()
