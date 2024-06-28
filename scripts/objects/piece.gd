extends Node3D

const ANIM_SPEED = 10
const HOR_SPEED = 5
const VER_SPEED = 5

var current_frame = 0
var collected = false
var random_sound = 0

func _ready():
	$piece_sprite.frame_coords.y = Global.pieces[get_parent().get_node(str(self.name)).get_index()]
	if Global.gen<=2 || Global.current_character==2 || Global.piece_log.has(Global.room_name) && Global.piece_log[Global.room_name].has(get_parent().get_node(str(self.name)).get_index()):
		self.get_child(0).queue_free()
		visible=false

func _process(delta):
	if visible:
		current_frame+=ANIM_SPEED*delta
	if current_frame>20:
		current_frame=0
	$piece_sprite.frame_coords.x=current_frame
	
	if collected:
		if position.y<10:
			position+= Vector3(0.,VER_SPEED*delta,HOR_SPEED*delta)
		else:
			self.set_process(PROCESS_MODE_DISABLED)
			visible=false


func _on_piece_area_body_entered(body):
	if body==get_tree().get_first_node_in_group("Player"):
		collected=true
		random_sound = randi_range(0,2)
		Global.pieces_amount+=1
		if Global.piece_log.has(Global.room_name):
			Global.piece_log[Global.room_name].push_back(get_parent().get_node(str(self.name)).get_index())
		else:
			if Global.room_name!="":
				Global.piece_log[Global.room_name] = [get_parent().get_node(str(self.name)).get_index()]
		if random_sound==0:
			$piece_sound1.play()
		if random_sound==1:
			$piece_sound2.play()
		if random_sound==2:
			$piece_sound3.play()
