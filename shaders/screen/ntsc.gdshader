shader_type canvas_item;

#define NTSC_CRT_GAMMA 2.5
#define NTSC_MONITOR_GAMMA 2.0

#define fetch_offset(offset, one_x) \
   texture(TEXTURE, SCREEN_UV + vec2((offset) * (one_x), 0.0)).xyz

uniform float effect;
uniform bool ntsc_enable;

#define outsize vec4(OutputSize, 1.0 / OutputSize)

// begin ntsc-rgbyuv
const mat3 yiq2rgb_mat = mat3(
   vec3(1.0, 0.956, 0.6210),
   vec3(1.0, -0.2720, -0.6474),
   vec3(1.0, -1.1060, 1.7046)
);

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

// begin ntsc-decode-filter-3phase

#define TAPS 32
const float luma_filter[34] = {
//const float luma_filter[TAPS + 1] = float[TAPS + 1](
   -0.000174844,
   -0.000205844,
   -0.000149453,
   -0.000051693,
   0.000000000,
   -0.000066171,
   -0.000245058,
   -0.000432928,
   -0.000472644,
   -0.000252236,
   0.000198929,
   0.000687058,
   0.000944112,
   0.000803467,
   0.000363199,
   0.000013422,
   0.000253402,
   0.001339461,
   0.002932972,
   0.003983485,
   0.00302668,
   -0.001102056,
   -0.008373026,
   -0.016897700,
   -0.022914480,
   -0.021642347,
   -0.008863273,
   0.017271957,
   0.054921920,
   0.098342579,
   0.139044281,
   0.168055832,
   0.178571429,
   0.0
};

const float chroma_filter[34] = {
   0.001384762,
   0.001678312,
   0.002021715,
   0.002420562,
   0.002880460,
   0.003406879,
   0.004004985,
   0.004679445,
   0.005434218,
   0.006272332,
   0.007195654,
   0.008204665,
   0.009298238,
   0.010473450,
   0.011725413,
   0.013047155,
   0.014429548,
   0.015861306,
   0.017329037,
   0.018817382,
   0.020309220,
   0.021785952,
   0.023227857,
   0.024614500,
   0.025925203,
   0.027139546,
   0.028237893,
   0.029201910,
   0.030015081,
   0.030663170,
   0.031134640,
   0.031420995,
   0.031517031,
   0.15
};
// end ntsc-decode-filter-3phase

void fragment()
{
// begin ntsc-pass2-decode
	float one_x = 1.0 / 2880.;
	vec3 signal = vec3(0.0);


	float offset = 0.;
	vec3 sums = vec3(0.,0.,0.);

	#define macro_loopz(c) offset = float(c) - 1.0; \
		sums = fetch_offset(offset - 32., one_x) + fetch_offset(32. - offset, one_x); \
		signal += sums * vec3(luma_filter[c], chroma_filter[c], chroma_filter[c]);
	
	macro_loopz(1)
	macro_loopz(2)
	macro_loopz(3)
	macro_loopz(4)
	macro_loopz(5)
	macro_loopz(6)
	macro_loopz(7)
	macro_loopz(8)
	macro_loopz(9)
	macro_loopz(10)
	macro_loopz(11)
	macro_loopz(12)
	macro_loopz(13)
	macro_loopz(14)
	macro_loopz(15)
	macro_loopz(16)
	macro_loopz(17)
	macro_loopz(18)
	macro_loopz(19)
	macro_loopz(20)
	macro_loopz(21)
	macro_loopz(22)
	macro_loopz(23)
	macro_loopz(24)
	macro_loopz(25)
	macro_loopz(26)
	macro_loopz(27)
	macro_loopz(28)
	macro_loopz(29)
	macro_loopz(30)
	macro_loopz(31)
	macro_loopz(32)
	
	signal += texture(TEXTURE, SCREEN_UV).xyz *
		vec3(luma_filter[33], chroma_filter[33],  chroma_filter[33]);

	vec3 rgb = signal * 0.85;//yiq2rgb(signal);

	if (ntsc_enable)
		COLOR = vec4(pow(rgb, vec3(NTSC_CRT_GAMMA / NTSC_MONITOR_GAMMA)), 1.0);
	else
		COLOR = COLOR;
}
