class_name Bomb
extends Entity

const EXPLOSION_TUT = preload("uid://d3c87ditddej4")

@export var size: int = 1
@export var pushable: bool = true

@onready var explosion: AudioStreamPlayer = $Explosion

var exploded: bool = false

signal detonated()

func detonate():
	if exploded:
		return
	exploded = true
	detonated.emit()
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
				if entity and entity != self:
					if entity is Bomb and !entity.exploded:
						entity.detonate()
					else:
						entity.hide()
		await get_tree().create_timer(.3).timeout
		
func _spawn_explosion(point: Vector3):
	var explision: Node3D = EXPLOSION_TUT.instantiate()
	get_parent().add_child(explision)
	explision.global_position = point
