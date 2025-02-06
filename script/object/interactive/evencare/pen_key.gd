extends Marker3D

var pressed: bool = false
var sound_played: bool = false

@onready var key_mesh = $PenKeyMesh


func set_sound() -> void:
	$Sound.set_stream(
						load(
								"res://sfx/object/pen-piano/" + str(
																		get_parent().get_child_count() - self.get_index() -1
																	) +".wav"
																)
							)


func _process(_delta: float) -> void:
	if pressed:
		if !sound_played:
			$Sound.play()
			sound_played = true
		
		key_mesh.position.y = -0.25
		key_mesh.rotation.x = deg_to_rad(-2.2)
		key_mesh.get_surface_override_material(0).set_shader_parameter("modulate_color", Color(0.62, 0.62, 0.82))
	else:
		sound_played = false
		key_mesh.position.y = 0.0
		key_mesh.rotation.x = 0.0
		key_mesh.get_surface_override_material(0).set_shader_parameter("modulate_color", Color.WHITE)
