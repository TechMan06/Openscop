extends Node


var temp_data: SaveData

var demo: bool = false
var replay: bool = false
var replay_setup: bool = false
var recording: bool = false
var recording_setup: bool = false
var recording_finished: bool = false

var recording_timer: int = 0
var recording_reader_p1: int = 0
var recording_reader_p2: int = 0
var recording_data: RecordingData
var cancel_movement: Array[int]

var input_sim: Array[InputEventAction]
var input_array: Array[String] = [
				"pressed_r1", 
				"pressed_r2", 
				"pressed_l1",
				"pressed_l2", 
				"pressed_up", 
				"pressed_down", 
				"pressed_left",
				"pressed_right", 
				"pressed_action", 
				"pressed_triangle",
				"pressed_circle", 
				"pressed_square", 
				"pressed_select", 
				"pressed_start"
			]


func _ready() -> void:
	EventBus.p2talk_key.connect(_on_p2talk_pressed)
	Console.load_recording.connect(load_recording)


func _physics_process(_delta: float) -> void:
	#R1,R2,L1,L2,UP,DOWN,LEFT,RIGHT,Crs,Tri,Cir,Squ,Sel,Sta
	if recording:
		recording_timer+=1
		
		if (
				check_input() 
				and Global.current_controller == 0
				and SaveManager.get_data().player_data.input_enabled
				or Input.is_action_just_pressed("pressed_select") 
				or Input.is_action_just_released("pressed_select")
			):
				var can_move: bool = !Global.is_game_paused and !Global.draw_mode
				var _frame_array: Array[int] = [recording_timer, can_move]
				
				for input in input_array:
					_frame_array.append(_check_input_type(input))
				
				recording_data.p1_data.push_back(
													_frame_array
												)
		
	if replay:
		if !replay_setup:
			recording_finished = false
			recording = false
			recording_timer = 0
			
			Console.console_log("[color=green]Loading Recording Data...[/color]")
		
			for input in input_array:
				InputMap.action_erase_events(input)
				input_sim.append(InputEventAction.new())
				input_sim[input_sim.size() - 1].set_action(input)
				input_sim[input_sim.size() - 1].set_pressed(false)
				Input.parse_input_event(input_sim[input_sim.size() - 1])
			
			replay_setup = true
		
		if replay_setup:
			recording_timer += 1
		
		if recording_data.p1_data[recording_reader_p1] == [recording_timer, null]:
			_finish_replay()
		else:
			if recording_timer <= recording_data.p1_data[recording_data.p1_data.size() - 1][0]:
				if recording_timer == recording_data.p1_data[recording_reader_p1][0]:

					for input in input_array:
						if input_array.find(input) < 15:
							_parse_input(input_array.find(input) + 2)
					
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: " + str(recording_timer) + " Data:" + str(recording_data.p1_data[recording_reader_p1]) + " Index: " + str(recording_reader_p1) + "[/color]")
					
					recording_reader_p1 += 1
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: " + str(recording_timer) + " Data: [/color][color=red]NONE[/color]")
		
				if recording_reader_p2 <= recording_data["p2_data"].size() - 1:
					if recording_timer == recording_data.p2_data[recording_reader_p2][0]:
						EventBus.p2talk_type.emit(
													recording_data.p2_data[recording_reader_p2][1],
													recording_data.p2_data[recording_reader_p2][2]
												)
						
						if Console.recording_parse:
								Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: " + str(recording_timer) + " Data:" + str(recording_data.p2_data[recording_reader_p2]) + " Index: " + str(recording_reader_p2) + "[/color]")
						
						recording_reader_p2 += 1
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: " + str(recording_timer) + " Data: [/color][color=red]NONE[/color]")


func _parse_input(index: int) -> void:
	if recording_data.p1_data[recording_reader_p1][index] != 0:
		var _parsed_button: bool = _number_parser(recording_data.p1_data[recording_reader_p1][index])
		input_sim[index - 1].set_pressed(_parsed_button)
		Input.parse_input_event(input_sim[index - 1])


func start_recording() -> void:
	if recording_data == null:
		recording_data = RecordingData.new()
		recording = true
		Console.console_log("[color=blue]Recording Started.[/color]")


func stop_recording() -> void:
	if recording_data != null && recording:
		recording_data.p1_data.push_back([recording_timer, null])
		recording_data.name =  "auto-" + recording_name()
		ResourceSaver.save(recording_data, "user://recordings/" + recording_data.name + ".tres")
	
	recording = false
	recording_timer = 0
	recording_setup = false
	recording_data = null
	
	Console.console_log("[color=blue]Recording Stopped.[/color]")


func cancel_recording() -> void:
	recording = false
	recording_timer = 0
	recording_setup = false
	recording_data = null
	
	Console.console_log("[color=blue]Recording was discarded.[/color]")


func _number_parser(number: int) -> bool:
	if number==1:
		return true
	else:
		return false


func check_input() -> bool:
	for action in InputMap.get_actions():
		if input_array.find(action) != -1:
			if Input.is_action_just_pressed(action) or Input.is_action_just_released(action):
				return true

	return false


func _check_input_type(key: String) -> int:
	if Input.is_action_just_pressed(key):
		return 1
	if Input.is_action_just_released(key):
		return 2
	
	return 0


func _on_p2talk_pressed(p2talkword: String, p2talkbuttons: String) -> void:
	if recording:
		recording_data.p2_data.push_back([recording_timer, p2talkword, p2talkbuttons])


func _finish_replay() -> void:
	Console.console_log("[color=red]RECORDING IS OVER[/color]")
	InputMap.load_from_project_settings()
	replay = false
	replay_setup = false
	recording_timer = 0
	recording_reader_p1 = 0
	recording_reader_p2 = 0
	Global.is_game_paused = false
	
	if !demo:
		var previous_load_preset: LoadingPreset = SaveManager.get_data().loading_preset
		
		Global.warp_to(SaveManager.get_data().room_path, previous_load_preset)
		
		await get_tree().create_timer(HUD.FADE_SPEED).timeout
		
		HUD.display_label(false, "", 0)
	else:
		demo = false
		GameManager.reset_game()
	
	SaveManager.set_data(temp_data)


func load_recording(filename: String, gen: int = 8) -> void:
	temp_data = SaveManager.get_data().duplicate(true)
	
	if ResourceLoader.exists("user://recordings/" + filename + ".tres"):
		stop_recording()
		
		recording_data = load("user://recordings/" + filename + ".tres")
		
		SaveManager.set_data(recording_data.save_data)
		
		Global.global_data.gen = gen
		
		Global.warp_to(recording_data.save_data.room_path, recording_data.save_data.loading_preset)
		Console.console_log("[color=blue]Loaded Game Data from Recording sucessfully! Replaying inputs...[/color]")
		
		await get_tree().create_timer(HUD.FADE_SPEED).timeout
		
		if !demo:
			HUD.display_label(true, filename , gen)
		
		HUD.demo_card.play(&"on")
		
		await EventBus.start_scene
		
		replay = true
	else:
		Console.console_log("[color=red]Recording file \"" + filename + "\" was not found![/color]")


func is_recording() -> bool:
	if recording:
		return true
	else:
		return false


func recording_name() -> String:
	var counter: int = 0
	var recording_filename: String = ""
	var letters: Array[String] = [
									"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
									"p","q","r","s","t","u","v","w","x","y","z","A","B","C","D",
									"E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S",
									"T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7",
									"8","9"
								]
	
	while counter < 8:
		recording_filename += letters.pick_random()
		counter += 1
	
	return recording_filename
