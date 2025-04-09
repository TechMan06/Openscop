//BY FROSTYARCHTIDE IN THE GODOT SERVER
//MODIFIED BY CHEDDAR
shader_type sky;

global uniform float float_time;

uniform bool is_color = true;
uniform vec3 sky_color: source_color;
uniform sampler2D sky_texture : source_color, filter_nearest;
uniform vec2 texture_size;
uniform float offset_y = 0.0;
uniform float scroll_speed = 0.25;

void sky() {
    if (is_color) {
		COLOR = sky_color;
 	} else {
		vec2 uv = (SCREEN_UV + vec2(float_time * scroll_speed, offset_y)) * (vec2(320, 240) / texture_size);
	    COLOR = texture(sky_texture, uv).rgb;
	}
}