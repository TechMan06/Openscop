extends Entity
class_name PlaybackPlayer

@export_category("Recording Playback Properties")
@export var main_recording_folder: bool = true
@export var recording: String = ""
@export var recording_delay: float = 0.0
@export var start_at_frame: int = 0
@export var player_stats: PlayerStats
@export var character_sheet: Texture2D
@export_enum("Destroy: 0", "Freeze: 1") var on_recording_end: int = 0 
@export_enum("Continue: 0", "Destroy: 1") var on_warp: int = 0
@export var show_p2totalk: bool = true
@export var invisible_until_playback: bool = false
@export var loop: bool = false
@export var use_recording_character: bool = false
@export var use_recording_position: bool = true
@export var flip_x: bool = false

var warp_timer: int = 0
var file: String = ""
var frozen: bool = false
var p2_talk_component: P2TalkComponent
var recording_timer: int = 0
var recording_data: RecordingData
var character_sheets: Array[String] = [
										"res://asset/2d/sprite/player/default.png",
										"res://asset/2d/sprite/player/belle.png",
										"res://asset/2d/sprite/player/marvin.png"
									]
var replay: bool = false
var replay_setup: bool = false
var recording_finished: bool = false
var recording_reader_p1: int = 0
var recording_reader_p2: int = 0
var recording_reader_draw: int = 0
var input_sim_select: bool = false
var input_sim_action: bool = false


func _ready() -> void:
	_sprite = $PlayerSprite
	_sprite_material = $PlayerSprite.get_material_override()
	_p2talk_text = $P2TalkOrigin/P2TalkButtons
	_p2talk_origin = $P2TalkOrigin
	_p2talk_button_sound = $ButtonSound
	p2_talk_component = $P2TalkComponent
	
	warp()
	
	if recording == "":
		if main_recording_folder:
			var _recording_list: Array = []
			
			for file in DirAccess.get_files_at("user://recordings/"):
				_recording_list.append(file)
			
			if _recording_list != []:
				file = "user://recordings/" + _recording_list.pick_random()
				recording_data = load(file)
		else:
			var _recording_list: Array = []
			
			for file in DirAccess.get_files_at("user://recordings/"):
				_recording_list.append(file)
			
			if _recording_list != []:
				file = "user://player_recordings/" + _recording_list.pick_random()
				recording_data = load(file)
	else:
		if !main_recording_folder:
			file = "user://player_recordings/" + recording
			recording_data = load("user://player_recordings/" + recording)
		else:
			file = "user://recordings/" + recording
			recording_data = load("user://recordings/" + recording)
	
	if Global.ghost_tracker.has(file):
		queue_free()
	
	if recording_data != null:
		if player_stats == null:
			player_stats = PlayerStats.new()
			player_stats = recording_data.save_data.player_data
			
		if (
				player_stats.character_id > 2 and 
				recording_data.gen > 6 and 
				recording_data.gen < 9
			):
			_movement_speed = 6.0
		else:
			_movement_speed = 5.0
		
		if use_recording_position:
			global_position = Vector3(
										player_stats.player_pos.x,
										player_stats.player_pos.y,
										player_stats.player_pos.z
									)
			
			direction = int(player_stats.player_pos.w)
	
	if character_sheet == null && player_stats != null:
		if player_stats.character_id > 0 and player_stats.character_id < character_sheets.size() - 1:
			_sprite.texture = load(character_sheets[player_stats.character_id])
		else:
			_sprite.texture = load("res://asset/2d/sprite/player/default.png")
	else:
		_sprite.texture = character_sheet
	
	_sprite_material.set_shader_parameter("albedoTex", _sprite.texture)
	
	await get_tree().physics_frame
	
	EventBus.playback_player_spawned.emit(self)
	
	if start_at_frame > 0:
		recording_timer = start_at_frame
	
	if invisible_until_playback:
		visible = false
	
	if recording_delay != 0.0:
		await get_tree().create_timer(recording_delay).timeout
	
	if recording_data != null:
		replay = true


func _physics_process(_delta: float) -> void:
	if input_sim_select && _p2talk_text.text != "" && _can_submit:
		p2_talk_component._create_word()
		_p2talk_text.text = ""
		_can_submit = false

	if Input.is_action_just_pressed("ui_end"):
		visible = true
		replay = true
	
	
	if replay:
		if !replay_setup:
			init()
			recording_finished = false
			recording_timer = 0
			Console.console_log("[color=green]Loading Player Recording Data...[/color]")
			
			Global.ghost_tracker[file] = {
				"data": recording_data,
				"timer" : start_at_frame,
				"sheet": _sprite.texture,
				"loop": loop,
				"flip_x": flip_x,
				"warp_timer": warp_timer
			}
			
			replay_setup = true
		
		if replay_setup:
			recording_timer = Global.ghost_tracker[file]["timer"]
		
		if recording_data.p1_data[recording_reader_p1][1] == null:
			Console.console_log("[color=red]RECORDING IS OVER[/color]")
			
			match on_recording_end:
				0:
					queue_free()
				1:
					freeze()
			
			replay = false
			replay_setup = false
			Global.ghost_tracker[file]["timer"] = 0
			recording_timer = Global.ghost_tracker[file]["timer"]
			recording_reader_p1 = 0
			recording_reader_p2 = 0
			
			if loop:
				if recording_delay != 0.0:
					await get_tree().create_timer(recording_delay).timeout
				
				Global.ghost_tracker[file]["timer"] = 0
				replay = true
			else:
				Global.ghost_tracker.erase(file)
				self.process_mode = Node.PROCESS_MODE_DISABLED
		
		else:
			if recording_reader_p1 <= recording_data.p1_data.size() - 1:
				if recording_timer == recording_data.p1_data[recording_reader_p1][0]:
					if  recording_data.p1_data[recording_reader_p1][1]:
						if recording_data.p1_data[recording_reader_p1][6] != 0:
							_v = -1.0 * number_parser(recording_data.p1_data[recording_reader_p1][6])
						
						if recording_data.p1_data[recording_reader_p1][7] != 0:
							_v = 1.0 * number_parser(recording_data.p1_data[recording_reader_p1][7])
						
						if recording_data.p1_data[recording_reader_p1][8] != 0:
							if flip_x:
								_h = 1.0 * number_parser(recording_data.p1_data[recording_reader_p1][8])
							else:
								_h = -1.0 * number_parser(recording_data.p1_data[recording_reader_p1][8])
						
						if recording_data.p1_data[recording_reader_p1][9] != 0:	
							if flip_x:
								_h = -1.0 * number_parser(recording_data.p1_data[recording_reader_p1][9])
							else:
								_h = 1.0 * number_parser(recording_data.p1_data[recording_reader_p1][9])
						
						if recording_data.p1_data[recording_reader_p1][10] != 0:	
							await get_tree().physics_frame
							input_sim_action = true
							await get_tree().physics_frame
							input_sim_action = false
						
						if recording_data.p1_data[recording_reader_p1][11] !=0:	
							await get_tree().physics_frame
							input_sim_select = true
							await get_tree().physics_frame
							input_sim_select = false
					
					recording_reader_p1 += 1
					
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: " + str(recording_timer) + " Data:" + str(recording_data.p1_data[recording_reader_p1]) + " Index: " + str(recording_reader_p1) + "[/color]")
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: " + str(recording_timer) + " Data: [/color][color=red]NONE/UNUSED[/color]")
			
			if show_p2totalk:
				if recording_reader_p2 <= recording_data.p2_data.size()-1:
					if recording_timer == recording_data.p2_data[recording_reader_p2][0]:
						_p2talk_button_sound.play()
						p2talk_word = recording_data.p2_data[recording_reader_p2][1]
						_p2talk_text.text = recording_data.p2_data[recording_reader_p2][2]
						
						if Console.recording_parse:
							Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: "+str(recording_timer) + " Data:" + str(recording_data.p2_data[recording_reader_p2]) + " Index: " + str(recording_reader_p2) + "[/color]")
						
						recording_reader_p2 += 1
					else:
						if Console.recording_parse:
							Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: " + str(recording_timer) + " Data: [/color][color=red]NONE[/color]")
				
			if recording_reader_draw <= recording_data["draw_mode"].size() - 1:
				if recording_timer == recording_data.draw_mode[recording_reader_draw][0]:
					EventBus.nifty_set_pixels.emit(recording_data.draw_mode[recording_reader_draw][1])
					recording_reader_draw += 1
		
		if Global.ghost_tracker[file].has("warp_timer"):
			if Global.ghost_tracker[file]["warp_timer"] <= recording_data["warp_out"].size() -1:
				if recording_timer == recording_data.warp_out[Global.ghost_tracker[file]["warp_timer"]][0]:
					if recording_data.warp_out[
													Global.ghost_tracker[file]["warp_timer"]
												][1] == get_tree().get_current_scene().scene_file_path:
						for spawn in get_tree().get_nodes_in_group("spawn"):
							if spawn.warp_id == recording_data.warp_out[Global.ghost_tracker[file]["warp_timer"]][2]:
								global_position = spawn.global_position
								unfreeze()
					else:
						if Global.ghost_tracker[file]["warp_timer"] > 0:
							freeze()
						
					Global.ghost_tracker[file]["warp_timer"] += 1


func init() -> void:
	visible = true
	$EntityComponent.set_process_mode(Node.PROCESS_MODE_ALWAYS)


func warp() -> void:
	visible = false
	$EntityComponent.set_process_mode(Node.PROCESS_MODE_DISABLED)


func freeze() -> void:
	velocity = Vector3.ZERO
	$EntityComponent.set_process_mode(Node.PROCESS_MODE_DISABLED)


func unfreeze() -> void:
	visible = true
	$EntityComponent.set_process_mode(Node.PROCESS_MODE_ALWAYS)


func number_parser(number: int) -> float:
	if number==1:
		return 1.0
	return 0.0
