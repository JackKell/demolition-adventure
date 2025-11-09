class_name CoveryBeltTile
extends Tile

@export var speed: float = 1

var entity_reached_center: bool = false
var entity: Entity = null
var target_coords: Vector2i
var target_position: Vector3
@onready var belt_material: StandardMaterial3D = $ConveyorBelt/ConveyorBelt.get_active_material(0)

func initalize(parent_level: Level):
	super.initalize(parent_level)
	var forward: Vector3i = Vector3i(global_transform.basis.z)
	target_coords = coords + Vector2i(forward.x, forward.z)
	target_position = level.map_to_world(target_coords)

func _physics_process(delta: float) -> void:
	var total_seconds = Time.get_ticks_msec() / 1000.0
	var x = fmod(total_seconds * 0.5, 1)
	belt_material.uv1_offset.y = x
	if not entity:
		return
	if entity.is_moving:
		return
	if entity.coords != coords:
		return
	if !entity_reached_center or !level.has_tile(target_coords) or level.get_entity(target_coords):
		if entity.global_position.is_equal_approx(global_position):
			entity_reached_center = true
		else:
			entity.global_position = entity.global_position.move_toward(global_position, delta * speed)
	else:
		entity.global_position = entity.global_position.move_toward(target_position, delta * speed)
	entity.update_coords()


func handle_entity_enter(entering_entity: Entity) -> void:
	entity = entering_entity


func handle_entity_exit(exiting_entity: Entity) -> void:
	var new_tile: Tile = level.get_tile(exiting_entity.coords)
	var target_tile: Tile = level.get_tile(target_coords)
	if target_tile == new_tile and new_tile is not CoveryBeltTile:
		entity.move_to_center()
	entity = null
	entity_reached_center = false
