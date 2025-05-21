@tool
extends Sprite2D
class_name FacePiece


const OFFSET_VALUE_HORIZONTAL: int = 4
const OFFSET_VALUE_VERTICAL: int = 4

var face_shader: Shader = load("res://shader/canvas/face_piece.gdshader")

#@export var expression_resource:
@export var selected: bool = false
@export var expression: int = 0
@export_range(0, 3) var offset_amount: int = 0
@export_enum("Left:0", "Middle:1", "Right:2") var horizontal_placement: int = 1
@export_enum("Top:0", "Middle:1", "Bottom:2") var vertical_placement: int = 1


func _ready() -> void:
	var face_shader_material: ShaderMaterial = ShaderMaterial.new()
	
	face_shader_material.set_shader(face_shader)
	self.set_material(face_shader_material)
	
	update()


func update() -> void:
	offset.x = offset_amount * OFFSET_VALUE_HORIZONTAL * get_left_right(horizontal_placement)
	offset.y = offset_amount * OFFSET_VALUE_VERTICAL * get_left_right(horizontal_placement)
	
	self.get_material().set_shader_parameter("enabled", selected)


func get_left_right(value: int) -> int:
	if value == 0:
		return -1
	
	if value == 2:
		return 1
	
	return 0
