class_name FillTool
extends LevelEditorTool

@export var max_draw_distance: int = 30

const HIGHLIGHT_TILE = preload("uid://dy6pw763hvr5")
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

@export var continuous: bool = true

var is_placing_first_point: bool = true

var connected_coords: Array[Vector2i] = []

func _ready() -> void:
	preview_tiles = PreviewTilePool.new()
	add_child(preview_tiles)

func _on_left_click_pressed() -> void:
	var x: Dictionary[Vector2i, PackedScene] = {}
	for coord in connected_coords:
		x.set(coord, draw_tile)
	draw(x)

func _on_right_click_pressed() -> void:
	_erase_tiles(connected_coords)

func mouse_moved(new_current_coords: Vector2i) -> void:
	if new_current_coords == current_cell:
		return
	current_cell = new_current_coords
	connected_coords = get_connect_coords()
	_draw_preview()

func get_connect_coords() -> Array[Vector2i]:
	var filled_coords: Array[Vector2i] = []
	# TODO: make this actually check the type of the thing being painted
	var start_type: PackedScene = tile_mapping.get(current_cell, EMPTY_CELL_DATA).scene
	var visited: Dictionary[Vector2i, bool] = {}
	var frontier: Array[Vector2i] = [current_cell]
	const MAX_MAP_SIZE: Vector2i = Vector2i(25, 25)
	while !frontier.is_empty():
		var coords: Vector2i = frontier.pop_front()
		visited.set(coords, true)
		# TODO: use max map size instead of hard coded
		if tile_mapping.get(coords, EMPTY_CELL_DATA).scene == start_type and abs(coords.x) <= MAX_MAP_SIZE.x and abs(coords.y) <= MAX_MAP_SIZE.y:
			filled_coords.append(coords)
			preview_tiles.set_tile(coords)
			for neighbor_direction in DIRECTIONS:
				var neighbor_coord: Vector2i = neighbor_direction + coords
				if !visited.has(neighbor_coord) and !frontier.has(neighbor_coord):
					frontier.append(neighbor_coord)
	return filled_coords

func _draw_preview():
	preview_tiles.hide_all()
	preview_tiles.set_tiles(connected_coords)
