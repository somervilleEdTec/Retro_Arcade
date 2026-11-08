extends LevelBase
## Open horde arena — timed waves + Scrap rain.

var camera: ArenaCamera
var wave: int = 0
var max_waves: int = 3
var _timer: float = 0.6
var _finishing: bool = false

func _ready() -> void:
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/backgrounds/plaza.png")
	bg.centered = false
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	setup_player(Vector2(320, 280))
	camera = ArenaCamera.new()
	add_child(camera)
	camera.center_on(Vector2(320, 180))
	_spawn_wave()

func _process(delta: float) -> void:
	if _finishing:
		return
	_timer -= delta
	if _timer <= 0.0 and wave < max_waves and enemies_alive() < 3:
		_spawn_wave()
	elif wave >= max_waves and enemies_alive() == 0:
		_finishing = true
		set_process(false)
		finish_level("res://scenes/bosses/BossLevel.tscn")

func _spawn_wave() -> void:
	wave += 1
	_timer = 3.5
	var roles: Array = ["grunt", "grunt", "projectile"]
	if wave >= 2:
		roles.append("grabber")
	if wave >= 3:
		roles.append_array(["tank", "grunt"])
	for i in roles.size():
		var ang := TAU * i / roles.size()
		var pos := Vector2(320, 280) + Vector2(cos(ang), sin(ang) * 0.45) * 120.0
		pos.y = clampf(pos.y, 250.0, 330.0)
		spawn_enemy(roles[i], pos)
	if wave == 2:
		ScrapBank.add(10)
