class_name LevelEditorUi
extends Control


@onready var selection_tool_button: Button = %SelectionToolButton
@onready var pencil_tool_button: Button = %PencilToolButton 
@onready var line_tool_button: Button = %LineToolButton
@onready var bucket_tool_button: Button = %BucketToolButton
@onready var box_tool_button: Button = %BoxToolButton
@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton
@onready var selected_tile_label: Label = %SelectedTileLabel
@onready var tile_list: ItemList = %TileList
@onready var entity_list: ItemList = %EntityList
@onready var theme_option_button: OptionButton = %ThemeOptionButton
@onready var back_button: Button = %BackButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var clear_button: Button = %ClearButton
@onready var toggle_grid_button: Button = %ToggleGridButton
@onready var x_mirror_button: Button = %XMirrorButton
@onready var y_mirror_button: Button = %YMirrorButton
@onready var x_mirror_offset_spin_box: SpinBox = %XMirrorOffsetSpinBox
@onready var y_mirror_offset_spin_box: SpinBox = %YMirrorOffsetSpinBox
