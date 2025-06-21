extends Node2D

var started: bool = true
var timer: float = 0.0
var gen: int = 1

@export_file("*.tscn") var wavey_room
@export_file("*.tscn") var sort_test

@onready var logo: Sprite2D = $LogoAnim
@onready var logo2: Sprite2D = $Logo


func _ready() -> void:
	if ResourceLoader.exists("user://savedata/global.tres"):
		gen = load("user://savedata/global.tres").gen
	
	BGMusic.stop()
	logo2.visible = false
	$GaralinaAnim.play(&"logo")
	
	if RecordingManager.replay:
		RecordingManager.replay = false
	
	if RecordingManager.recording:
		RecordingManager.stop_recording()
	
	create_tween().tween_property($Fade, "color:a", 0.0, 1.75)
	
	if gen > 3 && gen < 12:
		logo.texture =  load("res://asset/2d/garalina/gen" + str(gen) + ".png")
	
	if gen > 11:
		logo.texture =  load("res://asset/2d/garalina/gen" + str(gen - 8) + ".png")
		logo.flip_h = true
		logo.flip_v = true
		
	if gen < 4:
		logo.texture =  load("res://asset/2d/garalina/gen" + str(gen + 8) + ".png")
		logo.flip_h = true
		logo.flip_v = true
		
	if gen > 3 && gen < 12:
		logo2.frame = gen - 4
	
	if gen > 11:
		logo2.frame = gen - 12
		logo2.flip_h = true
		logo2.flip_v = true
		
	if gen < 4:
		logo2.frame =  gen + 4
		logo2.flip_h = true
		logo2.flip_v = true


func _on_garalina_anim_animation_finished(anim_name) -> void:
	if Input.is_action_pressed("debug"):
		Global.warp_to(
							"res://scene/debug/debug.tscn", 
							load("res://resource/loading_preset/ec_noload.tres")
						)
	else:
		if gen > 3:
			Global.warp_to(
								"res://scene/title/title.tscn", 
								load("res://resource/loading_preset/ec_noload.tres")
							)
			
			await get_tree().create_timer(HUD.FADE_SPEED).timeout
		
			BGMusic.play_stream("res://music/petscop.ogg")
		else:
			if gen > 1:
				Global.warp_to(
									wavey_room, 
									load("res://resource/loading_preset/ec_noload.tres")
								)
			else:
				Global.warp_to(
									sort_test, 
									load("res://resource/loading_preset/ec_noload.tres")
								)
