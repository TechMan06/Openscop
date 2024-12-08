@tool
@icon("res://icon/pet.png")
extends Marker3D
class_name Pet

const CAUGHT_SCENE: PackedScene = preload("res://scene/management/caught.tscn")

@export var pet_name: String
@export var cry_sound_file: AudioStream
@export var pet_sprite: Texture2D
@export var frames: Vector2 = Vector2i(1, 1):
	set(value):
		if Engine.is_editor_hint():
			_update_frames()
		
		frames = value

@export var frame_coords: Vector2:
	set(value):
		pet_sprite3d.frame_coords = value
		frame_coords = value

@export var animate: bool:
	set(value):
		if Engine.is_editor_hint():
			_update_animation()
		animate = value

@export var animation_speed: Vector2:
	set(value):
		if Engine.is_editor_hint():
			_update_anim_speed()
		animation_speed = value

@onready var pet_sprite3d: Sprite3D = $PetSprite
@onready var pet_area: Area3D = $PetArea
@onready var cry_sound: AudioStreamPlayer3D = $Cry


func _ready() -> void:
	if !Engine.is_editor_hint():
		pet_sprite3d.set_texture(pet_sprite)
		pet_sprite3d.get_material_override().set_shader_parameter("albedoTex", pet_sprite3d.texture)
		cry_sound.set_stream(cry_sound_file)
		
		_update_frames()
		_update_animation()
		_update_anim_speed()
		
		if SaveManager.get_data().pet.find(pet_name) != -1:
			queue_free()


func _process(_delta) -> void:
	if Engine.is_editor_hint():
		pet_sprite3d.set_texture(pet_sprite)
		pet_sprite3d.get_material_override().set_shader_parameter("albedoTex", pet_sprite3d.texture)


func _on_pet_area_body_entered(body) -> void:
	if !Engine.is_editor_hint():
		if body is Entity:
			cry_sound.play()
			pet_sprite3d.get_material_override().set_shader_parameter("billboard", false)
			
			if body is Player:
				$CaughtTimer.start()
				SaveManager._data.pet.append(pet_name)
			
			pet_area.queue_free()
			
			var _shrink_animator: Tween = create_tween().set_parallel()
			
			_shrink_animator.tween_property(pet_sprite3d, "scale", Vector3.ZERO,2.5)
			
			var _original_offset: int = pet_sprite3d.offset.y
			
			_shrink_animator.tween_property(
												pet_sprite3d, 
												"offset:y", 
												_original_offset * 2, 
												2.5
											).set_trans(Tween.TRANS_LINEAR)
			
			_shrink_animator.tween_property(pet_sprite3d, "rotation:y", deg_to_rad(360), 2.5)
			
			await _shrink_animator.finished


func _on_caught_timer_timeout() -> void:
	var _caught_instance: Marker2D = CAUGHT_SCENE.instantiate()
	add_child(_caught_instance)


func _update_frames() -> void:
	if frames.x > 1:
		pet_sprite3d.hframes = float(frames.x)
	if frames.y > 1:
		pet_sprite3d.vframes = float(frames.y)
	
	pet_sprite3d.get_material_override().set_shader_parameter(
																"animation_frames", 
																Vector2(
																			pet_sprite3d.hframes, 
																			pet_sprite3d.vframes
																		)
															)


func _update_animation() -> void:
	pet_sprite3d.get_material_override().set_shader_parameter("animate", animate)


func _update_anim_speed() -> void:
	pet_sprite3d.get_material_override().set_shader_parameter("animation_speed", animation_speed)
