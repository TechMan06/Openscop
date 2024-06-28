extends CharacterBody3D

#COMMENT

# MOVEMENT VARIABLES

@export var movement_speed = 5
const ACCELERATION = 8
@export var is_walking = false
@export	var v = 0.0
@export	var h = 0.0
@export var current_footstep = 0
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#ANIMATION PROPERTIES
@export var first_frame = false
@export var animation_speed = 8
const ANIMATION_THRESHOLD = 1.5
@export var animation_direction = 0
var current_frame = 0

#P2TOTALK RELATED VARIABLES AND OBJECTS
var prev_text = ""
@export var word = ""
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

#CODE THAT CHANGES FOOTSTEP SOUND
func change_sound(sound):
	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load(sound)
#PHYSICS PROCESS

func _ready():
	position = Vector3(Global.player_array.x,Global.player_array.y,Global.player_array.z)
	player_camera.position=position
	animation_direction = int(Global.player_array.w)
	material.texture = material.get_material_override().get_shader_parameter("albedoTex")

func on_floor():
	if not is_on_floor():
		if position.y>0.1:
			return false
		else:
			return true
	else:
		return true

#TO-DO: ORGANIZE PROPERLY
func _physics_process(delta):
	material.get_material_override().set_shader_parameter("modulate_color",Vector4(Global.player_brightness,Global.player_brightness,Global.player_brightness,1.0))
	#VARIABLE DEFINES IF FOG SHOULD FOLLOW PLAYER OR NOT
	#WILL BE USED LATER ON FOR THINGS LIKE WINDMILL EVENT AND BASEMENT MACHINE
	#USELESS FOR NOW
	var direction = Vector3()
	#CONTROL MODE 0: CONTROL PLAYER NORMALLY
	
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
		if on_floor():
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
	
	if Global.control_mode==0:
		#SETS PLAYER VELOCITY ACCORDING TO VECTOR
		if Global.current_character==2:
			velocity.x = lerp(velocity.x,h*-1*movement_speed,(delta)*ACCELERATION)
		else:
			velocity.x = lerp(velocity.x,h*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,v*movement_speed,(delta)*ACCELERATION)
	else:
		velocity.x = lerp(velocity.x,0.*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,0.*movement_speed,(delta)*ACCELERATION)
		
	if Global.control_mode==4:
		rotate_y(deg_to_rad(-h*10))
		direction.x = v
		direction = direction.rotated(Vector3(0,1,0),rotation.y)
		velocity.z = direction.z*(movement_speed*-1)
		velocity.x = direction.x*(movement_speed*-1)
		
	if Global.control_mode!=4 && Global.control_mode!=5:
		rotation.y=0


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
			animation_direction=2-(int(Global.current_character==2))
		elif h > 0:
			animation_direction=1+(int(Global.current_character==2))
			
	
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
			current_frame+=animation_speed*delta
			if current_frame>material.vframes:
				current_frame=1
		#UPDATE FRAMES
		material.frame_coords = Vector2(animation_direction, floor(current_frame))
	else:
		material.frame_coords = Vector2.ZERO


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
		child_index+=1
