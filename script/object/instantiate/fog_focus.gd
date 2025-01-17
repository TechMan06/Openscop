extends Marker3D

var focus_node: Node3D
var offset: Vector3

func _process(_delta: float) -> void:
	if focus_node != null:
		global_position = focus_node.global_position + offset
	
	RenderingServer.global_shader_parameter_set("fog_pos", global_position)
