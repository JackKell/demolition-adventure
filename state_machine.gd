class_name StateMachine
extends RefCounted

signal state_changed(old_state, new_state)

static var EMPTY_STATE = SMState.new()

var current_state: SMState = EMPTY_STATE

var current_state_name:
	get():
		return current_state.name
		
var has_current_state: bool:
	get:
		return current_state != EMPTY_STATE

func transition(new_state: SMState):
	if new_state == current_state:
		return
	var old_state = current_state
	if has_current_state and current_state.exit:
		current_state.exit.call()
	current_state = new_state
	if has_current_state and current_state.enter:
		current_state.enter.call()
	state_changed.emit(old_state, new_state)

func process(delta: float) -> void:
	if current_state and current_state.process:
		current_state.process.call(delta)
