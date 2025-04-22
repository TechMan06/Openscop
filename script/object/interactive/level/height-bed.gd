@tool
@icon("res://icon/height_bed.png")
extends Area3D
class_name HeightBed

var entities: Array[Entity]

@export var area_size: Vector2 = Vector2(1., 1.)
@export var height: float = 0.0


func _ready() -> void:
	if !Engine.is_editor_hint():
		
		await get_tree().physics_frame
		
		visible = GameManager.debug_settings.debug
	
	else:
		%Height.position.y = height


func _process(_delta: float) -> void:
	%ZoneCollision.get_shape().size = Vector3(area_size.x, 1.0, area_size.y)
	%ZoneMesh.get_mesh().size = Vector3(area_size.x, height, area_size.y)
	%ZoneMesh.global_position.y = height / 2.0
	
	if scale != Vector3(1.0, 1.0, 1.0):
		scale = Vector3(1.0, 1.0, 1.0)
	
	%Height.position.y = height

	if !Engine.is_editor_hint():
		for entity in entities:
			if (
					entity.global_position.x < self.global_position.x + (area_size.x / 2.0) and
					entity.global_position.x > self.global_position.x - (area_size.x / 2.0) and
					entity.global_position.z < self.global_position.z + (area_size.y / 2.0) and
					entity.global_position.z > self.global_position.z - (area_size.y / 2.0)
				):
					entity.player_stats.entity_y = (height * 1.5) + entity.entity_min


func _on_body_entered(body: Node3D) -> void:
	if body is Entity:
		entities.append(body)


func _on_body_exited(body: Node3D) -> void:
	if entities.find(body) != -1:
		entities.erase(body)
