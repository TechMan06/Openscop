extends Area3D
class_name PianoClone

var player: Player
var offset: Vector3
var current_tile: int
var max_keys: int
var key_space: float
var piano_pos: Vector3

@onready var clone_sprite = $CloneSprite


func _ready() -> void:
	clone_sprite.texture = player._sprite.texture
	clone_sprite.set_material_override(player._sprite.get_material_override())
	clone_sprite.offset = player._sprite.offset
	clone_sprite.hframes = player._sprite.hframes
	clone_sprite.vframes = player._sprite.vframes
	current_tile = ((global_position.x + 0.5) - self.global_position.x) / key_space


func _physics_process(_delta: float) -> void:
	current_tile = ((piano_pos.x + 0.5) - self.global_position.x) / key_space
	global_position = player.global_position + offset
	
	
	if current_tile < max_keys and global_position.x < (piano_pos.x + 0.5):
		visible = true
		clone_sprite.frame = player._sprite.frame
	else:
		visible = false


func deactivate() -> void:
	queue_free()
