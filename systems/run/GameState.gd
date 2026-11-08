extends Node
## Run state for the vertical slice (SP only; player_index reserved).

signal run_started
signal level_cleared(level_id: String)
signal run_won
signal run_lost
signal arsenal_changed

const SLICE_FLOW := ["neon_alley", "plaza_swarm", "boss_dumpster"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

var player_index: int = 0
var character_id: String = "rook"
var boss_id: String = "dumpster_king"
var flow_index: int = -1
var arsenal: Dictionary = {} # id -> rank
var evolve_material: int = 0
var grabs_landed: int = 0
var run_active: bool = false
var pending_level_pick: bool = false
## When true, level-up UI auto-picks the top (boss-biased) card.
var auto_pick: bool = false
## When true, player AI clears enemies for smoke / capture runs.
var auto_play: bool = false

func start_run() -> void:
	arsenal.clear()
	evolve_material = 0
	grabs_landed = 0
	flow_index = -1
	run_active = true
	boss_id = "dumpster_king"
	run_started.emit()

func advance_flow() -> String:
	flow_index += 1
	if flow_index >= SLICE_FLOW.size():
		return "hub_win"
	return SLICE_FLOW[flow_index]

func has_weapon(id: String) -> bool:
	return arsenal.has(id)

func has_tag(tag: String) -> bool:
	var cards: Dictionary = _card_lookup()
	for id in arsenal.keys():
		var c: Dictionary = cards.get(id, {})
		if tag in c.get("tags", []):
			return true
	return false

func wrong_build_for_dumpster() -> bool:
	# Hard counter is Arsenal AoE/orbit. Grab is a soft mid-fight answer only.
	return not (has_tag("orbit") or has_tag("aoe"))

func add_card(id: String) -> void:
	if id == "razor_gyre":
		arsenal.erase("pipe_orbit")
		arsenal[id] = 1
		evolve_material = max(0, evolve_material - 1)
	else:
		arsenal[id] = int(arsenal.get(id, 0)) + 1
	arsenal_changed.emit()

func _card_lookup() -> Dictionary:
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/arsenal_cards.json"))
	var out := {}
	for c in raw["cards"]:
		out[c["id"]] = c
	return out
