
@tool
extends Node3D

const ROTATION_ANGLE: float = 135.0
const ANIM_SPEED: float = 1.0

var rotation_array: Array[float] = [180.0, -90.0, 90.0, 0.0]
var opposite_rotation: Array[int] = [3, 2, 1, 0]

@export_category("Trapdoor Properties")
@export var has_door: bool = true
@export var open: bool = false
@export_range(0, 3) var direction = 3
@export var use_trigger: bool = false
@export var destroy_after_trigger: bool = true
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



func _ready() -> void:
	if !Engine.is_editor_hint():
		match direction:
			0:
				warp.global_position.z += warp_offset
			1:
				warp.global_position.x += warp_offset
			2:
				warp.global_position.x -= warp_offset
			3:
				warp.global_position.z -= warp_offset
		
		slope.slope_direction = direction
		slope.global_rotation.y = 0.0
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
		
		if has_door:
			if open:
				door_mesh.rotation.z = ROTATION_ANGLE
				front_shape.disabled = true
		else:
			door_mesh.visible = false
			front_shape.disabled = true
		
		if !use_trigger:
			trigger.queue_free()
	
		trigger.triggered.connect(_check_state)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		global_rotation.y = deg_to_rad(rotation_array[direction])
	#else:
		#$TrapdoorMesh/SpawnClass.scene_path = warp_to
		#$TrapdoorMesh/SpawnClass.warp_id = warp_id
		#$TrapdoorMesh/Darkener.darkener_direction = direction
		#$TrapdoorMesh/Darkener.g


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


func _check_state() -> void:
	if destroy_after_trigger:
		trigger.deactivate()
	
	if open:
		close_door()
	else:
		open_door()
	
