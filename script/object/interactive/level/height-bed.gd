@tool
@icon("res://icon/height_bed.png")
extends Area3D
class_name HeightBed

@export var height: float = 0.0


func _ready() -> void:
	if !Engine.is_editor_hint():
		
		await get_tree().physics_frame
		
		visible = GameManager.debug_settings.debug
	
	else:
		%Height.position.y = height


func _process(_delta: float) -> void:
	%Height.position.y = height


func _on_body_entered(body: Node3D) -> void:
	if body is Entity:
		body.inside_slope = true
		body.player_stats.entity_y = height + body.entity_min


func _on_body_exited(body: Node3D) -> void:
	if body is Entity:
		body.inside_slope = false
		body.player_stats.entity_y = 0.0 + body.entity_min
