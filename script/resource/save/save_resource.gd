extends Resource
class_name SaveData

## The template Resource used for Openscop's save data, it is also used to store save data in recordings in the [RecordingData] [Resource]. 

#BASIC DATA
## Save file specific randomization seed used by some random events in the game, such as where Randice is going to move to when there are more than 3 possible positions for it.
@export var save_seed: int = 0
## The player's data, uses a [PlayerStats] [Resource].
@export var player_data: PlayerStats = PlayerStats.new()
## Name of the save file
@export var save_name: String = ""
## Name of the room.
@export var room_name: String = ""
## Loading preset of the room the game was saved at, uses [LoadingPreset] [Resource].
@export var loading_preset: LoadingPreset
## File path within the game's files for the [LoadingPreset] of the room the game was saved at.
@export var loading_preset_path: String
## File path within the game's files to the room the game was saved at.
@export var room_path: String = ""
#ROOM INFO
## A log of all pieces collected throughout the game to prevent them from respawning.
@export var piece_log: Dictionary = {}
## Whether the player is carrying a bucket or not at the moment.
@export var has_bucket: bool = false
## Direction of the bucket in relation to the player.
@export var bucket_direction: int = 0
#GAME
## Stores the pets collected so far.
@export var pet: Array[String] = []
## Flag used for displaying the "PANICSV" warning on the file when displayed on the file selected.
@export var corrupted: bool
## Flag used for unlocking the Newmaker Plane
@export var unlocked_nmp: bool = false
## Flag used for when Odd Care has been unlocked using Lina's room.
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
