extends Node3D


var current_level: Level
var spawning: bool = false
var _remaining_time: int = 0
var _steps: int = 0

@export var levels: Levels
@export var level_index: int = 0

@onready var play_ui: PlayUi = $CanvasLayer/PlayUi
@onready var ticker: Timer = $Ticker
@onready var level_select: LevelSelect = $CanvasLayer/LevelSelect

func _ready() -> void:
	ticker.timeout.connect(_on_tick)
	level_select.level_selected.connect(_on_level_selected)

func _on_level_selected(level_data: LevelData) -> void:
	level_index = levels.levels.find(level_data)
	play_ui.visible = true
	spawn_level(level_data)
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_released():
			level_select.visible = !level_select.visible
			play_ui.visible = !play_ui.visible
		if event.keycode == KEY_R and event.is_released():
			get_viewport().set_input_as_handled()
			reload_current_level()
			
func reload_current_level() -> void:
	spawn_level(levels.levels.get(level_index))
	
func spawn_level(level_data: LevelData) -> void:
	if spawning:
		return
	spawning = true
	level_select.visible = false
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited
	current_level = level_data.level_scene.instantiate()
	current_level.all_bombs_detonated.connect(_on_level_completed, CONNECT_ONE_SHOT)
	connect_character.call_deferred()
	ticker.start()
	_steps = 0
	_remaining_time = 999
	play_ui.set_time_remaining(_remaining_time)
	play_ui.set_level_name("Stage " + str(level_data.stage))
	play_ui.set_steps(_steps)
	add_child(current_level)
	spawning = false

func connect_character():
	current_level._character.coords_changed.connect(_on_character_moved)

func _on_character_moved():
	_steps += 1
	play_ui.set_steps(_steps)

func _on_tick() -> void:
	_remaining_time -= 1
	play_ui.set_time_remaining(_remaining_time)
	if _remaining_time == 0:
		ticker.stop()
		print("ran out of time")

func _on_level_completed():
	ticker.stop()
	await get_tree().create_timer(5).timeout
	level_index = (level_index + 1) % levels.levels.size()
	spawn_level(levels.levels.get(level_index))
