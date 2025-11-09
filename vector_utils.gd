@abstract
class_name VectorUtils
extends Object

static func vector2_xz(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, vector3.z)

static func vector2i_xz(vector3: Vector3) -> Vector2i:
	return Vector2i(int(vector3.x), int(vector3.z))

static func vector3_xz(vector2i: Vector2i) -> Vector3:
	return Vector3(vector2i.x, 0, vector2i.y)
