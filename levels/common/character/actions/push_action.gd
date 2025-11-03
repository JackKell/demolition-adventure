class_name PushAction
extends Action

# TODO: Look into making action composable so that rotation actions, move, push actions can be used
# between action types

var pusher: Character
var pushed: Bomb
var pusher_old_facing_direction: Vector2i
var pusher_old_rotation: float
var pusher_old_point: Vector3
var pushed_old_point: Vector3

func _init(p_pusher: Character, p_pushed: Bomb) -> void:
	pusher = p_pusher
	pushed = p_pushed
	pusher_old_point = p_pusher.global_position
	pushed_old_point = p_pushed.global_position
	pusher_old_facing_direction = p_pusher.face_direction
	pusher_old_rotation = p_pusher.body.rotation.y

func execute() -> bool:
	return true

func undo() -> void:
	pushed.global_position = pushed_old_point
	pusher.global_position = pusher_old_point
	pusher.face_direction = pusher_old_facing_direction
	pusher.body.rotation.y = pusher_old_rotation
	pushed.update_coords()
	pusher.update_coords()

func _to_string() -> String:
	return "PushAction"
