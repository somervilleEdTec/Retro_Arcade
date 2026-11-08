extends Node
## Smoke / capture AI — chase nearest foe, punch, grab on boss recover.

var _cd: float = 0.0

func _physics_process(delta: float) -> void:
	if not GameState.auto_play:
		return
	var p: CharacterBody2D = get_parent() as CharacterBody2D
	if p == null or p.dead or (p.combat and p.combat.busy):
		return
	_cd = max(0.0, _cd - delta)
	var foe := _nearest()
	if foe == null:
		p.velocity = Vector2.ZERO
		return
	var to: Vector2 = foe.global_position - p.global_position
	if to.length() > 26.0:
		p.velocity = to.normalized() * p.move_speed
		p.facing = 1 if to.x >= 0.0 else -1
		p.get_node("Sprite").flip_h = p.facing < 0
	else:
		p.velocity = Vector2.ZERO
		if _cd <= 0.0:
			_cd = 0.18
			# DumpsterKing.Phase.RECOVER == 3
			if foe.is_in_group("boss") and int(foe.get("phase")) == 3:
				p.combat.try_grab()
			else:
				p.combat.try_punch()

func _nearest() -> Node2D:
	var best: Node2D = null
	var best_d := 9999.0
	var p: Node2D = get_parent()
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e) or e.get("dead"):
			continue
		var d: float = p.global_position.distance_to(e.global_position)
		if d < best_d:
			best = e
			best_d = d
	return best
