//MODIFIED FROM:
//https://github.com/MenacingMecha/godot-psx-style-demo
render_mode shadows_disabled, specular_disabled, depth_draw_always;

global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
global uniform bool fog_enabled;
global uniform vec3 fog_pos;
global uniform vec3 fog_color;
global uniform float fog_size;

varying float fog_amount;

group_uniforms Material_Properties;
uniform bool use_fog = true;
uniform vec4 modulate_color : source_color = vec4(1.0);

#ifndef LIT
render_mode	unshaded;
#endif

#ifdef CULL
render_mode	cull_back;
#endif

#ifndef CULL
render_mode	cull_disabled;
#endif

#ifdef BLEND
render_mode	blend_mix;
#endif

#ifndef NO_TEXTURE
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
#endif

#if defined(SPRITE) || defined(USE_ALPHA)
uniform vec3 alpha_color: source_color = vec3(1.0, 0.0, 1.0);
#endif


#if !defined(NO_TEXTURE) && !defined(METAL) && !defined(SPRITE)  // METAL doesn't use UV, so no need for panning properties
group_uniforms UV_Properties;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform vec2 uv_pan_velocity = vec2(0.0);
group_uniforms;
#endif

#ifdef SPRITE
group_uniforms Sprite_Properties;
uniform bool billboard = false;
uniform bool y_billboard = false;
uniform bool animate;
uniform ivec2 animation_frames;
uniform ivec2 animation_speed;
group_uniforms;
#endif

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
	
#ifdef LIT
	if (fog_enabled && use_fog) {
		fog_amount = length(fog_pos - (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz) / fog_size;
		
		if (fog_amount > 1.0) {
			fog_amount = 1.0;
		}
	}
#endif
	
#if !defined(NO_TEXTURE) && !defined(METAL) && !defined(SPRITE)  // METAL doesn't use UV, so no need to pan UVs
	UV = UV * uv_scale + uv_offset;
	UV += uv_pan_velocity * TIME;
#endif

#ifdef SPRITE
	if (animate) {
		UV += round(vec2(animation_speed) * TIME) / vec2(animation_frames);
	}
	
	if (y_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], MODEL_MATRIX[1], vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, MODEL_MATRIX[1].xyz)), 0.0), MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0 / length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}
	else if (billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
#endif

	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping

#ifdef SPRITE
	if (y_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}
#endif
}

void fragment()
{
#ifdef METAL
	vec2 texture_uv = vec2(NORMAL.x / 2.0 + 0.5, (-NORMAL.y) / 2.0 + 0.5);  // Special thanks to Adam McLaughlan
#elif !defined(NO_TEXTURE)
	vec2 texture_uv = UV;
#endif

	vec4 color_base = COLOR * modulate_color;

#ifdef NO_TEXTURE
	#ifdef LIT
		if (fog_enabled) {
			ALBEDO = color_base.rgb * (1.0 - fog_amount) + fog_color * fog_amount;
		} else {
			ALBEDO = color_base.rgb;
		}
	#else
		ALBEDO = color_base.rgb;
	#endif
#else
	vec4 texture_color = texture(albedoTex, texture_uv);
	#ifdef LIT
		if (fog_enabled) {
			ALBEDO = (color_base * texture_color).rgb * (1.0 - fog_amount) + fog_color * fog_amount;
		} else {
			ALBEDO = (color_base * texture_color).rgb;
		}
	#else
		ALBEDO = (color_base * texture_color).rgb;
	#endif
#endif

#ifdef LIGHT_VOLUME
	ALPHA = 1.0 - UV.y;
#elif defined(ALPHA_BLEND)
	ALPHA = texture_color.a * color_base.a;
#endif

#if defined(SPRITE) || defined(USE_ALPHA)
	ALPHA_SCISSOR_THRESHOLD = 0.25;
	
	if (length(texture_color.rgb - alpha_color.rgb) < ALPHA_SCISSOR_THRESHOLD) {
		ALPHA = 0.0;
	}
#endif
}
