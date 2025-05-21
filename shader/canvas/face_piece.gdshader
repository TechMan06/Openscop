shader_type canvas_item;

uniform bool enabled = false;
uniform vec3 old_color: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 new_color: source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
	if (enabled && COLOR.rgb == old_color) {
		COLOR.rgb = new_color;
	}
}
