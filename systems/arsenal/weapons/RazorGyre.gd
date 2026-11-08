extends "res://systems/arsenal/weapons/WeaponBase.gd"
## Evolved Pipe Orbit — denser, harder-hitting gyre.

var _angle: float = 0.0
var _blades: Array[Node2D] = []

func _ready() -> void:
	damage = 12.0
	tick = 0.22
	for i in 5:
		var s := Sprite2D.new()
		s.texture = load("res://assets/sprites/arsenal/razor.png")
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(s)
		_blades.append(s)

func _physics_process(delta: float) -> void:
	_angle += delta * 5.0
	for i in _blades.size():
		var a := _angle + i * TAU / _blades.size()
		_blades[i].position = Vector2(cos(a), sin(a)) * 50.0
	super._physics_process(delta)

func fire() -> void:
	for e in _enemies_in_radius(62.0):
		_hurt(e, damage)
