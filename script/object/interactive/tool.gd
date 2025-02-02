extends Marker3D


const ANIM_SPEED: float = 2.0
const I_DONT_KNOW_SPRITE: String = "res://asset/2d/sprite/object/tool/idontknow.png"
const WATCH_SPRITE: String = "res://asset/2d/sprite/object/tool/watch.png"

@export var pink: bool = false:
	set(value):
		EventBus.change_keyboard_bg.emit(int(value))
		if !value:
			tool_mesh.set_shader_parameter("modulate_color", Color(1.0, 0.5, 0.5))
		else:
			tool_mesh.set_shader_parameter("modulate_color", Color(1.0, 0.5, 1.0))

var questions: Array[Array] = [
									[
									"where was the windmill"
									],
									[
									"where was the windmill"
									]
						]
var images: Array[Array] = [
									[
										"res://asset/2d/sprite/object/tool/windmill.png"
									],
									[
										"res://asset/2d/sprite/object/tool/windmill.png"
									]
						]

@onready var answer_origin = $AnswerOrigin
@onready var answer_mesh = $AnswerOrigin/AnswerMesh.get_surface_override_material(0)
@onready var tool_mesh = $ToolMesh.get_surface_override_material(0)
@onready var keyboard_trigger = $KeyboardTrigger



func _ready() -> void:
	EventBus.finished_typing.connect(_on_finish_typing)
	create_tween().set_loops().tween_property(
												answer_origin, 
												"rotation:y", 
												-1.75, 
												1.0
											).set_trans(Tween.TRANS_LINEAR).as_relative()
	
	if !pink:
		tool_mesh.set_shader_parameter("modulate_color", Color(1.0, 0.6, 0.6))
	else:
		tool_mesh.set_shader_parameter("modulate_color", Color(1.0, 0.6, 1.0))


func _process(_delta: float) -> void:
	keyboard_trigger.background = int(pink)


func set_pink(value: bool) -> void:
	pink = value


func _on_finish_typing(answer: String, _attach_node: Node) -> void:
	if answer != "":
		keyboard_trigger.enabled = false
	
		var lift_mesh: Tween = create_tween()
	
		lift_mesh.tween_property(answer_origin, "position:y", 5.0, ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	
		await lift_mesh.finished
	
		var answer_index: int = questions[int(pink)].find(answer.to_lower())

		if answer_index != -1:
			answer_mesh.set_shader_parameter("albedoTex", load(images[int(pink)][answer_index]))
		else:
			answer_mesh.set_shader_parameter("albedoTex", load(I_DONT_KNOW_SPRITE))
	
	
		var low_mesh: Tween = create_tween()
		
		low_mesh.tween_property(answer_origin, "position:y", 0.0, ANIM_SPEED).set_trans(Tween.TRANS_SINE)
		
		await low_mesh.finished
		
		keyboard_trigger.enabled = true


func _on_watch() -> void:
	pink = false
	keyboard_trigger.enabled = false
		
	var lift_mesh: Tween = create_tween()
	
	lift_mesh.tween_property(answer_mesh, "position:y", 5.0, ANIM_SPEED)
	
	await lift_mesh.finished
	
	answer_mesh.set_shader_parameter("albedoTex", load(WATCH_SPRITE))
	
	var low_mesh: Tween = create_tween()
		
	low_mesh.tween_property(answer_mesh, "position:y", 0.0, ANIM_SPEED)
	
	await low_mesh.finished
	
	keyboard_trigger.enabled = true
