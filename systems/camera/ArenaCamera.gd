extends Camera2D
class_name ArenaCamera
## Centered arena camera with light shake.

func _ready() -> void:
	make_current()
	position_smoothing_enabled = true

func center_on(point: Vector2) -> void:
	global_position = point

func shake(amount: float = 4.0) -> void:
	offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
	var t := get_tree().create_timer(0.08)
	t.timeout.connect(func(): offset = Vector2.ZERO)
