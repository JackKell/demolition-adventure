@tool @abstract
class_name NodeUtils
extends Object

static func is_decedent(parent_node: Node, child_node: Node) -> bool:
	var current_parent = child_node.get_parent()
	while current_parent != null:
		if current_parent == parent_node:
			return true
		else:
			current_parent = current_parent.get_parent()
	return false

static func get_global_position_3D(node: Node3D) -> Vector3:
	return node.global_position
