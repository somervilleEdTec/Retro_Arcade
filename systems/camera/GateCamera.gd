extends Camera2D
class_name GateCamera
## Side-scroll gate camera — locks until screen cleared.

var gate_x: float = 320.0
var locked: bool = true

func _ready() -> void:
	make_current()
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0

func follow(target: Node2D) -> void:
	if target == null:
		return
	var x := target.global_position.x
	if locked:
		global_position.x = clampf(x, gate_x - 280.0, gate_x)
	else:
		global_position.x = x
	global_position = Vector2(global_position.x, 180.0)
	zoom = Vector2.ONE

func unlock_to(next_gate: float) -> void:
	locked = false
	gate_x = next_gate
	await get_tree().create_timer(0.35).timeout
	locked = true
