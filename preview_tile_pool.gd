class_name PreviewTilePool
extends Node3D

const HIGHLIGHT_TILE = preload("uid://dy6pw763hvr5")

var preview_tiles: Array[Node3D] = []
var i: int = 0

func hide_all() -> void:
	for tile in preview_tiles:
		tile.visible = false
	i = 0
	
func set_tile(coords: Vector2i) -> void:
	var tile: Node3D 
	if i >= preview_tiles.size():
		tile = HIGHLIGHT_TILE.instantiate()
		add_child(tile)
		preview_tiles.append(tile)
	else:
		tile = preview_tiles.get(i)  
	i += 1
	tile.visible = true
	tile.global_position = VectorUtils.vector3_xz(coords)

func set_tiles(coords: Array[Vector2i]) -> void:
	for coord in coords:
		set_tile(coord)

func get_cell_coords() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for tile: Node3D in preview_tiles.slice(0, i): 
		result.append(VectorUtils.vector2i_xz(tile.global_position))
	return result
