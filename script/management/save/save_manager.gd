extends Node


## SaveManager Autoload, responsible for creating, loading and providing the game's save data to other parts of the game.


## Path of the SaveData folder, this folder is created by the [Global] autoload in the [method Globa._ready] method.
const SAVE_PATH: String = "user://savedata/"


## The save data, uses a [SaveData] [Resource].
var _data: SaveData = SaveData.new()
var _player_stats: PlayerStats


func _ready() -> void:
	_player_stats = PlayerStats.new()


func get_data() -> SaveData:
	return _data


func set_data(data: SaveData) -> void:
	_data = data.duplicate(true)


func load_data(path: String) -> void:
	if ResourceLoader.exists(path):
		_data = load(path)


func load_slot(slot: int = 0) -> void:
	if ResourceLoader.exists("user://savedata/save" + str(slot) + ".tres"):
		_data = load("user://savedata/save" + str(slot) + ".tres")


func load_game(slot: int = 0) -> void:
	if ResourceLoader.exists("user://savedata/save" + str(slot) + ".tres"):
		_data = load("user://savedata/save" + str(slot) + ".tres")
		
		if (
				Global.global_data.gen < 4 and 
				_data.loading_preset_path == "res://resource/loading_preset/ec.tres"
			):
			_data.loading_preset_path = "res://resource/loading_preset/ec_old.tres"

		Global.warp_to(_data.room_path, load(_data.loading_preset_path))


func save_data(data: SaveData, slot: int) -> void:
	manage_player_data()
	ResourceSaver.save(data, "user://savedata/save" + str(slot) + ".tres")


func save_slot(slot: int = 0) -> void:
	manage_player_data()
	ResourceSaver.save(_data, "user://savedata/save" + str(slot) + ".tres")


func save_odd_care(slot: int = 0) -> void:
	if ResourceLoader.exists("user://savedata/save" + str(slot) + ".tres"):
		var loaded_old_data: SaveData = load("user://savedata/save" + str(slot) + ".tres")
		var old_data: SaveData = loaded_old_data.duplicate(true)
		
		old_data.corrupted = true
		old_data.unlocked_odd_care = _data.unlocked_odd_care
		old_data.petals = _data.petals
		old_data.cage = _data.cage
		
		ResourceSaver.save(old_data, "user://savedata/save" + str(slot) + ".tres")


func manage_player_data() -> void:
	_data.player_data = _data.player_data.duplicate(true)
	_data.player_data.scene_info = []
	
