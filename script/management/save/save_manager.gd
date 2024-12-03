extends Node


const SAVE_PATH: String = "user://savedata/"

var _data: SaveData = SaveData.new()
var _player_stats: PlayerStats


func _ready() -> void:
	_player_stats = PlayerStats.new()


func get_data() -> SaveData:
	return _data


func set_data(data: SaveData) -> void:
	_data = data.duplicate(true)


func load_data(path) -> void:
	if ResourceLoader.exists(path):
		_data = load(path)


func load_slot(slot: int = 0) -> void:
	if ResourceLoader.exists("user://savedata/save" + str(slot) + ".tres"):
		_data = load("user://savedata/save" + str(slot) + ".tres")


func load_game(slot: int = 0) -> void:
	if ResourceLoader.exists("user://savedata/save" + str(slot) + ".tres"):
		_data = load("user://savedata/save" + str(slot) + ".tres")
		Global.warp_to(_data.room_path, _data.loading_preset)


func save_data(data: SaveData, slot: int) -> void:
	manage_player_data()
	ResourceSaver.save(data, "user://savedata/save" + str(slot) + ".tres")


func save_slot(slot: int = 0) -> void:
	manage_player_data()
	ResourceSaver.save(_data, "user://savedata/save" + str(slot) + ".tres")


func manage_player_data() -> void:
	_data.player_data = _data.player_data.duplicate(true)
	_data.player_data.scene_info = []
	
