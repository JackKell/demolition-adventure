class_name PencilTool
extends LevelEditorTool

enum Shape {
	BOX,
	CIRCLE,
}

@export var shape: Shape = Shape.CIRCLE
@export var size: int = 1

var _stroke: Dictionary[Vector2i, bool] = {}

func activate() -> void:
	preview_tiles.hide_all()

func deactivate() -> void:
	preview_tiles.hide_all()

func _on_left_click_pressed():
	_stroke.set(current_cell, true)
	_draw_tile(current_cell, draw_tile)

func _on_left_click_released() -> void:
	_erase_tiles(_stroke.keys())
	var x: Dictionary[Vector2i, PackedScene] = {}
	for coord in _stroke.keys():
		x.set(coord, draw_tile)
	draw(x)
	_stroke.clear()

func _on_right_click_pressed() -> void:
	_erase_tile(current_cell)

func mouse_moved(new_current_coords: Vector2i) -> void:
	if new_current_coords == current_cell:
		return
	current_cell = new_current_coords
	preview_tiles.hide_all()
	preview_tiles.set_tile(current_cell)
	if left_click:
		_stroke.set(current_cell, true)
		_draw_tile(current_cell, draw_tile)
	elif right_click:
		_erase_tile(current_cell)
