extends Node2D
class_name LevelBase
## Shared spawn / clear / HUD wiring for slice levels.

signal cleared

var player: CharacterBody2D
var hud: CanvasLayer
var cards: CanvasLayer

func setup_player(at: Vector2) -> CharacterBody2D:
	player = preload("res://actors/player/Player.tscn").instantiate()
	add_child(player)
	player.global_position = at
	player.died.connect(_on_player_died)
	hud = preload("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	hud.bind_player(player)
	cards = preload("res://scenes/ui/LevelUpCards.tscn").instantiate()
	add_child(cards)
	return player

func spawn_enemy(role: String, at: Vector2) -> EnemyBase:
	var e := EnemyBase.new()
	e.role = role
	add_child(e)
	e.global_position = at
	return e

func enemies_alive() -> int:
	var n := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and not e.get("dead"):
			n += 1
	return n

func finish_level(next_scene: String) -> void:
	# Guaranteed clear pick
	if not get_tree().paused:
		ScrapBank.force_level_pick()
	while get_tree().paused:
		await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout
	cleared.emit()
	get_tree().change_scene_to_file(next_scene)

func _on_player_died() -> void:
	CoinBank.add(5 + ScrapBank.levels_gained * 2)
	GameState.run_active = false
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
