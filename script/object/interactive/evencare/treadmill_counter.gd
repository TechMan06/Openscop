extends Marker3D
class_name TreadmillCounter

var current_value: int = 0:
	set(value):
		if is_ready:
			if !petal_sounds:
				$CounterBeep.play()
			else:
				if current_value % 2 == 0:
					$PetalOdd.play()
				else:
					$PetalEven.play()
		current_value = value
var sheet_offset: int = 1
var is_ready: bool = false

@export var default_value: int = 5
@export var min_max_value: Vector2i = Vector2i(2, 7)
@export var treadmill: Treadmill
@export var odd_number_counter: bool = false
@export var cycle: bool = true
@export var petal_sounds: bool = false
@export var save_petals: bool = false

@onready var treadmill_sprite: Sprite3D = $TreadmillSprite


func _ready() -> void:
	if odd_number_counter:
		sheet_offset += treadmill_sprite.hframes
	
	current_value = default_value
	treadmill_sprite.frame = sheet_offset + current_value
	
	if treadmill != null:
		treadmill.add_number.connect(_add_number)
	
	is_ready = true

func _add_number(backward: bool) -> void:
	if backward:
		if cycle:
			current_value -= 1
			
			if current_value < min_max_value.x:
				current_value = min_max_value.y
		else:
			if current_value > min_max_value.x:
				current_value -= 1
	else:
		if cycle:
			current_value += 1
			
			if current_value > min_max_value.y:
				current_value = min_max_value.x
		else:
			if current_value < min_max_value.y:
				current_value += 1
	
	treadmill_sprite.frame = sheet_offset + current_value
	
	if RecordingManager.demo and current_value == 0:
		Global.crash_game()
	
	if save_petals:
		EventBus.petal_number_update.emit(current_value)
	
