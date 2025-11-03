class_name PlayerInputController
extends Node

@export var character: Character

var state: Vector2i = Vector2i.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		state.x = -1
	elif event.is_action_pressed("move_right"):
		state.x = 1
	elif event.is_action_pressed("move_up"):
		state.y = 1
	elif event.is_action_pressed("move_down"):
		state.y = -1
		
	if event.is_action_released("move_left") or event.is_action_released("move_right"):
		state.x = 0
	if event.is_action_released("move_up") or event.is_action_released("move_down"):
		state.y = 0
		

	if state.x != 0:
		character.input_direction = Vector2i.RIGHT * state.x
	elif state.y != 0:
		character.input_direction = Vector2i.UP * state.y
	else:
		character.input_direction = Vector2i.ZERO
