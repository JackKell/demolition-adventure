extends Node3D

@export var levels_data: Levels


var current_level: Level

func _ready() -> void:
	var viewport: Viewport = get_viewport()
	var i: int = 1
	for level_data in levels_data.levels:
		current_level = level_data.level_scene.instantiate()
		add_child(current_level)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var image: Image = viewport.get_texture().get_image()
		var path: String = "res://levels/thumbnails/level_" + str(i) + ".png"
		image.save_png(path)
		i += 1
		current_level.queue_free()
		await current_level.tree_exited
	get_tree().quit()
	
