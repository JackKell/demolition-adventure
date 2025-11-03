class_name CharacterMoveAction
extends MoveAction

var old_face_direction: Vector2i
var old_rotation: float


func _init(p_entity: Character, p_target: Vector3) -> void:
	super._init(p_entity, p_target)
	old_face_direction = p_entity.face_direction
	old_rotation = p_entity.body.rotation.y

func execute() -> bool:
	return super.execute()

func undo() -> void:
	super.undo()
	entity.face_direction = old_face_direction
	entity.body.rotation.y = old_rotation
	

func _to_string() -> String:
	return  "CharacterMoveAction " + str(target)
