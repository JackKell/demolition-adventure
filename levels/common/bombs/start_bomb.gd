class_name StartBomb
extends Bomb

@onready var sparks_emitter: GPUParticles3D = %SparksEmitter
@onready var fuse_lit: AudioStreamPlayer = $FuseLit

var is_ignited: bool = false

func ignite() -> void:
	if is_ignited:
		return
	is_ignited = true
	sparks_emitter.emitting = true
	fuse_lit.play()
	await get_tree().create_timer(3).timeout
	detonate()
