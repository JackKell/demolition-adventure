@abstract
class_name Action
extends RefCounted

func _init() -> void:
	pass

func execute() -> bool:
	return true

func undo() -> void:
	pass

func _to_string() -> String:
	return super.to_string()
