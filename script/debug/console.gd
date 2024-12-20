extends Window

signal load_recording(filename: String)
signal nifty

#SHOUTOUTS TO IZZINT
# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input: LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output: RichTextLabel

var recording_parse: bool = true


func _ready() -> void:
	visible = false
	console_log("\n\n[color=red]Welcome to the [color=purple]Openscop[/color] Console/Developer Menu.\nThis special menu contains a lot of tools that can help you with debugging Openscop's source code, toggle variables without having to edit the code, trigger events, and debug the game. It can also be used as an aid during the process of making your fangame or fan video.\nI'd like to thank Izzint for first implementing this into Openscop![/color]")
	#console_log("\n[color=yellow]For information and commands list, check the Docs![/color]")


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_accept") && console_input.text != "":
		var command_array = console_input.text.split(" ")
		console_input.text = ""
		_parse_command(command_array)


func _parse_command(input : Array) -> void:
	console_log("[color=yellow]Command parsed: [/color]" + input[0])
	
	match input[0]:
		"!toggle_parse":
			recording_parse=!recording_parse
			console_log("[color=purple]Toggled Print Recording to:[/color] [color=yellow]" + str(recording_parse).to_upper() + "[/color]")
		"!start_recording":
			if !RecordingManager.replay:
				RecordingManager.start_recording()
			else:
				console_log("[color=red]Cannot Record during Replay.[/color]")
		"!stop_recording":
			if !RecordingManager.replay:
				RecordingManager.stop_recording()
			else:
				console_log("[color=red]Cannot stop Recording during Replay.[/color]")
		"!reset_game":
			GameManager.reset_game()
		"!nifty":
			nifty.emit()
		"!set_char":
			if input[1] != "":
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
		"!load_recording":
			if input[1] != "":
				load_recording.emit(input[1])
			else:
				console_log("[color=red]Command \"!load_recording\" is missing argument \"Recording Name\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_recording auto-Vt7C8EuZ[/color]")
		"!set_gen":
			if input[1] != "":
				if int(input[1]) >= 1 && int(input[1]) <= 15:
					Global.global_data.gen = int(input[1])
					console_log("[color=purple]Gen set to:[/color] [color=yellow]" + input[1] + "[/color]")
				else:
					console_log("[color=red]Invalid Gen! Choose between [/color][color=yellow]1[/color][color=red] to [color=yellow]15[/color][color=red]![/color]")
			else:
				console_log("[color=red]Command \"!set_gen\" is missing argument \"Gen Number\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!set_gen 8[/color]")
		"!save_slot":
			if input[1] != "":
				SaveManager.save_slot(int(input[1]))
				console_log("[color=purple]Saved Game to Slot:[/color] [color=yellow]" + input[1] + "[/color]")
			else:
				console_log("[color=red]Command \"!save_slot\" is missing argument \"Save Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!save_slot 0[/color]")
		"!load_slot":
			if input[1] != "":
				SaveManager.load_slot(int(input[1]))
				console_log("[color=purple]Loaded Slot:[/color] [color=yellow]" + input[1] + "[/color][color=purple] Data[/color]")
			else:
				console_log("[color=red]Command \"!load_slot\" is missing argument \"Data Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_slot 0[/color]")
		"!load_game":
			if input[1] != "":
				SaveManager.load_game(int(input[1]))
				console_log("[color=purple]Loaded Game:[/color] [color=yellow]" + input[1] + "[/color][color=purple] Data[/color]")
			else:
				console_log("[color=red]Command \"!load_game\" is missing argument \"Data Slot\"[/color]")
				console_log("[color=red]Formatting Example:[/color] [color=yellow]!load_game 0[/color]")
		_:
			console_log("[color=red]Invalid Command![/color]")


func console_log(input) -> void:
	console_output.append_text(input)
	console_output.newline()
	console_input.clear()
