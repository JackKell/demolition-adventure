class_name MapData
extends Node2D

@onready var tiles_map: TileMapLayer = %Tiles
@onready var entities_map: TileMapLayer = %Entities
@onready var level: Level = get_parent()

const SCENE_UID: StringName = &"SceneUID"

var ui_to_scene_map: Dictionary[String, PackedScene] = {}

func _ready() -> void:
	hide()
	for coords: Vector2i in tiles_map.get_used_cells():
		var tile_data: TileData = tiles_map.get_cell_tile_data(coords)
		var uid: StringName = tile_data.get_custom_data(SCENE_UID)
		if !ui_to_scene_map.has(uid):
			ui_to_scene_map.set(uid, ResourceLoader.load(uid))
		var scene = ui_to_scene_map.get(uid)
		if scene == null:
			continue
		var tile: Node3D = scene.instantiate()
		level.add_tile.call_deferred(tile, coords)
	for coords: Vector2i in entities_map.get_used_cells():
		var tile_data: TileData = entities_map.get_cell_tile_data(coords)
		var uid: StringName = tile_data.get_custom_data(SCENE_UID)
		if !ui_to_scene_map.has(uid):
			ui_to_scene_map.set(uid, ResourceLoader.load(uid))
		var scene = ui_to_scene_map.get(uid)
		if scene == null:
			continue
		var entity: Entity = scene.instantiate()
		level.add_entity.call_deferred(entity, coords)
