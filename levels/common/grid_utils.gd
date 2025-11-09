@abstract
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

static func get_coords_in_rect(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var x_min: int = mini(p1.x, p2.x)
	var x_max: int = maxi(p1.x, p2.x)
	var y_min: int = mini(p1.y, p2.y)
	var y_max: int = maxi(p1.y, p2.y)
	for x in range(x_min, x_max + 1):
		for y in range(y_min, y_max + 1):
			points.append(Vector2i(x, y))
	return points

# https://www.redblobgames.com/grids/line-drawing/#orthogonal-steps
static func coords_in_line(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var delta = p2 - p1
	var normalized_delta = delta.abs()
	var sign_x: int = 1 if delta.x > 0 else -1
	var sign_y: int = 1 if delta.y > 0 else -1
	var current_point: Vector2i = Vector2i(p1)
	var result: Array[Vector2i] = [current_point]
	# NOTE: here to make sure we don't crash the game in a forever loop
	var offset = Vector2i.ZERO
	const MAX_STEPS = 100
	var i = 0
	while i <= MAX_STEPS and (offset.x < normalized_delta.x or offset.y < normalized_delta.y):
		i += 1
		var v1 = (1 + 2 * offset.x) * normalized_delta.y
		var v2 = (1 + 2 * offset.y) * normalized_delta.x
		if v1 < v2:
			current_point += Vector2i(sign_x, 0)
			offset.x += 1
		else:
			current_point += Vector2i(0, sign_y)
			offset.y += 1
		result.append(current_point)
	return result
