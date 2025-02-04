extends Marker3D

var pressed: bool = false;

@onready var key_mesh = $PenKeyMesh


func _process(_delta: float) -> void:
	if pressed:
		key_mesh.position.y = -0.25
		key_mesh.rotation.x = deg_to_rad(-2.2)
		
	else:
		key_mesh.position.y = 0.0
		key_mesh.rotation.x = 0.0
		key_mesh.get_surface_override_material().set_shader_parameter("modulate_color", Color(0.62, 0.62, 0.82))
