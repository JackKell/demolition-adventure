class_name Level
extends Node3D

signal lost
signal won
signal all_bombs_detonated
signal ignitor_bomb_ignited

const CHARACTER_GROUP = "character"
const ACHIEVED: AudioStream = preload("uid://cl1fiv31td17v")
const TOGGLE_CAMERA_DURATION: float = 0.3
const START_CAMERA_DURATION: float = 1
const START_CAMERA_DELAY: float = 0.4

var steps: int = 0
var ignitor_bomb: StartBomb:
	get:
		return _ignitor_bomb
var _ignitor_bomb: StartBomb
#var _history: ActionHistory = ActionHistory.new()
var _top_down_camera: Camera3D
var _animation_camera: Camera3D
var _coords_to_tile: Dictionary[Vector2i, Node3D] = {}
var _entities: Array[Entity] = []
var _detonation_count: int = 0
var _bomb_count: int = 0
var _character: Character
var _stream_player: AudioStreamPlayer3D
var _camera_toogle_tween: Tween
var _undo_redo: UndoRedo = UndoRedo.new()

func _ready() -> void:
	_init_tiles()
	_init_entities()
	
	_character = get_tree().get_first_node_in_group(CHARACTER_GROUP)
	_character.died.connect(_on_character_died)
	_character.moved.connect(_on_character_moved)
	_character.stopped.connect(_on_character_stopped)
	
	_add_top_down_camera()
	_add_animation_camera()
	_add_audio_stream_player()
	all_bombs_detonated.connect(_on_level_completed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		_toggle_camera()
		
	if event.is_action_pressed("undo") and _undo_redo.has_undo():
		_undo_redo.undo()
	elif event.is_action_pressed("redo") and _undo_redo.has_redo():
		_undo_redo.redo()

func world_to_map(global_point: Vector3) -> Vector2i:
	# NOTE: Assumes the cell size is 1 meter
	return VectorUtils.vector2i_xz(global_point.snapped(Vector3.ONE))

func map_to_world(coords: Vector2i) -> Vector3:
	# NOTE: Assumes the cell size is 1 meter
	return VectorUtils.vector3_xz(coords)

func has_tile(coords: Vector2i) -> bool:
	return _coords_to_tile.has(coords)

func get_entity(coords: Vector2i) -> Entity:
	for entity: Entity in _entities:
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
	var points: Array[Vector3]
	points.assign(_coords_to_tile.values().map(NodeUtils.get_global_position_3D))
	var bounds: VectorUtils.Bounds3D = VectorUtils.bounds_xz(points)
	# magic formula to determine camera height that fits level inside view nicely
	var height: float = 0.6 * bounds.max_side_length + 3.5
	var camera_position: Vector3 = bounds.center
	camera_position.y = height
	_top_down_camera = Camera3D.new()
	add_child(_top_down_camera)
	_top_down_camera.global_position = camera_position
	_top_down_camera.rotation_degrees.x = -90
	
func _init_tiles() -> void:
	for tile in get_tree().get_nodes_in_group(Tile.GROUP):
		if tile is Tile and NodeUtils.is_decedent(self, tile):
			tile.initalize(self)
			_coords_to_tile.set(tile.coords, tile)
			if tile is FallawayTile:
				tile.fell.connect(_on_tile_fell.bind(tile)) 

func _init_entities():
	for entity in get_tree().get_nodes_in_group(Entity.ENTITY_GROUP):
		if entity is Entity and NodeUtils.is_decedent(self, entity):
			entity.initalize(self)
			entity.coords_changed.connect(_handle_coords_changed.bind(entity))
			_entities.append(entity)
			if entity is Bomb:
				_bomb_count += 1
				entity.detonated.connect(_on_bomb_detonated)
				entity.moved.connect(_bomb_pushed.bind(entity))
			if entity is StartBomb:
				_ignitor_bomb = entity
				_ignitor_bomb.ignited.connect(ignitor_bomb_ignited.emit)
			

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

func _on_character_died() -> void:
	_on_lost()
	
func _on_lost():
	lost.emit()

func _on_win():
	won.emit()
	_character.lock()
	_stream_player.play()
	for tile: Tile in _coords_to_tile.values():
		if !tile.has_detonated and tile.coords != _character.coords:
			tile.detonate()
	for entity in _entities:
		if entity == _character:
			continue
		if !entity.has_detonated:
			entity.detonate()

func _on_level_completed() -> void:
	await get_tree().create_timer(0.3).timeout
	if !_character.is_alive:
		_on_lost()
		return
	_on_win()
	
func _bomb_pushed(bomb: Bomb) -> void:
	print("turn" + str(steps))
	prints(bomb.name, "pushed", bomb.coords, bomb.last_coords)
	_undo_redo.create_action("turn" + str(steps), UndoRedo.MERGE_ALL)
	_undo_redo.add_do_method(bomb.set_grid_position.bind(bomb.coords))
	_undo_redo.add_undo_method(bomb.set_grid_position.bind(bomb.last_coords))
	_undo_redo.commit_action(false)

func _on_character_stopped() -> void:
	print("turn" + str(steps))
	prints("character moved", _character.coords, _character.last_coords)
	_undo_redo.create_action("turn" + str(steps), UndoRedo.MERGE_ALL)
	_undo_redo.add_do_method(_character.set_grid_position.bind(_character.coords))
	_undo_redo.add_undo_method(_character.set_grid_position.bind(_character.last_coords))
	_undo_redo.commit_action(false)

func _on_character_moved() -> void:
	var old_step_count = steps
	var new_step_count = steps + 1
	steps = new_step_count
	print("turn" + str(steps))
	prints("character moved", _character.coords, _character.last_coords)
	_undo_redo.create_action("turn" + str(steps), UndoRedo.MERGE_ALL)
	_undo_redo.add_do_property(self, "steps", new_step_count)
	_undo_redo.add_undo_property(self, "steps", old_step_count)
	_undo_redo.commit_action(false)


func _on_tile_fell(fallawayTile: FallawayTile) -> void:
	prints(fallawayTile.name, "fell")
	_undo_redo.create_action("turn" + str(steps), UndoRedo.MERGE_ALL)
	_undo_redo.add_do_method(fallawayTile.fall)
	_undo_redo.add_undo_method(fallawayTile.raise)
	_undo_redo.commit_action(false)
