@icon("res://icon/warp.png")
@tool
extends Node3D
class_name WarpClass

## This object is used in the warp.tscn scene for the warp object.
## The warp object is used to send te player from one [Level] to another.

var performed_check: bool = false ## Checks if the signal for the warp spawning was spawned.
var is_ready: bool = false ## Checks if the warp is ready for usage, used to prevent instant teleport if the player is spawned at the same place as the warp.

@export_subgroup("Warp_properties")
@export var all_directions = false ## Whether the warp accepts any direction.
@export var diagonal_entrance = false ## Whether the warp's direction is diagonal.
@export var directions = Vector2i.ZERO ## Used if [member WarpClass.diagonal_entrance] is [code]true[/code] to set the directions accepted by the warp.
@export var detect_bucket: bool = true ## Whether this warp allows buckets to go through it.
@export_range(0, 3) var warp_direction = 0 ## The direction of the warp, used if [code]false[/code].
@export var y_offset: float ## The Y offset of the [Entity] needed for the warp to be triggered.
@export var disable_shadow_monster_man: bool = false ## Whether this warp disables the Shadow Monster Man if the [Entity] crossing it is currently using it.
@export var keep_child_library_face: bool = false ## Whether to reset the [member SaveManager.library_face] variable if the player goes through it.
@export_subgroup("Warp_to")
@export_file("*.tscn") var scene ## Scene the warp should send the [Player] to.
@export var loading_preset: LoadingPreset ## [LoadingPreset] used for the fade effect or the Loading Screen.
@export var warp_id: int ## Individual warp ID to identify it in the [SpawnClass].

@onready var sprite = $WarpSprite
@onready var warp_area = $WarpArea/WarpCollision
@onready var backup_warps = $BackupWarps


func _ready() -> void:
	if !Engine.is_editor_hint():
		EventBus.unlock_nmp.connect(_on_nmp_unlock)
		sprite.visible = GameManager.debug_settings.debug
		
		await get_tree().create_timer(0.05).timeout
		is_ready = true


func _process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		if !performed_check:
			EventBus.warp_spawned.emit(self)
			performed_check = true
	
	if !all_directions:
		sprite.frame_coords.x = clamp(warp_direction, 0, 3)
	
	if all_directions:
		sprite.frame_coords.x = 4
	
	if !all_directions:
		if warp_direction == 0 || warp_direction == 3:
			warp_area.get_shape().size = Vector3(2., 2., 0.)
			
			if warp_direction == 3:
				backup_warps.rotation.y = deg_to_rad(180)
			else:
				backup_warps.rotation.y = 0.0
		elif warp_direction == 1 || warp_direction == 2:
			warp_area.get_shape().size = Vector3(0., 2., 2.)
			
			if warp_direction == 2:
				backup_warps.rotation.y = deg_to_rad(-90)
			else:
				backup_warps.rotation.y = deg_to_rad(90)
	
	
	warp_direction = clamp(warp_direction, 0, 3)


func _on_warp_area_body_entered(body: Node3D) -> void:
	if scene != null and is_ready:
		if body is Bucket && detect_bucket:
			SaveManager.get_data().has_bucket = true
		
		if body is Player:
			if SaveManager.get_data().library_face != null and !keep_child_library_face:
				SaveManager.get_data().library_face = null
			
			if SaveManager.get_data().has_bucket && detect_bucket:
				SaveManager.get_data().bucket_direction = body.direction
			
			if body.velocity.x != 0.0 || body.velocity.z != 0.0:
				if diagonal_entrance:
					if body.direction == directions.x || body.direction == directions.y:
						body.player_stats.scene_info = [get_tree().get_current_scene().scene_file_path, warp_id, scene]
						Global.warp_to(scene, loading_preset, disable_shadow_monster_man)
				else:
					if body.direction == warp_direction || all_directions || body.control_mode == 1:
						body.player_stats.scene_info = [get_tree().get_current_scene().scene_file_path, warp_id, scene]
						Global.warp_to(scene, loading_preset, disable_shadow_monster_man)
			
			if y_offset != 0.0:
				body.entity_y = y_offset

	if body is PlaybackPlayer:
		if body.velocity.x != 0.0 || body.velocity.z != 0.0:
			if diagonal_entrance:
				if body.direction == directions.x || body.direction == directions.y:
					match body.on_warp:
						0:
							body.warp()
							
						1:
							body.queue_free()
			else:
				if body.direction == warp_direction || all_directions || body.control_mode == 1:
					match body.on_warp:
						0:
							body.warp()
						
						1:
							body.queue_free()


func _on_nmp_unlock() -> void:
	if loading_preset == load("res://resource/loading_preset/ec_noload.tres"):
		loading_preset = load("res://resource/loading_preset/nmp_delay.tres")
	elif loading_preset == load("res://resource/loading_preset/gift_load.tres"):
		loading_preset = load("res://resource/loading_preset/nmp_load.tres")
	
	if scene == "res://scene/room/gift_plane/gift_plane.tscn":
		scene = "res://scene/room/nmp/nmp.tscn"
