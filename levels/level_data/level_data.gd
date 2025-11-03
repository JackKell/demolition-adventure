class_name LevelData
extends Resource

@export var world: int
@export var stage: int 
@export var thumbnail: Texture2D
@export var alloted_time: int = 999
@export var level_scene: PackedScene
@export var tiles: Dictionary[Vector2i, Tile.TileType]
@export var entities: Dictionary[Vector2i, EntityConfig]
