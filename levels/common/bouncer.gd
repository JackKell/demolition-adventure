class_name Bouncer
extends Entity

const ARM_TIME: float = 0.01
const HOLD_DURATION: float = 0.1
const SHOOT_DURATION: float = 0.1
const RETURN_DURATION: float = 0.2
const RECOVERY_DURATION: float = 0.2
const ROTATION: float = 25

@export var mesh: MeshInstance3D

var t: Tween
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_B:
			bounce(Vector2i.UP)
			
func bounce(direction: Vector2i) -> void:
	if not mesh:
		return
	t = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	if direction.y < 0:
		t.tween_property(mesh, "rotation_degrees:x", ROTATION, ARM_TIME)
		t.tween_property(mesh, "rotation_degrees:x", -ROTATION, SHOOT_DURATION).set_delay(HOLD_DURATION)
		t.tween_property(mesh, "rotation_degrees:x", 0, RETURN_DURATION).set_delay(RECOVERY_DURATION)
	elif direction.y > 0:
		t.tween_property(mesh, "rotation_degrees:x", -ROTATION, ARM_TIME)
		t.tween_property(mesh, "rotation_degrees:x", ROTATION, SHOOT_DURATION).set_delay(HOLD_DURATION)
		t.tween_property(mesh, "rotation_degrees:x", 0, RETURN_DURATION).set_delay(RECOVERY_DURATION)
	elif direction.x < 0:
		t.tween_property(mesh, "rotation_degrees:z", -ROTATION, ARM_TIME)
		t.tween_property(mesh, "rotation_degrees:z", ROTATION, SHOOT_DURATION).set_delay(HOLD_DURATION)
		t.tween_property(mesh, "rotation_degrees:z", 0, RETURN_DURATION).set_delay(RECOVERY_DURATION)
	elif direction.x > 0:
		t.tween_property(mesh, "rotation_degrees:z", ROTATION, ARM_TIME)
		t.tween_property(mesh, "rotation_degrees:z", -ROTATION, SHOOT_DURATION).set_delay(HOLD_DURATION)
		t.tween_property(mesh, "rotation_degrees:z", 0, RETURN_DURATION).set_delay(RECOVERY_DURATION)
