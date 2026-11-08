extends CanvasLayer
## In-run HUD: HP, Scrap, combo, arsenal chips.

@onready var hp_bar: ProgressBar = $Root/HP
@onready var scrap_label: Label = $Root/Scrap
@onready var combo_label: Label = $Root/Combo
@onready var arsenal_label: Label = $Root/Arsenal
@onready var hint_label: Label = $Root/Hint

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ScrapBank.scrap_changed.connect(_on_scrap)
	GameState.arsenal_changed.connect(_on_arsenal)
	_on_scrap(ScrapBank.scrap)
	_on_arsenal()
	hint_label.text = "WASD move · J punch · K kick · L grab · I special"

func bind_player(player: Node) -> void:
	if player and player.has_signal("hp_changed"):
		player.hp_changed.connect(func(h, m):
			hp_bar.max_value = m
			hp_bar.value = h
		)
		if player.get("combo"):
			player.combo.combo_changed.connect(func(c): combo_label.text = "Combo x%d" % c if c > 0 else "")

func _on_scrap(total: int) -> void:
	scrap_label.text = "Scrap %d" % total

func _on_arsenal() -> void:
	var keys: Array = GameState.arsenal.keys()
	arsenal_label.text = "Arsenal: " + (", ".join(keys) if keys.size() else "—")
