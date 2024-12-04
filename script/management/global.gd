extends Node

signal boot_game

var global_data: GlobalData = load("res://resource/management/global_data.tres")
var custom_sheet: ImageTexture
var is_game_paused: bool
var p2talk_dict: Dictionary = JSON.parse_string(
								(FileAccess.open("res://json/p2_talk_data.json", 
								FileAccess.READ)
								).get_as_text()
							)
var dialogue_dict: Dictionary = JSON.parse_string(
							(FileAccess.open("res://json/dialogue.json", 
							FileAccess.READ)
							).get_as_text()
						)
var can_pause: bool = true
var can_unpause: bool
var current_slot: int = 0
var current_controller: int = 0


func _ready() -> void:
	var _directory = DirAccess.open("user://")
	var _directories = ["sheets", "savedata", "screenshots", "recordings"]
	for _folder in _directories:
		if !_directory.dir_exists(_folder):
			_directory.make_dir(_folder)
	
	await get_tree().process_frame
	
	if GameManager.debug_settings.custom_sheet != "":
		GameManager.file_dialog._on_sheet_selected(GameManager.debug_settings.custom_sheet)
	
	GameManager.file_dialog.set_root_subfolder("user://sheets")
	
	
	if ResourceLoader.exists("user://savedata/global.tres"):
		global_data = load("user://savedata/global.tres")
	else:
		save_global()

	boot_game.emit()


func save_global() -> void:
	ResourceSaver.save(global_data, "user://savedata/global.tres")


func warp_to(scene_path: String, preset) -> void:
	var _loading_preset: LoadingPreset = null
	
	if preset is String:
		_loading_preset = load(preset)
	else:
		_loading_preset = preset
	
	EventBus.emit_transition.emit(_loading_preset)
	
	await EventBus.start_scene
	
	get_tree().change_scene_to_file(scene_path)


func strip_bbcode(source: String) -> String:
	var _regex = RegEx.new()
	_regex.compile("\\[.+?\\]")
	return _regex.sub(source, "", true)


func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false


func sort_descending(a, b):
	if a[0] > b[0]:
		return true
	return false
