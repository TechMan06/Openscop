extends Resource
class_name RecordingData

@export var name: String
@export var gen: int = Global.global_data.gen
@export var memcard: bool = true
@export var rotation: bool = true
@export var creation_date: float = Time.get_unix_time_from_system()
@export var save_data: SaveData = SaveManager.get_data().duplicate(true)
@export var p1_data: Array[Array]
@export var p2_data: Array[Array]
