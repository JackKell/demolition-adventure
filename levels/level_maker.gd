extends Node2D

const TILE_TILESET: TileSet = preload("uid://b23psfks6fooe")
const ENTITY_TILESET: TileSet = preload("uid://bcxcjwnvggtyl")

@onready var tiles: TileMapLayer = %Tiles
@onready var entities: TileMapLayer = %Entities

var tile_count: int = 0
var tile_index: int = 0
var tile_atlas_source: TileSetAtlasSource
var last_changed: Vector2i 

var is_drawing: bool = false
var is_erasing: bool = false

func _ready() -> void:
	tile_atlas_source = TILE_TILESET.get_source(0)
	tile_count = tile_atlas_source.get_tiles_count()
	for i in range(tile_count):
		var atlas_coords: Vector2i = tile_atlas_source.get_tile_id(i)

func _draw() -> void:
	const size: float = 16
	for x in range(20):
		draw_line(Vector2(x * size, 0), Vector2(x * size, 1000), Color.BLACK, 1.0)
	for y in range(20):
		draw_line(Vector2(0, y * size), Vector2(1000, y * size), Color.BLACK, 1.0)
	
	#draw_line(Vector2(16, 0), Vector2(16, 160), Color.BLACK, 1.0)
	#draw_line(Vector2(32, 0), Vector2(32, 160), Color.BLACK, 1.0)

func draw_cell(coords: Vector2i, atlas_coords: Vector2i) -> void:
	tiles.set_cell(coords, 0, atlas_coords)

func erase_cell(coords: Vector2i) -> void:
	tiles.erase_cell(coords)

func _input(event: InputEvent) -> void:
	var coords: Vector2i = tiles.local_to_map(get_global_mouse_position())
	var atlas_coords: Vector2i = tile_atlas_source.get_tile_id(tile_index)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_drawing = true
				draw_cell(coords, atlas_coords)
			elif event.is_released():
				is_drawing = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				is_erasing = true
				erase_cell(coords)
			elif event.is_released():
				is_erasing = false
	if event is InputEventMouseMotion:
		if is_erasing:
			erase_cell(coords)
		elif is_drawing:
			draw_cell(coords, atlas_coords)
