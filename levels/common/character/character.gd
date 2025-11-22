class_name Character
extends Entity

signal died
signal input_direction_changed

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]
const QUARTER_TURN: float = TAU / 4
const CAMERA_ROTATION_PER_SECOND: float = TAU * 1.5
const SQUISH_DURATION: float = 0.05

@export var body: Node3D
@export var animation_player: AnimationPlayer
@export var input_direction: Vector2i = Vector2i.ZERO:
	set(value):
		var new_direction = value
		if camera.current:
			new_direction = Vector2i(Vector2(value).rotated(-_target_camera_rotation))
		if new_direction != input_direction:
			input_direction = new_direction
			input_direction_changed.emit()

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var current_state_label: Label3D = %CurrentStateLabel

var is_panicked: bool = false
var is_alive: bool = true
var face_direction: Vector2i = Vector2i.DOWN
var target_position: Vector3 =  Vector3.ZERO
var is_animating: bool = false
var has_input_direction: bool:
	get:
		return !is_zero_approx(input_direction.length_squared())
var state_machine: StateMachine = StateMachine.new()
var walk_state: SMState = SMState.new()
var sliding_state: SMState = SMState.new()
var idle_state: SMState = SMState.new()
var animating_state: SMState = SMState.new()
var locked_state: SMState = SMState.new()
var death_state: SMState = SMState.new()
var bounce_state: SMState = SMState.new()
var pushing_state: SMState = SMState.new()
var flatten_state: SMState = SMState.new()

var moving_states: Array[SMState] = [
	walk_state,
	pushing_state,
	bounce_state,
]

var _target_camera_rotation: float = 0

func _ready() -> void:
	walk_state.name = "WALK"
	sliding_state.name = "SLIDING"
	idle_state.name = "IDLE"
	animating_state.name = "ANIMATING"
	locked_state.name = "LOCKED"
	death_state.name = "DEATH"
	bounce_state.name = "BOUCE"
	pushing_state.name = "PUSHING"
	flatten_state.name = "FLATTEN"
	flatten_state.enter = flatten_enter
	walk_state.enter = walk_enter
	pushing_state.enter = pushing_enter
	death_state.enter = death_enter
	death_state.exit = death_exit
	sliding_state.enter = sliding_enter
	idle_state.enter = idle_enter
	idle_state.handle_input = idle_input
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.transition(idle_state)
	input_direction_changed.connect(_on_input_direction_changed)
	stopped.connect(_on_stopped)
	moved.connect(_on_moved)
	var input_controller: PlayerInputController = PlayerInputController.new()
	input_controller.character = self
	add_child(input_controller)

func _on_input_direction_changed():
	var state_input_handler: Callable = state_machine.current_state.handle_input
	if state_input_handler:
		state_input_handler.call()

func _on_moved():
	if state_machine.current_state == walk_state or state_machine.current_state == pushing_state:
		audio_stream_player_3d.play()

func _on_state_changed(_old_state: SMState, new_state: SMState):
	current_state_label.text = new_state.name

func _on_stopped() -> void:
	var tile: Tile = level.get_tile(coords)
	if tile.type == Tile.TileType.OIL:
		struggle()
		return
	
	if !moving_states.has(state_machine.current_state):
		return
	
	# Bouncing State Stuff
	var has_other_entity: bool = false
	for e in level._entities:
		if e != self and e.coords == coords:
			has_other_entity = true
			break
	if tile == null:
		body.rotate_y(PI)
		face_direction = Vector2i(Vector2(face_direction).rotated(PI))
		bounce(face_direction)
		return
	elif tile.type == Tile.TileType.SPIKES or has_other_entity:
		bounce(face_direction)
		return

		
	if !has_input_direction:
		if tile.type == Tile.TileType.ICY:
			if can_move_to(last_move_direction):
				state_machine.transition(sliding_state)
				move(last_move_direction)
			else:
				state_machine.transition(idle_state)
		else:
			state_machine.transition(idle_state)
		return
	_handle_move(input_direction)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		# TODO: find away to reset level state instead of reloading the scene
		get_tree().reload_current_scene()
		
func _handle_move(direction: Vector2i) -> void:
	# TODO: Refactor this to be more simple
	var target_coords: Vector2i = coords + direction
	var entity: Entity = level.get_entity(target_coords)
	if entity:
		if entity is Bomb and entity.pushable:
			var push_action: PushAction = PushAction.new(self, entity)
			var tile: Tile = level.get_tile(coords)
			if tile.type == Tile.TileType.OIL:
				struggle()
			else:
				var blocking_entity: Entity = level.get_entity(coords + direction * 2)
				if blocking_entity:
					if blocking_entity is Bouncer:
						entity.move(-direction)
						move(direction)
						squish()
						blocking_entity.bounce(-direction)
						level.add_action(push_action)
					else:
						state_machine.transition(idle_state)
				else:
					var can_push: bool = entity.try_move(direction)
					if can_push:
						state_machine.transition(pushing_state)
						level.add_action(push_action)
						move(direction)
					else:
						state_machine.transition(idle_state)
		else:
			state_machine.transition(idle_state)
			
	else:
		var move_happened: bool = try_move(direction)
		if move_happened:
			state_machine.transition(walk_state)
			level.add_action(CharacterMoveAction.new(self, level.map_to_world(target_coords)))
		else:
			state_machine.transition(idle_state)
	face_direction = direction
	_update_body_facing_direction(direction)

func idle_input() -> void:
	if is_moving or !has_input_direction:
		return
	_handle_move(input_direction)

func try_ignite() -> void:
	if state_machine.current_state != idle_state:
		return
	for direction: Vector2i in DIRECTIONS:
		var check_coords: Vector2i = coords + direction
		var start_bomb: StartBomb = level.get_ignitor_bomb(check_coords)
		if start_bomb and !start_bomb.is_ignited:
			_update_body_facing_direction(direction)
			await _play_animation("ignite")
			start_bomb.ignite()
			is_panicked = true
			face_direction = direction

func _play_animation(animation_name: String) -> bool:
	state_machine.transition(animating_state)
	animation_player.play(animation_name)
	await animation_player.animation_finished
	state_machine.transition(idle_state)
	return true

func _update_body_facing_direction(direction: Vector2i) -> void:
	body.rotation.y = Vector2(direction * Vector2i(1, -1)).angle() + QUARTER_TURN

func _input(event: InputEvent) -> void:
	if is_animating:
		return
	
	if event.is_action_pressed("ignite"):
		try_ignite()
	
	_handle_camera_rotation(event)

func death_enter() -> void:
	is_alive = false
	hide()
	died.emit()
	visible = false
	
func death_exit() -> void:
	show()
	is_alive = true
	visible = true

func sliding_enter() -> void:
	animation_player.play("sliding")

func idle_enter() -> void:
	animation_player.play("idle")
	if has_input_direction:
		_handle_move(input_direction)

func walk_enter() -> void:
	audio_stream_player_3d.play()
	animation_player.play("walk")

func pushing_enter() -> void:
	audio_stream_player_3d.play()
	animation_player.play("push")

func flatten_enter() -> void:
	animation_player.play("flatten")
	await animation_player.animation_finished
	await get_tree().create_timer(SQUISH_DURATION).timeout
	state_machine.transition(idle_state)
	
func _handle_camera_rotation(event: InputEvent) -> void:
	if !camera.current:
		return
	if event.is_action_pressed("rotate_camera_right"):
		_rotate_camera(QUARTER_TURN)
	elif event.is_action_pressed("rotate_camera_left"):
		_rotate_camera(-QUARTER_TURN)

func _rotate_camera(delta: float) -> void:
	_target_camera_rotation = fposmod(_target_camera_rotation + delta, TAU)

func _process(delta: float) -> void:
	if not level:
		return
	
	_update_camera_rotation(delta)
	
	state_machine.process(delta)

func _update_camera_rotation(delta: float):
	var camera_y_rotation: float = camera_pivot.rotation.y
	if !is_equal_approx(camera_y_rotation, _target_camera_rotation):
		camera_pivot.rotation.y = rotate_toward(
			camera_y_rotation, 
			_target_camera_rotation, 
			delta * CAMERA_ROTATION_PER_SECOND
		)

func struggle():
	if state_machine.current_state == animating_state:
		return
	state_machine.transition(animating_state)
	animation_player.play("fall")
	await animation_player.animation_finished
	state_machine.transition(idle_state)

func squish():
	state_machine.transition(flatten_state)

func bounce(direction: Vector2i):
	state_machine.transition(bounce_state)
	const t: float = 0.45
	const height: float = 1.25
	is_animating = true
	var target_pos: Vector3 = global_position + Vector3(direction.x, 0, direction.y)
	coords += direction
	var verticle: Tween = get_tree().create_tween()
	verticle.tween_property(body, "position:y", height, t / 2).set_ease(Tween.EASE_OUT).as_relative()
	verticle.tween_property(body, "position:y", -height, t / 2).set_ease(Tween.EASE_IN).as_relative()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_subtween(verticle)
	tween.parallel().tween_property(self, "global_position", target_pos, t)
	tween.tween_property(self, "is_animating", false, 0)
	tween.tween_callback(stopped.emit)
	return tween

func lock() -> void:
	state_machine.transition(locked_state)

func detonate() -> void:
	state_machine.transition(death_state)
