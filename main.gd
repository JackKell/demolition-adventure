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
@onready var completed_level_ui: CompletedLevelUi = %CompletedLevelUi

enum State {
	PLAY,
	EDITOR,
	LEVEL_SELECT,
	MENU,
	LEVEL_WON,
}

var current_state: State

func _ready() -> void:
	ticker.timeout.connect(_on_tick)
	level_select.level_selected.connect(_on_level_selected)
	level_editor.ui.back_button.pressed.connect(_transition_state.bind(State.MENU))
	level_select.back_button.pressed.connect(_transition_state.bind(State.MENU))
	main_screen.play_button.pressed.connect(_transition_state.bind(State.LEVEL_SELECT))
	main_screen.level_editor_button.pressed.connect(_transition_state.bind(State.EDITOR))
	completed_level_ui.next_level_button.pressed.connect(_on_pressed_next_level_button)
	completed_level_ui.main_menu_button.pressed.connect(_on_pressed_main_menu_button)
	completed_level_ui.level_select_button.pressed.connect(_on_pressed_level_select_button)
	_transition_state(State.MENU)

func _on_level_selected(level_data: LevelData) -> void:
	level_index = levels.levels.find(level_data)
	_transition_state(State.PLAY)
	spawn_level(level_data)
	
func _transition_state(state: State) -> void:
	if current_state != null:
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
			ticker.start()
		State.EDITOR:
			level_editor.visible = true
			level_editor.ui.visible = true
			level_editor.make_current()
		State.LEVEL_SELECT:
			level_select.visible = true
		State.LEVEL_WON:
			completed_level_ui.visible = true

func _exit_state(state: State) -> void:
	match state:
		State.MENU:
			main_screen.visible = false
			menu_screen_set.visible = false
		State.PLAY:
			play_ui.visible = false
			ticker.stop()
		State.EDITOR:
			level_editor.visible = false
			level_editor.ui.visible = false
		State.LEVEL_SELECT:
			level_select.visible = false
		State.LEVEL_WON:
			completed_level_ui.visible = false

func _input(event: InputEvent) -> void:
	match current_state:
		State.PLAY:
			if event.is_action_pressed("restart"):
				get_viewport().set_input_as_handled()
				reload_current_level()
			elif event.is_action_pressed("escape"):
				_transition_state(State.LEVEL_SELECT)
		State.LEVEL_SELECT:
			if event.is_action_pressed("escape"):
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
	current_level.won.connect(_on_level_won, CONNECT_ONE_SHOT)
	ticker.start()
	_steps = 0
	_remaining_time = 999
	play_ui.set_time_remaining(_remaining_time)
	play_ui.set_level_name("Stage " + str(level_data.stage))
	play_ui.set_steps(_steps)
	connect_character.call_deferred()
	add_child(current_level)
	spawning = false

func connect_character():
	current_level._character.coords_changed.connect(_on_character_moved)
	current_level._character.died.connect(_on_level_lost)
	
func clear_current_level():
	if current_level:
		current_level.queue_free()

func load_next_level():
	level_index = (level_index + 1) % levels.levels.size()
	spawn_level(levels.levels.get(level_index))
	_transition_state(State.PLAY)

func _on_pressed_next_level_button():
	load_next_level()

func _on_pressed_level_select_button() -> void:
	_transition_state(State.LEVEL_SELECT)
	
func _on_pressed_main_menu_button() -> void:
	_transition_state(State.MENU)

func _on_character_moved():
	_steps += 1
	play_ui.set_steps(_steps)

func _on_tick() -> void:
	_remaining_time -= 1
	play_ui.set_time_remaining(_remaining_time)
	if _remaining_time == 0:
		ticker.stop()

func _on_level_lost():
	pass

func _on_level_won():
	_transition_state(State.LEVEL_WON)
	
