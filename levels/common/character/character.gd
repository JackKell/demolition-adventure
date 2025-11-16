class_name Character
extends Entity

const QUARTER_TURN: float = TAU / 4

var face_direction: Vector2i = Vector2i.DOWN
var target_position: Vector3 =  Vector3.ZERO
var is_animating: bool = false
var _target_camera_rotation: float = 0

@export var body: Node3D
@export var animation_player: AnimationPlayer
@export var input_direction: Vector2i = Vector2i.ZERO

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var is_panicked: bool = false

var state_machine: StateMachine = StateMachine.new()
var walk_state: SMState = SMState.new()
var sliding_state: SMState = SMState.new()
var idle_state: SMState = SMState.new()
var animating_state: SMState = SMState.new()
var locked_state: SMState = SMState.new()

func _init() -> void:
	idle_state.process = idle_process
	state_machine.transition(idle_state)

func _ready() -> void:
	stopped.connect(_on_stopped)
	moved.connect(_on_moved)
	var input_controller: PlayerInputController = PlayerInputController.new()
	input_controller.character = self
	add_child(input_controller)

func _on_stopped() -> void:
	audio_stream_player_3d.stop()
	if animation_player.current_animation == "walk":
		animation_player.play("idle")
	var tile = level.get_tile(coords)
	
	var has_other_entity: bool = false
	for e in level._entities:
		if e != self and e.coords == coords:
			has_other_entity = true
			break
	if tile == null:
		body.rotate_y(PI)
		face_direction = Vector2i(Vector2(face_direction).rotated(PI))
		bounce(face_direction)
	elif tile.type == Tile.TileType.SPIKES or has_other_entity:
		bounce(face_direction)
	elif tile.type == Tile.TileType.ICY:
		if can_move_to(input_direction):
			animation_player.play("sliding")
			move(input_direction)

func _on_moved() -> void:
	audio_stream_player_3d.play()
	if animation_player:
		animation_player.play("walk")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		# TODO: find away to reset level state instead of reloading the scene
		get_tree().reload_current_scene()

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

func try_ignite() -> void:
	for direction: Vector2i in DIRECTIONS:
		var check_coords: Vector2i = coords + direction
		var start_bomb: StartBomb = level.get_ignitor_bomb(check_coords)
		if start_bomb:
			start_bomb.ignite()
			face_direction = direction
			_update_body_facing_direction(direction)

func _update_body_facing_direction(direction: Vector2i) -> void:
	body.rotation.y = Vector2(direction * Vector2i(1, -1)).angle() + QUARTER_TURN

func _input(event: InputEvent) -> void:
	if is_animating:
		return
	
	if event.is_action_pressed("ignite"):
		try_ignite()
	
	_handle_camera_rotation(event)

func idle_process(_delta: float) -> void:
	var current_direction = Vector2i(input_direction)
	if camera.current:
		current_direction = Vector2i(Vector2(current_direction).rotated(-_target_camera_rotation))
	if !is_moving and current_direction.length() >  0:
		var target_coords: Vector2i = coords + current_direction
		var entity: Entity = level.get_entity(target_coords)
		if entity: 
			if entity is Bomb and entity.pushable:
				var push_action: PushAction = PushAction.new(self, entity)
				var tile: Tile = level.get_tile(coords)
				if tile.type == Tile.TileType.OIL:
					struggle()
				else:
					var push_entity: Entity = level.get_entity(coords + current_direction * 2)
					if push_entity:
						if push_entity is Bouncer:
							entity.move(-current_direction)
							move(current_direction)
							squish()
							push_entity.bounce(-current_direction)
							level.add_action(push_action)
					else:
						var can_push: bool = entity.try_move(current_direction)
						if can_push:
							level.add_action(push_action)
							move(current_direction)
		else:
			var move_happened: bool = try_move(current_direction)
			if move_happened:
				level.add_action(CharacterMoveAction.new(self, level.map_to_world(target_coords)))
		face_direction = current_direction
		_update_body_facing_direction(face_direction)

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
	
	var camera_y_rotation: float = camera_pivot.rotation.y
	if !is_equal_approx(camera_y_rotation, _target_camera_rotation):
		camera_pivot.rotation.y = rotate_toward(
			camera_y_rotation, 
			_target_camera_rotation, 
			delta * 3 * PI
		)
	
	state_machine.process(delta)

func struggle():
	if state_machine.current_state == animating_state:
		return
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(state_machine.transition.bind(animating_state))
	tween.tween_property(body, "rotation:x", PI / 4, .2).as_relative()
	tween.tween_property(body, "rotation:x", -PI / 4, .2).as_relative()
	tween.tween_property(self, "is_animating", false, 0)
	tween.tween_callback(state_machine.transition.bind(idle_state))
	return tween

func squish():
	if state_machine.current_state == animating_state:
		return
	state_machine.transition(animating_state)
	animation_player.play("flatten")
	await animation_player.animation_finished
	await get_tree().create_timer(1).timeout
	state_machine.transition(idle_state)

func bounce(direction: Vector2i):
	if is_animating:
		return
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
