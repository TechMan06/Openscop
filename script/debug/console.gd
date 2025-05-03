extends Window

signal load_recording(filename: String)
signal nifty
signal set_camera(cam_mode: int)

#SHOUTOUTS TO IZZINT
# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input: LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output: RichTextLabel
@export var parse_button: Button

var recording_parse: bool = false


func _ready() -> void:
	if !OS.has_feature("movie"):
		visible = false
	
	console_log("\n\n[color=red]Welcome to the [color=purple]Openscop[/color] Console/Developer Menu.\nThis special menu contains a lot of tools that can help you with debugging Openscop's source code, toggle variables without having to edit the code, trigger events, and debug the game. It can also be used as an aid during the process of making your fangame or fan video.\nI'd like to thank Izzint for first implementing this into Openscop![/color]")
	#console_log("\n[color=yellow]For information and commands list, check the Docs![/color]")
	parse_button.pressed.connect(_submit_command)
	
	if OS.has_feature("movie"):
		console_log("\n[color=yellow]MOVIE WRITER IS ENABLED, RECORDING MOVIE...[/color]\n\n")
		


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") && console_input.text != "":
		_submit_command()


func _submit_command() -> void:
	var command_array: PackedStringArray = console_input.text.split(" ")
	console_input.text = ""
	_parse_command(command_array)


func _parse_command(input : Array) -> void:
	console_log("[color=yellow]Command parsed: [/color]" + input[0])
	
	match input[0]:
		"!toggle_parse":
			recording_parse=!recording_parse
			console_log("[color=purple]Toggled Print Recording to:[/color] [color=yellow]" + str(recording_parse).to_upper() + "[/color]")
		"!start_rec":
			if !RecordingManager.replay:
				RecordingManager.start_recording()
			else:
				console_log("[color=red]Cannot Record during Replay.[/color]")
		"!stop_rec":
			if !RecordingManager.replay:
				RecordingManager.stop_recording()
			else:
				console_log("[color=red]Cannot stop Recording during Replay.[/color]")
		"!cancel_rec":
			if !RecordingManager.replay:
				RecordingManager.cancel_recording()
			else:
				console_log("[color=red]Cannot cancel Recording during Replay.[/color]")
		"!reset_game":
			GameManager.reset_game()
		"!hard_reset":
			GameManager.hard_reset_game()
		"!nifty":
			nifty.emit()
		"!set_char":
			if check_valid_argument(input) != "":
				load("res://resource/stat/player.tres").character_id = int(input[1])
				
				if int(input[1]) >= 0 && int(input[1]) <= 2:
					match input[1]:
						"0":
							console_log("[color=purple]Character set to ID:[/color][color=yellow] 0[/color][color=purple], Paul/Default[/color]")
						"1":
							console_log("[color=purple]Character set to ID:[/color][color=yellow] 1[/color][color=purple], Belle[/color]")
						"2":
							console_log("[color=purple]Character set to ID:[/color][color=yellow] 1[/color][color=purple], Marvin[/color]")
				else:
					console_log("[color=yellow]Invalid Character, game may still work but with NULL character!.\nIdeally Choose between [/color][color=yellow]0 = Paul[/color][color=red], [/color][color=yellow]1 = Belle[/color][color=red], [/color][color=yellow]2 = Marvin[/color][color=red]![/color]")
			else:
				console_log("[color=red]Invalid Character! Choose between [/color][color=yellow]0 = Paul[/color][color=red], [/color][color=yellow]1 = Belle[/color][color=red], [/color][color=yellow]2 = Marvin[/color][color=red]![/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!set_char 0[/color]")
		"!load_rec":
			if check_valid_argument(input) != "":
				load_recording.emit(input[1])
			else:
				console_log("[color=red]Command \"!load_recording\" is missing argument \"Recording Name\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_recording auto-Vt7C8EuZ[/color]")
		"!set_gen":
			if check_valid_argument(input) != "":
				if int(input[1]) >= 1 && int(input[1]) <= 15:
					Global.global_data.gen = int(input[1])
					console_log("[color=purple]Gen set to:[/color] [color=yellow]" + input[1] + "[/color]")
				else:
					console_log("[color=red]Invalid Gen! Choose between [/color][color=yellow]1[/color][color=red] to [color=yellow]15[/color][color=red]![/color]")
			else:
				console_log("[color=red]Command \"!set_gen\" is missing argument \"Gen Number\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!set_gen 8[/color]")
		"!save_slot":
			if check_valid_argument(input) != "":
				SaveManager.save_slot(int(input[1]))
				console_log("[color=purple]Saved Game to Slot:[/color] [color=yellow]" + input[1] + "[/color]")
			else:
				console_log("[color=red]Command \"!save_slot\" is missing argument \"Save Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!save_slot 0[/color]")
		"!load_slot":
			if check_valid_argument(input) != "":
				SaveManager.load_slot(int(input[1]))
				console_log("[color=purple]Loaded Slot:[/color] [color=yellow]" + input[1] + "[/color][color=purple] Data[/color]")
			else:
				console_log("[color=red]Command \"!load_slot\" is missing argument \"Data Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_slot 0[/color]")
		"!load_game":
			if check_valid_argument(input) != "":
				SaveManager.load_game(int(input[1]))
				console_log("[color=purple]Loaded Game:[/color] [color=yellow]" + input[1] + "[/color][color=purple] Data[/color]")
			else:
				console_log("[color=red]Command \"!load_game\" is missing argument \"Data Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_game 0[/color]")
		"!set_camera":
			match check_valid_argument(input):
				"copy":
					set_camera.emit(0)
				"follow":
					set_camera.emit(1)
				"pov":
					set_camera.emit(2)
				"lerp":
					set_camera.emit(3)
				"no_code":
					set_camera.emit(5)
				"static":
					set_camera.emit(6)
				"free":
					set_camera.emit(7)
				_:
					console_log("[color=red]This Camera Mode does not exist[/color]")
					console_log("[color=red]Valid Modes:[/color] [color=yellow]copy[/color], [color=yellow]follow[/color], [color=yellow]pov[/color], [color=yellow]lerp[/color], [color=yellow]no_code[/color], [color=yellow]static[/color], [color=yellow]free[/color].")
		"!crash_game":
			Global.crash_game()
		_:
			console_log("[color=red]Invalid Command![/color]")


func check_valid_argument(input: Array) -> String:
	if input.size() > 1:
		return input[1]
	else:
		return ""


func console_log(input: String) -> void:
	console_output.append_text(input)
	console_output.newline()
	console_input.clear()
