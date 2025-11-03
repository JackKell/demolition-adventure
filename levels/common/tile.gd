class_name Tile
extends RigidBody3D

const GROUP: String = "tile"

enum TileType {
	NORMAL,
	OBSTICAL,
	WATER,
	OIL,
	SPIKES,
	ICY,
}

@export var type: TileType
var level: Level
var coords: Vector2i
var _detonated: bool = false
var has_detonated: bool:
	get:
		return _detonated
		
func _init() -> void:
	freeze = true
	collision_layer = 1
	collision_mask = 2

func _ready() -> void:
	add_to_group(GROUP)

func initalize(parent_level: Level):
	level = parent_level
	var snapped_position: Vector3 = global_position.snapped(Vector3.ONE)
	global_position = snapped_position
	coords = level.world_to_map(global_position)

func handle_entity_enter(_entering_entity: Entity) -> void:
	return

func handle_entity_exit(_exiting_entity: Entity) -> void:
	return

func detonate() -> void:
	if _detonated:
		return 
	_detonated = true
	freeze = false
	apply_impulse(Vector3(randf_range(-5, 5), randf_range(5, 10), randf_range(-5, 5)))
	#apply_torque_impulse(Vector3(randf_range(-5, 5), randf_range(5, 10), randf_range(-5, 5)))
	angular_velocity = Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2))
