
@tool
extends Node3D
class_name Trapdoor

const ROTATION_ANGLE: float = 135.0
const ANIM_SPEED: float = 1.0

var rotation_array: Array[float] = [180.0, -90.0, 90.0, 0.0]
var opposite_rotation: Array[int] = [3, 2, 1, 0]

@export_category("Trapdoor Properties")
@export var has_door: bool = true
@export var open: bool = false
@export var door_id: int = 0
@export_range(0, 3) var direction = 3
@export var use_trigger: bool = false
@export var destroy_after_trigger: bool = true
@export var use_timer: float = 0.0
@export var play_jingle: bool = false
@export_category("Warp Properties")
@export var warp_offset: float = 0.0
@export_file("*.tscn") var warp_to
@export var spawn_scene_path: String
@export var loading_preset: LoadingPreset
@export var detect_bucket: bool = true
@export var warp_id: int


@onready var trapdoor_mesh: Marker3D = %TrapdoorMesh
@onready var door_mesh = %DoorMesh
@onready var front_shape = %FrontShape
@onready var darkener: Marker3D = %Darkener
@onready var slope: Marker3D = %Slope
@onready var warp: WarpClass = %Warp
@onready var trigger: Marker3D = %Trigger
@onready var spawn: SpawnClass = %SpawnClass
@onready var room_name: String = get_tree().get_current_scene().room_name



func _ready() -> void:
	if !Engine.is_editor_hint():
		match direction:
			0:
				warp.global_position.z += warp_offset
				warp.disable_shadow_monster_man = false
				darkener.queue_free()
			1:
				warp.global_position.x += warp_offset
			2:
				warp.global_position.x -= warp_offset
			3:
				warp.global_position.z -= warp_offset
				
		
		slope.slope_direction = direction
		slope.global_rotation.y = 0.0
		
		if direction != 0:
			darkener.darkener_direction = direction
			darkener.global_rotation.y = 0.0
		
		warp.scene = warp_to
		warp.detect_bucket = detect_bucket
		warp.loading_preset = loading_preset
		warp.warp_id = warp_id
		spawn.scene_path = warp_to
		spawn.warp_id = warp_id
		spawn.player_direction = opposite_rotation[direction]
		trigger.global_rotation.y = 0.0
		
		if open:
			set_opened()
		
		if !use_trigger:
			trigger.queue_free()
	
		trigger.triggered.connect(_used_trigger)
		
		if use_timer > 0.0:
			await get_tree().create_timer(use_timer).timeout
			
			check_state()
		
		if SaveManager.get_data().trapdoor.has(room_name):
			if SaveManager.get_data().trapdoor[room_name].has(str(door_id)):
				if SaveManager.get_data().trapdoor[room_name][str(door_id)]:
					set_opened()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		global_rotation.y = deg_to_rad(rotation_array[direction])


func open_door() -> void:
	var open_tween: Tween = create_tween()
	
	open_tween.tween_property(
								door_mesh, 
								"rotation:z", 
								deg_to_rad(ROTATION_ANGLE), 
								ANIM_SPEED
							).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(ANIM_SPEED / 2.0).timeout
	
	front_shape.disabled = true
	
	await open_tween.finished
	
	open = true
	
	if !SaveManager.get_data().trapdoor.has(room_name):
		SaveManager.get_data().trapdoor[room_name] = {
														str(door_id) : open
													}
	else:
		SaveManager.get_data().trapdoor[room_name][str(door_id)] = open


func close_door() -> void:
	var close_tween: Tween = create_tween()
	
	close_tween.tween_property(
								door_mesh, 
								"rotation:z", 
								0.0, 
								ANIM_SPEED
							).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(ANIM_SPEED / 2.0).timeout
	
	front_shape.disabled = false
	
	await close_tween.finished
	
	open = false


func _used_trigger() -> void:
	if destroy_after_trigger:
		trigger.deactivate()
	
	check_state()


func check_state() -> void:
	if open:
		close_door()
	else:
		open_door()


func set_opened() -> void:
	if has_door:
		door_mesh.rotation.z = deg_to_rad(ROTATION_ANGLE)
		front_shape.disabled = true
	else:
		door_mesh.visible = false
		front_shape.disabled = true
