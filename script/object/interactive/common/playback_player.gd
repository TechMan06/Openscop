extends Entity
class_name PlaybackPlayer

## This object is used for simulating ghost players shown in levels ranging from Paul's own replays to Marvin and Belle's.

@export_category("Recording Playback Properties")
@export var main_recording_folder: bool = true ## Whether to load a recording from [code]user://recordings/[/code] or another folder.
@export var recording: String = "" ## Filename of the recording to load.
@export var recording_delay: float = 0.0 ## Delay to be waited before the recording starts.
@export var start_at_frame: int = 0 ## Frame to start the recording start at.
@export var player_stats: PlayerStats ## [PlayerStats] for that player, if [code]null[/code], load the one from the recording.
@export var character_sheet: Texture2D ## Spritesheet the ghost uses, if [code]null[/code] use the one from [member PlaybackPlayer.player_stats] instead.
@export_enum("Destroy: 0", "Freeze: 1") var on_recording_end: int = 0 ## Whether to Destroy ([code]0[/code]) or Freeze ([code]1[/code]) the ghost after the recording replay is finished.
@export_enum("Continue: 0", "Destroy: 1") var on_warp: int = 0 ## Whether to Continue ([code]0[/code]) the recording playback or Destroy ([code]1[/code]) the ghost after the ghost enters a warp.
@export var show_p2totalk: bool = true ## Whether the ghost uses P2 to Talk, disabled by default below Gen 11.
@export var invisible_until_playback: bool = false ## Whether the ghost should be invisible until the recording starts.
@export var loop: bool = false ## Whether to loop the recording.
@export var use_recording_character: bool = false ## Whether to use the character set of the recording.
@export var use_recording_position: bool = true ## Whether to place the ghost at the recording's beginning position.
@export var flip_x: bool = false ## Whether to invert the ghost's horizontal movement.

var _warp_timer: int = 0
var _file: String = ""
var _frozen: bool = false
var _p2_talk_component: P2TalkComponent
var _recording_timer: int = 0
var _recording_data: RecordingData
var _character_sheets: Array[String] = [
										"res://asset/2d/sprite/player/default.png",
										"res://asset/2d/sprite/player/belle.png",
										"res://asset/2d/sprite/player/marvin.png"
									]
var _replay: bool = false
var _replay_setup: bool = false
var _recording_finished: bool = false
var _recording_reader_p1: int = 0
var _recording_reader_p2: int = 0
var _recording_reader_draw: int = 0
var _input_sim_select: bool = false
var _input_sim_action: bool = false


func _ready() -> void:
	_sprite = $PlayerSprite
	_sprite_material = $PlayerSprite.get_material_override()
	_p2talk_text = $P2TalkOrigin/P2TalkButtons
	_p2talk_origin = $P2TalkOrigin
	_p2talk_button_sound = $ButtonSound
	_p2_talk_component = $P2TalkComponent
	
	warp()
	
	if Global.global_data.gen < 11:
		show_p2totalk = false
	
	if recording == "":
		if main_recording_folder:
			var _recording_list: Array = []
			
			for _file in DirAccess.get_files_at("user://recordings/"):
				_recording_list.append(_file)
			
			if _recording_list != []:
				_file = "user://recordings/" + _recording_list.pick_random()
				_recording_data = load(_file)
		else:
			var _recording_list: Array = []
			
			for file in DirAccess.get_files_at("user://recordings/"):
				_recording_list.append(file)
			
			if _recording_list != []:
				_file = "user://player_recordings/" + _recording_list.pick_random()
				_recording_data = load(_file)
	else:
		if !main_recording_folder:
			_file = "user://player_recordings/" + recording
			_recording_data = load("user://player_recordings/" + recording)
		else:
			_file = "user://recordings/" + recording
			_recording_data = load("user://recordings/" + recording)
	
	if Global.ghost_tracker.has(_file):
		queue_free()
	
	if _recording_data != null:
		if player_stats == null:
			player_stats = PlayerStats.new()
			player_stats = _recording_data.save_data.player_data
			
		if (
				player_stats.character_id > 2 and 
				_recording_data.gen > 6 and 
				_recording_data.gen < 9
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
		if player_stats.character_id > 0 and player_stats.character_id < _character_sheets.size() - 1:
			_sprite.texture = load(_character_sheets[player_stats.character_id])
		else:
			_sprite.texture = load("res://asset/2d/sprite/player/default.png")
	else:
		_sprite.texture = character_sheet
	
	_sprite_material.set_shader_parameter("albedoTex", _sprite.texture)
	
	await get_tree().physics_frame
	
	EventBus.playback_player_spawned.emit(self)
	
	if start_at_frame > 0:
		_recording_timer = start_at_frame
	
	if invisible_until_playback:
		visible = false
	
	if recording_delay != 0.0:
		await get_tree().create_timer(recording_delay).timeout
	
	if _recording_data != null:
		_replay = true


func _physics_process(_delta: float) -> void:
	if _input_sim_select && _p2talk_text.text != "" && _can_submit:
		_p2_talk_component._create_word()
		_p2talk_text.text = ""
		_can_submit = false

	if Input.is_action_just_pressed("ui_end"):
		visible = true
		_replay = true
	
	
	if _replay:
		if !_replay_setup:
			init()
			_recording_finished = false
			_recording_timer = 0
			Console.console_log("[color=green]Loading Player Recording Data...[/color]")
			
			Global.ghost_tracker[_file] = {
				"data": _recording_data,
				"timer" : start_at_frame,
				"sheet": _sprite.texture,
				"loop": loop,
				"flip_x": flip_x,
				"warp_timer": _warp_timer
			}
			
			_replay_setup = true
		
		if _replay_setup:
			_recording_timer = Global.ghost_tracker[_file]["timer"]
		
		if _recording_data.p1_data[_recording_reader_p1][1] == null:
			Console.console_log("[color=red]RECORDING IS OVER[/color]")
			
			match on_recording_end:
				0:
					queue_free()
				1:
					freeze()
			
			_replay = false
			_replay_setup = false
			Global.ghost_tracker[_file]["timer"] = 0
			_recording_timer = Global.ghost_tracker[_file]["timer"]
			_recording_reader_p1 = 0
			_recording_reader_p2 = 0
			
			if loop:
				if recording_delay != 0.0:
					await get_tree().create_timer(recording_delay).timeout
				
				Global.ghost_tracker[_file]["timer"] = 0
				_replay = true
			else:
				Global.ghost_tracker.erase(_file)
				self.process_mode = Node.PROCESS_MODE_DISABLED
		
		else:
			if _recording_reader_p1 <= _recording_data.p1_data.size() - 1:
				if _recording_timer == _recording_data.p1_data[_recording_reader_p1][0]:
					if _recording_data.p1_data[_recording_reader_p1][1]:
						if _recording_data.p1_data[_recording_reader_p1][6] != 0:
							_v = -1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][6])
						
						if _recording_data.p1_data[_recording_reader_p1][7] != 0:
							_v = 1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][7])
						
						if _recording_data.p1_data[_recording_reader_p1][8] != 0:
							if flip_x:
								_h = 1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][8])
							else:
								_h = -1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][8])
						
						if _recording_data.p1_data[_recording_reader_p1][9] != 0:	
							if flip_x:
								_h = -1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][9])
							else:
								_h = 1.0 * number_parser(_recording_data.p1_data[_recording_reader_p1][9])
						
						if _recording_data.p1_data[_recording_reader_p1][10] != 0:	
							await get_tree().physics_frame
							_input_sim_action = true
							await get_tree().physics_frame
							_input_sim_action = false
						
						if _recording_data.p1_data[_recording_reader_p1][11] !=0:	
							await get_tree().physics_frame
							_input_sim_select = true
							await get_tree().physics_frame
							_input_sim_select = false
					
					_recording_reader_p1 += 1
					
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: " + str(_recording_timer) + " Data:" + str(_recording_data.p1_data[_recording_reader_p1]) + " Index: " + str(_recording_reader_p1) + "[/color]")
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER NPC CONTROL 1[/color][color=yellow]Frame: " + str(_recording_timer) + " Data: [/color][color=red]NONE/UNUSED[/color]")
			
			if show_p2totalk:
				if _recording_reader_p2 <= _recording_data.p2_data.size()-1:
					if _recording_timer == _recording_data.p2_data[_recording_reader_p2][0]:
						_p2talk_button_sound.play()
						p2talk_word = _recording_data.p2_data[_recording_reader_p2][1]
						_p2talk_text.text = _recording_data.p2_data[_recording_reader_p2][2]
						
						if Console.recording_parse:
							Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: "+str(_recording_timer) + " Data:" + str(_recording_data.p2_data[_recording_reader_p2]) + " Index: " + str(_recording_reader_p2) + "[/color]")
						
						_recording_reader_p2 += 1
					else:
						if Console.recording_parse:
							Console.console_log("[color=green]PLAYER NPC CONTROL 2[/color][color=yellow]Frame: " + str(_recording_timer) + " Data: [/color][color=red]NONE[/color]")
				
			if _recording_reader_draw <= _recording_data["draw_mode"].size() - 1:
				if _recording_timer == _recording_data.draw_mode[_recording_reader_draw][0]:
					EventBus.nifty_set_pixels.emit(_recording_data.draw_mode[_recording_reader_draw][1])
					_recording_reader_draw += 1
		
		if Global.ghost_tracker[_file].has("warp_timer"):
			if Global.ghost_tracker[_file]["warp_timer"] <= _recording_data["warp_out"].size() -1:
				if _recording_timer == _recording_data.warp_out[Global.ghost_tracker[_file]["warp_timer"]][0]:
					if _recording_data.warp_out[
													Global.ghost_tracker[_file]["warp_timer"]
												][1] == get_tree().get_current_scene().scene_file_path:
						for _spawn in get_tree().get_nodes_in_group("spawn"):
							if _spawn.warp_id == _recording_data.warp_out[Global.ghost_tracker[_file]["warp_timer"]][2]:
								global_position = _spawn.global_position
								unfreeze()
					else:
						if Global.ghost_tracker[_file]["warp_timer"] > 0:
							freeze()
						
					Global.ghost_tracker[_file]["warp_timer"] += 1


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
