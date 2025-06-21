@tool
@icon("res://icon/piece.png")
extends Area3D
class_name Piece

const PIECE_SEED: int = 26
const ANIM_SPEED: int = 10
const HOR_SPEED: int = 5
const VER_SPEED: int = 5

var global_data: GlobalData = load("res://resource/management/global_data.tres")
var current_frame: int = 0
var collected: bool = false
var room_name: String = ""
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

@onready var room: Level
@onready var piece_id: int = get_tree().get_nodes_in_group("piece").find(self)
@onready var piece_sprite = $PieceSprite
@onready var piece_collision = $PieceCollision
@onready var piece_sound = $PieceSound


func _ready() -> void:
	if !Engine.is_editor_hint():
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		
		rng.set_seed(PIECE_SEED)
		
		room = get_tree().get_current_scene()
		
		room_name = room.room_name
		
		if (
				Global.global_data.gen < 4 and 
				room.hardcoded_properties == room.HardcodedProperties.EVEN_CARE and
				room.odd_care_room_on_gen_3
			):
			room_name = room.room_name.replace("level1", "odd")
		
		if Global.global_data.gen < 3:
			queue_free()
		
		if type_array[piece_id] != null:
			piece_sprite.frame_coords.y = type_array[piece_id]
		else:
			piece_sprite.frame_coords.y = rng.randi_range(0, 4)
		
		if SaveManager.get_data().piece_log.has(room_name):
			if SaveManager.get_data().piece_log[room_name].find(piece_id) != -1:
				self.queue_free()
		
		if SaveManager.get_data().player_data.character_id == 2:
			self.queue_free()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if type_array[get_tree().get_nodes_in_group("piece").find(self)] != null:
			$PieceSprite.frame_coords.y = type_array[get_tree().get_nodes_in_group("piece").find(self)]
		else:
			$PieceSprite.frame_coords.y = 0


func _on_body_entered(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		if body is Player:
			piece_sound.play()
			
			if SaveManager.get_data().piece_log.has(room_name):
				SaveManager.get_data().piece_log[room_name].push_back(piece_id)
			elif room_name != "" || room_name.rstrip(" ") != "":
				SaveManager.get_data().piece_log[room_name] = [piece_id]
			
			body.player_stats.piece_amount += 1
			
			HUD.update_counter()
			HUD.show_counter()
			
			piece_collision.queue_free()
			
			var _collected_anim: Tween = create_tween()
			
			_collected_anim.tween_property(self, "position", Vector3(0., 10., 10.), 2.).as_relative()
			
			await _collected_anim.finished
			
			visible = false
