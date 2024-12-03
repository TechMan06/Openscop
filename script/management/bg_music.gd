extends AudioStreamPlayer

const _EXTENSION = ".ogg"
const _TRACKS = [
	"",
	"res://music/gift_plane",
	"res://music/level1",
	"res://music/level2"
]


func set_track(track_id) -> void:
	if track_id != 0:
		if stream != null:
			if str(stream.get_path()) != _TRACKS[track_id] + _EXTENSION:
				stream = load(_TRACKS[track_id] + _EXTENSION)
		else:
			stream = load(_TRACKS[track_id] + _EXTENSION)
	else:
		stop()


func play_track(track_id) -> void:
	if track_id != 0:
		
		if stream != null:
			if str(stream.get_path()) != _TRACKS[track_id] + _EXTENSION:
				stream = load(_TRACKS[track_id] + _EXTENSION)
				play()
			
			if stream_paused || !playing:
				play()
		else:
			stream = load(_TRACKS[track_id] + _EXTENSION)
			play()
	else:
		stop()


func decrease_volume() -> void:
	create_tween().tween_property(self, "volume_db", -20.0, 1.0)


func pause() -> void:
	stream_paused = true


func resume() -> void:
	stream_paused = false


func increase_volume() -> void:
	create_tween().tween_property(self, "volume_db", 0.0, 1.0)


func mute() -> void:
	create_tween().tween_property(self, "volume_db", -80.0, 1.0)


func unmute() -> void:
	increase_volume()


func play_stream(path: String) -> void:
	if stream != null:
		if str(stream.get_path()) != path:
			stream = load(path)
			play()
	else:
		stream = load(path)
		play()


func get_stream_path() -> String:
	if stream != null:
		return stream.get_path()
	else:
		return "NONE"
