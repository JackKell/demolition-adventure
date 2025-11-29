class_name LevelData
extends Resource

@export var world: int
@export var stage: int 
@export var thumbnail: Texture2D
@export var alloted_time: int = 999
@export var level_scene: PackedScene
@export var tiles: Dictionary[Vector2i, BaseConfig]
@export var entities: Dictionary[Vector2i, BaseConfig]
var save_data: LevelSaveData:
	get:
		if save_data == null:
			_load_data()
		return save_data
var save_file_name: String:
	get:
		return "user://level" + str(world) + "_" + str(stage) + ".save_data.tres"
		
func save():
	ResourceSaver.save(save_data, save_file_name)

func _load_data() -> void:
	if (ResourceLoader.exists(save_file_name)):
		save_data = ResourceLoader.load(save_file_name)
	else:
		save_data = LevelSaveData.new()
		ResourceSaver.save(save_data, save_file_name)
		
	
