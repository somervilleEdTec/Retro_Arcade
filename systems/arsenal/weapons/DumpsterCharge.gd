extends "res://systems/arsenal/weapons/WeaponBase.gd"
## Forward-ramming dumpster — soft AoE / boss soft counter.

func _ready() -> void:
	damage = 18.0
	tick = 2.2

func fire() -> void:
	var host := get_parent() as Node2D
	if host == null:
		return
	var dir := Vector2.RIGHT * (host.scale.x if abs(host.scale.x) > 0.0 else 1.0)
	if host.get("facing"):
		dir = Vector2(host.facing, 0)
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprites/arsenal/dumpster.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.global_position = host.global_position
	host.get_parent().add_child(sprite)
	var travel := dir.normalized() * 160.0
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "global_position", host.global_position + travel, 0.35)
	tween.tween_callback(sprite.queue_free)
	for e in _enemies_in_radius(180.0):
		var to_e: Vector2 = e.global_position - host.global_position
		if to_e.dot(dir) > 0 and abs(to_e.y) < 36.0:
			_hurt(e, damage)
