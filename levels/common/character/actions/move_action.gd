class_name MoveAction
extends Action

var entity: Entity
var target: Vector3
var old_position: Vector3

func _init(p_entity: Entity, p_target: Vector3) -> void:
	old_position = p_entity.global_position
	entity = p_entity
	target = p_target

func execute() -> bool:
	return true

func undo() -> void:
	entity.global_position = old_position
	entity.update_coords()

func _to_string() -> String:
	return  "MoveAction " + str(target)
