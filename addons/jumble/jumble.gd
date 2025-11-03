@tool
extends EditorPlugin

var dock: Control

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/jumble/my_dock.tscn").instantiate()
	dock.undo_redo = get_undo_redo()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
