class_name LevelEditorObjectData
extends Resource

enum WorldTheme {
	TROPICAL,
	DESERT,
	ICE,
	LAVA,
	CASTLE,
	ABSTRACT,
	ANY,
}

@export var id: int 
@export var name: String
@export var icon: Texture2D = AtlasTexture.new()
@export var scene: PackedScene
@export var world_theme: WorldTheme = WorldTheme.ANY
# assumed to be a square
@export_range(1, 2) var size: int = 1
