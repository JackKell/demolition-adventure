class_name Level
extends Node3D


signal all_bombs_detonated

const CHARACTER_GROUP = "character"
const ACHIEVED: AudioStream = preload("uid://cl1fiv31td17v")
const TOGGLE_CAMERA_DURATION: float = 0.3
const START_CAMERA_DURATION: float = 1
const START_CAMERA_DELAY: float = 0.4

var _history: ActionHistory = ActionHistory.new()
var _top_down_camera: Camera3D
var _animation_camera: Camera3D
var _coords_to_tile: Dictionary[Vector2i, Node3D] = {}
var _entities: Array[Entity] = []
var _detonation_count: int = 0
var _bomb_count: int = 0
var _character: Character
var _stream_player: AudioStreamPlayer3D
var _camera_toogle_tween: Tween

enum State {
	ANIMATION,
	NORMAL,
	PANICKED,
}

var state: State = State.NORMAL

func _ready() -> void:
	_init_tiles()
	_init_entities()
	
	_character = get_tree().get_first_node_in_group(CHARACTER_GROUP)
	
	_add_top_down_camera()
	_add_animation_camera()
	_add_audio_stream_player()
	all_bombs_detonated.connect(_on_level_completed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		_toggle_camera()
	if event.is_action_pressed("undo"):
		undo_action()
	elif  event.is_action_pressed("redo"):
		redo_action()

func add_action(action: Action) -> void:
	_history.add(action)
	
func redo_action() -> void:
	_history.redo()

func undo_action() -> void:
	_history.undo()

func world_to_map(global_point: Vector3) -> Vector2i:
	var snapped_position: Vector3i = Vector3i(global_point.snapped(Vector3.ONE))
	return Vector2i(snapped_position.x, snapped_position.z)

func map_to_world(coords: Vector2i) -> Vector3:
	# NOTE: Assumes the cell size is 1 meter
	return Vector3(coords.x, 0, coords.y)

func has_tile(coords: Vector2i) -> bool:
	return _coords_to_tile.has(coords)

func get_entity(coords: Vector2i) -> Entity:
	for entity in _entities:
		if entity.coords == coords:
			return entity
	return null

func get_ignitor_bomb(coords: Vector2i) -> StartBomb:
	var entity: Entity = get_entity(coords)
	if entity is StartBomb:
		return entity
	return null

func has_entity(coords: Vector2i) -> bool:
	return get_entity(coords) != null

func get_tile(coords: Vector2i) -> Tile:
	return _coords_to_tile.get(coords)

func add_tile(tile: Tile, coords: Vector2i) -> void:
	add_child(tile)
	var point = map_to_world(coords)
	tile.global_position = point
	if tile.type != Tile.TileType.OBSTICAL:
		_coords_to_tile.set(coords, tile)

func add_entity(entity: Entity, coords: Vector2i) -> void:
	add_child(entity)
	_entities.append(entity)
	var point = map_to_world(coords)
	entity.global_position = point
	entity.level = self
	entity.coords = coords
	if entity is Bomb:
		_bomb_count += 1
		entity.detonated.connect(_on_bomb_detonated)

func _calculate_center_point(points: Array[Vector3]) -> Vector3:
	var top: float = points[0].z
	var bottom: float = points[0].z
	var right: float = points[0].x
	var left: float = points[0].x
	
	for point: Vector3 in points:
		if point.x < left:
			left = point.x
		elif point.x > right:
			right = point.x
			
		if point.z > bottom:
			bottom = point.z
		elif point.z < top:
			top = point.z
	
	var max_side_length: float = max(abs(top - bottom), abs(left - right))
	var height: float = 0.6 * max_side_length + 3.5
	
	return Vector3((left + right) / 2, height, (top + bottom) / 2)

func _add_audio_stream_player() -> void:
	_stream_player = AudioStreamPlayer3D.new()
	_stream_player.volume_db = -10
	add_child(_stream_player)
	_stream_player.stream = ACHIEVED

func _add_animation_camera() -> void:
	_animation_camera = Camera3D.new()
	add_child(_animation_camera)
	_animation_camera.global_transform = _top_down_camera.global_transform
	_animation_camera.make_current()

	var t = create_tween()
	t.tween_property(
		_animation_camera, 
		"global_transform", 
		_character.camera.global_transform, 
		START_CAMERA_DURATION
	).set_delay(START_CAMERA_DELAY)
	t.tween_callback(_character.camera.make_current)

func _add_top_down_camera() -> void:
	var positions: Array[Vector3] = []
	for tile: Tile in _coords_to_tile.values():
		positions.append(Vector3(tile.global_position.x, 0, tile.global_position.z))
	var center_point: Vector3 = _calculate_center_point(positions)
	_top_down_camera = Camera3D.new()
	add_child(_top_down_camera)
	_top_down_camera.global_position = center_point
	_top_down_camera.rotation_degrees.x = -90
	
func _init_tiles() -> void:
	for tile in get_tree().get_nodes_in_group(Tile.GROUP):
		if tile is Tile and is_decedent_of(self, tile):
			tile.initalize(self)
			_coords_to_tile.set(tile.coords, tile)
			
static func is_decedent_of(parent_node: Node, child_node: Node) -> bool:
	var current_parent = child_node.get_parent()
	while current_parent != null:
		if current_parent == parent_node:
			return true
		else:
			current_parent = current_parent.get_parent()
	return false

func _init_entities():
	for entity in get_tree().get_nodes_in_group(Entity.ENTITY_GROUP):
		if entity is Entity and is_decedent_of(self, entity):
			entity.initalize(self)
			entity.coords_changed.connect(_handle_coords_changed.bind(entity))
			_entities.append(entity)
			if entity is Bomb:
				_bomb_count += 1
				entity.detonated.connect(_on_bomb_detonated)

func _toggle_camera() -> void:
	if not _top_down_camera or not _character:
		return
	if _camera_toogle_tween and _camera_toogle_tween.is_running():
		_camera_toogle_tween.kill()
	var target_camera: Camera3D
	if _top_down_camera.current:
		target_camera = _character.camera
	else:
		target_camera = _top_down_camera
	_animation_camera.make_current()
	_camera_toogle_tween = create_tween()
	_camera_toogle_tween.tween_property(
		_animation_camera, 
		"global_transform", 
		target_camera.global_transform, 
		TOGGLE_CAMERA_DURATION
	)
	_camera_toogle_tween.tween_callback(target_camera.make_current)

func _handle_coords_changed(entity: Entity):
	var exiting_tile: Tile = get_tile(entity.last_coords)
	if exiting_tile:
		exiting_tile.handle_entity_exit(entity)
	var entering_tile: Tile = get_tile(entity.coords)
	if entering_tile:
		entering_tile.handle_entity_enter(entity)

func _on_bomb_detonated() -> void:
	_detonation_count += 1
	if _detonation_count == _bomb_count:
		all_bombs_detonated.emit()

func _on_level_completed() -> void:
	await get_tree().create_timer(0.3).timeout
	_stream_player.play()
	for tile: Tile in _coords_to_tile.values():
		if !tile.has_detonated and tile.coords != _character.coords:
			tile.detonate()
	for entity in _entities:
		if entity == _character:
			continue
		entity.detonate()
