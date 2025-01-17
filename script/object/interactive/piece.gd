@icon("res://icon/piece.png")
extends Area3D
class_name Piece

const ANIM_SPEED: int = 10
const HOR_SPEED: int = 5
const VER_SPEED: int = 5

var global_data: GlobalData = load("res://resource/management/global_data.tres")
var current_frame: int = 0
var collected: bool = false
var type_array: Array[int] = [
								0,1,2,3,4,
								4,0,2,1,3,
								4,2,3,1,0,
								2,3,1,4,0,
								1,4,3,0,2,
								1,0,3,2,4,
								2,3,1,0,4,
								2,1,0,3,4,
								3,1,0,4,2,
								1,0,4,2,3
							]

@onready var piece_sprite = $PieceSprite
@onready var piece_collision = $PieceCollision
@onready var piece_sound = $PieceSound


func _ready() -> void:
	if Global.global_data.gen < 3:
		queue_free()
	
	if type_array[get_tree().get_nodes_in_group("piece").find(self)] != null:
		piece_sprite.frame_coords.y = type_array[get_tree().get_nodes_in_group("piece").find(self)]
	else:
		piece_sprite.frame_coords.y = randi_range(0, 4)
	
	await get_tree().process_frame
	
	EventBus.piece_spawned.emit(get_tree().get_nodes_in_group("piece").find(self))


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		piece_sound.play()
		
		EventBus.piece_collected.emit(get_tree().get_nodes_in_group("piece").find(self))
		
		body.player_stats.piece_amount += 1
		
		HUD.update_counter()
		HUD.show_counter()
		
		piece_collision.queue_free()
		
		var _collected_anim: Tween = create_tween()
		
		_collected_anim.tween_property(self, "position", Vector3(0., 10., 10.), 2.).as_relative()
		
		await _collected_anim.finished
		
		visible = false
