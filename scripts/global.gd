extends Node


#LOCAL VARS
#GLOBAL GAME VARS
var allow_walking = true
var debug = false
var keyboard_RAM=""
var picked_slot = 0
#ROOM
var room_name =""
var loading_preset = ""
var fog_radius = 13.5
var fog_color = Vector4(0.0,0.0,0.0,0.0)

#CAMERA
var camera_mode = 0
var camera_limit_x = 2
var camera_limit_z = 2
var camera_limit_y = 4
var camera_rot = -18
var camera_dist_hor = 12
var camera_dist_ver = 4
var camera_move_x = true
var camera_move_y = true
var camera_move_z = true
var camera_freeze_x =  0.0
var camera_freeze_y = 0.0
var camera_freeze_z = 0.0
var camera_root_dist_ver = 0.0
var cam_move_limit_x = Vector2.ZERO
var cam_move_limit_y = Vector2.ZERO
var cam_move_limit_z = Vector2.ZERO
#GAME
var control_mode = 0
#0 = normal controls
#1 = P2toTALK
#2 = Retrace steps.
#3 = Empty slot.
#4 = School
#5 = Green Tool
var game_paused = false
var can_pause = true
var user_name = ""

#SAVEDATA
var gen = 8
var current_character = 0
# 0 = guardian
# 1 = Belle
# 2 = Marvin
var pieces_amount = 0
var piece_log = {
}

var player_array = Vector4(0.,0.,0.,0)
var player_brightness = 1.0
var pets = [true,false,false,false,false,false,false,false,false,false]
var fog_focus = 0
#0 = follow player
#

#P2TALKDICT
var p2talkdict = {}

#DIALOGUE
var dialogue = {}

#LEVEL LOADING DATA
var level_data = {}

#PIECE_ARRAY
var pieces = [0,1,2,3,4,
			4,0,2,1,3,
			4,2,3,1,0,
			2,3,1,4,0,
			1,4,3,0,2,
			1,0,3,2,4,
			2,3,1,0,4,
			2,1,0,3,4,
			3,1,0,4,2,
			1,0,4,2,3]
#0 = CONE
#1 = TORUS
#2 = GREEN "SPHERE"
#3 = TRIANGLE
#4 = PINK PIECE

#MULTIPLAYER DATA
var players = {}

func _ready():
	var directory = DirAccess.open("user://")
	#GAME BOOTUP
	#CHECKS IF CUSTOM SHEETS DIRECTORY DOESNT EXIST SO IT CAN CREATE IT
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	if !directory.dir_exists("screenshots"):
		directory.make_dir("screenshots")
	
	
	#LOADS P2TOTALK DICTIONARY
	p2talkdict = JSON.parse_string((FileAccess.open("res://scripts/p2_talk_data.json", FileAccess.READ)).get_as_text())
	dialogue = JSON.parse_string((FileAccess.open("res://scripts/dialogue.json", FileAccess.READ)).get_as_text())
	level_data = JSON.parse_string((FileAccess.open("res://scripts/level_data.json", FileAccess.READ)).get_as_text())
#FUNCTION THAT CHECKS P2TOTALK DICTIONARY TABLE, CALLED EVERY TIME P2TOTALK IS USED
func get_p2_word(word):
	if p2talkdict.find_key(word)!=null:
		if word=="OW K EY":
			return "OK"
		else:
			return str(p2talkdict.find_key(word)).to_lower().capitalize().replace ("1","").replace ("2","").replace ("3","").replace ("4","").replace ("5","").replace ("6","").replace ("7","").replace ("8","").replace ("9","")
	else:
		return "Not in Table"
		
func create_textbox(background,big_textbox,text):
	var textbox_scene = preload("res://scenes/objects/setup/player/textbox_object.tscn")
	var dialogue_instance = textbox_scene.instantiate()
	dialogue_instance.background = background
	dialogue_instance.text = text
	dialogue_instance.big = big_textbox
	if get_tree().get_first_node_in_group("HUD_textboxes").get_child_count()<2:
		get_tree().get_first_node_in_group("HUD_textboxes").get_child(0).add_child(dialogue_instance)

func warp_to(scene,preset: String = "evencare"):
	if get_tree().get_first_node_in_group("loading_overlay").get_child(0).color.a==0.0:
		can_pause=false
		if preset!="":
			get_tree().get_first_node_in_group("loading_overlay").get_child(0).color=Color(level_data[preset]["fade_color"][0],level_data[preset]["fade_color"][1],level_data[preset]["fade_color"][2],0.)
		else:
			get_tree().get_first_node_in_group("loading_overlay").get_child(0).color=Color(level_data["evencare"]["fade_color"][0],level_data["evencare"]["fade_color"][1],level_data["evencare"]["fade_color"][2],0.)
		var fade_in = create_tween()
		fade_in.tween_property(get_tree().get_first_node_in_group("loading_overlay").get_child(0),"color:a",1.0,0.5)
		await fade_in.finished
		game_paused = true
		if preset!="":
			if level_data[preset]["loading_file"]!=null:
				bg_music.stop()
				get_tree().get_first_node_in_group("loading_overlay").get_child(1).set_texture(load("res://graphics/sprites/ui/loading_screen/"+level_data[preset]["loading_file"]+".png"))
		else:
			bg_music.stop()
			get_tree().get_first_node_in_group("loading_overlay").get_child(1).set_texture(load("res://graphics/sprites/ui/loading_screen/"+level_data["evencare"]["loading_file"]+".png"))
		if preset!="":
			get_tree().get_first_node_in_group("loading_overlay").get_child(2).wait_time =float(level_data[preset]["wait_time"])+randf_range(0.,float(level_data[preset]["wait_time"])/4)
		else:
			get_tree().get_first_node_in_group("loading_overlay").get_child(2).wait_time =float(level_data["evencare"]["wait_time"])+randf_range(0.,float(level_data["evencare"]["wait_time"])/4)
		get_tree().get_first_node_in_group("loading_overlay").get_child(2).start()
		await get_tree().get_first_node_in_group("loading_overlay").get_child(2).timeout
		get_tree().change_scene_to_file(scene)

func create_keyboard(background,ask,fade):
	var keyboard_scene = preload("res://scenes/objects/menu/keyboard.tscn")
	var keyboard_instance = keyboard_scene.instantiate()
	keyboard_instance.background = background
	keyboard_instance.ask = ask
	keyboard_instance.has_fade = fade
	if get_tree().get_first_node_in_group("HUD_keyboard").get_child_count()<1:
		get_tree().get_first_node_in_group("HUD_keyboard").add_child(keyboard_instance)
		can_pause=false
		
func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)
	
func caught(id:int = -1,pet:Node = null,pet_origin:Node = null,disable_rotation: bool = false):
	if get_tree().get_first_node_in_group("HUD_caught").get_child_count()==0:
		get_tree().get_first_node_in_group("HUD_caught").add_child(preload("res://scenes/HUD/caught.tscn").instantiate())
	if id!=-1:
		pets[id]=true
	if pet!=null:
		pet.set_billboard_mode(0)
		if !disable_rotation:
			pet.get_material_override().set_shader_parameter("billboard",false)
		var shrink_animator = create_tween().set_parallel()
		shrink_animator.tween_property(pet,"scale",Vector3.ZERO,2.5)
		var original_offset = pet.offset.y
		shrink_animator.tween_property(pet,"offset:y",original_offset*2,2.5).set_trans(Tween.TRANS_LINEAR)
		if !disable_rotation:
			shrink_animator.tween_property(pet,"rotation:y",deg_to_rad(360),2.5)
		await shrink_animator.finished
		if pet_origin!=null:
			pet_origin.queue_free()
			
func nifty():
	can_pause=false
	get_tree().get_first_node_in_group("Nifty").visible=true
	bg_music.pause()
