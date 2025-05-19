extends Node3D


const READING_CARD_WAIT = 2.5

var save_data: SaveData = SaveData.new()
var cont_option: bool = true
var logo_timer: float = 0
var timer: int = 0
var title_stage: int = 0
var selected_file: int = 0
var enable_selection: bool = true
var game_started: bool = false
var demos: Array[RecordingData]

@onready var logo_gift: Sprite3D = %LogoGift
@onready var start_button: Sprite2D = %StartButton
@onready var card_timer: Timer = $CardTimer
@onready var demo_timer: Timer = $DemoTimer
@onready var title: Marker2D = $Title
@onready var logo_origin: Marker3D = %LogoOrigin
@onready var file_select: Marker2D = %FileSelect
@onready var files: Marker2D = %Files
@onready var move_perm: Timer = %MovePermission
@onready var continue_btn: TextureRect = %Continue
@onready var color_overlay: ColorRect = %ColorOverlay
@onready var file_select_buttons: Marker2D = %FileSelectButtons
@onready var file_select_buttons_2: Marker2D = %FileSelectButtons2
@onready var logo_mesh: MeshInstance3D = %LogoMesh
@onready var road_mesh: MeshInstance3D = %RoadMesh


func _ready() -> void:
	var recording_list: PackedStringArray = DirAccess.get_files_at("user://recordings")
	var allowed_recordings: RecordingData
	
	for recording in recording_list:
		demos.append(load("user://recordings/" + recording))
	
	if demos != []:
		for demo in demos:
			if !demo.rotation:
				demos.erase(demo)
	
	if BGMusic.get_stream_path() != "res://music/petscop.ogg":
		BGMusic.stream_paused = true
	
	get_tree().paused = false
	Global.is_game_paused = false
	Global.can_pause = false
	continue_btn.position.y = -157
	$Continue/ContinueCursor.position = Vector2(137, 9)
	
	RenderingServer.global_shader_parameter_set("fog_enabled", true)
	RenderingServer.global_shader_parameter_set("fog_color", Vector3(1.0, 1.0, 1.0))
	RenderingServer.global_shader_parameter_set("fog_size", 25.0)
	
	check_files()
	
	$DemoTimer.wait_time = randi_range(60,10800)
	$DemoTimer.start()
	
	EventBus.finished_typing.connect(_on_file_created)


func _process(delta: float) -> void:
	timer += 1
	logo_timer += delta
	
	logo_mesh.rotation.z = -sin(1.5 * logo_timer * PI) * cos(logo_timer * PI / 5) * 0.25
	logo_mesh.rotation.y = -cos(1.5 * (logo_timer + 0.25) * PI) * sin(logo_timer * PI / 5) * 0.4
	logo_gift.rotation.z = cos(2.5 * logo_timer * PI) * 0.2
	
	road_mesh.position.x -= delta * 2

	if road_mesh.position.x <= -12:
		road_mesh.position.x += 12
	
	if timer == 30:
		timer = 0
	
	start_button.visible = bool(int(timer < 24) * int(title_stage == 0))
	
	if Input.is_action_just_pressed("pressed_start") && title_stage == 0:
		if start_button.frame_coords.y != 1:
			$PressedStart.play()
		
		selected_file = 0
		start_button.frame_coords.y = 1
		card_timer.wait_time = READING_CARD_WAIT + randf_range(0.0, 2.0)
		card_timer.start()
		#_check_files()
		
		await card_timer.timeout
		
		var logo_origin_pos: float = 3.921
		var logo_scale: float = logo_origin_pos - 3.5
		
		var logo_tween: Tween = create_tween().set_parallel()
		var logo_pos: int = 26
		var logo_scale_1: float = logo_scale * (logo_pos / 320.0)
		
		logo_tween.tween_property(title, "position:x", logo_pos, .25).set_trans(Tween.TRANS_SINE)
		logo_tween.tween_property(logo_mesh, "scale:x", 1.5, .25).set_trans(Tween.TRANS_SINE)
		logo_tween.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_1, .25).set_trans(Tween.TRANS_SINE)
		logo_tween.tween_property(file_select, "position:x", 320 + logo_pos, .25).set_trans(Tween.TRANS_SINE)
		
		await logo_tween.finished
		
		$Whistle.play()
		
		var logo_tween_2: Tween = create_tween().set_parallel()
		var logo_pos_2: int = -345
		var logo_scale_2: float = logo_scale * (logo_pos_2 / 320.0)
		
		create_tween().tween_property(logo_mesh, "scale:x", 0, .3).set_trans(Tween.TRANS_SINE)
		logo_tween_2.tween_property(title, "position:x", logo_pos_2, .5).set_trans(Tween.TRANS_SINE)
		logo_tween_2.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_2, .5).set_trans(Tween.TRANS_SINE)
		logo_tween_2.tween_property(file_select, "position:x", 320 + logo_pos_2, .5).set_trans(Tween.TRANS_SINE)
		
		await logo_tween_2.finished
		
		var logo_tween_3: Tween = create_tween().set_parallel()
		var logo_pos_3: int = -320
		var logo_scale_3: float = logo_scale * (logo_pos_3 / 320.0)
		
		logo_tween_3.tween_property(title, "position:x", logo_pos_3, .25).set_trans(Tween.TRANS_SINE)
		logo_tween_3.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_3, .25).set_trans(Tween.TRANS_SINE)
		logo_tween_3.tween_property(file_select, "position:x", 320 + logo_pos_3, .25).set_trans(Tween.TRANS_SINE)
		
		await logo_tween_3.finished
		
		title_stage = 1
	
	if title_stage == 1:
		for file in files.get_children():
			file.get_child(0).modulate = Color(1.0,1.0,1.0)
		
		if Input.is_action_just_pressed("pressed_down") && selected_file < 2 && enable_selection:
			select_file()
		
		if Input.is_action_just_pressed("pressed_up") && selected_file > 0 && enable_selection:
			select_file(true)
		
		if Input.is_action_just_pressed("pressed_action") && file_select.position.x == 0.0:
			if FileAccess.file_exists("user://savedata/save"+str(selected_file)+".tres"):
				title_stage = 2
				
				create_tween().tween_property(continue_btn, "position:y", 83.0, 0.5).set_trans(Tween.TRANS_SINE)
				
				var overlay_move: Tween = create_tween()
				
				overlay_move.tween_property(color_overlay, "color:a", 0.5, 0.5)
				
				await overlay_move.finished
				
				title_stage = 3
			else:
				title_stage = 4
				
				$FileSelected.play()
				
				HUD.create_keyboard(3, false, false, true)
				
				for file in files.get_children():
					if file.get_index() % 2 == 0:
						create_tween().tween_property(file, "position:x", -266., 0.45).set_trans(Tween.TRANS_SINE)
					else:
						create_tween().tween_property(file, "position:x", 334., 0.45).set_trans(Tween.TRANS_SINE)
						
				var button_tween: Tween = create_tween().set_parallel()
				button_tween.tween_property(file_select_buttons, "position:y", 50.0, 0.5).set_trans(Tween.TRANS_SINE)
				
				await button_tween.finished
				create_tween().tween_property(file_select_buttons_2, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
				
		if Input.is_action_just_pressed("pressed_triangle"):
			start_button.frame_coords.y = 0
			create_tween().tween_property(logo_origin, "position:x", 3.921, 1.).set_trans(Tween.TRANS_BACK)
			
			var logo_origin_pos: float = 3.921
			var logo_scale: float = logo_origin_pos - 3.5
		
			var logo_tween: Tween = create_tween().set_parallel()
			var logo_pos: int = -345
			var logo_scale_1: float = logo_scale * (logo_pos / 320.0)
		
			logo_tween.tween_property(title, "position:x", logo_pos, .25).set_trans(Tween.TRANS_SINE)
			logo_tween.tween_property(logo_mesh, "scale:x", 1.5, .25).set_trans(Tween.TRANS_SINE)
			logo_tween.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_1, .25).set_trans(Tween.TRANS_SINE)
			logo_tween.tween_property(file_select, "position:x", 320 + logo_pos, .25).set_trans(Tween.TRANS_SINE)
		
			await logo_tween.finished
		
			var logo_tween_2: Tween = create_tween().set_parallel()
			var logo_pos_2: int = 26
			var logo_scale_2: float = logo_scale * (logo_pos_2 / 320.0)
		
			logo_tween_2.tween_property(logo_mesh, "scale:x", 1, .5).set_trans(Tween.TRANS_SINE)
			logo_tween_2.tween_property(title, "position:x", logo_pos_2, .5).set_trans(Tween.TRANS_SINE)
			logo_tween_2.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_2, .5).set_trans(Tween.TRANS_SINE)
			logo_tween_2.tween_property(file_select, "position:x", 320 + logo_pos_2, .5).set_trans(Tween.TRANS_SINE)
		
			await logo_tween_2.finished
		
			var logo_tween_3: Tween = create_tween().set_parallel()
			var logo_pos_3: int = 0
			var logo_scale_3: float = logo_scale * (logo_pos_3 / 320.0)
		
			logo_tween_3.tween_property(title, "position:x", logo_pos_3, .25).set_trans(Tween.TRANS_SINE)
			logo_tween_3.tween_property(logo_origin, "position:x", logo_origin_pos + logo_scale_3, .25).set_trans(Tween.TRANS_SINE)
			logo_tween_3.tween_property(file_select, "position:x", 320 + logo_pos_3, .25).set_trans(Tween.TRANS_SINE)
			
			selected_file = 0
			
			for file in files.get_children():
				if file.get_index() == selected_file:
					file.get_node("Icon").visible = true
				else:
					file.get_node("Icon").visible = false
			
			title_stage = 0
	
	
	if title_stage == 3:
		if Input.is_action_just_pressed("pressed_triangle"):
			title_stage = 1
			
			create_tween().tween_property(color_overlay, "color:a", 0.0, 0.5)
			
			var _go_back: Tween = create_tween()
			
			_go_back.tween_property($Continue, "position:y", -240.0, 0.5)
			
			await _go_back.finished
			
			cont_option = true
		
		if Input.is_action_just_pressed("pressed_up"):
			cont_option = true
			
		if Input.is_action_just_pressed("pressed_down"):
			cont_option = false

		if Input.is_action_just_pressed("pressed_action"):
			if cont_option:
				title_stage = -1
				$PressedStart.play()
				
				SaveManager.load_game(selected_file)

			else:
				DirAccess.remove_absolute("user://savedata/save" + str(selected_file) + ".tres")	
				create_tween().tween_property($FileSelect/ColorOverlay, "color:a", 0.0, 0.5)
				title_stage = 1
				
				create_tween().tween_property(color_overlay, "color:a", 0.0, 0.5)
				
				var go_back: Tween = create_tween()
				
				go_back.tween_property($Continue, "position:y", -240.0, 0.5)
				
				await go_back.finished
				
				cont_option = true
				
				check_files()
		
		if cont_option:
			$Continue/ContinueCursor.position = Vector2(137, 9)
		else:
			$Continue/ContinueCursor.position = Vector2(118, 49)
	
	if title_stage == 4:
		if Input.is_action_pressed("pressed_triangle"):
			create_tween().tween_property(file_select_buttons_2, "position:y", 50.0, 0.5).set_trans(Tween.TRANS_SINE)
			for file in files.get_children():
				if file.get_index() % 2 == 0:
					create_tween().tween_property(file, "position:x" , 26., 0.5).set_trans(Tween.TRANS_SINE)
				else:
					create_tween().tween_property(file, "position:x" , 93., 0.5).set_trans(Tween.TRANS_SINE)
	
	if title_stage > 3:
		if (int(timer) / 3) % 2:
			files.get_child(selected_file).modulate = Color(1.0, 1.0, 1.0)
		else:
			files.get_child(selected_file).modulate = Color(1.0, 0.5, 1.0)
	else:
		files.get_child(selected_file).modulate = Color(1.0, 1.0, 1.0)


func check_files() -> void:
	check_individual_file(0)
	check_individual_file(1)
	check_individual_file(2)


func check_individual_file(slot: int) -> void:
	var file: Marker2D = files.get_child(slot)
	
	if FileAccess.file_exists("user://savedata/save"+ str(slot) +".tres"):
		var _save_slot: SaveData = load("user://savedata/save"+ str(slot) +".tres")
		
		file.get_node("FileName").text = _save_slot.save_name
		file.get_node("CounterOrigin").visible = true
		file.get_node("CounterOrigin/Counter").text = str(_save_slot.player_data.piece_amount).pad_zeros(5)
		file.get_node("Panic").visible = _save_slot.corrupted
	else:
		file.get_node("FileName").text = "Empty Game"
		file.get_node("CounterOrigin").visible = false
		file.get_node("Panic").visible = false


func select_file(up: bool = false) -> void:
	var _bounce: Tween = create_tween()
	
	if up:
		selected_file -= 1
	else:
		selected_file += 1
	
	enable_selection = false
	
	$FileSound.play()
	
	for file in files.get_children():
		if file.get_index() == selected_file:
			file.get_node("Icon").visible = true
		else:
			file.get_node("Icon").visible = false
	
	if up:
		_bounce.tween_property(
								files.get_child(selected_file), 
								"position:y", 
								-10.0, 
								0.2
							).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		_bounce.tween_property(
								files.get_child(selected_file), 
								"position:y", 
								10.0, 
								0.2
							).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)	
	
	if up:
		_bounce.tween_property(
								files.get_child(selected_file), 
								"position:y", 
								10.0, 
								0.2
							).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	else:
		_bounce.tween_property(
								files.get_child(selected_file), 
								"position:y", 
								-10.0,
								0.2
							).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await _bounce.finished
	enable_selection = true


func _on_file_created(file_name: String, attach_node: Node) -> void:
	title_stage = 1
	
	if file_name != "":
		save_data.save_name = file_name
		var _default_data: SaveData = SaveData.new()
		_default_data.save_seed = randi()
		_default_data.save_name = file_name
		_default_data.room_path = "res://scene/room/gift_plane/gift_plane.tscn"
		_default_data.loading_preset = load("res://resource/loading_preset/gift_load.tres")
		_default_data.loading_preset_path = "res://resource/loading_preset/gift_load.tres"
		_default_data.player_data = PlayerStats.new()
		SaveManager.save_data(_default_data, selected_file)
		check_files()
	
	for file in files.get_children():
		if file.get_index() == selected_file:
			file.get_node("Icon").visible = true
		else:
			file.get_node("Icon").visible = false
	
	for file in files.get_children():
		if file.get_index() % 2 == 0:
			create_tween().tween_property(file, "position:x" , 26.0, 0.5).set_trans(Tween.TRANS_SINE)
		else:
			create_tween().tween_property(file, "position:x" , 93.0, 0.5).set_trans(Tween.TRANS_SINE)
			
	create_tween().tween_property(file_select_buttons, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)


func _on_demo_timer_timeout() -> void:
	if title_stage == 0 && demos != []:
		var _picked_demo: RecordingData = demos.pick_random()
		
		RecordingManager.demo = true
		RecordingManager.load_recording(_picked_demo.name, _picked_demo.gen)
