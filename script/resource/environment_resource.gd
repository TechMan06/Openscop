extends Resource
class_name EnvironmentResource

@export_category("Sky Properties")
@export var sky_color: Color = Color(1.0, 1.0, 1.0,1.0)
@export var texture: Texture2D
@export var scroll_speed: float = 0.25
@export_category("Ambient Properties")
@export var ambient_color: Color = Color(1.0, 1.0, 1.0,1.0)
@export var environment_darkness: float = 1.0
@export_category("Fog Properties")
@export var enable_fog: bool
@export var fog_color: Color = Color(1.0, 1.0, 1.0,1.0)
@export var fog_radius: float = 13.5


