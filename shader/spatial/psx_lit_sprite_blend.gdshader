shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define CULL cull_disabled
#define SPRITE
#define BLEND_ALPHA

#include "res://shader/spatial/include/psx_base.gdshaderinc"
