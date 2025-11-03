class_name ActionHistory
extends RefCounted

var _last_action_pointer: int = -1
var _history: Array[Action] = []

func add(new_action: Action) -> void:
	for index in range(_history.size() - 1, _last_action_pointer, -1):
		_history.remove_at(index)
	_history.append(new_action)
	_last_action_pointer += 1

func redo():
	print("impelement redo! :(")
	
func undo():
	if _last_action_pointer < 0:
		return 
	var last_action: Action = _history.get(_last_action_pointer)
	last_action.undo()
	_last_action_pointer -= 1
