extends RefCounted
class_name GrabThrow
## Grab / throw stub helpers.

static func try_grab(player: Node2D, reach: float = 36.0) -> Node:
	var best: Node = null
	var best_d := reach
	for e in player.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.get("grab_immune"):
			continue
		var ep: Vector2 = (e as Node2D).global_position
		var d: float = player.global_position.distance_to(ep)
		if d < best_d and abs(ep.y - player.global_position.y) < 18.0:
			best = e
			best_d = d
	return best

static func throw_enemy(enemy: Node, dir: Vector2) -> void:
	if enemy == null:
		return
	if enemy.has_method("on_thrown"):
		enemy.on_thrown(dir)
	elif enemy.has_method("take_damage"):
		enemy.take_damage(18.0, "throw")
