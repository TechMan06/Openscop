extends CharacterBody3D

#MASSIVE SHOUTOUT TO POEDEV


# MOVEMENT VARIABLES

var movement_speed = 5.0
const ACCELERATION = 8

@export_category("Recording Playback Properties")
@export var recording_file = ""
@export var delay = 0.0
@export var destroy_after_end = false
@export var invisible_until_playback = false
@export var loop = false
@export var main_recording_folder = true
@export var use_cue = false
@export var use_recording_character = false
@export var use_recording_position = true

var player_array = Vector4()
var key = false
#CURRENT PLAYER OBJECT
@export_category("Character Properties")
@export var character = 0
@export var head_sheet: CompressedTexture2D
@export var character_sheet: CompressedTexture2D
@export var marvin_speed = false
@export var flip_input = false
@export var flip_x_input = false
@export var retrace_steps = false
@export var animation_direction = 0
@export_category("Misc. Variables")
@export var is_walking = false
var v = 0.0
var h = 0.0
var current_footstep = 0
@export var brightness = 1.0

#RECORDING VARIABLES:
var recording_data = {}
var recording_timer = 0
var replay = false
var replay_setup = false
var recording_finished = false
var recording_reader_p1 = 0
var recording_reader_p2 = 0
@export var input_sim_action = false
var input_sim_select = false
var recordings = []
#ANIMATION PROPERTIES
var first_frame = false
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 1.5

var current_frame = 0

#P2TOTALK RELATED VARIABLES AND OBJECTS
var prev_text = ""
var word = ""
var last_press = ""
var can_submit = true
@onready var p2_talk = get_node("p2_talk_buttons")
@onready var p2_talk_word = preload("res://scenes/objects/setup/player/p2_talk_word.tscn")


#PLAYER SPRITE RELATED OBJECTS
@onready var material = get_node("sprite")
@onready var head = get_node("sprite/head")

#FOOTSTEP RELATED OBJECTS
@onready var footstep_controller = get_node("footstep_controller")
@onready var footstep_sound = get_node("footstep")
@onready var player_camera = get_tree().get_first_node_in_group("Player_camera")

func allow_typing():
	can_submit=true

#CODE THAT CHANGES FOOTSTEP SOUND
func change_sound(sound):
	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load(sound)
#PHYSICS PROCESS

func _ready():
	if recording_file=="":
		for file in DirAccess.get_files_at("user://recordings/"):
			recordings.append(file)
		if recordings!=[]:
			recording_file = recordings.pick_random().trim_suffix(".rec")
	
	material.frame_coords = Vector2(animation_direction, 0)
	add_collision_exception_with(get_tree().get_first_node_in_group("Player"))
	current_footstep = get_tree().get_first_node_in_group("Player").current_footstep
	recording_timer = 0
	
	if recording_file!="":
		if main_recording_folder:
			recording_data = JSON.parse_string((FileAccess.open("user://recordings/"+recording_file+".rec",FileAccess.READ)).get_as_text())
		else:
			recording_data = JSON.parse_string((FileAccess.open("user://player_recordings/"+recording_file+".rec",FileAccess.READ)).get_as_text())
		Console.console_log("[color=green]Loading Player Playback Data from Recording...[/color]")
		retrace_steps = recording_data["save_data"]["game"]["retrace_steps"]
		player_array = Vector4(recording_data["save_data"]["player"]["coords"][0],recording_data["save_data"]["player"]["coords"][1],recording_data["save_data"]["player"]["coords"][2],recording_data["save_data"]["player"]["coords"][3])
		brightness = recording_data["save_data"]["player"]["brightness"]
		key = recording_data["save_data"]["player"]["key"]
		if use_recording_character:
			character = recording_data["save_data"]["player"]["character"]
		Console.console_log("[color=blue]Loaded Player Playback Data from Recording sucessfully![/color]")
	else:
		queue_free()
	
	if !use_recording_character:
		if head_sheet==null:
			if character_sheet==null:
				if character==0:
					if Global.gen<=2:
						material.texture = load("res://graphics/sprites/player/gen_1.png")
					else:
						material.texture = load("res://graphics/sprites/player/guardian.png")
				if character==1:
					material.texture = load("res://graphics/sprites/player/belle.png")
				if character==2:
					material.texture = load("res://graphics/sprites/player/marvin.png")
			else:
				material.texture = character_sheet
		else:
			material.texture = load("res://graphics/sprites/player/headless.png")
			head.texture = head_sheet
			head.get_material_override().set_shader_parameter("albedoTex", head.texture)
		if marvin_speed or character==2:
			movement_speed = 6.0
		else:
			movement_speed = 5.0
	
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	if use_recording_position:
		position = Vector3(player_array.x,player_array.y,player_array.z)

	animation_direction = int(player_array.w)
	if retrace_steps or flip_input:
		movement_speed = movement_speed*-1
	material.texture = material.get_material_override().get_shader_parameter("albedoTex")
	if material.hframes!= material.texture.get_size().x/64:
		material.hframes = material.texture.get_size().x/64
		material.vframes = material.texture.get_size().y/64
	if Global.gen<=2:
		set_collision_mask(0)

	if use_cue && invisible_until_playback or invisible_until_playback:
		visible = false
	
	if delay!=0.0:
		$recording_wait.wait_time = delay
		$recording_wait.start()
	else:
		if !use_cue:
			replay = true


#TO-DO: ORGANIZE PROPERLY
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_end"):
		visible = true
		replay = true
	
	if replay:
		if !replay_setup:
			recording_finished = false
			recording_timer = 0
			Console.console_log("[color=green]Loading Player Recording Data...[/color]")
			replay_setup = true
		if replay_setup:
			recording_timer+=1
		if recording_data["p1_data"].find(str(recording_timer)+"_END")!=-1:
			Console.console_log("[color=red]RECORDING IS OVER[/color]")
			if destroy_after_end:
				queue_free()
			replay = false
			replay_setup = false
			recording_timer = 0
			recording_reader_p1 = 0
			recording_reader_p2 = 0
			if loop:
				if delay!=0.0:
					$recording_wait.start()
				else:
					replay = true
		else:
			#UP,DOWN,LEFT,RIGHT,Crs
			if recording_reader_p1<=recording_data["p1_data"].size()-1:
				if recording_timer==int((recording_data["p1_data"][recording_reader_p1].split("_"))[0]):
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[5])!=0:
						v = -1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[5]))
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[6])!=0:
						v = 1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[6]))
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[7])!=0:
						if flip_x_input:
							h = 1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[7]))
						else:
							h = -1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[7]))
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[8])!=0:	
						if flip_x_input:
							h = -1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[8]))
						else:
							h = 1.0*number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[8]))
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[9])!=0:	
						await get_tree().process_frame
						input_sim_action = true
						await get_tree().process_frame
						input_sim_action = false
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[13])!=0:	
						await get_tree().process_frame
						input_sim_select = true
						await get_tree().process_frame
						input_sim_select = false
					recording_reader_p1+=1
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p1_data"][recording_reader_p1]+" Index: "+str(recording_reader_p1)+"[/color]")
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE/UNUSED[/color]")
	
			if recording_reader_p2<=recording_data["p2_data"].size()-1:
				if recording_timer==int((recording_data["p2_data"][recording_reader_p2].split("_"))[0]):
					word = (recording_data["p2_data"][recording_reader_p2].split("_"))[1]
					$p2_talk_buttons.text = (recording_data["p2_data"][recording_reader_p2].split("_"))[2]
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p2_data"][recording_reader_p2]+" Index: "+str(recording_reader_p2)+"[/color]")
					recording_reader_p2+=1
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE[/color]")
	
	#DETECTS IF PLAYER IS WALKING BEFORE ANIMATING AND MAKE FOOTSTEP SOUND
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		if material.hframes>1 && material.vframes>1:
			if !footstep_sound.playing:
				if footstep_sound.stream_paused:
					footstep_sound.stream_paused=false
				else:
					footstep_sound.playing=true
			create_tween().tween_property(footstep_sound,"volume_db",80.0,0.5)
		is_walking=true
		#DETECTS IF PLAYER IS ON FLOOR OR Y0, DEFINES SURFACE TYPE AND SETS FOOTSTEP SOUND
		if is_on_floor() || position.y==0.0:
			#CHECKS IF BELOW PLAYER THERE'S MESH WITH THESE NAMES
			if footstep_controller.get_collider()!=null:
				if str(footstep_controller.get_collider().name)=="grass":
					current_footstep=1
				if str(footstep_controller.get_collider().name)=="evencare":
					current_footstep=0
				if str(footstep_controller.get_collider().name)=="cement":
					current_footstep=2
				if str(footstep_controller.get_collider().name)=="cement2":
					current_footstep=3
				if str(footstep_controller.get_collider().name)=="cement3":
					current_footstep=4
				if str(footstep_controller.get_collider().name)=="school":
					current_footstep=5
				if str(footstep_controller.get_collider().name)=="sand":
					current_footstep=6
	else:
		#IF SPEED NOT FASTER THAN 0.2, DISABLE WALKING ANIM
		is_walking=false
	
	if current_footstep==0:
		change_sound("res://sfx/player/ec_steps.wav")
	if current_footstep==1:
		change_sound("res://sfx/player/grass.wav")
	if current_footstep==2:
		change_sound("res://sfx/player/cement.wav")
	if current_footstep==3:
		change_sound("res://sfx/player/cement2.wav")
	if current_footstep==4:
		change_sound("res://sfx/player/cement3.wav")
	if current_footstep==5:
		change_sound("res://sfx/player/school_steps.wav")
	if current_footstep==6:
		change_sound("res://sfx/player/sand_steps.wav")
		
	if footstep_sound.volume_db<-79.0:
		footstep_sound.stream_paused=true
		
	#REGULATES PLAYER SPEED SO IT DOESNT GO FASTER WHEN WALKING ON DIAGONALS
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude

	#SETS PLAYER VELOCITY ACCORDING TO VECTOR
	if character==2:
		velocity.x = lerp(velocity.x,h*-1*movement_speed,(delta)*ACCELERATION)
	else:
		velocity.x = lerp(velocity.x,h*movement_speed,(delta)*ACCELERATION)
	velocity.z = lerp(velocity.z,v*movement_speed,(delta)*ACCELERATION)



	if velocity.x<0.01 && velocity.x>-0.01:
		velocity.x=0.
	if velocity.z<0.01 && velocity.z>-0.01:
		velocity.z=0.
	
	#CHANGES PLAYER SPRITE DEPENDING ON DIRECTION
	if material.hframes>1 && material.vframes>1:
		if v > 0:
			animation_direction=0
		elif v < 0:
			animation_direction=3

		if h < 0:
			animation_direction=2-(int(character==2))
		elif h > 0:
			animation_direction=1+(int(character==2))
			
	
	#DOES HEAD BOPPING
	if material.frame_coords.y==2 || material.frame_coords.y==4:
		head.offset.y=39
	else:
		head.offset.y=35
	if animation_direction==4:
		head.offset.y=36
	if animation_direction==2 || animation_direction==3:
		head.flip_h=true
	else:
		head.flip_h=false
	
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
	#if not is_on_floor():
		#velocity.y -= gravity * delta

#SUBMIT P2TOTALK WORD
	if input_sim_select && p2_talk.text!="" && can_submit:
		if word!="":
			word = word.erase(word.length()-1,1)
		create_word()
		word = ""
		last_press = ""
		p2_talk.text = ""
		can_submit = false

#MOVES THE PLAYER
	move_and_slide()

#IF PLAYER IS NOT WALKING
	if material.hframes>1 && material.vframes>1:
		if is_walking==false:
			material.frame_coords = Vector2(animation_direction, 0)
			current_frame=0
			create_tween().tween_property(footstep_sound,"volume_db",-80.0,0.5)
			#footstep_sound.stop()
		else:
			if current_frame==0:
				create_tween().tween_property(footstep_sound,"volume_db",-80.0,0.5)
			#IF PLAYER IS WALKING
			head.frame_coords= Vector2(0,0)
			material.vframes = int(material.texture.get_size().y)/(int(material.texture.get_size().x)/material.hframes) # animations
			current_frame+=ANIMATION_SPEED*delta
			if current_frame>material.vframes:
				current_frame=1
		#UPDATE FRAMES
		material.frame_coords = Vector2(animation_direction, floor(current_frame))
	else:
		material.frame_coords = Vector2.ZERO

	if prev_text!=p2_talk.text && p2_talk.text!="":
		get_node("button_press").play()
		prev_text=p2_talk.text


#PROCESSES INPUTS SUBMITTED, CHECKS TABLE, AND SPAWNS FLOATING WORD
func create_word():
	#CREATES OBJECT OF FLOATING WORD
	var word_instance = p2_talk_word.instantiate()
	#CHECKS P2TOTALK TABLE AND SETS THE TEXT OF FLOATING WORD TO VALUE RETURNED
	#BY FUNCTION
	word_instance.text = Global.get_p2_word(word.rstrip(" "))
	#SPAWNS P2TOTALK WORD
	get_node("p2_talk_buttons/P2_talk").add_child(word_instance)
	
	#RESPONSIBLE FOR "CASCADE" EFFECT WHEN THERES MORE THAN 1 P2TALKWORD
	#ALSO RESPONSIBLE FOR ANIMATING THEM RISING
	var child_index = 0
	for words in get_node("p2_talk_buttons/P2_talk").get_children():
		if child_index!=get_node("p2_talk_buttons/P2_talk").get_child_count()-1:
			create_tween().tween_property(words, "position", Vector3(0, 0.5, 0), 1.0).set_trans(Tween.TRANS_LINEAR).as_relative()
		else:
			var tween = create_tween()
			tween.tween_property(words, "position", Vector3(0, 1.0, 0), 1.0).set_trans(Tween.TRANS_LINEAR).as_relative()
			tween.tween_callback(allow_typing)
		child_index+=1
		
func number_parser(number):
	if number==1:
		return 1.0
	if number==2:
		return 0.0

func _on_recording_wait_timeout():
	replay = true
	visible = true
