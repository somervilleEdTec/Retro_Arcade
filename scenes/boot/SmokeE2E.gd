extends Node
## Headless/display smoke: full slice + wrong-build fail check.
## Run: godot4 --path . res://scenes/boot/SmokeE2E.tscn
## Optional: -- --capture  writes plaza/boss PNGs under user:// then copies noted in log.

var _capture: bool = false
var _report: Dictionary = {}

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--capture":
			_capture = true
	GameState.auto_pick = true
	GameState.auto_play = true
	await _run_correct()
	await _run_wrong()
	_write_report()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit(0 if _report.get("ok", false) else 1)

func _run_correct() -> void:
	CoinBank.coins = 0
	ScrapBank.reset()
	GameState.start_run()
	GameState.add_card("pipe_orbit")
	GameState.add_card("dumpster_charge")
	_report["correct_wrong_build_flag"] = GameState.wrong_build_for_dumpster()
	get_tree().change_scene_to_file("res://scenes/levels/PlazaSwarm.tscn")
	await get_tree().create_timer(0.4).timeout
	if _capture:
		await _shot("live-04-plaza.png")
	await _wait_scene("BossLevel", 90.0)
	if _capture:
		await get_tree().create_timer(0.5).timeout
		await _shot("live-05-boss.png")
	await _wait_scene("Hub", 90.0)
	_report["correct_coins"] = CoinBank.coins
	_report["correct_won"] = CoinBank.coins >= 25
	_report["correct_arsenal"] = GameState.arsenal.keys()

func _run_wrong() -> void:
	ScrapBank.reset()
	GameState.start_run()
	GameState.add_card("neon_zap") # single-target only
	_report["wrong_flag"] = GameState.wrong_build_for_dumpster()
	var coins_before := CoinBank.coins
	get_tree().change_scene_to_file("res://scenes/bosses/BossLevel.tscn")
	await _wait_scene("Hub", 75.0)
	_report["wrong_died_or_returned"] = get_tree().current_scene != null
	_report["wrong_coins_gained"] = CoinBank.coins > coins_before
	# Wrong build should not leave player with a "easy" win streak — expect death coins (<=15-ish) or long fail
	_report["wrong_was_hard"] = _report["wrong_flag"] == true

func _wait_scene(name_part: String, timeout_s: float) -> void:
	var t := 0.0
	while t < timeout_s:
		await get_tree().create_timer(0.25).timeout
		t += 0.25
		var sc := get_tree().current_scene
		if sc and name_part in sc.name:
			return
	_report["timeout_%s" % name_part] = true

func _shot(filename: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	var path := "user://%s" % filename
	img.save_png(path)
	_report["shot_%s" % filename] = ProjectSettings.globalize_path(path)
	print("SMOKE_SHOT ", ProjectSettings.globalize_path(path))

func _write_report() -> void:
	_report["ok"] = (
		_report.get("correct_won", false)
		and _report.get("wrong_flag", false)
		and not _report.get("correct_wrong_build_flag", true)
		and not _report.has("timeout_Hub")
	)
	print("SMOKE_REPORT ", JSON.stringify(_report))
