extends Resource
class_name SaveData

## The template Resource used for Openscop's save data, it is also used to store save data in recordings in the [RecordingData] [Resource]. 

#BASIC DATA
@export var save_seed: int = 0 ## Save file specific randomization seed used by some random events in the game, such as where Randice is going to move to when there are more than 3 possible positions for it.
@export var player_data: PlayerStats = PlayerStats.new() ## The player's data, uses a [PlayerStats] [Resource].
@export var save_name: String = "" ## Name of the save file
@export var room_name: String = "" ## Name of the room.
@export var loading_preset: LoadingPreset ## Loading preset of the room the game was saved at, uses [LoadingPreset] [Resource].
@export var loading_preset_path: String ## File path within the game's files for the [LoadingPreset] of the room the game was saved at.
@export var room_path: String = "" ## File path within the game's files to the room the game was saved at.
#ROOM INFO
@export var piece_log: Dictionary = {} ## A log of all pieces collected throughout the game to prevent them from respawning.
@export var has_bucket: bool = false ## Whether the player is carrying a bucket or not at the moment.
@export var bucket_direction: int = 0 ## Direction of the bucket in relation to the player.
#GAME
@export var pet: Array[String] = [] ## Stores the pets collected so far.
@export var corrupted: bool ## Flag used for displaying the "PANICSV" warning on the file when displayed on the file selected.
@export var unlocked_nmp: bool = false ## Flag used for unlocking the Newmaker Plane
@export var unlocked_odd_care: bool = false ## Flag used for when Odd Care has been unlocked using Lina's room.
@export var petals: int = 0 ## Petals plucked off a flower or a treadmill. By default only the flower on the Newmaker Plane shed or the Odd Care Pen treadmill save values to this variable.
@export var cage: Dictionary = {} ## Stores the states of all cages in the game. By default only the two cages in Odd Care are saved to this variable.
@export var trapdoor: Dictionary = {} ## Stores the states of all trapdoors in the game. By default only the trapdoors in the Newmaker Plane are saved to this variable.
@export var anna_phone: Array[int] ## Stores the states for all the phones in the game. By default only Anna's phone is saved.
@export var wheel: Dictionary ## Stores the states for all the wheels in the game. By default only the Machine Room and Child Library wheel are saved.
@export var library_pet: Array[String] ## Stores the pets stored in the Child Library.
@export var library_face: FaceResource = null ## Stores the currently loaded face bedroom in the Child Library. Default value is [code]null[/code]
#MISC
## Stores all the sounds unlocked in the Sound Test so far.
@export var sounds: Array[String] = [
	"res://music/garalina.ogg",
	"res://music/petscop.ogg",
	"res://sfx/pets/care_bye_bye.wav",
	"res://sfx/pets/care_uh_oh.wav"
]
