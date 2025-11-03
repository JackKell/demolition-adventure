class_name FallawayTile
extends Tile

@export var mesh: MeshInstance3D

const FALL_ANIMATION_DURATION: float = 0.6

func handle_entity_exit(exiting_entity: Entity) -> void:
	if exiting_entity is Character:
		level._coords_to_tile.erase(coords)
		var t = create_tween()
		t.tween_property(mesh, "position", Vector3.DOWN, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN).as_relative()
		t.parallel().tween_property(mesh, "rotation_degrees:x", 45, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN)
		t.parallel().tween_property(mesh, "rotation_degrees:z", 45, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN)
		await t.finished
		queue_free()
