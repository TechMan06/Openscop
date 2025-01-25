shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define CULL cull_back
#define BLEND blend_mix
#define NO_TEXTURE

#include "res://shader/spatial/include/psx_base.gdshaderinc"
