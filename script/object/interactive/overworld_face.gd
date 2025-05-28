extends Marker3D

@export var id: int = 0
@export var use_custom_expression: bool = false
@export var update_on_signal: bool = true
@export var expression: Array[int]
@export var vertical_offsets: Array[int]
@export var horizontal_offsets: Array[int]

@onready var face = %Face


func _ready() -> void:
	face.id = id
	
	if use_custom_expression:
		face.visible = true
		face.update()
