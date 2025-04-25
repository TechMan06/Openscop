extends Node3D

var level_mesh_instance: MeshInstance3D
var level_mesh: Mesh


var tiles: Array[PackedVector3Array] = [
	[
		Vector3(0.5, 0.0, -0.5),
		Vector3(0.5, 0.0, 0.5),
		Vector3(-0.5, 0.0, 0.5),
		Vector3(0.5, 0.0, -0.5),
		Vector3(-0.5, 0.0, 0.5),
		Vector3(-0.5, 0.0, -0.5)
	]
]

var tile_data: Array = []
var tile_vert_data: PackedVector3Array = []
var tile_normal_data: PackedVector3Array = []


func _ready() -> void:
	tile_data.resize(ArrayMesh.ARRAY_MAX)
	
	level_mesh_instance = MeshInstance3D.new()
	level_mesh = ArrayMesh.new()
	level_mesh_instance.set_mesh(level_mesh)
	
	get_tree().get_current_scene().add_child.call_deferred(level_mesh_instance)
	
	for vert in tiles[0]:
		tile_vert_data.push_back(vert)
	
	_update_tilemap()


func _process(_delta: float) -> void:
	pass


func _update_tilemap() -> void:
	if tile_vert_data.size() > 12:
		for tile in tile_vert_data:
			if tile_vert_data.find(tile) < 2:
				#PEGAR MÉDIA DE 2 VECTOR3 E CALCULAR MÉDIA E MANDAR PRO ARRAY
				#PRECISA TER A NORMAL DE CADA VÉRTICE CERTINHO
				#RESULTADO DO CÁLCULO TEM QUE SER O CENTRO ENTRE 2 TRIÂNGULOS
				#2 TRIÂNGULOS = 1 QUAD
				var vector3_average_0: Vector3 = 
	
	tile_data[Mesh.ARRAY_VERTEX] = tile_vert_data
	tile_data[Mesh.ARRAY_NORMAL] = tile_normal_data
	level_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tile_data)
