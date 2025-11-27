@tool @abstract
class_name VectorUtils
extends Object

static func vector2_xz(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, vector3.z)

static func vector2i_xz(vector3: Vector3) -> Vector2i:
	return Vector2i(int(vector3.x), int(vector3.z))

static func vector3_xz(vector2: Vector2) -> Vector3:
	return Vector3(vector2.x, 0, vector2.y)

class Bounds3D:
	var left: float = 0
	var right: float = 0
	var top: float = 0
	var bottom: float = 0
	var up: float = 0
	var down: float = 0
	
	var max_side_length: float:
		get:
			return max(abs(top - bottom), abs(left - right), abs(up - down))
	
	var center: Vector3:
		get:
			return Vector3((left + right) / 2, (up + down) / 2, (top + bottom) / 2)

static func bounds_xz(points: Array[Vector3]) -> Bounds3D:
	var bounds = Bounds3D.new()
	bounds.top = points[0].z
	bounds.bottom = points[0].z
	bounds.right = points[0].x
	bounds.left = points[0].x
	
	for point: Vector3 in points:
		if point.x < bounds.left:
			bounds.left = point.x
		elif point.x > bounds.right:
			bounds.right = point.x
			
		if point.z > bounds.bottom:
			bounds.bottom = point.z
		elif point.z < bounds.top:
			bounds.top = point.z
	return bounds

static func center_point_xz(points: Array[Vector3]) -> Vector3:
	var top: float = points[0].z
	var bottom: float = points[0].z
	var right: float = points[0].x
	var left: float = points[0].x
	
	for point: Vector3 in points:
		if point.x < left:
			left = point.x
		elif point.x > right:
			right = point.x
			
		if point.z > bottom:
			bottom = point.z
		elif point.z < top:
			top = point.z
	return Vector3((left + right) / 2, 0, (top + bottom) / 2)
