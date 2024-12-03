//MODIFIED FROM:
//https://github.com/MenacingMecha/godot-psx-style-demo
shader_type spatial;
render_mode shadows_disabled, unshaded, specular_disabled, depth_draw_opaque, cull_back, ambient_light_disabled;

global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
global uniform bool fog_enabled;
global uniform vec3 fog_pos;
global uniform vec3 fog_color;
global uniform float fog_size;

varying float fog_amount;

uniform bool use_fog;
uniform vec4 modulate_color : source_color = vec4(1.0);
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform vec2 uv_pan_velocity = vec2(0.0);

uniform vec3 alpha_color: source_color = vec3(1.0, 0.0, 1.0);

// https://github.com/dsoft20/psx_retroshader/blob/master/Assets/Shaders/psx-vertexlit.shader
const vec2 base_snap_res = vec2(160.0, 120.0);
vec4 get_snapped_pos(vec4 base_pos)
{
	vec4 snapped_pos = base_pos;
	snapped_pos.xyz = base_pos.xyz / base_pos.w; // convert to normalised device coordinates (NDC)
	vec2 snap_res = floor(base_snap_res * precision_multiplier);  // increase "snappy-ness"
	snapped_pos.x = floor(snap_res.x * snapped_pos.x) / snap_res.x;  // snap the base_pos to the lower-vertex_resolution grid
	snapped_pos.y = floor(snap_res.y * snapped_pos.y) / snap_res.y;
	snapped_pos.xyz *= base_pos.w;  // convert back to projection-space
	return snapped_pos;
}

void vertex()
{
	COLOR.rgb = COLOR.rgb * COLOR.rgb * COLOR.rgb;
	
	if (fog_enabled && use_fog) {
		fog_amount = length((fog_pos - NODE_POSITION_WORLD) - VERTEX) / fog_size;
		if (fog_amount > 1.0) fog_amount = 1.0;
	}

	UV = UV * uv_scale + uv_offset;
	UV += uv_pan_velocity * TIME;

	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping
}

void fragment()
{
	vec2 texture_uv = UV;


	vec4 color_base = COLOR * modulate_color;

	vec4 texture_color = texture(albedoTex, texture_uv);
	if (fog_enabled) {
		ALBEDO = (color_base * texture_color).rgb * (1.0 - fog_amount) + fog_color * fog_amount;
	} else {
		ALBEDO = (color_base * texture_color).rgb;
	}

	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	if (length(texture_color.rgb - alpha_color.rgb) < ALPHA_SCISSOR_THRESHOLD) {
		ALPHA = 0.0;
	}

}
