class_name Character
extends Entity

var locked: bool = false
var face_direction: Vector2i = Vector2i.DOWN
var target_position: Vector3 =  Vector3.ZERO

var _target_camera_rotation: float = 0

@export var body: Node3D
@export var animation_player: AnimationPlayer
@export var input_direction: Vector2i = Vector2i.ZERO

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var is_animating: bool = false

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
	if event is InputEventKey:
		if event.keycode == KEY_R and event.is_released():
			get_tree().reload_current_scene()

func try_ignite() -> void:
	var target_coords: Vector2i = coords + face_direction
	var entity: Entity = level.get_entity(target_coords)
	if entity is StartBomb:
		entity.ignite()

func _input(event: InputEvent) -> void:
	if is_animating:
		return
	
	if event.is_action_pressed("ignite"):
		try_ignite()
	
	if camera.current:
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_E:
				_target_camera_rotation = fposmod(_target_camera_rotation + (PI / 2), TAU)
			elif event.keycode == KEY_Q:
				_target_camera_rotation = fposmod(_target_camera_rotation - (PI / 2), TAU)

func _process(delta: float) -> void:
	var camera_y_rotation: float = camera_pivot.rotation.y
	if !is_equal_approx(camera_y_rotation, _target_camera_rotation):
		camera_pivot.rotation.y = rotate_toward(
			camera_y_rotation, 
			_target_camera_rotation, 
			delta * 3 * PI
		)

	if locked:
		return
	
	if is_animating:
		return
	
	if !is_moving and input_direction.length() >  0:
		if camera.current:
			var rotated_input_direction: Vector2i = Vector2i(Vector2(input_direction).rotated(-_target_camera_rotation))
			input_direction = rotated_input_direction 
		var target_coords: Vector2i = coords + input_direction
		var entity: Entity = level.get_entity(target_coords)
		if entity: 
			if entity is Bomb and entity.pushable:
				var push_action: PushAction = PushAction.new(self, entity)
				var tile: Tile = level.get_tile(coords)
				if tile.type == Tile.TileType.OIL:
					await play_struggle().finished
				else:
					var push_entity: Entity = level.get_entity(coords + input_direction + input_direction)
					if push_entity:
						if push_entity is Bouncer:
							entity.move(-input_direction)
							move(input_direction)
							play_squished()
							push_entity.bounce(-input_direction)
							level.add_action(push_action)
					else:
						var can_push: bool = entity.try_move(input_direction)
						if can_push:
							level.add_action(push_action)
							move(input_direction)
		else:
			var move_happened: bool = try_move(input_direction)
			if move_happened:
				level.add_action(CharacterMoveAction.new(self, level.map_to_world(target_coords)))
		face_direction = input_direction
		body.rotation.y = Vector2(input_direction * Vector2i(1, -1)).angle() + PI / 2

func play_struggle():
	if is_animating:
		return
	is_animating = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(body, "rotation:x", PI / 4, .2).as_relative()
	tween.tween_property(body, "rotation:x", -PI / 4, .2).as_relative()
	tween.tween_property(self, "is_animating", false, 0)
	return tween

func play_squished():
	if is_animating:
		return
	is_animating = true
	animation_player.play("flatten")
	is_animating = false

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
