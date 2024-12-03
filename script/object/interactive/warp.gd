@icon("res://icon/warp.png")
@tool
extends Node3D
class_name WarpClass
@export_subgroup("Warp_properties")
@export var all_directions = false
@export var diagonal_entrance = false
@export var directions = Vector2i.ZERO
@export_range(0, 3) var warp_direction = 0
@export var y_offset: float
@export_subgroup("Warp_to")
@export_file("*.tscn") var scene
@export var loading_preset: LoadingPreset
@export var warp_id: int

@onready var sprite = $WarpSprite
@onready var warp_area = $WarpArea/WarpCollision
@onready var backup_warp = $BackupWarp


func _ready() -> void:
	if !Engine.is_editor_hint():
		sprite.visible = GameManager.debug_settings.debug


func _process(_delta) -> void:
	if !all_directions:
		sprite.frame_coords.x = clamp(warp_direction, 0, 3)
	
	if all_directions:
		sprite.frame_coords.x = 4
	
	if !all_directions:
		if warp_direction == 0 || warp_direction == 3:
			warp_area.get_shape().size = Vector3(2., 2., 0.)
			
			if warp_direction == 3:
				backup_warp.rotation.y = deg_to_rad(180)
			else:
				backup_warp.rotation.y = 0.0
		elif warp_direction == 1 || warp_direction == 2:
			warp_area.get_shape().size = Vector3(0., 2., 2.)
			
			if warp_direction == 2:
				backup_warp.rotation.y = deg_to_rad(-90)
			else:
				backup_warp.rotation.y = deg_to_rad(90)
	
	
	warp_direction = clamp(warp_direction, 0, 3)


func _on_warp_area_body_entered(body) -> void:
	if body is Player:
		if diagonal_entrance:
			if body.direction == directions.x || body.direction == directions.y:
				Global.warp_to(scene, loading_preset)
		else:
			if body.direction == warp_direction || all_directions || body.control_mode == 1:
				body.player_stats.scene_info = [get_tree().get_current_scene().scene_file_path, warp_id]
				Global.warp_to(scene, loading_preset)
		
		if y_offset != 0.0:
			body.entity_y = y_offset

	if body is PlaybackPlayer:
		body.queue_free()
