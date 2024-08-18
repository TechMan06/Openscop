extends Node3D

const ANIM_SPEEDS = 2.5
const DEFAULT_ANSWER_WAIT = 0.5
var pink = false

var went_down = false
var answer_finished = false
var answer = ""
var current_answer = ""
@onready var material = $answer_origin/answer

func _process(delta):
	
	if Input.is_action_just_pressed("ui_end"):
		watch_windmill()
	
	$answer_origin.rotation.y+=1.5*delta
	if $answer_origin.rotation.y>6.28319:
		$answer_origin.rotation.y=0.

	if Global.keyboard_RAM!="":
		answer_finished = false
		if current_answer!=answer:
			var go_up = create_tween()
			go_up.tween_property($answer_origin,"position:y",10.0,ANIM_SPEEDS)
			await go_up.finished
			answer_processing(Global.keyboard_RAM)
			material.texture = load(answer)
			current_answer = answer
			material.get_material_override().set_shader_parameter("albedoTex", material.texture)
			$answer_wait.start()
			went_down=false
		else:
			$answer_wait.start()
		Global.keyboard_RAM=""
		
	if pink:
		$interaction.behavior=1
	else:
		$interaction.behavior=0

func answer_processing(keyboard_answer):
	var question = keyboard_answer.to_lower()
	print(keyboard_answer)
	if !pink:
		if question=="where was the windmill":
			$answer_wait.wait_time = DEFAULT_ANSWER_WAIT
			answer = "res://graphics/sprites/objects/tool/answer_windmill.png"
		elif !answer_finished:
			$answer_wait.wait_time = DEFAULT_ANSWER_WAIT
			answer = "res://graphics/sprites/objects/tool/answer_idontknow.png"
	else:
		if question=="poop":
			$answer_wait.wait_time = DEFAULT_ANSWER_WAIT
			answer = "res://graphics/sprites/objects/tool/answer_windmill.png"
		elif !answer_finished:
			$answer_wait.wait_time = DEFAULT_ANSWER_WAIT
			answer = "res://graphics/sprites/objects/tool/answer_idontknow.png"

func watch_windmill():
	var go_up = create_tween()
	go_up.tween_property($answer_origin,"position:y",5.0,ANIM_SPEEDS)
	await go_up.finished
	material.texture = load("res://graphics/sprites/objects/tool/answer_watch.png")
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	create_tween().tween_property($answer_origin,"position:y",0.0,ANIM_SPEEDS).set_trans(Tween.TRANS_SINE)

func _on_answer_wait_timeout():
	create_tween().tween_property($answer_origin,"global_position:y",0.0,ANIM_SPEEDS).set_trans(Tween.TRANS_SINE)
	if !went_down:
		went_down=true
