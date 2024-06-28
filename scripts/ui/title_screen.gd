extends Node3D

@export var title_stage = 0

var timer:int = 0
const READING_CARD_WAIT = 2.5


var file_data = {}
var fade_color = 0

var selected_file = 0
var cont_option = true
var recording_files = DirAccess.get_files_at("user://recordings/")
var allowed_recordings = []

@onready var start_button = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/press_start
@onready var logo = $title_root/title_mesh_root/title_mesh
@onready var menu_1 = $PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1
func _ready():
	get_tree().paused = false
	Global.game_paused = false
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/buttons_group/GoBack.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/buttons_group/ChangeUsername.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/buttons_group/Continue.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/buttons_group2/Finish.play()
	$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/buttons_group2/Select.play()
	$song.play()
	for file in recording_files:
		if (JSON.parse_string((FileAccess.open(("user://recordings/"+file),FileAccess.READ)).get_as_text()))["recording_info"]["rotation"]:
			allowed_recordings.append(file)
		
func _physics_process(_delta):
	timer += 1
	if timer == 30:
		timer = 0
	start_button.visible = bool(int(timer < 24) * int(title_stage==0))
	
	if Input.is_action_just_pressed("pressed_start") && title_stage==0:
		$pressed_start.play()
		selected_file=0
		start_button.frame_coords.y = 1
		$reading_card_timer.wait_time = READING_CARD_WAIT+randf_range(0.0,2.0)
		$reading_card_timer.start()
		await $reading_card_timer.timeout
		create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/Copyright,"position:x",-224.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property(start_button,"position:x",-224.0,1.0).set_trans(Tween.TRANS_BACK)
		create_tween().tween_property($title_root,"position:x",3.5,1.0).set_trans(Tween.TRANS_BACK)
		var scale_logo = create_tween().set_parallel()
		scale_logo.tween_property(logo,"scale:y",0.75,0.5).set_trans(Tween.TRANS_SINE)
		scale_logo.tween_property(logo,"scale:x",1.25,0.5).set_trans(Tween.TRANS_SINE)
		await scale_logo.finished
		var scale_logo_2 = create_tween().set_parallel()
		scale_logo_2.tween_property(logo,"scale:y",1.5,0.25).set_trans(Tween.TRANS_SINE)
		scale_logo_2.tween_property(logo,"scale:x",0.25,0.25).set_trans(Tween.TRANS_SINE)
		$whistle.play()
		create_tween().tween_property(menu_1,"position:x",0.0,1.0).set_trans(Tween.TRANS_BACK)
		await scale_logo_2.finished
		title_stage=1
		
	if title_stage==1:
		if Input.is_action_just_pressed("pressed_square"):
			Global.create_keyboard(3,0,0)
			
		if Input.is_action_just_pressed("pressed_start"):
			create_tween().tween_property($PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/join_menu,"position:y",0.0,0.5)
			title_stage = 2
			
		if Global.keyboard_RAM!="":
			Global.user_name=Global.keyboard_RAM
			Global.keyboard_RAM=""
			$PSXLayer/NTSC/NTSC_viewport/Dither/dither_view/no_filter_view/no_filter_view/menu_1/user_card/user_name.text = Global.user_name
	
	#
	if Input.is_action_just_pressed("ui_end"):
		Network.host()
	if title_stage==2:
		if Input.is_action_just_pressed("pressed_action"):
			Network.join()
			Global.warp_to("res://scenes/rooms/levels/level1/room1.tscn","evencare")
		
