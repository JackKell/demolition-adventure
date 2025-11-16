class_name StateMachine
extends RefCounted

var current_state: SMState

var current_state_name:
	get():
		return current_state.name

func transition(new_state: SMState):
	if current_state and current_state.exit:
		current_state.exit.call()
	current_state = new_state
	if current_state and current_state.enter:
		current_state.enter.call()

func process(delta: float) -> void:
	if current_state and current_state.process:
		current_state.process.call(delta)
