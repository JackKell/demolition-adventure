@tool
class_name SelectionGrid
extends MeshInstance3D

const SELECTION_GRID = preload("uid://55apqhwjbhbk")

var selected_tiles: Dictionary[Vector2i, Vector3]

const point1: Vector3 = Vector3(-0.5, 0, -0.5)
const point2: Vector3 = Vector3(0.5, 0, -0.5)
const point3: Vector3 = Vector3(-0.5, 0, 0.5)
const point4: Vector3 = Vector3(0.5, 0, 0.5)

const uv1: Vector2 = Vector2(0, 0)
const uv2: Vector2 = Vector2(0.1, 0)
const uv3: Vector2 = Vector2(0.9, 0)
const uv4: Vector2 = Vector2(1, 0)
const uv5: Vector2 = Vector2(0, 0.1)
const uv6: Vector2 = Vector2(0.1, 0.1)
const uv7: Vector2 = Vector2(0.9, 0.1)
const uv8: Vector2 = Vector2(1, 0.1)
const uv9: Vector2 = Vector2(0, 0.9)
const uv10: Vector2 = Vector2(0.1, 0.9)
const uv11: Vector2 = Vector2(0.9, 0.9)
const uv12: Vector2 = Vector2(1, 0.9)
const uv13: Vector2 = Vector2(0, 1)
const uv14: Vector2 = Vector2(0.1, 1)
const uv15: Vector2 = Vector2(0.9, 1)
const uv16: Vector2 = Vector2(1, 1)

const offset: float = 0.1

func _init() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _ready() -> void:
	update_mesh()

func _process(_delta: float) -> void:
	var x_offset = snappedf(fmod(Time.get_ticks_msec() / 1000.0 * 0.75, 1), 0.25)
	
	var material: StandardMaterial3D = get_active_material(0)
	if material:
		material.uv1_offset.x = x_offset

func add_tile(tile: Vector2i) -> void:
	selected_tiles.set(tile, Vector3(tile.x, 0, tile.y))
	update_mesh()

func remove_tile(tile: Vector2i) -> void:
	selected_tiles.erase(tile)
	update_mesh()

func add_tiles(tiles: Array[Vector2i]) -> void:
	for tile: Vector2i in tiles:
		selected_tiles.set(tile, Vector3(tile.x, 0, tile.y))
	update_mesh()

func clear_tiles() -> void:
	selected_tiles.clear()
	update_mesh()

func update_mesh() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for coords in selected_tiles:
		var global_point: Vector3 = selected_tiles.get(coords)
		var has_top: bool = selected_tiles.has(coords + Vector2i.UP)
		var has_right: bool = selected_tiles.has(coords + Vector2i.RIGHT)
		var has_top_right: bool = selected_tiles.has(coords + Vector2i.UP + Vector2i.RIGHT)
		var has_top_left: bool = selected_tiles.has(coords + Vector2i.UP + Vector2i.LEFT)
		var has_left: bool = selected_tiles.has(coords + Vector2i.LEFT)
		var has_bottom_left: bool = selected_tiles.has(coords + Vector2i.DOWN + Vector2i.LEFT)
		var has_bottom_right: bool = selected_tiles.has(coords + Vector2i.DOWN + Vector2i.RIGHT)
		var has_bottom: bool = selected_tiles.has(coords + Vector2i.DOWN)
		_draw_tile(
			st, 
			global_point, 
			has_top, 
			has_top_right, 
			has_top_left, 
			has_right, 
			has_bottom, 
			has_bottom_right, 
			has_bottom_left, 
			has_left
		)
	self.mesh = st.commit()
	set_surface_override_material(0, SELECTION_GRID)

func _draw_tile(
	st: SurfaceTool, 
	global_point: Vector3, 
	top: bool,
	top_right: bool,
	top_left: bool,
	right: bool, 
	bottom: bool, 
	bottom_right: bool,
	bottom_left: bool,
	left: bool
) -> void:
	var p1 = point1 + global_point;
	var p2 = p1 + Vector3(offset, 0, 0);
	var p5 = p1 + Vector3(0, 0, offset);
	var p6 = p1 + Vector3(offset, 0, offset);
	
	var p4 = point2 + global_point;
	var p3 = p4 + Vector3(-offset, 0, 0)
	var p7 = p4 + Vector3(-offset, 0, offset)
	var p8 = p4 + Vector3(0, 0, offset)
	
	var p13 = point3 + global_point;
	var p9 = p13 + Vector3(0, 0, -offset)
	var p10 = p13 + Vector3(offset, 0, -offset)
	var p14 = p13 + Vector3(offset, 0, 0)
	
	var p16 = point4 + global_point;
	var p11 = p16 + Vector3(-offset, 0, -offset)
	var p12 = p16 + Vector3(0, 0, -offset)
	var p15 = p16 + Vector3(-offset, 0, 0)
	
	if !top_left or !top or !left:
		_draw_rectangle(st, p1, p2, p5, p6, uv1, uv2, uv5, uv6)
	if !top_right or !top or !right:
		_draw_rectangle(st, p3, p4, p7, p8, uv3, uv4, uv7, uv8)
	if !bottom_left or !bottom or !left:
		_draw_rectangle(st, p9, p10, p13, p14, uv9, uv10, uv13, uv14)
	if !bottom_right or !bottom or !right:
		_draw_rectangle(st, p11, p12, p15, p16, uv11, uv12, uv15, uv16)
	if !top:
		_draw_rectangle(st, p2, p3, p6, p7, uv2, uv3, uv6, uv7)
	if !right:
		_draw_rectangle(st, p7, p8, p11, p12, uv7, uv8, uv11, uv12)
	if !left:
		_draw_rectangle(st, p5, p6, p9, p10, uv5, uv6, uv9, uv10)
	if !bottom:
		_draw_rectangle(st, p10, p11, p14, p15, uv10, uv11, uv14, uv15)

func _draw_rectangle(
	st: SurfaceTool, 
	p1: Vector3, 
	p2: Vector3, 
	p3: Vector3, 
	p4: Vector3,
	u1: Vector2,
	u2: Vector2,
	u3: Vector2,
	u4: Vector2,
) -> void:
	st.set_uv(u1)
	st.add_vertex(p1)
	st.set_uv(u2)
	st.add_vertex(p2)
	st.set_uv(u3)
	st.add_vertex(p3)
	st.set_uv(u3)
	st.add_vertex(p3)
	st.set_uv(u2)
	st.add_vertex(p2)
	st.set_uv(u4)
	st.add_vertex(p4)
	
