extends "res://systems/arsenal/weapons/WeaponBase.gd"
## Single-target neon zap — weak vs Dumpster King waves alone.

func _ready() -> void:
	damage = 14.0
	tick = 0.9

func fire() -> void:
	var foes := _enemies_in_radius(140.0)
	if foes.is_empty():
		return
	foes.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	_hurt(foes[0], damage)
	_flash(foes[0].global_position)

func _flash(to: Vector2) -> void:
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.25, 0.9, 0.85, 0.9)
	line.points = PackedVector2Array([Vector2.ZERO, to - global_position])
	add_child(line)
	var t := get_tree().create_timer(0.08)
	t.timeout.connect(line.queue_free)
