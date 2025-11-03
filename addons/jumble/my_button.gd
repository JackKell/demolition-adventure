@tool
class_name MyButton
extends Button

func _enter_tree() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	prints(name, "pressed")
