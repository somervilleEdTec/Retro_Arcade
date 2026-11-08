extends Control
## Hub alley — start run / Coins / fighter stub.

@onready var coins: Label = $VBox/Coins
@onready var start_btn: Button = $VBox/Start
@onready var title: Label = $VBox/Title
@onready var blurb: Label = $VBox/Blurb

func _ready() -> void:
	title.text = "ARCADE GAME"
	blurb.text = "Rook · Neon Alley → Plaza Swarm → Dumpster King"
	_refresh()
	CoinBank.coins_changed.connect(func(_c): _refresh())
	start_btn.pressed.connect(_start)
	start_btn.grab_focus()
	AudioBus.play("res://assets/audio/sfx/ui.wav")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		_start()

func _refresh() -> void:
	coins.text = "Coins: %d" % CoinBank.coins

func _start() -> void:
	ScrapBank.reset()
	GameState.start_run()
	get_tree().change_scene_to_file("res://scenes/ui/BossReveal.tscn")
