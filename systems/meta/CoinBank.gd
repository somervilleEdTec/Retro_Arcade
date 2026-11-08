extends Node
## Hub meta currency earned on run end.

signal coins_changed(total: int)

const SAVE_PATH := "user://meta.cfg"
var coins: int = 0

func _ready() -> void:
	_load()

func add(amount: int) -> void:
	coins += max(0, amount)
	_save()
	coins_changed.emit(coins)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "coins", coins)
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		coins = int(cfg.get_value("meta", "coins", 0))
