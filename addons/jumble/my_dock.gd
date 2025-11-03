@tool
extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var randomize_sprite_color_button: Button = %RandomizeSpriteColorButton
@onready var selected_color_preview: ColorRect = %SelectedColorPreview
@onready var set_color_button: Button = %SetColorButton
@onready var color_picker: ColorPicker = %ColorPicker
@onready var _selection: EditorSelection = EditorInterface.get_selection()
@onready var hue_range_select: RangeSelect = %HueRangeSelect
@onready var saturation_range_select: RangeSelect = %SaturationRangeSelect
@onready var value_range_select: RangeSelect = %ValueRangeSelect

var undo_redo: EditorUndoRedoManager

var _selected_sprites: Array[Sprite2D] = []

func _ready() -> void:
	randomize_sprite_color_button.pressed.connect(_on_action_button_pressed)
	color_picker.color_changed.connect(_on_color_changed)
	_selection.selection_changed.connect(_on_selection_changed)
	_on_selection_changed()
	set_color_button.pressed.connect(_on_set_color_button_pressed)
	
func _on_set_color_button_pressed():
	for sprite: Sprite2D in _selected_sprites:
		sprite.modulate = color_picker.color
	
func _on_selection_changed():
	_selected_sprites.clear()
	for node in _selection.get_selected_nodes():
		if node is Sprite2D:
			_selected_sprites.append(node)
	randomize_sprite_color_button.disabled = _selected_sprites.is_empty()
	set_color_button.disabled = _selected_sprites.is_empty()
	
func _on_color_changed(new_color: Color) -> void:
	selected_color_preview.color = new_color
	
func _on_action_button_pressed() -> void:
	undo_redo.create_action("My Plugin: randomize color")
	for node in EditorInterface.get_selection().get_selected_nodes():
		if node is Sprite2D:
			var hue: float = randf_range(hue_range_select.min_value, hue_range_select.max_value)
			var saturation: float = randf_range(saturation_range_select.min_value, saturation_range_select.max_value)
			var value: float = randf_range(value_range_select.min_value, value_range_select.max_value)
			var random_color = Color.from_hsv(hue, saturation, value)
			#var random_color: Color = Color(randf(), randf(), randf(), 1.0)
			undo_redo.add_do_property(node, "modulate", random_color)
			undo_redo.add_undo_property(node, "modulate", node.modulate)
	undo_redo.commit_action()
