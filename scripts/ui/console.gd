extends Window

# TODO: fix tooltips
@export_category("Console")
## The [LineEdit] to be parsed.
@export var console_input : LineEdit
## The [RichTextLabel] to display Console output.
@export var console_output : RichTextLabel

var recording_parse = false
	
func _parse_command(input : Array):
	match input[0]:
		"!toggle_parse":
			recording_parse=!recording_parse
			console_log("[color=purple]Toggled Print Recording to[/color] [color=yellow]"+str(recording_parse).to_upper()+"[/color]")
		"!caught":
			Global.caught()
			console_log("[color=blue]CAUGHT![/color]")
		"!debug":
			Global.debug = !Global.debug
			console_log("[color=blue]DEBUG Toggled[/color]")
		"!shutup":
			bg_music.stop()
			console_log("[color=blue]Music is now mute[/color]")
		"!reset":
			get_tree().change_scene_to_file("res://scenes/rooms/garalina.tscn")
			console_log("[color=blue]Game Reset.[/color]")
		"!nifty":
			Global.nifty()
			console_log("[color=blue]The Nifty Menu has been opened.[/color]")
		"!start_recording":
			if !Record.replay:
				Record.start_recording()
			else:
				console_log("[color=red]Cannot Record during Replay.[/color]")
		"!stop_recording":
			if !Record.replay:
				Record.stop_recording()
			else:
				console_log("[color=red]Cannot stop Recording during Replay.[/color]")
		#"!replay_recording":
			#Record.replay = true
		#"!load_rectest":
			#Record.load_recording("rec_test")
		"!set_slot_1":
			Global.picked_slot = 1
			console_log("[color=green]Current Save Slot is now 1[/color]")
		"!set_slot_2":
			Global.picked_slot = 2
			console_log("[color=green]Current Save Slot is now 2[/color]")
		"!set_slot_3":
			Global.picked_slot =3
			console_log("[color=green]Current Save Slot is now 3[/color]")
		"!save_game_0":
			if !Record.replay:
				Global.save_game(0)
				console_log("[color=green]Game Data Saved to Slot 1[/color]")
			else:
				console_log("[color=red]Cannot Save Game during Recording Replay.[/color]")
		"!save_game_1":
			if !Record.replay:
				Global.save_game(1)
				console_log("[color=green]Game Data Saved to Slot 2[/color]")
			else:
				console_log("[color=red]Cannot Save Game during Recording Replay.[/color]")
		"!save_game_2":
			if !Record.replay:
				Global.save_game(2)
				console_log("[color=green]Game Data Saved to Slot 3[/color]")
			else:
				console_log("[color=red]Cannot Save Game during Recording Replay.[/color]")
		"!load_game_0":
			if !Record.replay:
				Global.load_game(0)
				console_log("[color=green]Slot 1 Game Data Loaded[/color]")
			else:
				console_log("[color=red]Cannot Load Game during Recording Replay.[/color]")
		"!load_game_1":
			if !Record.replay:
				Global.load_game(1)
				console_log("[color=green]Slot 2 Game Data Loaded[/color]")
			else:
				console_log("[color=red]Cannot Load Game during Recording Replay.[/color]")
		"!load_game_2":
			if !Record.replay:
				Global.load_game(2)
				console_log("[color=green]Slot 3 Game Data Loaded[/color]")
			else:
				console_log("[color=red]Cannot Load Game during Recording Replay.[/color]")
		"!set_gen_1":
			Global.gen = 1
			console_log("[color=green]Gen set to 1[/color]")
		"!set_gen_2":
			Global.gen = 2
			console_log("[color=green]Gen set to 2[/color]")
		"!set_gen_3":
			Global.gen = 3
			console_log("[color=green]Gen set to 3[/color]")
		"!set_gen_4":
			Global.gen = 4
			console_log("[color=green]Gen set to 4[/color]")
		"!set_gen_5":
			Global.gen = 5
			console_log("[color=green]Gen set to 5[/color]")
		"!set_gen_6":
			Global.gen = 6
			console_log("[color=green]Gen set to 6[/color]")
		"!set_gen_7":
			Global.gen = 7
			console_log("[color=green]Gen set to 7[/color]")
		"!set_gen_8":
			Global.gen = 8
			console_log("[color=green]Gen set to 8[/color]")
		"!set_gen_9":
			Global.gen = 9
			console_log("[color=green]Gen set to 9[/color]")
		"!set_gen_10":
			Global.gen = 10
			console_log("[color=green]Gen set to 10[/color]")
		"!set_gen_11":
			Global.gen = 11
			console_log("[color=green]Gen set to 11[/color]")
		"!set_gen_12":
			Global.gen = 12
			console_log("[color=green]Gen set to 12[/color]")
		"!set_gen_13":
			Global.gen = 13
			console_log("[color=green]Gen set to 13[/color]")
		"!set_gen_14":
			Global.gen = 14
			console_log("[color=green]Gen set to 14[/color]")
		"!set_gen_15":
			Global.gen = 15
			console_log("[color=green]Gen set to 15[/color]")
		"!set_char_0":
			Global.current_character = 0
			console_log("[color=green]Character set to Paul/Default[/color]")
		"!set_char_1":
			Global.current_character = 1
			console_log("[color=green]Character set to Belle[/color]")
		"!set_char_2":
			Global.current_character = 2
			console_log("[color=green]Character set to Marvin[/color]")
		"!set_char_null":
			Global.current_character = 3
			console_log("[color=red]Character set to NULL[/color]")
		"!get_gen":
			console_log("[color=yellow]Current Gen is: "+str(Global.gen)+"[/color]")
		"!get_char":
			console_log("[color=yellow]Current Character is: "+str(Global.current_character)+"[/color]")
			console_log("[color=yellow]PAUL/DEFAULT= 0    BELLE = 1    MARVIN = 2    NULL = ETC.[/color]")
		"!show_sheets":
			Global.update_sheets = !Global.update_sheets
			console_log("[color=blue]Sheet Visibility toggled to [/color][color=yellow]"+str(Global.update_sheets)+"[/color]")
		_:
			console_log("[color=red]Invalid Command[/color]")
			
func console_log(input):
	console_output.append_text(input)
	console_output.newline()
	console_input.clear()

func _close_requested():
	visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") && console_input.text!="":
		var command_array = console_input.text.split(" ")
		console_input.text = ""
		_parse_command(command_array)

func _on_focus_entered():
	if !Record.replay:
		# maybe we should make a recording function to get all the buttons
		var inputs = ["pressed_r1", "pressed_r2", "pressed_l1",
		"pressed_l2", "pressed_up", "pressed_down", "pressed_left",
		"pressed_right", "pressed_action", "pressed_triangle",
		"pressed_circle", "pressed_square", "pressed_select", "pressed_start"]
		
		for button in inputs:
			InputMap.action_erase_events(button);

func _on_focus_exited():
	InputMap.load_from_project_settings()


func _on_visibility_changed():
	if visible:
		console_log("\n\n[color=red]Welcome to the [color=purple]Openscop[/color] Console/Developer Menu.\nThis special menu contains a lot of tools that can help you with debugging Openscop's source code, toggle variables without having to edit the code, trigger events, and debug the game. It can also be used as an aid during the process of making your fangame or fan video.\nI'd like to thank Izzint for first implementing this into Openscop![/color]")
		console_log("\n[color=yellow]For information and commands list, check the Docs![/color]")
		_on_focus_entered()
