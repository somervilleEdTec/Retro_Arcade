extends Node
## Punch / kick / grab / special stubs for Rook.

signal attacked(kind: String)

@onready var player: CharacterBody2D = get_parent()
var busy: bool = false
var _cooldown: float = 0.0

func _process(delta: float) -> void:
	_cooldown = max(0.0, _cooldown - delta)

func try_punch() -> void:
	if busy or _cooldown > 0.0:
		return
	_strike("punch", 12.0, 28.0, 0.18, "res://assets/sprites/characters/rook_punch.png")

func try_kick() -> void:
	if busy or _cooldown > 0.0:
		return
	_strike("kick", 16.0, 34.0, 0.22, "res://assets/sprites/characters/rook_kick.png")

func try_grab() -> void:
	if busy or _cooldown > 0.0:
		return
	busy = true
	player.set_frame("grab")
	AudioBus.play("res://assets/audio/sfx/punch.wav")
	var foe: Node = GrabThrow.try_grab(player)
	if foe:
		GameState.grabs_landed += 1
		GrabThrow.throw_enemy(foe, Vector2(player.facing, -0.2))
		ScrapBank.add(int(6 * player.combo.scrap_mult()))
		player.combo.register_hit()
	await get_tree().create_timer(0.25).timeout
	busy = false
	_cooldown = 0.3
	player.set_frame("idle")
	attacked.emit("grab")

func try_special() -> void:
	if busy or _cooldown > 0.0:
		return
	_strike("special", 22.0, 40.0, 0.28, "res://assets/sprites/characters/rook_kick.png")

func _strike(kind: String, dmg: float, reach: float, life: float, tex: String) -> void:
	busy = true
	player.set_frame_texture(tex)
	AudioBus.play("res://assets/audio/sfx/punch.wav" if kind != "kick" else "res://assets/audio/sfx/kick.wav")
	var box := Hitbox.new()
	box.damage = dmg
	box.lifetime = life
	box.owner_group = "player"
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(reach, 28)
	cs.shape = shape
	box.add_child(cs)
	box.position = Vector2(player.facing * reach * 0.5, -10)
	player.add_child(box)
	box.hit.connect(func(_h): player.combo.register_hit())
	await get_tree().create_timer(life + 0.05).timeout
	busy = false
	_cooldown = 0.12
	player.set_frame("idle")
	attacked.emit(kind)
