extends Marker3D
class_name TreadmillCounter

var current_value: int = 0
var sheet_offset: int = 1

@export var default_value: int = 5
@export var min_max_value: Vector2i = Vector2i(2, 7)
@export var treadmill: Treadmill

@onready var treadmill_sprite: Sprite3D = $TreadmillSprite


func _ready() -> void:
	current_value = default_value
	treadmill_sprite.frame = sheet_offset + current_value
	
	if treadmill != null:
		treadmill.add_number.connect(_add_number)


func _add_number(backward: bool) -> void:
	if backward:
		current_value -= 1
		
		if current_value < min_max_value.x:
			current_value = min_max_value.y
	else:
		current_value += 1
		
		if current_value > min_max_value.y:
			current_value = min_max_value.x
	
	treadmill_sprite.frame = sheet_offset + current_value
	$CounterBeep.play()
