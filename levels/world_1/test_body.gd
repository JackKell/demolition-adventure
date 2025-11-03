extends RigidBody3D


func _ready() -> void:
	apply_impulse(Vector3(randf_range(-5, 5), randf_range(5, 10), randf_range(-5, 5)))
	angular_velocity = Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2))
