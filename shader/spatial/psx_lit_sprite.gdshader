shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define CULL cull_disabled
#define BLEND blend_mix
#define SPRITE

#include "res://shader/spatial/include/psx_base.gdshaderinc"
