shader_type spatial;
render_mode shadows_disabled,unshaded, depth_draw_opaque;

global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
global uniform bool fog_enable;
uniform vec4 modulate_color : source_color = vec4(1.0);
#ifndef NO_TEXTURE
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
#endif

#if !defined(NO_TEXTURE) && !defined(METAL)  // METAL doesn't use UV, so no need for panning properties
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform vec2 uv_pan_velocity = vec2(0.0);
#endif
// https://github.com/dsoft20/psx_retroshader/blob/master/Assets/Shaders/psx-vertexlit.shader
global uniform vec4 fog_color;
global uniform float sphere_size;
global uniform vec3 player_pos; 

varying vec3 world_vertex;

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
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float min_dist = length(player_pos - world_vertex);
	float fog_func = ( 1.0 - clamp((min_dist)/100.0, 0.0, 1.0) );
	COLOR = vec4( fog_func, fog_func, fog_func, 1.0);

#if !defined(NO_TEXTURE) && !defined(METAL)  // METAL doesn't use UV, so no need to pan UVs
	UV = UV * uv_scale + uv_offset;
	UV += uv_pan_velocity * TIME;
#endif

	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping

	VERTEX = VERTEX;  // it breaks without this - not sure why
}

void fragment()
{
	ALBEDO = COLOR.rgb;
	vec2 texture_uv = UV;
	vec4 color_base = mix(fog_color , modulate_color, COLOR.r);
	vec4 texture_color = texture(albedoTex, texture_uv);
	if (fog_enable) {
		ALBEDO = mix(fog_color,(texture_color*modulate_color), COLOR).rgb;
	} else {
		ALBEDO = (texture_color*modulate_color).rgb;
	}
}

