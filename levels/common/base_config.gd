class_name BaseConfig
extends Resource

enum Direction {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export var id: int
@export var rotation: Direction = Direction.SOUTH
