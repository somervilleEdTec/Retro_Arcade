extends LevelBase
## Dumpster King arena — wrong build fails / correct build wins.

var boss: Node
var camera: ArenaCamera
var _ended: bool = false

func _ready() -> void:
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/backgrounds/boss_arena.png")
	bg.centered = false
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	setup_player(Vector2(180, 260))
	# Seed a starter pick reminder via scrap if player somehow has nothing
	if GameState.arsenal.is_empty():
		ScrapBank.add(20)
	camera = ArenaCamera.new()
	add_child(camera)
	camera.center_on(Vector2(320, 180))
	boss = _make_boss()
	add_child(boss)
	boss.global_position = Vector2(420, 260)
	boss.defeated.connect(_on_boss_down)
	boss.hp_changed.connect(_on_boss_hp)
	var tip := Label.new()
	tip.text = "WRONG BUILD" if GameState.wrong_build_for_dumpster() else "COUNTER BUILD READY"
	tip.position = Vector2(200, 16)
	tip.add_theme_color_override("font_color", Color(1, 0.5, 0.3) if GameState.wrong_build_for_dumpster() else Color(0.4, 1, 0.7))
	add_child(tip)

func _make_boss() -> CharacterBody2D:
	var b := CharacterBody2D.new()
	b.set_script(load("res://actors/enemies/DumpsterKing.gd"))
	return b

func _on_boss_hp(h: float, m: float) -> void:
	if hud and hud.has_node("Root/Hint"):
		hud.get_node("Root/Hint").text = "Dumpster King  %d / %d" % [int(h), int(m)]

func _on_boss_down() -> void:
	if _ended:
		return
	_ended = true
	player.heal(40.0)
	# Offer evolve if pipe owned
	if GameState.has_weapon("pipe_orbit") and GameState.evolve_material > 0:
		ScrapBank.force_level_pick()
		while get_tree().paused:
			await get_tree().process_frame
	CoinBank.add(25 + ScrapBank.levels_gained * 3)
	GameState.run_active = false
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
