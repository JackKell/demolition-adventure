class_name Bomb
extends Entity

const EXPLOSION_TUT = preload("uid://d3c87ditddej4")

@export var size: int = 1
@export var pushable: bool = true

@onready var explosion: AudioStreamPlayer = $Explosion

signal detonated()

func detonate():
	if has_detonated:
		return
	prints(name, "detonated")
	_has_detonated = true
	if explosion:
		explosion.play()
	hide()
	for i in range(size):
		for offset: Vector2i in GridUtils.get_coords_in_ring(i):
			var target: Vector2i = coords + offset
			var tile: Tile = level.get_tile(target)
			if tile:
				_spawn_explosion(tile.global_position)
				level._coords_to_tile.erase(target)
				tile.detonate()
				var entity = level.get_entity(target)
				if entity and entity != self and !entity.has_detonated:
					entity.detonate()
		await get_tree().create_timer(0.3).timeout
	detonated.emit()

func _spawn_explosion(point: Vector3):
	var explision: Node3D = EXPLOSION_TUT.instantiate()
	get_parent().add_child(explision)
	explision.global_position = point
