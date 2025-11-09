class_name BoxTool
extends LevelEditorTool

const HIGHLIGHT_TILE = preload("uid://dy6pw763hvr5")


var point_1: Vector2i
var point_2: Vector2i

var is_placing_first_point: bool = true


func _on_left_click_pressed() -> void:
	if is_placing_first_point:
		is_placing_first_point = false
		point_1 = current_cell
	else:
		is_placing_first_point = true
		point_2 = current_cell
		preview_tiles.hide_all()
		var x: Dictionary[Vector2i, PackedScene] = {}
		for coord in GridUtils.get_coords_in_rect(point_1, point_2):
			x.set(coord, draw_tile)
		draw(x)

func _on_right_click_pressed() -> void:
	if is_placing_first_point:
		is_placing_first_point = false
		point_1 = current_cell
	else:
		is_placing_first_point = true
		point_2 = current_cell
		preview_tiles.hide_all()
		_erase_tiles(GridUtils.get_coords_in_rect(point_1, point_2))
		
func reset() -> void:
	preview_tiles.hide_all()

func mouse_moved(new_current_coords: Vector2i) -> void:
	if new_current_coords == current_cell:
		return
	current_cell = new_current_coords 
	if is_placing_first_point:
		point_1 = current_cell
	else:
		point_2 = current_cell
	_draw_preview()

func _draw_preview():
	preview_tiles.hide_all()
	if is_placing_first_point:
		preview_tiles.set_tile(point_1)
	else:
		preview_tiles.set_tiles(GridUtils.get_coords_in_rect(point_1, point_2))
