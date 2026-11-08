extends CharacterBody2D
## Rook — belt-scroller fighter. player_index reserved for future co-op.

@export var player_index: int = 0
@export var move_speed: float = 140.0
@export var max_hp: float = 100.0

var hp: float = 100.0
var facing: int = 1
var combo: ComboTracker
var combat: Node
var arsenal_inv: Node
var _sprite: Sprite2D
var _invuln: float = 0.0
var dead: bool = false

signal died
signal hp_changed(hp: float, max_hp: float)

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	combo = ComboTracker.new()
	add_child(combo)
	combat = preload("res://actors/player/PlayerCombat.gd").new()
	add_child(combat)
	arsenal_inv = preload("res://systems/arsenal/ArsenalInventory.gd").new()
	add_child(arsenal_inv)
	arsenal_inv.bind_player(self)
	var auto := preload("res://actors/player/AutoFighter.gd").new()
	add_child(auto)
	_sprite = $Sprite
	_ensure_collision()
	hp_changed.emit(hp, max_hp)

func _physics_process(delta: float) -> void:
	if dead:
		return
	_invuln = max(0.0, _invuln - delta)
	if not GameState.auto_play:
		if not combat.busy:
			_move(delta)
		if Input.is_action_just_pressed("punch"):
			combat.try_punch()
		elif Input.is_action_just_pressed("kick"):
			combat.try_kick()
		elif Input.is_action_just_pressed("grab"):
			combat.try_grab()
		elif Input.is_action_just_pressed("special"):
			combat.try_special()
	move_and_slide()
	global_position.y = clampf(global_position.y, 250.0, 340.0)
	global_position.x = maxf(40.0, global_position.x)
	z_index = int(global_position.y)

func _move(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * move_speed
	if abs(dir.x) > 0.1:
		facing = 1 if dir.x > 0.0 else -1
		_sprite.flip_h = facing < 0

func take_damage(amount: float, _src: String = "") -> void:
	if dead or _invuln > 0.0:
		return
	hp -= amount
	_invuln = 0.45
	set_frame("hurt")
	AudioBus.play("res://assets/audio/sfx/hit.wav")
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()

func heal(amount: float) -> void:
	hp = min(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func set_frame(name: String) -> void:
	set_frame_texture("res://assets/sprites/characters/rook_%s.png" % name)

func set_frame_texture(path: String) -> void:
	if ResourceLoader.exists(path):
		_sprite.texture = load(path)

func _die() -> void:
	dead = true
	velocity = Vector2.ZERO
	AudioBus.play("res://assets/audio/sfx/death.wav")
	died.emit()

func _ensure_collision() -> void:
	if has_node("Col"):
		return
	var col := CollisionShape2D.new()
	col.name = "Col"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 28)
	col.shape = shape
	col.position = Vector2(0, -8)
	add_child(col)
