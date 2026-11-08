extends Node
## Autoload smoke driver — survives scene changes.
## Enable: godot4 --path . -- --smoke [--capture]

var active: bool = false
var capture: bool = false
var report: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a == "--smoke":
			active = true
		if a == "--capture":
			capture = true
	if active:
		call_deferred("run")

func run() -> void:
	GameState.auto_pick = true
	GameState.auto_play = true
	await get_tree().create_timer(0.25).timeout
	await _run_full_correct()
	await _run_wrong()
	_finalize()

func _run_full_correct() -> void:
	CoinBank.coins = 0
	ScrapBank.reset()
	GameState.start_run()
	# Seed early AoE so Dumpster King is the intended counter build
	GameState.add_card("pipe_orbit")
	report["correct_is_wrong_build"] = GameState.wrong_build_for_dumpster()
	get_tree().change_scene_to_file("res://scenes/levels/NeonAlleyCrawl.tscn")
	var to_plaza := await _wait_name("PlazaSwarm", 120.0)
	report["reached_plaza"] = to_plaza
	if to_plaza and capture:
		await get_tree().create_timer(0.5).timeout
		await _shot("live-04-plaza.png")
	var to_boss := await _wait_name("BossLevel", 120.0)
	report["reached_boss"] = to_boss
	if to_boss and capture:
		await get_tree().create_timer(0.6).timeout
		await _shot("live-05-boss.png")
	var to_hub := await _wait_name("Hub", 120.0)
	report["correct_hub"] = to_hub
	report["correct_coins"] = CoinBank.coins
	report["correct_won"] = to_hub and CoinBank.coins >= 20

func _run_wrong() -> void:
	ScrapBank.reset()
	GameState.start_run()
	GameState.add_card("neon_zap")
	report["wrong_flag"] = GameState.wrong_build_for_dumpster()
	var before := CoinBank.coins
	get_tree().change_scene_to_file("res://scenes/bosses/BossLevel.tscn")
	var back := await _wait_name("Hub", 90.0)
	report["wrong_returned_hub"] = back
	report["wrong_coins_delta"] = CoinBank.coins - before
	report["wrong_looks_like_death"] = back and (CoinBank.coins - before) <= 20

func _wait_name(part: String, timeout_s: float) -> bool:
	var t := 0.0
	while t < timeout_s:
		await get_tree().create_timer(0.25).timeout
		t += 0.25
		var sc := get_tree().current_scene
		if sc != null and part in String(sc.name):
			return true
	report["timeout_%s" % part] = true
	return false

func _shot(filename: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var tex: ViewportTexture = get_viewport().get_texture()
	if tex == null:
		return
	var img: Image = tex.get_image()
	var user_path := "user://%s" % filename
	img.save_png(user_path)
	var abs_path := ProjectSettings.globalize_path(user_path)
	report["shot_%s" % filename] = abs_path
	print("SMOKE_SHOT ", abs_path)

func _finalize() -> void:
	report["ok"] = (
		report.get("correct_won", false)
		and report.get("reached_plaza", false)
		and report.get("reached_boss", false)
		and report.get("wrong_flag", false)
		and report.get("wrong_returned_hub", false)
		and report.get("correct_is_wrong_build", true) == false
	)
	print("SMOKE_REPORT ", JSON.stringify(report))
	get_tree().quit(0 if report["ok"] else 1)
