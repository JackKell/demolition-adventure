@tool
class_name JumbleSandyBrickTiles
extends EditorScript

const SANDY_BRICK_1_TILE = preload("uid://mr1atvvs4qae")
const SANDY_BRICK_2_TILE = preload("uid://bc073xu5yq0wj")
const SANDY_BRICK_3_TILE = preload("uid://dnabsi3t3jusq")

const TILE_OPTIONS: Array[PackedScene] = [
	SANDY_BRICK_1_TILE,
	SANDY_BRICK_2_TILE,
	SANDY_BRICK_3_TILE,
]

var undo_redo

func _run() -> void:
	print("run jumble tiles script")
	undo_redo = UndoRedo.new()
	var sandy_brick_tiles = get_scene().get_tree().get_nodes_in_group("sandy_brick_tile")
	for sandy_brick_tile in sandy_brick_tiles:
		if sandy_brick_tile is Node3D:
			var new_sandy_brick_tile: Node3D = TILE_OPTIONS.pick_random().instantiate()
			new_sandy_brick_tile.global_position = sandy_brick_tile.global_position
			var parent = sandy_brick_tile.get_parent()
			sandy_brick_tile.get_parent().add_child(new_sandy_brick_tile, true)
			new_sandy_brick_tile.owner = get_scene()
			parent.remove_child(sandy_brick_tile)
