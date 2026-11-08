extends "res://systems/arsenal/weapons/WeaponBase.gd"
## Orbiting pipes — AoE hard counter for Dumpster King trash waves.

var _angle: float = 0.0
var _pipes: Array[Node2D] = []

func _ready() -> void:
	damage = 7.0
	tick = 0.35
	for i in 3:
		var s := Sprite2D.new()
		s.texture = load("res://assets/sprites/arsenal/pipe.png")
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(s)
		_pipes.append(s)

func _physics_process(delta: float) -> void:
	_angle += delta * 3.5
	var r := 42.0
	for i in _pipes.size():
		var a := _angle + i * TAU / _pipes.size()
		_pipes[i].position = Vector2(cos(a), sin(a)) * r
	super._physics_process(delta)

func fire() -> void:
	for e in _enemies_in_radius(52.0):
		_hurt(e, damage)
