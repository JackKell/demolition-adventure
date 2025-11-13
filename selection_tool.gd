class_name SelectionTool
extends LevelEditorTool

var selection_grid: SelectionGrid
var is_holding_left: bool = false
var is_holding_right: bool = false

func activate() -> void:
	pass

func deactivate() -> void:
	pass

func _on_left_click_pressed() -> void:
	selection_grid.add_tile(current_cell)
	is_holding_left = true
	
func _on_left_click_released() -> void:
	is_holding_left = false
	

func _on_right_click_pressed() -> void:
	selection_grid.remove_tile(current_cell)
	is_holding_right = true

func _on_right_click_released() -> void:
	is_holding_right = false
	
func mouse_moved(new_current_coords: Vector2i) -> void:
	if new_current_coords == current_cell:
		return
	current_cell = new_current_coords
	if is_holding_left:
		selection_grid.add_tile(current_cell)
	elif is_holding_right:
		selection_grid.remove_tile(current_cell)
