class_name LevelUpService
extends RefCounted
## Builds biased 3-pick Arsenal choices for the shown boss.

static func build_choices() -> Array:
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/arsenal_cards.json"))
	var cards: Array = raw["cards"].duplicate(true)
	var pool: Array = []
	for c in cards:
		if c["type"] == "evolve":
			if GameState.has_weapon(c.get("requires", "")) and GameState.evolve_material > 0:
				pool.append(c)
			continue
		if GameState.has_weapon(c["id"]) and c["id"] != "pipe_orbit":
			continue
		if GameState.has_weapon("razor_gyre") and c["id"] == "pipe_orbit":
			continue
		pool.append(c)
	pool.sort_custom(func(a, b): return _score(a) > _score(b))
	var picks: Array = []
	for c in pool:
		picks.append(c)
		if picks.size() == 3:
			break
	while picks.size() < 3 and pool.size() > 0:
		picks.append(pool[0])
	return picks

static func _score(c: Dictionary) -> int:
	var s := 0
	if GameState.boss_id in c.get("boss_bias", []):
		s += 10
	if "aoe" in c.get("tags", []) or "orbit" in c.get("tags", []):
		s += 5
	if c["type"] == "evolve":
		s += 20
	return s
