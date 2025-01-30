extends Marker2D


func _ready() -> void:
	BGMusic.decrease_volume()
	
	var _scale_animation = create_tween()
	#SCALE ANIM
	_scale_animation.tween_property(
										self, 
										"scale", 
										Vector2(1.0, 1.0), 
										1.0
									).set_trans(Tween.TRANS_LINEAR)
	
	var _animation = create_tween()
	
	_animation.tween_property(
								self, 
								"position:x", 
								10.0, 
								0.25
							).as_relative().set_trans(Tween.TRANS_SINE)
	_animation.tween_property(
								self, 
								"position:x",
								-20.0, 
								0.5
							).as_relative().set_trans(Tween.TRANS_SINE)
	_animation.tween_property(
								self, 
								"position:x", 
								10.0, 
								0.25
							).as_relative().set_trans(Tween.TRANS_SINE)
	_animation.tween_property(
								self, 
								"rotation", 
								deg_to_rad(360), 
								2.0
							).set_trans(Tween.TRANS_SINE).set_delay(0.25)
	_animation.tween_property(
								self, 
								"modulate", 
								Color(1.0, 1.0, 1.0, 0.0), 
								1.0
							).set_trans(Tween.TRANS_SINE).set_delay(0.5)
	
	await _animation.finished
	queue_free()


func _on_sound_finished():
	BGMusic.increase_volume()
