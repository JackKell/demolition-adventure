@tool
extends EditorScript

func _run() -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selection.size() != 1:
		return
	var root: Node = selection.get(0)
	
	var seen: Dictionary[Vector2i, bool] = {}
	for child in root.get_children():
		if child is Tile:
			var pos = child.global_position
			var index = Vector2i(pos.x, pos.z)
			if seen.has(index):
				prints("found duplicate at", index)
				child.queue_free()
			else:
				seen.set(index, true)
