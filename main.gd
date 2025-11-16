extends Node3D

var current_level: Level
var spawning: bool = false
var _remaining_time: int = 0
var _steps: int = 0

@export var levels: Levels
@export var level_index: int = 0

@onready var menu_screen_set: MainMenuSet = %MenuScreenSet
@onready var ticker: Timer = $Ticker
@onready var play_ui: PlayUi = %PlayUi
@onready var level_select: LevelSelect = %LevelSelect
@onready var main_screen: MainGameScreen = %MainScreen
@onready var level_editor: LevelEditor = %LevelEditor3D

enum State {
	PLAY,
	EDITOR,
	LEVEL_SELECT,
	MENU,
}

var current_state: State

func _ready() -> void:
	ticker.timeout.connect(_on_tick)
	level_select.level_selected.connect(_on_level_selected)
	level_editor.ui.back_button.pressed.connect(_transition_state.bind(State.MENU))
	level_select.back_button.pressed.connect(_transition_state.bind(State.MENU))
	main_screen.play_button.pressed.connect(_transition_state.bind(State.LEVEL_SELECT))
	main_screen.level_editor_button.pressed.connect(_transition_state.bind(State.EDITOR))
	_transition_state(State.MENU)

func _on_level_selected(level_data: LevelData) -> void:
	level_index = levels.levels.find(level_data)
	_transition_state(State.PLAY)
	spawn_level(level_data)
	
func _transition_state(state: State) -> void:
	if current_state:
		_exit_state(current_state)
	current_state = state
	_enter_state(current_state)

func _enter_state(state: State) -> void:
	match state:
		State.MENU:
			main_screen.visible = true
			menu_screen_set.visible = true
			menu_screen_set.camera.make_current()
			clear_current_level()
		State.PLAY:
			play_ui.visible = true
		State.EDITOR:
			level_editor.visible = true
			level_editor.ui.visible = true
			level_editor.make_current()
		State.LEVEL_SELECT:
			level_select.visible = true

func _exit_state(state: State) -> void:
	match state:
		State.MENU:
			main_screen.visible = false
			menu_screen_set.visible = false
		State.PLAY:
			play_ui.visible = false
		State.EDITOR:
			level_editor.visible = false
			level_editor.ui.visible = false
		State.LEVEL_SELECT:
			level_select.visible = false 

func _input(event: InputEvent) -> void:
	match current_state:
		State.PLAY:
			if event is InputEventKey:
				if event.keycode == KEY_ESCAPE and event.is_pressed():
					_transition_state(State.LEVEL_SELECT)
				if event.keycode == KEY_R and event.is_released():
					get_viewport().set_input_as_handled()
					reload_current_level()
		State.LEVEL_SELECT:
			if event is InputEventKey:
				if event.keycode == KEY_ESCAPE and event.is_pressed():
					_transition_state(State.PLAY)
		State.EDITOR:
			level_editor.update_input(event)

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
	
func clear_current_level():
	if current_level:
		current_level.queue_free()

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
