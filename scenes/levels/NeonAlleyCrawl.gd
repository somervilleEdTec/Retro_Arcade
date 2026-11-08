extends LevelBase
## Gated side-scroll — clear packs to advance.

var gates: Array = [320.0, 560.0, 800.0]
var gate_i: int = 0
var camera: GateCamera
var clearing: bool = false
var wave_active: bool = false

func _ready() -> void:
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/backgrounds/neon_alley.png")
	bg.centered = false
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	# Extend alley art for gated scroll
	var bg2 := Sprite2D.new()
	bg2.texture = bg.texture
	bg2.centered = false
	bg2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg2.position = Vector2(640, 0)
	add_child(bg2)
	setup_player(Vector2(80, 280))
	camera = GateCamera.new()
	add_child(camera)
	camera.gate_x = gates[0]
	_spawn_gate_wave()

func _process(_d: float) -> void:
	if player:
		camera.follow(player)
	if wave_active and not clearing and enemies_alive() == 0:
		_advance()

func _spawn_gate_wave() -> void:
	wave_active = true
	var gx: float = gates[gate_i]
	var roles := ["grunt", "grunt", "tank"] if gate_i == 0 else ["grunt", "grabber", "projectile", "grunt"]
	if gate_i == 2:
		roles = ["tank", "grabber", "projectile", "grunt", "grunt"]
	for i in roles.size():
		spawn_enemy(roles[i], Vector2(gx - 40 + i * 36, 260 + (i % 3) * 12))

func _advance() -> void:
	clearing = true
	wave_active = false
	if gate_i >= gates.size() - 1:
		set_process(false)
		finish_level("res://scenes/levels/PlazaSwarm.tscn")
		return
	gate_i += 1
	camera.unlock_to(gates[gate_i])
	await get_tree().create_timer(0.5).timeout
	clearing = false
	_spawn_gate_wave()
