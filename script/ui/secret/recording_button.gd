extends Marker2D


var recording_resource: RecordingData
var focused: bool:
	set(value):
		if !value:
			$ButtonFace.play(&"RESET")
			$AnimationPlayer.play(&"RESET")
		else:
			$ButtonFace.play(&"focus")
			$AnimationPlayer.play(&"focus")


func _ready() -> void:
	if recording_resource != null:
		$ButtonFace/RecordingIcon.frame = int(recording_resource.memcard)
		$ButtonFace/TextOrigin/RecordingName.text = recording_resource.name
		$ButtonFace/TextOrigin/GenNumber.text = str(recording_resource.gen).pad_zeros(2)
