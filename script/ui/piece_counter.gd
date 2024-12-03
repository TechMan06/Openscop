extends TextureRect


const COUNTER_SPEED: float = 0.5


func _ready() -> void:
	EventBus.destroy_hud.connect(_on_destruction)


func get_anim_speed() -> float:
	return (100 - ((self.position.y + 17) * (100 / 46))) * 0.01


func show_counter() -> void:
	
	var lower_tween: Tween = null
	
	if lower_tween == null:
		lower_tween = create_tween()
		
		lower_tween.tween_property(
										self, 
										"position:y", 
										29., 
										COUNTER_SPEED * get_anim_speed()
									).set_trans(Tween.TRANS_LINEAR)
	
	lower_tween = null
	
	$CounterTimer.start()


func _on_counter_timer_timeout():
	create_tween().tween_property(
									self, 
									"position:y", 
									-17, 
									COUNTER_SPEED
								).set_trans(Tween.TRANS_LINEAR)


func update_counter():
	$Counter.text = str(SaveManager.get_data().player_data.piece_amount).pad_zeros(5)


func _on_destruction() -> void:
	position.y = -17
