@tool
@icon("res://icon/pet.png")
extends Marker3D

var jumping: bool = false
var jump_timer: float = 0.0
var frame_count: int = 0
var animation_setup: bool = false

enum AmberStates {
	IDLE,
	PREPARE,
	JUMP,
	LAND,
	NO_CODE
}

var amber_state: AmberStates
var current_height: float = 0.0
var pos_distance: float = 0.0

@export_category("Cage Position Properties")
@export_enum("A","B") var current_position: int = 0
@export var pos_a: Vector3i = Vector3i(0.0, 0.0, 0.0)
@export var pos_b: Vector3i = Vector3i(0.0, 0.0, 0.0)
@export_category("Animation Properties")
@export var jump_height: float = 4.75
@export var jump_speed: float = 1.0
@export_category("Connected Switchers")
@export var switch_a: SwitcherClass
@export var switch_b: SwitcherClass

@onready var amber_pos_a: Marker3D = %AmberPosA
@onready var amber_pos_b: Marker3D = %AmberPosB
@onready var pet_object: Pet = %PetObject
@onready var jump_offset: Marker3D = %JumpOffset
@onready var jump_anim: AnimationPlayer = %JumpAnim
@onready var amber_origin: Marker3D = %AmberOrigin
@onready var jump_sound: AudioStreamPlayer = %JumpSound
@onready var land_sound: AudioStreamPlayer = %LandSound
@onready var amber_area: Area3D = %AmberArea


func _ready() -> void:
	if !Engine.is_editor_hint():
		pet_object.caught.connect(_disable)
		
		amber_pos_a.global_position = pos_a
		amber_pos_b.global_position = pos_b
	
		if current_position == 0:
			amber_origin.global_position = pos_a
		else:
			amber_origin.global_position = pos_b
		
		amber_pos_a.visible = GameManager.debug_settings.debug
		amber_pos_b.visible = GameManager.debug_settings.debug
		amber_state = AmberStates.IDLE
		
		if switch_a != null:
			switch_a.switched.connect(amber_jump)
		
		if switch_b != null:
			switch_b.switched.connect(amber_jump)
			
		if SaveManager.get_data().pet.find("amber") != -1:
			queue_free()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		amber_pos_a.global_position = pos_a
		amber_pos_b.global_position = pos_b
	else:
		match amber_state:
			AmberStates.IDLE:
				current_height = 0.0
				pet_object.disable_collection = false
				pet_object.frame_coords.x = 0
				jump_anim.play(&"jump")
				frame_count = 0
			
			AmberStates.PREPARE:
				pet_object.disable_collection = true
				jump_anim.play(&"RESET")
				pet_object.frame_coords.x = 1
				
				if frame_count <= 5:
					frame_count += 1
				else:
					current_position += 1
					
					if current_position == 2:
						current_position = 0

					amber_state = AmberStates.JUMP
			
			AmberStates.JUMP:
				pet_object.frame_coords.x = 2
				frame_count = 0
				current_height += get_cage().distance_to(get_inv_cage()) * delta / 6.5
				current_height = clamp(current_height, 0.0, 1.0)
				
				jump_offset.position.y = _jump_curve(
														pos_a, 
														Vector3(get_cage().x, jump_height, get_cage().z),
														Vector3(get_inv_cage().x, jump_height, get_inv_cage().z),
														pos_b,
														current_height
													).y
		
				var move_tween: Tween
				
				if !animation_setup:
					move_tween = create_tween()
					move_tween.tween_property(
												amber_origin, 
												"global_position", 
												Vector3(get_cage()), 
												jump_speed
											)
					animation_setup = true
				
				if move_tween != null:
					await move_tween.finished
					land_sound.play()
					$QuakeTimer.start()
					EventBus.camera_earthquake.emit(true)
					EventBus.camera_shake_amount.emit(0.05)
					EventBus.camera_shake_speed.emit(37.0)
					amber_state = AmberStates.LAND
			
			AmberStates.LAND:
				animation_setup = false
				pet_object.frame_coords.x = 1
				if frame_count <= 5:
					frame_count += 1
				else:
					amber_state = AmberStates.IDLE


func get_cage() -> Vector3:
	if current_position == 0:
		return pos_a

	return pos_b


func get_inv_cage() -> Vector3:
	if current_position == 0:
		return pos_b

	return pos_a


func _on_amber_area_entered(body):
	if !Engine.is_editor_hint():
		if body is Player && amber_state == AmberStates.IDLE:
			jump_sound.play()
			amber_state = AmberStates.PREPARE


func amber_jump(_value: bool) -> void:
	if amber_state == AmberStates.IDLE:
		jump_sound.play()
		amber_state = AmberStates.PREPARE


func _jump_curve(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	
	return s


func _disable() -> void:
	amber_area.queue_free()
	amber_state = AmberStates.NO_CODE


func _on_quake_timer_timeout():
	EventBus.camera_earthquake.emit(false)
