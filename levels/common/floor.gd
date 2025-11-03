extends Area3D


func _ready() -> void:
	body_entered.connect(_on_tile_enter)
	
func _on_tile_enter(tile: Tile):
	# TODO: Make a splashing noise
	await get_tree().create_timer(1).timeout
	tile.queue_free()
	
