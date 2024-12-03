shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define CULL cull_back
#define USE_ALPHA

#include "res://shader/spatial/include/psx_base.gdshaderinc"
