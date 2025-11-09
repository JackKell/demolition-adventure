class_name LineTool
extends LevelEditorTool

const HIGHLIGHT_TILE = preload("uid://dy6pw763hvr5")

var is_placing_start_point: bool = true
var point_1: Vector2i
var point_2: Vector2i

var coords: Array[Vector2i] = []

func mouse_moved(new_current_coords: Vector2i) -> void:
	if new_current_coords == current_cell:
		return
	current_cell = new_current_coords
	if is_placing_start_point:
		point_1 = current_cell
		coords = [point_1]
	else: 
		point_2 = current_cell
		coords = GridUtils.coords_in_line(point_1, point_2)
	_draw_preview()


func _on_left_click_pressed() -> void:
	if !is_placing_start_point:
		var x: Dictionary[Vector2i, PackedScene] = {}
		for coord in coords:
			x.set(coord, draw_tile)
		draw(x)
	_handle_click()

func _on_right_click_released() -> void:
	_handle_click()
	if !is_placing_start_point:
		_erase_tiles(GridUtils.coords_in_line(point_1, point_2))

func _handle_click() -> void:
	if is_placing_start_point:
		is_placing_start_point = false
		point_1 = current_cell
	else:
		is_placing_start_point = true
		point_2 = current_cell
		

func _draw_preview():
	preview_tiles.hide_all()
	preview_tiles.set_tiles(coords)
