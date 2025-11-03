@tool
extends EditorPlugin

const MainPanel: PackedScene = preload("uid://bww38tv4mt5ma")

var main_panel_instance: Control

func _handles(object: Object) -> bool:
	if object is Resource:
		if object is LevelData:
			return true
	return false

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass
	
func _has_main_screen() -> bool:
	return true
	
func _get_plugin_name() -> String:
	return "Main Screen Plugin"

func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()

func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
