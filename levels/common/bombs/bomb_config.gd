class_name BombConfig
extends EntityConfig

enum Size {
	ONE,
	TWO,
	THREE,
}

@export var size: Size = Size.ONE
@export var stuck: bool = false
