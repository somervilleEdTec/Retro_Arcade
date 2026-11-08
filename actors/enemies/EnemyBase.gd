extends CharacterBody2D
class_name EnemyBase
## Shared AI for grunt / tank / grabber / projectile roles.

@export var role: String = "grunt"
var hp: float = 30.0
var damage: float = 6.0
var speed: float = 70.0
var scrap_value: int = 4
var grab_immune: bool = false
var _atk_cd: float = 0.0
var _sprite: Sprite2D
var dead: bool = false

func _ready() -> void:
	add_to_group("enemies")
	_apply_role()
	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/sprites/enemies/%s.png" % role)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.position = Vector2(0, -20)
	add_child(_sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 30)
	col.shape = shape
	col.position = Vector2(0, -10)
	add_child(col)

func _apply_role() -> void:
	var raw = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemies.json"))
	var d: Dictionary = raw["roles"].get(role, raw["roles"]["grunt"])
	hp = float(d["hp"]); damage = float(d["damage"])
	speed = float(d["speed"]); scrap_value = int(d["scrap"])
	if role == "tank":
		grab_immune = false

func _physics_process(delta: float) -> void:
	if dead:
		return
	_atk_cd = max(0.0, _atk_cd - delta)
	var player := _player()
	if player == null:
		return
	var to := player.global_position - global_position
	if to.length() > 22.0:
		velocity = to.normalized() * speed
	else:
		velocity = Vector2.ZERO
		_try_attack(player)
	move_and_slide()
	z_index = int(global_position.y)
	if _sprite:
		_sprite.flip_h = to.x < 0.0

func _try_attack(player: Node) -> void:
	if _atk_cd > 0.0:
		return
	_atk_cd = 0.9 if role != "grabber" else 1.2
	if role == "projectile":
		_throw_bottle(player)
		return
	if role == "grabber" and player.has_method("take_damage"):
		player.take_damage(damage * 1.2, "grab")
	elif player.has_method("take_damage"):
		player.take_damage(damage, "melee")

func _throw_bottle(player: Node) -> void:
	var b := Area2D.new()
	b.monitoring = true
	b.collision_layer = 0
	b.collision_mask = 2
	var s := Sprite2D.new()
	s.texture = load("res://assets/sprites/enemies/bottle.png")
	b.add_child(s)
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6
	cs.shape = circle
	b.add_child(cs)
	var dir: Vector2 = ((player as Node2D).global_position - global_position).normalized()
	b.set_meta("vel", dir * 180.0)
	b.set_meta("dmg", damage)
	b.set_script(load("res://actors/enemies/ProjectileMotion.gd"))
	get_parent().add_child(b)
	b.global_position = global_position + Vector2(0, -20)

func take_damage(amount: float, _src: String = "") -> void:
	if dead:
		return
	hp -= amount
	modulate = Color(1.4, 0.7, 0.7)
	var t := get_tree().create_timer(0.08)
	t.timeout.connect(func(): modulate = Color.WHITE)
	if hp <= 0.0:
		_die()

func on_thrown(dir: Vector2) -> void:
	take_damage(20.0, "throw")
	global_position += dir.normalized() * 50.0

func _die() -> void:
	dead = true
	ScrapBank.add(scrap_value)
	AudioBus.play("res://assets/audio/sfx/scrap.wav")
	queue_free()

func _player() -> Node2D:
	var arr := get_tree().get_nodes_in_group("player")
	return arr[0] if arr.size() > 0 else null
