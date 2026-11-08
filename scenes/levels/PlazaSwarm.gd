extends LevelBase
## Open horde arena — timed waves + Scrap rain.

var camera: ArenaCamera
var wave: int = 0
var max_waves: int = 4
var _timer: float = 1.0

func _ready() -> void:
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/backgrounds/plaza.png")
	bg.centered = false
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	setup_player(Vector2(320, 240))
	camera = ArenaCamera.new()
	add_child(camera)
	camera.center_on(Vector2(320, 180))
	_spawn_wave()

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0 and wave < max_waves and enemies_alive() < 3:
		_spawn_wave()
	elif wave >= max_waves and enemies_alive() == 0:
		set_process(false)
		finish_level("res://scenes/bosses/BossLevel.tscn")

func _spawn_wave() -> void:
	wave += 1
	_timer = 4.0
	var roles: Array = ["grunt", "grunt", "projectile"]
	if wave >= 2:
		roles.append("grabber")
	if wave >= 3:
		roles.append("tank")
	if wave == 4:
		roles.append_array(["grunt", "projectile", "grabber"])
	for i in roles.size():
		var ang := TAU * i / roles.size()
		spawn_enemy(roles[i], Vector2(320, 240) + Vector2(cos(ang), sin(ang)) * 130.0)
	if wave == 2 or wave == 4:
		ScrapBank.add(8)
