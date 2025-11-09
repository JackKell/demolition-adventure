@abstract
class_name LevelEditorTool
extends Node

static var EMPTY_CELL_DATA = CellData.new(null, null)
var preview_tiles: PreviewTilePool
var tile_mapping: Dictionary[Vector2i, CellData] = {}
var current_cell: Vector2i = Vector2i.ZERO
var draw_tile: PackedScene
var undo_redo: UndoRedo

var left_click: bool = false:
	set(value):
		if value == left_click:
			return
		left_click = value
		if left_click:
			_on_left_click_pressed()
		else:
			_on_left_click_released()

var right_click: bool = false:
	set(value):
		if value == right_click:
			return
		right_click = value
		if right_click:
			_on_right_click_pressed()
		else:
			_on_right_click_released()
			
func activate() -> void:
	_draw_preview()

func deactivate() -> void:
	preview_tiles.hide_all()

func mouse_moved(_new_current_coords: Vector2i) -> void:
	pass

func _on_left_click_pressed() -> void:
	pass

func _on_left_click_released() -> void:
	pass

func _on_right_click_pressed() -> void:
	pass

func _on_right_click_released() -> void:
	pass
	
func _draw_preview() -> void:
	pass

func reset() -> void:
	pass

func undo_tiles(original_cell_types: Dictionary[Vector2i, PackedScene], coords_to_remove: Array[Vector2i]) -> void:
	_erase_tiles(coords_to_remove)
	for coords in original_cell_types.keys():
		var scene: PackedScene = original_cell_types.get(coords)
		var tile: Node3D = scene.instantiate()
		add_child(tile)
		tile.global_position.x = coords.x
		tile.global_position.z = coords.y
		tile_mapping.set(coords, CellData.new(scene, tile))
		

func _erase_tile(coords: Vector2i) -> void:
	if tile_mapping.has(coords):
		var old_tile: CellData = tile_mapping.get(coords)
		old_tile.node.queue_free()
		tile_mapping.erase(coords)

func _erase_tiles(coords_list: Array[Vector2i]) -> void:
	for coords in coords_list:
		_erase_tile(coords)
		
func get_cell_types(coords_list: Array[Vector2i]) -> Dictionary[Vector2i, PackedScene]:
	var result: Dictionary[Vector2i, PackedScene] = {}
	for coords in coords_list:
		if tile_mapping.has(coords):
			var cell_data: CellData = tile_mapping.get(coords, null)
			result.set(coords, cell_data.scene)
	return result

func _draw_tile(coords: Vector2i, tile_scene: PackedScene):
	_erase_tile(coords)
	var tile: Node3D = tile_scene.instantiate()
	add_child(tile)
	tile.global_position.x = coords.x
	tile.global_position.z = coords.y
	tile_mapping.set(coords, CellData.new(tile_scene, tile))

func _draw_tiles(coords_list: Dictionary[Vector2i, PackedScene]) -> void:
	for coords in coords_list:
		_draw_tile(coords, coords_list.get(coords))

func draw(coords_list: Dictionary[Vector2i, PackedScene]) -> void:
	var original_cell_types: Dictionary[Vector2i, PackedScene] = get_cell_types(coords_list.keys())
	undo_redo.create_action("draw box")
	undo_redo.add_do_method(_draw_tiles.bind(coords_list))
	undo_redo.add_undo_method(undo_tiles.bind(original_cell_types, coords_list.keys()))
	undo_redo.commit_action()
