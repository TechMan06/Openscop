extends Sprite2D
class_name FacePiece


const OFFSET_VALUE_HORIZONTAL: int = 4
const OFFSET_VALUE_VERTICAL: int = 4

var face_shader: Shader = load("res://shader/canvas/face_piece.gdshader")

@export var resource: FacePieceResource
@export var selected: bool = false
@export var expression: int = 0
@export var is_parent_of: FacePiece
@export_range(0, 3) var horizontal_offset: int = 0
@export_range(0, 3) var vertical_offset: int = 0
@export_enum("Left:0", "Middle:1", "Right:2") var horizontal_placement: int = 1
@export_enum("Top:0", "Middle:1", "Bottom:2") var vertical_placement: int = 1


func _ready() -> void:
	var face_shader_material: ShaderMaterial = ShaderMaterial.new()
	
	face_shader_material.set_shader(face_shader)
	self.set_material(face_shader_material)
	
	update()


func update() -> void:
	offset.x = horizontal_offset * OFFSET_VALUE_HORIZONTAL * get_left_right(horizontal_placement)
	offset.y = vertical_offset * OFFSET_VALUE_VERTICAL * get_left_right(vertical_placement)
	
	if is_parent_of != null:
		is_parent_of.offset.x = offset.x + is_parent_of.horizontal_offset * OFFSET_VALUE_HORIZONTAL * get_left_right(is_parent_of.horizontal_placement)
		is_parent_of.offset.y = offset.y + is_parent_of.vertical_offset * OFFSET_VALUE_VERTICAL * get_left_right(is_parent_of.vertical_placement)
	
	if vframes > 0 and hframes > 0:
		frame_coords.y = clamp(resource.use_row, 0, vframes - 1)
		
		if resource.has_none_option:
			expression = clamp(expression, 0, resource.variations + 1)
			
			if expression == 0:
				visible = false
			else:
				visible = true
				frame_coords.x = expression - 1
		else:
			expression = clamp(expression, 0, resource.variations)
			visible = true
			frame_coords.x = clamp(expression, 0, resource.variations)
	
	self.get_material().set_shader_parameter("enabled", selected)


func get_left_right(value: int) -> int:
	if value == 0:
		return -1
	
	if value == 2:
		return 1
	
	return 0
