class_name FallawayTile
extends Tile

signal fell

@export var mesh: Node3D

const FALL_ANIMATION_DURATION: float = 0.6

var _has_fallen: bool = false
var _falling_tween: Tween
var _is_falling: bool:
	get:
		return _falling_tween and _falling_tween.is_running()

func handle_entity_exit(exiting_entity: Entity) -> void:
	if exiting_entity is Character:
		fall()

func fall() -> void:
	if _is_falling or _has_fallen:
		return
	type = TileType.OBSTICAL
	_has_fallen = true
	fell.emit()
	_falling_tween = create_tween()
	_falling_tween.tween_property(mesh, "position", Vector3.DOWN, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN).as_relative()
	_falling_tween.parallel().tween_property(mesh, "rotation_degrees:x", 45, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	_falling_tween.parallel().tween_property(mesh, "rotation_degrees:z", 45, FALL_ANIMATION_DURATION).set_ease(Tween.EASE_IN)
	_falling_tween.tween_property(mesh, "visible", false, 0)
	
func raise() -> void:
	if !_has_fallen:
		return
	if _is_falling:
		_falling_tween.kill()
	_has_fallen = false
	type = TileType.NORMAL
	mesh.rotation_degrees = Vector3.ZERO
	mesh.position = Vector3.ZERO
	mesh.visible = true
