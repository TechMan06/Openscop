extends Marker3D
class_name Pen

signal caught

const ANIM_SPEED: float = 0.125
const CAUGHT_SCENE: PackedScene = preload("res://scene/management/caught.tscn")

var key_space: float
var current_tile: int

@export var pet_name: String = "pen"
@export var cry_sound: AudioStream = load("res://sfx/pets/pen_cry.wav")
@export var was_caught: bool = false
@export var piano: PenPiano
@export_range(0, 25) var pen_start_position: int = 0

@onready var pen_sprite: AnimatedSprite3D = $PenSprite
@onready var cry: AudioStreamPlayer3D = $Cry


func _ready() -> void:
	if piano != null:
		await piano.piano_ready
		
		setup_position(piano.keys.get_child(pen_start_position).global_position)

	if SaveManager.get_data().pet.find(pet_name) != -1:
		queue_free()
	
	key_space = piano.KEY_SPACE
	
	cry.set_stream(cry_sound)
	


func setup_position(new_position: Vector3) -> void:
	global_position = new_position
	current_tile = ((piano.global_position.x + 0.5) - self.global_position.x) / key_space


func update_position(new_position: Vector3) -> void:
	if !was_caught:
		global_position = new_position
		
		pen_sprite.rotation.y = deg_to_rad(180.0)
		
		pen_sprite.get_material_override().set_shader_parameter("billboard", false)
		
		var _reappear: Tween = create_tween()
		
		_reappear.tween_property(pen_sprite, "rotation:y", 0.0, ANIM_SPEED)
		
		await _reappear.finished
		
		pen_sprite.get_material_override().set_shader_parameter("billboard", true)
	
	current_tile = ((piano.global_position.x + 0.5) - self.global_position.x) / key_space


func _on_clone_collided(clone: Area3D) -> void:
	if clone is PianoClone:
		for single_clone in piano.clones.get_children():
			if single_clone.current_tile == current_tile:
				caught.emit()
				was_caught = true
				piano.pen = null
				piano.update_piano_keys(piano.current_tile)
				cry.play()
				
				if pen_sprite.get_material_override().get_shader_parameter("billboard"):
					pen_sprite.get_material_override().set_shader_parameter("billboard", false)
				
				$CaughtTimer.start()
				
				SaveManager._data.pet.append(pet_name)
				
				$PetArea.queue_free()
				
				var _shrink_animator: Tween = create_tween().set_parallel()
				
				_shrink_animator.tween_property(pen_sprite, "scale", Vector3.ZERO,2.5)
				
				var _original_offset: int = pen_sprite.offset.y
				
				_shrink_animator.tween_property(
													pen_sprite, 
													"offset:y", 
													_original_offset * 2, 
													2.5
												).set_trans(Tween.TRANS_LINEAR)
				
				_shrink_animator.tween_property(pen_sprite, "rotation:y", deg_to_rad(360), 2.5)


func _on_caught_timer_timeout():
	var _caught_instance: Marker2D = CAUGHT_SCENE.instantiate()
	add_child(_caught_instance)
