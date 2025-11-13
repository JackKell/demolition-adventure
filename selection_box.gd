@tool
class_name SelectionBox
extends MeshInstance3D

@export var material: StandardMaterial3D

@export var top: int = 4:
	set(value):
		if top != value and value > 0:
			top = value
			size_changed.emit()
		
@export var bottom: int = 2:
	set(value):
		if bottom != value and value > 0:
			bottom = value
			size_changed.emit()
		
@export var left: int = 2:
	set(value):
		if left != value and value > 0:
			left = value
			size_changed.emit()
		
@export var right: int = 2:
	set(value):
		if right != value and value > 0:
			right = value
			size_changed.emit()
		

signal size_changed

func _init() -> void:
	size_changed.connect(_build_grid_mesh)


func _ready() -> void:
	material.changed.connect(_build_grid_mesh)

func _build_grid_mesh() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for b: int in range(left + right):
		# Top Wall
		# Triangle 1
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(b + 1 - left, 0, bottom))
		st.set_uv(Vector2(0, 1))
		st.add_vertex(Vector3(b - left, 0, bottom))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(b - left, 1, bottom))
		# Triangle 2
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(b + 1 - left, 1, bottom))
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(b + 1 - left, 0, bottom))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3( b - left, 1, bottom))
		
		# Bottom Wall
		# Triangle 1
		st.set_uv(Vector2(0, 1))
		st.add_vertex(Vector3(b - left, 0, -top))
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(b + 1 - left, 0, -top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(b - left, 1, -top))
		# Triangle 2
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(b + 1 - left, 0, -top))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(b + 1 - left, 1, -top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3( b - left, 1, -top))

	for b: int in range(top + bottom):
		# Left Wall
		# Triangle 1
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(-left, 0, b + 1 - top))
		st.set_uv(Vector2(0, 1))
		st.add_vertex(Vector3(-left, 0, b - top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(-left, 1, b - top))
		# Triangle 2
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(-left, 1, b + 1 - top))
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(-left, 0, b + 1 - top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(-left, 1, b - top))

		# Right Wall
		# Triangle 1
		st.set_uv(Vector2(0, 1))
		st.add_vertex(Vector3(right, 0, b - top))
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(right, 0, b + 1 - top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(right, 1, b - top))
		# Triangle 2
		st.set_uv(Vector2(1, 1))
		st.add_vertex(Vector3(right, 0, b + 1 - top))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(right, 1, b + 1 - top))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(right, 1, b - top))
	
	self.mesh = st.commit()
	self.set_surface_override_material(0, material)

func _process(_delta: float) -> void:
	var total_seconds = Time.get_ticks_msec() / 1000.0
	var x = fmod(total_seconds * 0.5, 1)
	material.uv1_offset.x = x
