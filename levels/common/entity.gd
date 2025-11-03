class_name Entity
extends Node3D

const ENTITY_GROUP = "entity"
const MOVE_SPEED: float = 3

var last_move_direction: Vector2i
var last_coords: Vector2i
var coords: Vector2i:
	set(value):
		if value != coords:
			last_coords = coords
			coords = value
			coords_changed.emit()
var level: Level

var _is_moving: bool = false
var is_moving: bool:
	get():
		return _is_moving

var _centering_tween: Tween

signal moved
signal stopped
signal coords_changed

var target_point: Vector3 = Vector3.ZERO

func initalize(parent_level: Level) -> void:
	level = parent_level
	var snapped_position: Vector3 = global_position.snapped(Vector3.ONE)
	global_position = snapped_position
	var current_coords = level.world_to_map(global_position)
	last_coords = current_coords
	coords = current_coords

func _ready() -> void:
	add_to_group(ENTITY_GROUP)
	stopped.connect(_on_stopped)

func can_move_to(direction: Vector2i) -> bool:
	var target_coords: Vector2i = direction + coords
	var tile: Tile = level.get_tile(target_coords)
	return tile and tile.type != Tile.TileType.OBSTICAL and not level.has_entity(target_coords)

func try_move(direction: Vector2i) -> bool:
	if is_moving:
		return false
	if !can_move_to(direction):
		return false
	move(direction)
	return true

func _physics_process(delta: float) -> void:
	if is_moving:
		global_position = global_position.move_toward(target_point, delta * MOVE_SPEED)
		if global_position.is_equal_approx(target_point):
			_is_moving = false 
			stopped.emit()

func _on_stopped() -> void:
	var tile: Tile = level.get_tile(coords)
	# Calculate the whole travel delta of the move
	if tile.type == Tile.TileType.ICY:
		if can_move_to(last_move_direction):
			move(last_move_direction)

func move(direction: Vector2i) -> void:
	last_move_direction = direction
	var target_coords = coords + direction
	if _centering_tween and _centering_tween.is_running():
		_centering_tween.stop()
	target_point = level.map_to_world(target_coords)
	coords = target_coords
	moved.emit()
	_is_moving = true

func move_to_center(centering_speed: float = 1.0) -> void:
	var target_position: Vector3 = level.map_to_world(coords)
	var duration: float = target_position.distance_to(global_position) / centering_speed
	_centering_tween = create_tween()
	_centering_tween.tween_property(self, "global_position", target_position, duration)

func update_coords() -> void:
	coords = level.world_to_map(global_position)

func detonate() -> void:
	var rb = RigidBody3D.new()
	get_parent().add_child(rb)
	rb.global_position = global_position
	rb.apply_impulse(Vector3(randf_range(-5, 5), randf_range(5, 10), randf_range(-5, 5)))
	rb.angular_velocity = Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2))
	reparent(rb)
