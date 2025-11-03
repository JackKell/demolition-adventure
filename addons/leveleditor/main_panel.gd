@tool
extends Control

@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_print_hello_pressed)
	
func _on_print_hello_pressed() -> void:
	pass
