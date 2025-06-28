shader_type canvas_item;

uniform float threshold = 1.22;
uniform vec3 primary_color : source_color = vec3(1.0);
uniform vec3 secondary_color : source_color = vec3(1.0);
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;

void fragment() {
	vec4 screen_col = texture(screen_texture, SCREEN_UV, 0).rgba;
	
	if (length(screen_col) > threshold) {
		COLOR.rgb = screen_col.rgb * primary_color;
	} else {
		COLOR.rgb = screen_col.rgb * secondary_color;
	}
}
