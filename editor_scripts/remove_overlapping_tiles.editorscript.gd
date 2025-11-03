@tool
class_name RemoveOverlappingTiles
extends EditorScript

func _run() -> void:
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes.size() != 1:
		print("can only select one node")
		return
	var tiles_node = EditorInterface.get_selection().get_selected_nodes()[0]
	
	if tiles_node.name != "Tiles":
		print("node must be called tiles")
		return

	if tiles_node is Node3D:
		var map: Dictionary[Vector3, Node3D] = {}
		for tile_node in tiles_node.get_children():
			if tile_node is Node3D:
				var position: Vector3 = tile_node.global_position.snappedf(1.0)
				if map.has(position):
					tile_node.queue_free()
					prints("removed overalpping tile", tile_node.name, "at", position)
				else:
					map.set(position, tile_node)
