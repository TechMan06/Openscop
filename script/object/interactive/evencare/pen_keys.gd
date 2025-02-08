@tool
extends Area3D

const KEY_SCENE: PackedScene = preload("res://scene/object/interactive/evencare/pen_key.tscn")
const KEY_SPACE: float = 1.3

@export_category("General Properties")
@export var key_amount: int = 15
@export var camera: Node3D
@export var camera_speed: float = 0.5

var player: Player
var key_pos: float = 0.0
var _original_pos: Vector3
var _animation_flags: Array[bool] = [false, false, false]
var camera_marker: CameraMarker
var current_tile: int = -1:
	set(value):
		current_tile = value
		
		if value != -1:
			for piano_key in keys.get_children():
				if piano_key.get_index() != value:
					piano_key.pressed = false
				else:
					piano_key.pressed = true
		else:
			for piano_key in keys.get_children():
				piano_key.pressed = false
		
var inside_zone: bool = false
var og_camera: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
var og_marker: Vector3
var target_camera: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
var x_offset: float = 0.0
var follow_camera: bool = false

@onready var camera_focus: Marker3D = $CameraFocus
@onready var zone_collision = $PianoCollision
@onready var keys = $Keys


func _ready() -> void:
	if !Engine.is_editor_hint():
		if !GameManager.debug_settings.debug:
			zone_collision.visible = false

		await get_tree().physics_frame
		
		EventBus.camera_zone_spawned.emit(self)
		
		var key_iterate: int = 0
		
		while key_iterate < key_amount:
			var pen_key: Marker3D = KEY_SCENE.instantiate()
			keys.add_child(pen_key)
			pen_key.global_position.x = global_position.x + key_pos
			key_pos -= KEY_SPACE
			key_iterate += 1
		
		for piano_keys in keys.get_children():
			piano_keys.set_sound()
		
		if camera != null:
			target_camera[0] = camera.global_position
			target_camera[1] = camera.global_rotation
		
		zone_collision.get_shape().size.x = KEY_SPACE * key_amount - 1.0
		zone_collision.position.x = ((zone_collision.get_shape().size.x / 2.0) - 0.25) * -1.0


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		zone_collision.get_child(0).scale.x = KEY_SPACE * key_amount
		zone_collision.position.x = ((zone_collision.get_child(0).scale.x / 2.0) - 0.5) * -1.0 
	else:
		if player != null && inside_zone:
			current_tile = ((global_position.x + 0.5) - player.global_position.x) / KEY_SPACE
			x_offset = ((player.global_position.x - global_position.x) / 2.0)
			
			if follow_camera:
				#camera_marker.set_top_level(true)
				camera_marker.get_child(0).global_position.x = x_offset


func get_anim_speed(target_pos: Vector3) -> float:
	var percentage: float = (
								100.0 - 
								(100 / camera_focus.global_position.distance_to(target_pos))
							) * 0.01
	return percentage


func reset_camera(body: Node3D) -> void:
	camera_marker.set_focus(body)
	camera_marker.camera_mode = camera_marker.CameraModes.FOLLOW


func _on_body_entered(body) -> void:
	if body is Player:
		player = body
		inside_zone = true
		
		if camera != null:
			camera_marker.camera_mode = camera_marker.CameraModes.NO_CODE
			camera_marker.global_position.x = global_position.x
			og_marker = camera_marker.global_position
			og_camera[0] = camera_marker.get_camera().position
			og_camera[1] = camera_marker.get_camera().rotation
			og_camera[2] = camera_marker.global_position
			
			var rotmove_camera_in: Tween = create_tween().set_parallel()
			
			rotmove_camera_in.tween_property(
											camera_marker.get_camera(),
											"global_position",
											target_camera[0],
											camera_speed *  get_anim_speed(target_camera[0])
			).set_trans(Tween.TRANS_SINE)
			
			rotmove_camera_in.tween_property(
											camera_marker.get_camera(),
											"rotation",
											target_camera[1],
											camera_speed *  get_anim_speed(target_camera[1])
			).set_trans(Tween.TRANS_SINE)
			
			await rotmove_camera_in.finished
			
			follow_camera = true


func _on_body_exited(body) -> void:
	follow_camera = false
	x_offset = 0.0
	inside_zone = false
	current_tile = -1
	
	if camera != null:
		camera_marker.get_child(0).position.x = 0.0
		camera_marker.global_position.x = player.global_position.x + 1.0
		camera_marker.camera_mode = camera_marker.CameraModes.FOLLOW
		camera_marker.get_camera().position = og_camera[0]
		camera_marker.get_camera().rotation = og_camera[1]
		#camera_marker.global_position.x = x_offset
