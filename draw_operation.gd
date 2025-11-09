class_name DrawOperation
extends LevelEditorOperation

var _coords: Array[Vector2i]
var _tile_scene: PackedScene
var _created_tiles: Array[Node3D] = []
var _parent_node: Node3D

func _init(coords: Array[Vector2i], tile_scene: PackedScene, parent_node: Node3D) -> void:
	_coords = coords
	_tile_scene = tile_scene
	_parent_node = parent_node
	add_do_method(draw_tiles)
	add_undo_method(remove_tiles)

func draw_tiles():
	for coord: Vector2i in _coords:
		var tile: Node3D = _tile_scene.instantiate()
		_parent_node.add_child(tile)
		tile.global_position = VectorUtils.vector3_xz(coord)
	
func remove_tiles():
	for tile in _created_tiles:
		tile.queue_free()
	_created_tiles.clear()
