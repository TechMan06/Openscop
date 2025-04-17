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
var room_texture: Image
var draw_texture: Image

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
@export var allow_recording: bool = true
@export_multiline var level_slogan: String = ""
@export var school_preset: bool = false
@export var spawn_player: bool = true
@export_enum("EvenCare", 
			"Grass", 
			"Cement", 
			"Cement2", 
			"Cement3", 
			"School", 
			"Sand") var footstep_sound: int = 0
@export var disable_shadow_monster_man: bool = false
@export_category("Starting Textbox Settings")
@export_multiline var textbox: String = ""
@export var textbox_preset: TextboxResource
@export_subgroup("General Camera Properties")
@export var spawn_camera_root: bool = true
@export var focus_on_player: bool = true
@export var camera_focus: Node3D
@export_enum("Copy:0", "Follow:1", "Pov:2", "Lerp:3") var camera_mode: int = 1
@export_subgroup("Camera_Properties")
@export var place_camera_at: Vector3 = Vector3.ZERO
@export var camera_offset: Vector3 = Vector3.ZERO
@export var allow_horizontal_movement: bool = true
@export var allow_front_movement: bool = true
@export var allow_vertical_movement = true
@export var camera_height: float = 4.0
@export var camera_distance: float = 12.0
@export var camera_angle: float = -18.0
@export var camera_root_offset_y: float = 0.0
@export_subgroup("Limit Camera")
@export var limit_camera_horizontal: bool = false
@export var horizontal_limit: Vector2 = Vector2.ZERO
@export var limit_camera_front: bool = false
@export var front_limit: Vector2 = Vector2.ZERO
@export var limit_camera_vertical: bool = false
@export var vertical_limit: Vector2 = Vector2.ZERO
@export var max_distance_from_guardian: Vector3 = Vector3(2.0, 2.0, 2.0)
@export_subgroup("Environment_properties")
@export var environment_settings: EnvironmentResource
@export var fog_focus_on_player: bool = true
@export var fog_focus: Node3D
@export var fog_offset: Vector3 = Vector3.ZERO
@export_subgroup("Misc_properties")
@export var bucket_spawn_offset: Vector3 = Vector3.ZERO
@export var hardcoded_properties: HardcodedProperties = HardcodedProperties.NONE

enum HardcodedProperties {
	NONE,
	EVEN_CARE,
	ODD_CARE_PIANO_ROOM,
	RONETH_ROOM
}


func _ready() -> void:
	EventBus.playback_player_spawned.connect(_on_playback_player_spawn)
	EventBus.nifty_upload.connect(_on_texture_upload)
	EventBus.nifty_finished.connect(_store_background)
	EventBus.warp_spawned.connect(_on_warp_spawned)
	EventBus.nifty_set_pixels.connect(nifty_set_pixels)
	Console.nifty.connect(_nifty)
	
	SaveManager.get_data().room_name = room_name
	SaveManager.get_data().loading_preset = loading_preset
	SaveManager.get_data().room_path = get_tree().get_current_scene().scene_file_path
	
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	if RecordingManager.replay:
		if RecordingManager.demo:
			level_slogan = "Demo Recording"
		else:
			level_slogan = "Recording Playback"
	
	match hardcoded_properties:
		HardcodedProperties.EVEN_CARE:
			if Global.global_data.gen < 4:
				loading_preset = load("res://resource/loading_preset/ec_old.tres")
			elif RecordingManager.demo:
				loading_preset = load("res://resource/loading_preset/ec_demo.tres")
	
	
	if Global.global_data.gen < 5 || RecordingManager.demo:
		if background_music == 2:
			background_music = 3
	
	if Global.global_data.gen < 4:
		if environment_settings != null:
			environment_settings = null
		
		environment_settings = EnvironmentResource.new()
	
	if environment_settings == null:
		environment_settings = EnvironmentResource.new()
		printerr("Environment Settings are missing, created blank environment as placeholder!")
	
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
		_get_sky().set_shader_parameter("offset_y", environment_settings.offset_y)
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
		if !SaveManager.get_data().unlocked_nmp:
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
	
	if SaveManager.get_data().has_bucket:
		var bucket: CharacterBody3D = load("res://scene/object/interactive/common/bucket.tscn").instantiate()
		var spawn_pos: Vector3 = Vector3.ZERO
		
		if _player_instance.player_stats.scene_info != []:
			for spawn in get_tree().get_nodes_in_group("spawn"):
				if [spawn.scene_path, spawn.warp_id] == _player_instance.player_stats.scene_info:
					spawn_pos = spawn.global_position
					
					match SaveManager.get_data().bucket_direction:
						0:
							spawn_pos.z += 1.0
						1:
							spawn_pos.x += 1.0
						2:
							spawn_pos.x -= 1.0
						3:
							spawn_pos.z -= 1.0
		
		add_child(bucket)
		bucket.global_position = spawn_pos + bucket_spawn_offset
	
	if spawn_player:
		if school_preset:
			_player_instance.control_mode = 1
		
		if hardcoded_properties == HardcodedProperties.ODD_CARE_PIANO_ROOM and RecordingManager.demo:
			_player_instance.odd_care = true
			
		if disable_shadow_monster_man:
			_player_instance.player_stats.brightness = 1.0
		
		add_child(_player_instance)
		
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
			
			_player_instance.direction = int(_player_instance.player_stats.player_pos.w)
		
		_player_instance.player_stats.scene_info == []
		
		if spawn_camera_root && focus_on_player:
			var _player_camera: CameraMarker = create_camera()
			
			_player_camera.focus_node = _player_instance
			
			if !school_preset:
				_player_camera.set_mode(_player_camera.CameraModes.FOLLOW)
			else:
				_player_camera.set_mode(_player_camera.CameraModes.POV)
			
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
		
		match camera_mode:
			0:
				_camera.set_mode(_camera.CameraModes.COPY)
			1:
				_camera.set_mode(_camera.CameraModes.FOLLOW)
			2:
				_camera.set_mode(_camera.CameraModes.POV)
			3:
				_camera.set_mode(_camera.CameraModes.LERP)
		
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
	
	await self.tree_entered
	
	EventBus.room_started.emit(self)


func _process(delta: float) -> void:
	Global.clock_float += delta
	
	if !Global.is_game_paused:
		RenderingServer.global_shader_parameter_set("float_time", Global.clock_float)
	
	if textbox != "":
		if textbox_preset != null:
			await HUD.transition_end
			HUD.create_textbox(textbox_preset, textbox)
		else:
			printerr("Starting TextboxPreset is missing!")
	
	
	if Input.is_action_just_pressed("pressed_start") && Global.current_controller == 0:
		if Global.can_pause && Global.global_data.gen > 2:
			var _pause_instance: Control = PAUSE_SCENE.instantiate()
			
			if hardcoded_properties == HardcodedProperties.RONETH_ROOM:
				_pause_instance.secret_code = true
			
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
			if input_counter < nifty_code.size() - 1:
				input_counter += 1
			else:
				if !Global.is_game_paused:
					_nifty()
		else:
			input_counter = 0


func _on_playback_player_spawn(playback_player_obj: PlaybackPlayer) -> void:
	playback_player_obj.add_collision_exception_with(_player_instance)


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
	
	_camera_marker.distance_limit = max_distance_from_guardian
	_camera_marker.setup_camera(Vector2(camera_distance, camera_height), camera_angle)
	
	return _camera_marker


func _get_environment() -> Environment:
	return environment_obj.environment


func _get_sky() -> ShaderMaterial:
	return _get_environment().sky.get_material()


func _store_background(_room_tex: Image, draw_image: Image, pixel_array: Array[Vector2i]) -> void:
	draw_texture = draw_image
	
	if RecordingManager.recording:
		RecordingManager.recording_data.draw_mode.push_back([RecordingManager.recording_timer, pixel_array])


func _nifty() -> void:
	var _draw_instance: Control = DRAW_MODE.instantiate()
				
	_draw_instance.texture = room_texture
	_draw_instance.draw_layer_image = draw_texture
	
	Global.can_pause = false
	Global.is_game_paused = true
	Global.draw_mode = true
	add_child(_draw_instance)


func _on_warp_spawned(warp: WarpClass) -> void:
	if (
			hardcoded_properties == HardcodedProperties.EVEN_CARE or
			hardcoded_properties == HardcodedProperties.RONETH_ROOM
		):
			if SaveManager.get_data().unlocked_nmp:
				if warp.loading_preset == load("res://resource/loading_preset/ec_noload.tres"):
					warp.loading_preset = load("res://resource/loading_preset/nmp_delay.tres")
				elif warp.loading_preset == load("res://resource/loading_preset/gift_load.tres"):
					warp.loading_preset = load("res://resource/loading_preset/nmp_load.tres")
				
				if (
						warp.scene == "res://scene/room/level1/room1.tscn" or 
						warp.scene == "res://scene/room/level1/room2.tscn"
					):
					warp.loading_preset = load("res://resource/loading_preset/nmp_noload_delay.tscn")
				
				if warp.scene == "res://scene/room/gift_plane/gift_plane.tscn":
					warp.scene = "res://scene/room/nmp/nmp.tscn"


func nifty_set_pixels(pixel_array: Array[Vector2i]) -> void:
	if draw_texture == null:
		draw_texture = Image.create(
										int(str(room_texture.get_width() / 257.0)[0])  + 512, 
										int(str(room_texture.get_height() / 257.0)[0]) + 512, 
										false, 
										4
									)
		draw_texture.fill(Color.html("#FF00FF"))
		
	for pixel in pixel_array:
		draw_texture.set_pixel(
								clamp(
										pixel.x,
										0,
										draw_texture.get_width()
									), 
								clamp(
										pixel.y,
										0,
										draw_texture.get_height()
									), 
								Color.html("#FFCEE5FF")
							)
		room_texture.set_pixel(
								clamp(
										pixel.x,
										0,
										room_texture.get_width()
									), 
								clamp(
										pixel.y,
										0,
										room_texture.get_height()
									), 
								Color.html("#FFCEE5FF")
							)
	
	EventBus.nifty_finished.emit(room_texture, draw_texture, pixel_array)
