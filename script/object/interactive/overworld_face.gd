extends Marker3D

@export var id: int = 0
@export var use_custom_expression: bool = false
@export var update_on_signal: bool = true
@export var expression: Array[int]
@export var vertical_offsets: Array[int]
@export var horizontal_offsets: Array[int]
@export var special_faces: Array[FaceResource]

@onready var face = %Face


func _ready() -> void:
	EventBus.create_face.connect(check_face)
	
	face.id = id
	
	if use_custom_expression:
		face.visible = true
		face.update()


func check_face(
						new_id: int,
						new_expression: Array[int], 
						new_horizontal_offset: Array[int], 
						new_vertical_offset: Array[int]
					) -> void:
	for _face in special_faces:
		if (  
				_face != null and
				id == new_id and
				_face.textbox != "" and
				_face.expression == new_expression and
				_face.horizontal_offsets == new_horizontal_offset and
				_face.vertical_offsets == new_vertical_offset
			):
			HUD.create_textbox(load("res://resource/textbox/darkest.tres"), _face.textbox)
	
	EventBus.camera_earthquake.emit(true)
	EventBus.camera_shake_amount.emit(0.0)
	EventBus.camera_shake_speed.emit(37.0)
