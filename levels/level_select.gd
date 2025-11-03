class_name LevelSelect
extends Control


const LEVEL_OPTION: PackedScene = preload("uid://bum7dca86w1j4")

@export var levels_data: Levels

@onready var level_options: GridContainer = %LevelOptions
@onready var world_tabs: TabBar = %WorldTabs

signal level_selected(level_data: LevelData)

var level_index: int = 0
var selected_world: int = 1
var world_to_levels: Dictionary[int, Levels] = {}
var level_options_objects: Array[LevelOption] = []

func _ready() -> void:
	world_tabs.tab_changed.connect(_on_tab_changed)
	for level_data in levels_data.levels:
		var level_option: LevelOption = LEVEL_OPTION.instantiate()
		level_option.level_data = level_data
		level_option.clicked.connect(_on_clicked_level.bind(level_option))
		level_options_objects.append(level_option)
		level_options.add_child(level_option)
	_on_tab_changed(0)

func _on_tab_changed(tab: int):
	selected_world = tab + 1
	for level_option: LevelOption in level_options_objects:
		level_option.visible = level_option.level_data.world == selected_world

func _on_clicked_level(levelOption: LevelOption) -> void:
	level_selected.emit(levelOption.level_data)
