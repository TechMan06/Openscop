extends Node2D
class_name ChildFace

signal loading_finished

var horizontal_offset_counter: int = 0
var vertical_offset_counter: int = 0
var selected: bool = false

@export var vertical_offsets: Array[int]
@export var horizontal_offsets: Array[int]
@export var expression: Array[int]


func _ready() -> void:
	for face_piece in get_children():
		if face_piece is FacePiece:
			expression.append(0)
			
			if face_piece.horizontal_placement != 1:
				horizontal_offsets.append(0)
			
			if face_piece.vertical_placement != 1:
				vertical_offsets.append(0)
	
	update()


func update_color(value: bool) -> void:
	for face_piece in get_children():
		face_piece.selected = value
		face_piece.update()
		
		if face_piece.get_child_count() > 0:
			for face_piece_child in face_piece.get_children():
				face_piece_child.selected = value
				face_piece_child.update()


func update() -> void:
	vertical_offset_counter = 0
	horizontal_offset_counter = 0
	
	for face_piece in get_children():
		if face_piece is FacePiece:
			face_piece.expression = expression[face_piece.get_index()]

			if (
					face_piece.horizontal_placement != 1 and 
					horizontal_offset_counter < horizontal_offsets.size()
				):
				face_piece.horizontal_offset = horizontal_offsets[horizontal_offset_counter]
				horizontal_offset_counter += 1
			
			if (
					face_piece.vertical_placement != 1 and 
					vertical_offset_counter < vertical_offsets.size()
				):
				face_piece.vertical_offset = vertical_offsets[vertical_offset_counter]
				vertical_offset_counter += 1
			
			face_piece.update()
