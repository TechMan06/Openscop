@icon("res://icon/level.png")
extends Node3D
class_name Level 
# do you think its worth it to make this a class? - izz

const PAUSE_SCENE: PackedScene = preload("res://scene/ui/pause_menu/pause_menu.tscn")
const FOG_FOCUS_OBJECT: PackedScene = preload("res://scene/object/instantiate/fog_focus.tscn")
const CAMERA_OBJECT: PackedScene = preload("res://scene/management/camera_marker.tscn")
const DRAW_MODE: PackedScene = preload("res://scene/ui/draw_mode.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scene/object/player/player.tscn")

var environment_obj: WorldEnvironment = WorldEnvironment.new()
var player: Player
var room_texture: Image
var background_texture: Image

#CODES
var nifty_code: Array[String] = ["pressed_l2","pressed_square","pressed_r1","pressed_triangle","pressed_r2","pressed_up","pressed_r2","pressed_circle","pressed_r2","pressed_circle"]
var input_counter: int = 0
var last_input: String = ""
var _player_instance: Player = PLAYER_SCENE.instantiate()

@export_category("Level Manipulator")
@export_subgroup("Level Settings")
@export var room_name: String = ""
@export var loading_preset: LoadingPreset
@export_enum("None:0", "GiftPlane:1", "EvenCare:2", "Level 2:3") var background_music: int = 0
@export var allow_recording = true
@export_multiline var level_slogan = ""
@export var school_preset: bool
@export var spawn_player: bool = true
@export_enum("EvenCare", 
			"Grass", 
			"Cement", 
			"Cement2", 
			"Cement3", 
			"School", 
			"Sand") var footstep_sound: int
@export_subgroup("General Camera Properties")
@export var spawn_camera_root: bool = true
@export var focus_on_player: bool = true
@export var camera_focus: Node3D
@export var camera_mode: int = 1
@export_subgroup("Camera_Properties")
@export var place_camera_at: Vector3
@export var camera_offset: Vector3
@export var allow_horizontal_movement: bool = true
@export var allow_front_movement: bool = true
@export var allow_vertical_movement = true
@export var camera_height: float = 4.0
@export var camera_distance: float = 12.0
@export var camera_angle: float = -18.0
@export var camera_root_offset_y: float
@export_subgroup("Limit Camera")
@export var limit_camera_horizontal: bool
@export var horizontal_limit: Vector2
@export var limit_camera_front: bool
@export var front_limit: Vector2
@export var limit_camera_vertical: bool
@export var vertical_limit: Vector2
@export var max_distance_from_guardian: Vector3
@export_subgroup("Environment_properties")
@export var environment_settings: EnvironmentResource
@export var fog_focus_on_player: bool = true
@export var fog_focus: Node3D
@export var fog_offset: Vector3 = Vector3(0.0, 0.0, 0.0)
#@export_enum("None:0", "EvenCare:1") var hardcoded_preset: int = 0

func _ready() -> void:
	EventBus.playback_player_spawned.connect(_on_playback_player_spawn)
	EventBus.piece_spawned.connect(_on_piece_spawned)
	EventBus.piece_collected.connect(_on_piece_collected)
	EventBus.nifty_upload.connect(_on_texture_upload)
	EventBus.nifty_finished.connect(_store_background)
	Console.nifty.connect(_nifty)

	
	SaveManager.get_data().room_name = room_name
	SaveManager.get_data().loading_preset = loading_preset
	SaveManager.get_data().room_path = get_tree().get_current_scene().scene_file_path
	
	if loading_preset == load("res://resource/loading_preset/gift_load.tres") && Global.global_data.gen < 5:
		loading_preset == load("res://resource/loading_preset/gift_load_demo.tres")
	
	if Global.global_data.gen < 5 || RecordingManager.demo:
		if background_music == 2:
			background_music = 3
	
	if Global.global_data.gen < 4:
		if environment_settings != null:
			environment_settings = null
		
		environment_settings = EnvironmentResource.new()

	
	environment_obj.environment = Environment.new()
	
	_get_environment().set_ambient_light_color(environment_settings.ambient_color)
	_get_environment().set_ambient_light_energy(environment_settings.environment_darkness)
	_get_environment().set_background(2)
	_get_environment().sky = Sky.new()
	_get_environment().sky.sky_material = ShaderMaterial.new()
	_get_sky().shader = load("res://shader/sky/sky.gdshader")
	
	if environment_settings.texture != null:
		_get_sky().set_shader_parameter("is_color", false)
		_get_sky().set_shader_parameter("sky_texture", environment_settings.texture)
		_get_sky().set_shader_parameter(
											"texture_size", 
											Vector2(
												environment_settings.texture.get_width(), 
												environment_settings.texture.get_height()
											)
										)
		_get_sky().set_shader_parameter("scroll_speed", environment_settings.scroll_speed)
	else:
		_get_sky().set_shader_parameter("sky_color", environment_settings.sky_color)
	
	_get_environment().set_ambient_source(2)
	_get_environment().ambient_light_color = environment_settings.ambient_color
	add_child(environment_obj)

	if environment_settings.enable_fog:
		RenderingServer.global_shader_parameter_set("fog_enabled", true)
		RenderingServer.global_shader_parameter_set("fog_color", environment_settings.fog_color)
		RenderingServer.global_shader_parameter_set("fog_size", environment_settings.fog_radius)
	else:
		RenderingServer.global_shader_parameter_set("fog_enabled", false)
	
	if Global.global_data.gen > 2:
		BGMusic.play_track(background_music)
	else:
		BGMusic.stream_paused = true
	
	_player_instance.player_stats = SaveManager.get_data().player_data
	
	var _fog_focus: Marker3D = FOG_FOCUS_OBJECT.instantiate()
		
	if environment_settings.enable_fog:
		if fog_focus_on_player:
			_fog_focus.focus_node = _player_instance
		else:
			_fog_focus.focus_node = fog_focus
		
		_fog_focus.offset = fog_offset

	if spawn_player:
		add_child(_player_instance)
		
		if school_preset:
			_player_instance.control_mode = 1
		
		_player_instance.set_footstep_sound(footstep_sound)

		if _player_instance.player_stats.scene_info != []:
			for spawn in get_tree().get_nodes_in_group("spawn"):
				if [spawn.scene_path, spawn.warp_id] == _player_instance.player_stats.scene_info:
					_player_instance.global_position = spawn.global_position
					_player_instance.direction = spawn.player_direction
		else:
			_player_instance.global_position = Vector3(
														_player_instance.player_stats.player_pos.x,
														_player_instance.player_stats.player_pos.y,
														_player_instance.player_stats.player_pos.z
													)
			
			_player_instance.direction = _player_instance.player_stats.player_pos.w
		
		
		_player_instance.player_stats.scene_info == []
		
		if spawn_camera_root && focus_on_player:
			var _player_camera = create_camera()
			
			_player_camera.focus_node = _player_instance
			if !school_preset:
				_player_camera.set_mode(1)
			else:
				_player_camera.set_mode(2)
			
			add_child(_player_camera)
			
			_player_camera.global_position = _player_camera.global_position + camera_offset
			
			if !allow_horizontal_movement:
				_player_camera.global_position.x = place_camera_at.x
				
			if !allow_vertical_movement:
				_player_camera.global_position.y = place_camera_at.y
			
			if !allow_front_movement:
				_player_camera.global_position.z = place_camera_at.z
	else:
		fog_focus_on_player = false
		focus_on_player = false
	
	if environment_settings.enable_fog:
		add_child(_fog_focus)
	
	if !focus_on_player && spawn_camera_root && !spawn_player:
		var _camera: CameraMarker = create_camera()
		
		_camera.global_position = place_camera_at
		_camera.global_position = _camera.global_position + camera_offset
		_camera.focus_node = camera_focus
		
		_camera.set_mode(camera_mode) 
		
		add_child(_camera)
	

	if allow_recording && GameManager.debug_settings.auto_record:
		if (
				!RecordingManager.recording
				and !RecordingManager.demo
				and !RecordingManager.replay
			):
			RecordingManager.start_recording()
	else:
		RecordingManager.stop_recording()


func _process(_delta):
	if Input.is_action_just_pressed("pressed_start"):
		if Global.can_pause && Global.global_data.gen > 2:
			var _pause_instance: Control = PAUSE_SCENE.instantiate()
			
			_pause_instance.level_slogan = level_slogan
			
			add_child(_pause_instance)
			
			Global.can_pause = false
			Global.is_game_paused = true
	
	if (
			Input.is_action_just_pressed("pressed_l2") 
			or Input.is_action_just_pressed("pressed_l1") 
			or Input.is_action_just_pressed("pressed_r2") 
			or Input.is_action_just_pressed("pressed_r1")
			or Input.is_action_just_pressed("pressed_up")
			or Input.is_action_just_pressed("pressed_down")
			or Input.is_action_just_pressed("pressed_left")
			or Input.is_action_just_pressed("pressed_right")
			or Input.is_action_just_pressed("pressed_start")
			or Input.is_action_just_pressed("pressed_select")
			or Input.is_action_just_pressed("pressed_action")
			or Input.is_action_just_pressed("pressed_triangle")
			or Input.is_action_just_pressed("pressed_square")
			or Input.is_action_just_pressed("pressed_circle")
		):
		if Input.is_action_just_pressed(nifty_code[input_counter]):
			if input_counter < 9:
				input_counter += 1
			else:
				_nifty()
		else:
			input_counter = 0

func _on_playback_player_spawn(playback_player_obj: PlaybackPlayer) -> void:
	playback_player_obj.add_collision_exception_with(_player_instance)


func _on_piece_spawned(piece_id: int) -> void:
	if SaveManager.get_data().piece_log.has(room_name):
		if SaveManager.get_data().piece_log[room_name].find(piece_id) != -1:
			get_tree().get_nodes_in_group("piece")[piece_id].queue_free()


func _on_piece_collected(piece_id: int) -> void:
	if SaveManager.get_data().piece_log.has(room_name):
		SaveManager.get_data().piece_log[room_name].push_back(piece_id)
	elif room_name != "" || room_name.rstrip(" ") != "":
		SaveManager.get_data().piece_log[room_name] = [piece_id]


func _on_texture_upload(texture: Image) -> void:
	if room_texture == null:
		room_texture = texture


func create_camera() -> CameraMarker:
	var _camera_marker: CameraMarker = CAMERA_OBJECT.instantiate()
	_camera_marker.position = place_camera_at
	
	if !allow_horizontal_movement:
		_camera_marker.can_move[0] = false
	
	if !allow_vertical_movement:
		_camera_marker.can_move[1] = false
	
	if !allow_front_movement:
		_camera_marker.can_move[2] = false
	
	if limit_camera_horizontal:
		_camera_marker.set_limit(0, horizontal_limit)
	
	if limit_camera_vertical:
		_camera_marker.set_limit(1, vertical_limit)
	
	if limit_camera_front:
		_camera_marker.set_limit(2, front_limit)
	
	_camera_marker.distance_limit = Vector3(2.0, 2.0, 2.0)
	_camera_marker.setup_camera(Vector2(camera_distance, camera_height), camera_angle)
	
	return _camera_marker


func _get_environment() -> Environment:
	return environment_obj.environment


func _get_sky() -> ShaderMaterial:
	return _get_environment().sky.get_material()


func _store_background(_room_tex: Image, background_image: Image) -> void:
	background_texture = background_image


func _nifty() -> void:
	var _draw_instance: Control = DRAW_MODE.instantiate()
				
	_draw_instance.texture = room_texture
	_draw_instance.background_image = background_texture
	
	Global.can_pause = false
	Global.is_game_paused = true
	
	add_child(_draw_instance)