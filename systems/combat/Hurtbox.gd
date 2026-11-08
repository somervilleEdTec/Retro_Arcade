extends Area2D
class_name Hurtbox
## Receives melee / arsenal hits and forwards to owner.

signal damaged(amount: float, source: String)

func receive_hit(amount: float, _from: Vector2, _kb: float) -> void:
	var host := get_parent()
	if host and host.has_method("take_damage"):
		host.take_damage(amount, "melee")
	damaged.emit(amount, "melee")
