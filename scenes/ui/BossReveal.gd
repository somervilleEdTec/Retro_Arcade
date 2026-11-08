extends CanvasLayer
## Run-start Dumpster King portrait + mechanics tip.

signal continue_pressed

@onready var portrait: TextureRect = $Root/Portrait
@onready var name_l: Label = $Root/Name
@onready var rarity_l: Label = $Root/Rarity
@onready var mech: Label = $Root/Mechanic
@onready var hard: Label = $Root/Hard
@onready var wrong: Label = $Root/Wrong
@onready var btn: Button = $Root/Continue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/boss_pool.json"))
	var b: Dictionary = raw["bosses"]["dumpster_king"]
	portrait.texture = load(b["portrait"])
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	name_l.text = b["name"]
	rarity_l.text = "Rarity: %s" % b["rarity"]
	mech.text = "Mechanic: %s" % b["mechanic"]
	hard.text = "Hard counter: %s" % b["hard_counter"]
	wrong.text = "Wrong build: %s" % b["wrong_build"]
	btn.pressed.connect(_continue)
	btn.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		_continue()

func _continue() -> void:
	AudioBus.play("res://assets/audio/sfx/ui.wav")
	continue_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/levels/NeonAlleyCrawl.tscn")
