extends Node2D

const FACE_EXPRESSION: PackedScene = preload("res://scene/ui/face_template.tscn")
const MAX_OFFSETS: int = 3

var id: int = 0
var current_state: int = 0
var expression_counter: int = 0
var current_option: int = 0
var options_available: int = 0
var face_counter: int = 0
var selectable: bool = false
var offset_limit: int = 0
var face_sent: bool = false

var vertical_offsets: Array[int]
var horizontal_offsets: Array[int]
var expression: Array[int]


@export var slides: Array[CanvasSlideResource]

@onready var faces: Marker2D = %Faces


func _ready():
	var face: ChildFace = FACE_EXPRESSION.instantiate()
	
	SaveManager.get_data().player_data.input_enabled = false
	
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
			match slides[current_state].affect:
				0:
					expression[slides[current_state].index_of_child_affected] = current_option
				1:
					vertical_offsets[
										slides[current_state].index_of_child_affected
									] = current_option
				2:
					horizontal_offsets[
											slides[current_state].index_of_child_affected
										] = current_option
			
			current_state += 1
			
			if current_state == slides.size():
				if !face_sent:
					EventBus.create_face.emit(id, expression, horizontal_offsets, vertical_offsets)
					print("EXPRESSION: " + str(expression) + "\nHORIZONTAL_OFFSETS: " + str(horizontal_offsets) + "\nVERTICAL_OFFSETS: " + str(vertical_offsets))
					face_sent = true
				
				SaveManager.get_data().player_data.input_enabled = true
				queue_free()
			else:
				refresh()
		
		if Input.is_action_just_pressed("pressed_triangle"):
			if current_state != 0:
				match slides[current_state].affect:
					0:
						expression[slides[current_state].index_of_child_affected] = 0
					1:
						vertical_offsets[
											slides[current_state].index_of_child_affected
										] = 0
					2:
						horizontal_offsets[
												slides[current_state].index_of_child_affected
											] = 0
				
				current_state -= 1
				
				refresh()
			else:
				SaveManager.get_data().player_data.input_enabled = true
				queue_free()


func refresh() -> void:
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
	
	match slides[current_state].affect:
		0:
			if current_state < expression_counter:
				options_available = counter_face.get_child(
																current_state
															).resource.variations - 1
			
				if counter_face.get_child(current_state).resource.has_none_option:
					options_available += 1
		1:
			options_available = counter_face.get_child(
															slides[
																		current_state
																	].index_of_child_affected
														).max_offset_options_vertical
		2:
			options_available = counter_face.get_child(
															slides[
																		current_state
																	].index_of_child_affected
														).max_offset_options_horizontal
		
	counter_face.queue_free()

	while face_counter <= options_available:
		var face: ChildFace = FACE_EXPRESSION.instantiate()

		faces.add_child(face)
		
		if face_counter == 0:
			face.selected = true
			face.update_color(true)
		
		face.vertical_offsets = vertical_offsets
		face.horizontal_offsets = horizontal_offsets
		face.expression = expression
		
		match slides[current_state].affect:
			0:
				face.expression[slides[current_state].index_of_child_affected] = face_counter
			1:
				face.vertical_offsets[
											slides[current_state].index_of_child_affected
										] = face_counter
			2:
				face.horizontal_offsets[
											slides[
														current_state
													].index_of_child_affected
										] = face_counter
		
		face.position = Vector2(20 * face_counter, 35 * face_counter)
		
		face.update()
		
		face_counter += 1
		
		for expression in face.get_children():
			if expression.get_index() > current_state:
				expression.queue_free()
	
	selectable = true
