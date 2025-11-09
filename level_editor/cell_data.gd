class_name CellData
extends RefCounted

var scene: PackedScene
var node: Node3D

func _init(new_scene: PackedScene, new_node: Node3D) -> void:
	scene = new_scene
	node = new_node
