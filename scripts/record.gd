extends Node

var replay = false
var replay_setup = false
var recording = false
var recording_setup = false
var recording_finished = false
var menu_loading = false
var title_loading = false

var recording_timer = 0
var recording_reader_p1 = 0
var recording_reader_p2 = 0
var recording_data = {}

var temporary_data = {}




var input_sim_r1 = null
var input_sim_r2 = null
var input_sim_l1 = null
var input_sim_l2 = null
var input_sim_up = null
var input_sim_down = null
var input_sim_left = null
var input_sim_right = null
var input_sim_action = null
var input_sim_triangle = null
var input_sim_circle = null
var input_sim_square = null
var input_sim_select = null
var input_sim_start = null


var parsed_input_left = false

func current_data():
	pass

func start_recording():
	pass
	
func stop_recording():
	pass
	
func number_parser(number):
	pass
		
func check_pressed():
	pass

func check_input():
	pass

func check_input_type(key):
	pass

func _process(_delta):
	pass
		
func finish_replay():
	pass
	
func load_recording(file, gen: int = 8, menu: bool = false, title: bool = false):
	pass
