extends Marker3D
class_name TreadmillCounter

## Class for the Counter used alongside Pen's Treadmill in Even Care and Odd Care.

var current_value: int = 0: ## Current value of the counter
	set(value):
		if is_ready:
			if !petal_sounds:
				$CounterBeep.play()
			else:
				if value % 2 == 0:
					$PetalOdd.play()
				else:
					$PetalEven.play()
		
		current_value = value
	
var sheet_offset: int = 1 ## Offset of the counter's spritesheet
var is_ready: bool = false ## Used for defining whether the treadmill is ready before playing the counter's sound effects when the value changes, prevents the sound effect from playing as soon as the counter spawns

@export var default_value: int = 5 ## Value the counter starts at.
@export var min_max_value: Vector2i = Vector2i(2, 7) ## Minimum and maximum value of the counter.
@export var treadmill: Treadmill ## Pen treadmill that this object is assigned to, should be of class [Treadmill].
@export var odd_number_counter: bool = false ## Defines whether odd numbers in the counter should be colored red.
@export var cycle: bool = true ## Whether to stop counting when the counter goes beyond the maximum value or start over from the beginning.
@export var petal_sounds: bool = false ## Whether to play sound effects when the counter's value changes.
@export var save_petals: bool = false ## Whether to save the data of this counter to the save file.

@onready var treadmill_sprite: Sprite3D = $TreadmillSprite ## [Sprite3D] object for the counter's sprite.


func _ready() -> void:
	if odd_number_counter:
		sheet_offset += treadmill_sprite.hframes
	
	current_value = default_value
	treadmill_sprite.frame = sheet_offset + current_value
	
	if treadmill != null:
		treadmill.add_number.connect(_add_number)
	
	is_ready = true


## This function is used for adding or subtracting the counter's value.
## It's responsible for cycling or clamping the counter, crashing the game on Odd Care demos and saving the current value to the save file.
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
		SaveManager.get_data().petals = current_value
