extends Node3D

@export var entities: LevelEditorObjects
@export var tiles: LevelEditorObjects
@export var size: Vector2i = Vector2i(50, 50)

@onready var top_down_camera: Camera3D = %TopDownCamera
@onready var free_camera: Camera3D = %FreeCamera
@onready var free_camera_pivot: Node3D = %FreeCameraPivot
@onready var box_tool: BoxTool = $BoxTool
@onready var fill_tool: FillTool = $FillTool
@onready var pencil_tool: PencilTool = $PencilTool
@onready var line_tool: LineTool = $LineTool
@onready var selection_tool: SelectionTool = $SelectionTool

@onready var selection_tool_button: Button = %SelectionToolButton
@onready var pencil_tool_button: Button = %PencilToolButton
@onready var line_tool_button: Button = %LineToolButton
@onready var bucket_tool_button: Button = %BucketToolButton
@onready var box_tool_button: Button = %BoxToolButton
@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton
@onready var selected_tile_label: Label = %SelectedTileLabel
@onready var tile_list: ItemList = %TileList
@onready var entity_list: ItemList = %EntityList
@onready var theme_option_button: OptionButton = %ThemeOptionButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var clear_button: Button = %ClearButton
@onready var toggle_grid_button: Button = %ToggleGridButton
@onready var grid_mesh: GridMesh = $GridMesh
@onready var x_mirror_button: Button = %XMirrorButton
@onready var z_mirror_button: Button = %YMirrorButton
@onready var x_mirror_line: MeshInstance3D = %XMirrorLine
@onready var y_mirror_line: MeshInstance3D = %YMirrorLine


var ENTITY_ID_TO_ENTITY_DATA: Dictionary[int, LevelEditorObjectData] = {}
var ENTITY_NAME_TO_ENTITY_DATA: Dictionary[String, LevelEditorObjectData] = {}
var ENTITY_SCENE_PATH_TO_ENTITY_ID: Dictionary[String, int] = {}
var TILE_ID_TO_TILE_DATA: Dictionary[int, LevelEditorObjectData] = {}
var TILE_NAME_TO_TILE_DATA: Dictionary[String, LevelEditorObjectData] = {}
var TILE_SCENE_PATH_TO_TILE_ID: Dictionary[String, int] = {}

var tile_mapping: Dictionary[Vector2i, CellData] = {}
var entity_mapping: Dictionary[Vector2i, CellData] = {}
var current_cell: Vector2i = Vector2i.ZERO
var current_tool: LevelEditorTool
var camera_size: float = 0
var tools: Array[LevelEditorTool]
var undo_redo: UndoRedo = UndoRedo.new()
var preview_tiles: PreviewTilePool
var selected_tile: PackedScene
var top_down_mode: bool = true
var world_theme: LevelEditorObjectData.WorldTheme = LevelEditorObjectData.WorldTheme.TROPICAL

const LEVEL_SAVE_PATH: String = "res://level_editor/temp_level_data.tres"
var current_level_save: LevelData
var camera_speed: float = 0
var camera_acceleration: float = 100
const MAX_CAMERA_SPEED: float = 20
var selection_grid: SelectionGrid


func _ready() -> void:
	selection_grid = SelectionGrid.new()
	add_child(selection_grid)
	selection_tool.selection_grid = selection_grid
	selection_grid.global_position.y = 0.1
	for entity: LevelEditorObjectData in entities.objects:
		ENTITY_ID_TO_ENTITY_DATA.set(entity.id, entity)
		ENTITY_NAME_TO_ENTITY_DATA.set(entity.name, entity)
		ENTITY_SCENE_PATH_TO_ENTITY_ID.set(entity.scene.resource_path, entity.id)
		
	for tile: LevelEditorObjectData in tiles.objects:
		TILE_ID_TO_TILE_DATA.set(tile.id, tile)
		TILE_NAME_TO_TILE_DATA.set(tile.name, tile)
		TILE_SCENE_PATH_TO_TILE_ID.set(tile.scene.resource_path, tile.id)
	
	preview_tiles = PreviewTilePool.new()
	add_child(preview_tiles)
	tools = [
		box_tool,
		fill_tool,
		pencil_tool,
		line_tool,
	]
	for tool: LevelEditorTool in tools:
		tool.undo_redo = undo_redo
		tool.preview_tiles = preview_tiles
		tool.tile_mapping = tile_mapping
		tool.current_cell = current_cell
		tool.deactivate()
	selection_tool_button.pressed.connect(switch_tool.bind(selection_tool))
	box_tool_button.pressed.connect(switch_tool.bind(box_tool))
	bucket_tool_button.pressed.connect(switch_tool.bind(fill_tool))
	pencil_tool_button.pressed.connect(switch_tool.bind(pencil_tool))
	line_tool_button.pressed.connect(switch_tool.bind(line_tool))
	undo_button.pressed.connect(undo_redo.undo)
	redo_button.pressed.connect(undo_redo.redo)
	undo_redo.version_changed.connect(_on_version_changed)
	theme_option_button.item_selected.connect(_on_theme_selected)
	save_button.pressed.connect(save)
	load_button.pressed.connect(load_level)
	clear_button.pressed.connect(clear)
	tile_list.item_selected.connect(_on_tile_selected)
	entity_list.item_selected.connect(_on_entity_selected)
	toggle_grid_button.pressed.connect(_on_toggle_grid_visible_pressed)
	x_mirror_button.pressed.connect(_on_x_mirror_button_pressed)
	z_mirror_button.pressed.connect(_on_z_mirror_button_pressed)
	
	update_entity_items()
	update_tile_items()
	
	switch_tool(pencil_tool)
	pencil_tool_button.button_pressed = true
	camera_size = top_down_camera.size
	
	const DEFAULT_TILE_ID: int = 2
	tile_list.select(DEFAULT_TILE_ID)
	tile_list.emit_signal("item_selected", DEFAULT_TILE_ID)
	load_level()
	if top_down_mode:
		top_down_camera.make_current()
	else:
		free_camera.make_current()

func _on_x_mirror_button_pressed():
	x_mirror_line.visible = !x_mirror_line.visible 

func _on_z_mirror_button_pressed():
	y_mirror_line.visible = !y_mirror_line.visible 

func _on_toggle_grid_visible_pressed() -> void:
	grid_mesh.visible = !grid_mesh.visible
	

func clear():
	for coords in tile_mapping.keys():
		var tile_data: CellData = tile_mapping.get(coords)
		tile_data.node.queue_free()
	tile_mapping.clear()
	
	for coords in entity_mapping.keys():
		var entity_data: CellData = entity_mapping.get(coords)
		entity_data.node.queue_free()
	entity_mapping.clear()
	

func save():
	# save tiles
	current_level_save.tiles.clear()
	for coord in tile_mapping:
		var tile_data: CellData = tile_mapping.get(coord)
		# Find a way to make this name standard
		var tile_id: int = TILE_SCENE_PATH_TO_TILE_ID.get(tile_data.scene.resource_path)
		# TODO: Convert node roation to direction
		var tile_config: BaseConfig = BaseConfig.new()
		tile_config.id = tile_id
		current_level_save.tiles.set(coord, tile_config)
	
	# save entities
	current_level_save.entities.clear()
	for coord in entity_mapping:
		var entity_data: CellData = entity_mapping.get(coord)
		# Find a way to make this name standard
		var entity_id: int = ENTITY_SCENE_PATH_TO_ENTITY_ID.get(entity_data.scene.resource_path)
		# TODO: Convert node roation to direction
		var entity_config: BaseConfig = BaseConfig.new()
		entity_config.id = entity_id
		current_level_save.entities.set(coord, entity_config)
	ResourceSaver.save(current_level_save)
	
func load_level():
	clear()
	current_level_save = load(LEVEL_SAVE_PATH)
	# Load Tiles
	var saved_tiles := current_level_save.tiles
	for coords: Vector2i in saved_tiles.keys():
		var tile_config: BaseConfig = saved_tiles.get(coords)
		var tile_data: LevelEditorObjectData = TILE_ID_TO_TILE_DATA.get(tile_config.id)
		if !tile_data:
			continue
		var tile: Node3D = tile_data.scene.instantiate()
		add_child(tile)
		tile.global_position.x = coords.x
		tile.global_position.z = coords.y
		tile_mapping.set(coords, CellData.new(tile_data.scene, tile))
		# TODO: set rotation based on config direction

	# Load Entities
	var saved_entities := current_level_save.entities
	for coords: Vector2i in saved_entities.keys():
		var entity_config: BaseConfig = saved_entities.get(coords)
		var entity_data: LevelEditorObjectData = ENTITY_ID_TO_ENTITY_DATA.get(entity_config.id)
		if !entity_data:
			continue
		var entity: Node3D = entity_data.scene.instantiate()
		add_child(entity)
		entity.global_position.x = coords.x
		entity.global_position.z = coords.y
		entity_mapping.set(coords, CellData.new(entity_data.scene, entity))
		# TODO: set rotation based on config direction

static func filter_item_list_to_world_theme(
		list: ItemList, 
		name_to_data: Dictionary[String, LevelEditorObjectData],  
		filtered_world_theme: LevelEditorObjectData.WorldTheme
	) -> void:
	list.clear()
	for option in name_to_data.keys():
		var data: LevelEditorObjectData = name_to_data.get(option)
		if data.world_theme == LevelEditorObjectData.WorldTheme.ANY or data.world_theme == filtered_world_theme:
			list.add_item(option, data.icon)
	

func update_entity_items():
	filter_item_list_to_world_theme(entity_list, ENTITY_NAME_TO_ENTITY_DATA, world_theme)

func update_tile_items():
	filter_item_list_to_world_theme(tile_list, TILE_NAME_TO_TILE_DATA, world_theme)

func _on_theme_selected(id: int):
	var theme_name: String = theme_option_button.get_item_text(id).to_lower()
	match theme_name:
		"tropical":
			world_theme = LevelEditorObjectData.WorldTheme.TROPICAL
		"desert":
			world_theme = LevelEditorObjectData.WorldTheme.DESERT
		"ice":
			world_theme = LevelEditorObjectData.WorldTheme.ICE
		"lava":
			world_theme = LevelEditorObjectData.WorldTheme.LAVA
		"castle":
			world_theme = LevelEditorObjectData.WorldTheme.CASTLE
		"abstract":
			world_theme = LevelEditorObjectData.WorldTheme.ABSTRACT
	update_entity_items()
	update_tile_items()
	tile_list.emit_signal("item_selected", 0)

func set_mapping_layer(mapping: Dictionary[Vector2i, CellData]):
	for tool in tools:
		tool.tile_mapping = mapping

func set_draw_tile(tile: PackedScene) -> void:
	selected_tile = tile
	for tool in tools:
		tool.draw_tile = selected_tile

func _on_entity_selected(id: int) -> void:
	var entity_name = entity_list.get_item_text(id).to_lower()
	if !ENTITY_NAME_TO_ENTITY_DATA.has(entity_name):
		return
	var data: LevelEditorObjectData = ENTITY_NAME_TO_ENTITY_DATA.get(entity_name)
	set_draw_tile(data.scene)
	selected_tile_label.text = data.name
	set_mapping_layer(entity_mapping)
	tile_list.deselect_all()


func _on_tile_selected(id: int) -> void:
	var tile_name = tile_list.get_item_text(id).to_lower()
	if !TILE_NAME_TO_TILE_DATA.has(tile_name):
		return
	var data: LevelEditorObjectData = TILE_NAME_TO_TILE_DATA.get(tile_name)
	selected_tile_label.text = data.name
	set_draw_tile(data.scene)
	set_mapping_layer(tile_mapping)
	entity_list.deselect_all()

func _on_version_changed() -> void:
	undo_button.disabled = !undo_redo.has_undo()
	redo_button.disabled = !undo_redo.has_redo()

func _on_undo_button_pressed() -> void:
	if undo_redo.has_undo():
		undo_redo.undo()

func _on_redo_button_pressed() -> void:
	if undo_redo.has_redo():
		undo_redo.redo()

func switch_tool(tool: LevelEditorTool) -> void:
	if current_tool:
		current_tool.deactivate()
	current_tool = tool
	current_tool.activate()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if [KEY_1, KEY_P].has(event.keycode):
				switch_tool(pencil_tool)
			elif [KEY_2, KEY_L].has(event.keycode):
				switch_tool(line_tool)
			elif [KEY_3, KEY_G].has(event.keycode):
				switch_tool(fill_tool)
			elif [KEY_4, KEY_B].has(event.keycode):
				switch_tool(box_tool)
			elif event.keycode == KEY_X:
				camera_speed = 0
				if top_down_mode:
					free_camera.make_current()
					top_down_mode = false
				else:
					top_down_camera.make_current()
					top_down_mode = true
	
	if event is InputEventMouseMotion:
		var space_state = get_world_3d().direct_space_state
		var current_camera = get_viewport().get_camera_3d()
		var from = current_camera.project_ray_origin(event.position)
		var to = from + current_camera.project_ray_normal(event.position) * 1000
		var query = PhysicsRayQueryParameters3D.create(from, to, 8)
		var result = space_state.intersect_ray(query)
		if result:
			var world_position: Vector3 = result.position
			world_position.x = clampf(world_position.x, -24, 25)
			world_position.z = clampf(world_position.z, -24, 25)
			world_position = world_position.snappedf(1)
			current_tool.mouse_moved(
				Vector2i(int(world_position.x), int(world_position.z))
			)
	
	if event.is_action_pressed("level_editor_left_click"):
		current_tool.left_click = true
	elif event.is_action_released("level_editor_left_click"):
		current_tool.left_click = false
		
	if event.is_action_pressed("level_editor_right_click"):
		current_tool.right_click = true
	elif event.is_action_released("level_editor_right_click"):
		current_tool.right_click = false
	
	if event.is_action_pressed("ui_redo", true):
		undo_redo.redo()
	elif event.is_action_pressed("ui_undo", true):
		undo_redo.undo()
	
	if event.is_action_pressed("zooom_in"):
		camera_size = clampf(camera_size - 1, 5, 50)
	elif event.is_action_pressed("zoom_out"):
		camera_size = clampf(camera_size + 1, 5, 50)
	
func _process(delta: float) -> void:
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move_input:
		camera_speed = move_toward(camera_speed, MAX_CAMERA_SPEED, delta * camera_acceleration)
	else:
		camera_speed = move_toward(camera_speed, 0, delta * camera_acceleration)
	
	var move_delta: Vector2 = move_input * delta * camera_speed
	var desired_position = free_camera_pivot.global_position + VectorUtils.vector3_xz(move_delta)
	desired_position.x = clampf(desired_position.x, -24, 25)
	desired_position.z = clampf(desired_position.z, -24, 25)
	free_camera_pivot.global_position = desired_position
	
	if !is_equal_approx(top_down_camera.global_position.y, camera_size):
		top_down_camera.size = move_toward(
			top_down_camera.size, 
			camera_size, 
			100 * delta
		)
