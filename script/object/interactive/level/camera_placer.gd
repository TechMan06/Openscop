@tool
extends Area3D
class_name CameraPlacer

var camera_marker: CameraMarker

@export_category("General Properties")
@export var target_pos: Vector3 = Vector3.ZERO


func _ready() -> void:
	if !Engine.is_editor_hint():
		
		await get_tree().physics_frame
		
		EventBus.camera_placer_spawned.emit(self)
		
		visible = GameManager.debug_settings.debug


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$CamTarget.global_position = target_pos


func _on_body_entered(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		if body is Player:
			camera_marker.global_position = target_pos
