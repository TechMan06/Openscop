shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

#define TWO_PHASE
#define COMPOSITE
#define FRAGMENT


#if defined(TWO_PHASE)
	#define CHROMA_MOD_FREQ (4.0 * PI / 15.0)
#elif defined(THREE_PHASE)
	#define CHROMA_MOD_FREQ (PI / 3.0)
#endif

#if defined(COMPOSITE)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 1.0
	#define FRINGING 1.0
#elif defined(SVIDEO)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 0.0
	#define FRINGING 0.0
#endif
// end params

#if defined(VERTEX)

#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D

#define COMPAT_PRECISION mediump

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 pix_no;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// vertex compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
    VERTEX = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
   pix_no = vTexCoord * SourceSize.xy * (outsize.xy / InputSize.xy);
}

#elif defined(FRAGMENT)
//#pragma format R8G8B8A8_SRGB

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#define COMPAT_VARYING varying
#define COMPAT_TEXTURE texture2D

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 pix_no;

// fragment compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)


// begin ntsc-rgbyuv
const mat3 yiq2rgb_mat = mat3(
  vec3(1.0, 0.956, 0.6210),
  vec3(1.0, -0.2720, -0.6474),
  vec3(1.0, -1.1060, 1.7046));

vec3 yiq2rgb(vec3 yiq)
{
   return yiq * yiq2rgb_mat;
}

const mat3 yiq_mat = mat3(
      vec3(0.2989, 0.5870, 0.1140),
      vec3(0.5959, -0.2744, -0.3216),
      vec3(0.2115, -0.5229, 0.3114)
);

vec3 rgb2yiq(vec3 col)
{
   return col * yiq_mat;
}
// end ntsc-rgbyuv

void fragment()
{
	#if defined(COMPOSITE) || defined(SVIDEO)
	mat3 mix_mat = mat3(vec3(BRIGHTNESS, FRINGING, FRINGING), vec3(ARTIFACTING, 2.0 * SATURATION, 0.0), vec3(ARTIFACTING, 0.0, 2.0 * SATURATION));
	#endif
	ivec2 uv = ivec2(FRAGCOORD.xy);
//#ifdef ntsc-pass1-demodulate-encode
	vec3 col = texelFetch(screen_texture, uv, 0).rgb;
	vec3 yiq = rgb2yiq(col);

	float chroma_phase = 0.0;
	
	#if defined(TWO_PHASE)
		chroma_phase = PI * (mod(pix_no.y, 2.0) + float(TIME));
	#elif defined(THREE_PHASE)
		chroma_phase = 0.6667 * PI * (mod(pix_no.y, 3.0) + TIME);
	#endif

	float mod_phase = chroma_phase + pix_no.x * CHROMA_MOD_FREQ;

	float i_mod = cos(mod_phase);
	float q_mod = sin(mod_phase);

	yiq.yz *= vec2(i_mod, q_mod); // Modulate.
	yiq *= mix_mat; // Cross-talk.
	yiq.yz *= vec2(i_mod, q_mod); // Demodulate.
	COLOR = vec4(yiq, 1.0);
//#endif
}
#endif