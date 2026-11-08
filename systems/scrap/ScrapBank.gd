extends Node
## Run Scrap XP + level-up thresholds.

signal scrap_changed(total: int)
signal level_up_ready(choices: Array)

var scrap: int = 0
var levels_gained: int = 0
var _thresholds: Array = []
var _paused_for_pick: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/arsenal_cards.json"))
	_thresholds = raw["scrap_thresholds"]

func reset() -> void:
	scrap = 0
	levels_gained = 0
	_paused_for_pick = false
	scrap_changed.emit(scrap)

func add(amount: int) -> void:
	if amount <= 0 or _paused_for_pick:
		return
	scrap += amount
	scrap_changed.emit(scrap)
	_check_level()

func force_level_pick() -> void:
	if _paused_for_pick:
		return
	_offer_pick()

func notify_pick_done() -> void:
	_paused_for_pick = false
	get_tree().paused = false

func _check_level() -> void:
	if levels_gained >= _thresholds.size():
		return
	if scrap >= int(_thresholds[levels_gained]):
		_offer_pick()

func _offer_pick() -> void:
	_paused_for_pick = true
	levels_gained += 1
	get_tree().paused = true
	level_up_ready.emit(LevelUpService.build_choices())
