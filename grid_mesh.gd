@tool
class_name GridMesh
extends MeshInstance3D

@export var material: StandardMaterial3D = StandardMaterial3D.new()
@export var cell_size: Vector2i = Vector2i.ONE:
	set(value):
		cell_size = value
		_build_grid_mesh()
@export var grid_size: Vector2i = Vector2i(100, 100):
	set(value):
		grid_size = value
		_build_grid_mesh()

func _ready() -> void:
	material.changed.connect(_build_grid_mesh)
	_build_grid_mesh()

func _build_grid_mesh() -> void:
	var st = SurfaceTool.new()
	var cell_offset: Vector3 = VectorUtils.vector3_xz(Vector2(cell_size) * 0.5)
	var grid_offset: Vector3 = VectorUtils.vector3_xz(Vector2(-grid_size) * 0.5)
	var offset: Vector3 = cell_offset + grid_offset
	st.begin(Mesh.PRIMITIVE_LINES)
	for x: int in range(grid_size.x + 1):
		var row_offset: float = cell_size.y * x
		st.add_vertex(Vector3(0, 0, row_offset) + offset)
		st.add_vertex(Vector3(grid_size.x, 0, row_offset) + offset)
	for y: int in range(grid_size.y + 1):
		var col_offset: float = cell_size.x * y
		st.add_vertex(Vector3(col_offset, 0, 0) + offset)
		st.add_vertex(Vector3(col_offset, 0, grid_size.y) + offset)
	self.mesh = st.commit()
	self.set_surface_override_material(0, material)
