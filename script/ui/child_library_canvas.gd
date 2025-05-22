extends Node2D

const FACE_EXPRESSION: PackedScene = preload("res://scene/ui/face_template.tscn")
const MAX_OFFSETS: int = 3

var current_state: int = 0
var expression_counter: int = 0
var horizontal_offset_counter: int = 0
var vertical_offset_counter: int = 0
var current_option: int = 0
var options_available: int = 0
var face_counter: int = 0
var selectable: bool = false

var vertical_offsets: Array[int]
var horizontal_offsets: Array[int]
var expression: Array[int]


@onready var faces: Marker2D = %Faces


func _ready():
	var face: ChildFace = FACE_EXPRESSION.instantiate()
	
	add_child(face)
	
	for face_piece in face.get_children():
		expression.append(0)
		
		if face_piece.horizontal_placement != 1:
			horizontal_offsets.append(0)
			
		if face_piece.vertical_placement != 1:
			vertical_offsets.append(0)
	
	expression_counter = face.get_child_count()
	
	face.queue_free()
	
	update()


func _process(_delta: float) -> void:
	if selectable:
		if Input.is_action_just_pressed("pressed_up") and current_option > 0:
			current_option -= 1
			update_faces()
		
		if Input.is_action_just_pressed("pressed_down") and current_option < options_available:
			current_option += 1
			update_faces()
		
		if Input.is_action_just_pressed("pressed_action"):
			if current_state < expression_counter:
				expression[current_state] = current_option
			
			current_state += 1
			
			refresh()
		
		if Input.is_action_just_pressed("pressed_triangle") and current_state > 0:
			current_state -= 1
			refresh()


func refresh() -> void:
	print(expression)
	face_counter = 0
	current_option = 0
	update()


func update_faces() -> void:
	for face in faces.get_children():
		if face.get_index() == current_option:
			face.selected = true
		else:
			face.selected = false
		
		face.update_color(face.selected)


func update() -> void:
	selectable = false
	
	for old_face in faces.get_children():
		old_face.queue_free()
	
	var counter_face: ChildFace = FACE_EXPRESSION.instantiate()
	
	add_child(counter_face)
	
	if current_state < expression_counter:
		options_available = counter_face.get_child(current_state).resource.variations - 1
		
		if counter_face.get_child(current_state).resource.has_none_option:
			options_available += 1
			
		counter_face.queue_free()

		while face_counter <= options_available:
			var face: ChildFace = FACE_EXPRESSION.instantiate()

			faces.add_child(face)
			
			if face_counter == 0:
				face.selected = true
				face.update_color(true)
			
			face.expression = expression
			face.expression[current_state] = face_counter
			face.position = Vector2(20 * face_counter, 35 * face_counter)
			face.update()
			face_counter += 1
			
			for expression in face.get_children():
				if expression.get_index() > current_state:
					expression.queue_free()
	else:
		counter_face.queue_free()
		
		options_available = MAX_OFFSETS
		
		while face_counter <= MAX_OFFSETS:
			var face: ChildFace = FACE_EXPRESSION.instantiate()

			faces.add_child(face)
			
			if face_counter == 0:
				face.selected = true
				face.update_color(true)
			
			face.expression = expression

			face.vertical_offsets = vertical_offsets
			face.horizontal_offsets = horizontal_offsets
			face.vertical_offsets[vertical_offset_counter] = face_counter
			face.horizontal_offsets[horizontal_offset_counter] = face_counter
			face.position = Vector2(20 * face_counter, 35 * face_counter)
			face.update()
			face_counter += 1
			
			for expression in face.get_children():
				if expression.get_index() > current_state:
					expression.queue_free()
	
	selectable = true
