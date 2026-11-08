extends Node2D
class_name WeaponBase
## Base for auto-firing Street Arsenal weapons.

@export var damage: float = 8.0
@export var tick: float = 0.6
var _timer: float = 0.0

func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = tick
		fire()

func fire() -> void:
	pass

func _enemies_in_radius(r: float) -> Array:
	var out: Array = []
	for n in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(n) and global_position.distance_to(n.global_position) <= r:
			out.append(n)
	return out

func _hurt(target: Node, amount: float) -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(amount, "arsenal")
