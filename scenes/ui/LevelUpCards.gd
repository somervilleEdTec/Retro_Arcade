extends CanvasLayer
## Pause 3-pick Arsenal card UI.

signal card_picked(id: String)

@onready var row: HBoxContainer = $Center/Panel/Row
@onready var title: Label = $Center/Panel/Title

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	ScrapBank.level_up_ready.connect(show_choices)

func show_choices(choices: Array) -> void:
	visible = true
	title.text = "Street Arsenal — pick 1"
	for c in row.get_children():
		c.queue_free()
	await get_tree().process_frame
	var first_id: String = ""
	for c in choices:
		var b := Button.new()
		b.custom_minimum_size = Vector2(160, 120)
		b.text = "%s\n\n%s" % [c["name"], c["desc"]]
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var id: String = c["id"]
		if first_id == "":
			first_id = id
		b.pressed.connect(_pick.bind(id))
		row.add_child(b)
	AudioBus.play("res://assets/audio/sfx/levelup.wav")
	if GameState.auto_pick and first_id != "":
		await get_tree().create_timer(0.15).timeout
		_pick(first_id)

func _pick(id: String) -> void:
	GameState.add_card(id)
	visible = false
	ScrapBank.notify_pick_done()
	card_picked.emit(id)
	AudioBus.play("res://assets/audio/sfx/ui.wav")
