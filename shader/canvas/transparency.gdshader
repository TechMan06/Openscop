//BY CHEDDAR
//MODIFIED FROM:
//https://github.com/MenacingMecha/godot-psx-style-demo
shader_type canvas_item;

uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
uniform vec3 alpha_color: source_color = vec3(1.0, 0.0, 1.0);
uniform vec4 modulate_color : source_color = vec4(1.0);

void fragment() {
	vec2 texture_uv = UV;
	vec4 texture_color = texture(albedoTex, texture_uv);
	
	COLOR.rgb = texture_color.rgb * modulate_color.rgb;
	
	if (length(texture_color.rgb - alpha_color.rgb) < 0.1) {
		COLOR.a = 0.0;
	}
}
