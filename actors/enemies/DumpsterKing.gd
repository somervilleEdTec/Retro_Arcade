extends CharacterBody2D
## Boss: charge lanes + trash waves. Wrong build is punished.

enum Phase { IDLE, TELEGRAPH, CHARGE, RECOVER, SUMMON }

var hp: float = 220.0
var max_hp: float = 220.0
var damage: float = 12.0
var phase: Phase = Phase.IDLE
var _timer: float = 0.8
var _dir: int = 1
var _sprite: Sprite2D
var dead: bool = false
var grab_immune: bool = false
var wrong_build: bool = false

signal hp_changed(hp: float, max_hp: float)
signal defeated

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	wrong_build = GameState.wrong_build_for_dumpster()
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemies.json"))["boss"]["dumpster_king"]
	max_hp = float(raw["hp"])
	if wrong_build:
		max_hp *= float(raw["wrong_build_hp_mult"])
	hp = max_hp
	damage = float(raw["damage"])
	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/sprites/enemies/dumpster_king.png")
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.position = Vector2(0, -40)
	add_child(_sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(56, 60)
	col.shape = shape
	col.position = Vector2(0, -20)
	add_child(col)
	hp_changed.emit(hp, max_hp)
	AudioBus.play("res://assets/audio/sfx/boss.wav")

func _physics_process(delta: float) -> void:
	if dead:
		return
	_timer -= delta
	match phase:
		Phase.IDLE:
			if _timer <= 0.0:
				phase = Phase.TELEGRAPH
				_timer = 0.55 if wrong_build else 0.75
				modulate = Color(1.3, 0.8, 0.5)
		Phase.TELEGRAPH:
			if _timer <= 0.0:
				phase = Phase.CHARGE
				_timer = 0.5
				var p := _player()
				_dir = 1 if p and p.global_position.x >= global_position.x else -1
		Phase.CHARGE:
			velocity = Vector2(_dir * (320.0 if wrong_build else 260.0), 0)
			move_and_slide()
			_hit_player_contact()
			if _timer <= 0.0:
				phase = Phase.RECOVER
				_timer = 0.7 if wrong_build else 1.2
				velocity = Vector2.ZERO
				modulate = Color.WHITE
				grab_immune = false
		Phase.RECOVER:
			if _timer <= 0.0:
				phase = Phase.SUMMON
				_timer = 0.15
		Phase.SUMMON:
			_spawn_trash_wave()
			phase = Phase.IDLE
			_timer = 0.55 if wrong_build else 1.35
	global_position.y = clampf(global_position.y, 250.0, 320.0)
	z_index = int(global_position.y)

func _hit_player_contact() -> void:
	var p := _player()
	if p and global_position.distance_to(p.global_position) < 48.0:
		p.take_damage(damage, "charge")

func _spawn_trash_wave() -> void:
	var count := 3
	if wrong_build:
		count = 8
	for i in count:
		var e := EnemyBase.new()
		if wrong_build:
			e.role = ["grunt", "grunt", "projectile", "tank"][i % 4]
		else:
			e.role = "grunt" if i % 2 == 0 else "projectile"
		get_parent().add_child(e)
		e.global_position = global_position + Vector2((i - count / 2.0) * 34.0, randf_range(-12, 12))
		e.global_position.y = clampf(e.global_position.y, 250.0, 330.0)

func take_damage(amount: float, src: String = "") -> void:
	if dead:
		return
	if phase == Phase.CHARGE and src == "melee":
		amount *= 0.4
	hp -= amount
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()

func on_thrown(dir: Vector2) -> void:
	if phase == Phase.RECOVER:
		hp -= 40.0
		phase = Phase.IDLE
		_timer = 1.8
		GameState.grabs_landed += 1
		hp_changed.emit(hp, max_hp)
		if hp <= 0.0:
			_die()
			return
	take_damage(14.0, "throw")
	global_position += dir.normalized() * 20.0

func _die() -> void:
	dead = true
	GameState.evolve_material += 1
	ScrapBank.add(40)
	defeated.emit()
	queue_free()

func _player() -> Node2D:
	var arr := get_tree().get_nodes_in_group("player")
	return arr[0] if arr.size() > 0 else null
