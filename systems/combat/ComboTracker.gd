extends Node
class_name ComboTracker
## Tracks stylish hits for Scrap multipliers.

signal combo_changed(count: int)

var count: int = 0
var _window: float = 0.0

func register_hit() -> void:
	count += 1
	_window = 1.4
	combo_changed.emit(count)

func reset() -> void:
	count = 0
	combo_changed.emit(count)

func _process(delta: float) -> void:
	if count <= 0:
		return
	_window -= delta
	if _window <= 0.0:
		reset()

func scrap_mult() -> float:
	return 1.0 + min(count, 8) * 0.15
