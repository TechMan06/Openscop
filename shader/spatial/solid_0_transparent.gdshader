shader_type spatial;
render_mode unshaded;
uniform vec3 MAIN_COLOR : source_color;
varying vec3 world_vertex;


const vec2 base_snap_res = vec2(160.0, 120.0);
global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;

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
	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
}

void fragment(){
	vec2 dithVec = vec2(SCREEN_UV.x * 320.0,SCREEN_UV.y * 240.0);
	float dith = float(int(dithVec.x + dithVec.y) % 2);
	ALBEDO = (MAIN_COLOR*round(dith));
	ALPHA = round(dith);
}