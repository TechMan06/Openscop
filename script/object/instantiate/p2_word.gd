extends Label3D

const SOUND_FILES: Array = [
	"res://sfx/p2talk/p2paul.wav",
	"res://sfx/p2talk/p2belle.wav",
	"res://sfx/p2talk/p2marvin.wav",
	"res://sfx/p2talk/p2null.wav"
]
var sound_id: int = 0


func _ready() -> void:
	modulate.a = 0.0
	
	get_child(0).stream = load(SOUND_FILES[sound_id])
	get_child(0).play()
	
	var _tween: Tween = create_tween()
	
	_tween.tween_property(self, "modulate:a", 1.0,0.5)
	_tween.tween_interval(2)
	_tween.tween_property(self, "modulate:a", 0.0, 1)
	_tween.tween_callback(queue_free)
