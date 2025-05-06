@tool
@icon("res://icon/pet.png")
extends Marker3D
class_name Pet

signal caught

const CAUGHT_SCENE: PackedScene = preload("res://scene/management/caught.tscn")

@export_category("General Settings")
@export var pet_name: String
@export var cry_sound_file: AudioStream
@export var pet_sprite: Texture2D
@export var disable_collection: bool = false
@export var hitbox_size: float = 1.0
@export var was_caught: bool = false
@export_category("Sprite Settings")
@export var sprite_size: float = 0.03:
	set(value):
		sprite_size = value
		
		$PetSprite.pixel_size = value

@export var frames: Vector2 = Vector2i(1, 1):
	set(value):
		frames = value
		
		if Engine.is_editor_hint():
			_update_frames()

@export var sprite_offset: Vector2 = Vector2i.ZERO:
	set(value):
		sprite_offset = value
		
		if Engine.is_editor_hint():
			_update_frames()

@export var frame_coords: Vector2 = Vector2.ZERO:
	set(value):
		frame_coords = value
		pet_sprite3d.frame_coords = value

@export var animate: bool = false:
	set(value):
		animate = value
		
		if Engine.is_editor_hint():
			_update_animation()

@export var animation_speed: Vector2 = Vector2.ZERO:
	set(value):
		animation_speed = value
		
		if Engine.is_editor_hint():
			_update_anim_speed()

@onready var pet_sprite3d: Sprite3D = $PetSprite
@onready var pet_area: Area3D = $PetArea
@onready var cry_sound: AudioStreamPlayer3D = $Cry


func _ready() -> void:
	if !Engine.is_editor_hint():
		pet_sprite3d.pixel_size = sprite_size
		pet_sprite3d.set_texture(pet_sprite)
		pet_sprite3d.get_material_override().set_shader_parameter("albedoTex", pet_sprite3d.texture)
		cry_sound.set_stream(cry_sound_file)
		
		_update_frames()
		_update_animation()
		_update_anim_speed()
		
		$PetArea/PetCollision.get_shape().size = Vector3(hitbox_size, hitbox_size, hitbox_size)
		
		if SaveManager.get_data().pet.find(pet_name) != -1:
			queue_free()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$PetSprite.set_texture(pet_sprite)
		$PetSprite.get_material_override().set_shader_parameter("albedoTex", pet_sprite3d.texture)
		_update_frames()


func _on_pet_area_body_entered(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		if body is Entity && !disable_collection:
			caught.emit()
			was_caught = true
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


func _on_caught_timer_timeout() -> void:
	var _caught_instance: Marker2D = CAUGHT_SCENE.instantiate()
	add_child(_caught_instance)


func _update_frames() -> void:
	if frames.x > 1:
		$PetSprite.hframes = float(frames.x)
	
	if frames.y > 1:
		$PetSprite.vframes = float(frames.y)
	
	$PetSprite.offset = sprite_offset
	
	$PetSprite.get_material_override().set_shader_parameter(
																"animation_frames", 
																Vector2(
																			pet_sprite3d.hframes, 
																			pet_sprite3d.vframes
																		)
															)


func _update_animation() -> void:
	$PetSprite.get_material_override().set_shader_parameter("animate", animate)


func _update_anim_speed() -> void:
	$PetSprite.get_material_override().set_shader_parameter("animation_speed", animation_speed)
