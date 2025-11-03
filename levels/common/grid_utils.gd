class_name GridUtils
extends Object

static func get_coords_in_circle(radius: int, center: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	assert(radius >= 0)
	var circle_coords: Array[Vector2i] = []
	for x_offset in range(-radius, radius + 1):
		for y_offset in range(-radius, radius + 1):
			if abs(x_offset) + abs(y_offset) <= radius: 
				circle_coords.append(Vector2i(x_offset, y_offset) + center)
	return circle_coords
	
static func get_coords_in_ring(radius: int, center: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	assert(radius >= 0)
	var ring_coords: Array[Vector2i] = []
	for x_offset in range(-radius, radius + 1):
		for y_offset in range(-radius, radius + 1):
			if abs(x_offset) + abs(y_offset) == radius:
				ring_coords.append(Vector2i(x_offset, y_offset) + center)
	return ring_coords
