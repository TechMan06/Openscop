extends Resource
class_name SaveData

#BASIC DATA
@export var player_data: PlayerStats = PlayerStats.new()
@export var save_name: String = ""
@export var room_name: String = ""
@export var loading_preset: LoadingPreset
@export var room_path: String = ""
#ROOM INFO
@export var piece_log: Dictionary = {}
#GAME
@export var pet: Array[String]
@export var corrupted: bool
