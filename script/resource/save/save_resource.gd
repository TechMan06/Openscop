extends Resource
class_name SaveData

#BASIC DATA
@export var save_seed: int = 0
@export var player_data: PlayerStats = PlayerStats.new()
@export var save_name: String = ""
@export var room_name: String = ""
@export var loading_preset: LoadingPreset
@export var loading_preset_path: String
@export var room_path: String = ""
#ROOM INFO
@export var piece_log: Dictionary = {}
@export var has_bucket: bool = false
@export var bucket_direction: int = 0
#GAME
@export var pet: Array[String] = ["care_nlm"]
@export var corrupted: bool
@export var unlocked_nmp: bool = false
@export var unlocked_odd_care: bool = false
@export var petals: int = 0
@export var cage: Dictionary = {}
@export var trapdoor: Dictionary = {}
@export var anna_phone: Array[int]
@export var wheel: Dictionary
@export var wheel_pet: Array[String]
@export var library_pet: Array[String]
#MISC
@export var sounds: Array[String] = [
	"res://music/garalina.ogg",
	"res://music/petscop.ogg",
	"res://sfx/pets/care_bye_bye.wav",
	"res://sfx/pets/care_uh_oh.wav"
]
