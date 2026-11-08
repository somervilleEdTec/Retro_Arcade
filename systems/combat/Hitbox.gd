extends Area2D
class_name Hitbox
## Short-lived strike volume.

signal hit(hurtbox: Area2D)

@export var damage: float = 10.0
@export var lifetime: float = 0.12
var owner_group: String = "player"
var knockback: float = 40.0

func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 8
	collision_mask = 5  # world + enemies (default layer)
	body_entered.connect(_on_body)
	area_entered.connect(_on_area)
	var t := get_tree().create_timer(lifetime)
	t.timeout.connect(queue_free)

func _on_body(body: Node) -> void:
	if body.has_method("take_damage") and not body.is_in_group(owner_group):
		body.take_damage(damage, "melee")
		hit.emit(null)

func _on_area(area: Area2D) -> void:
	if area.has_method("receive_hit"):
		area.receive_hit(damage, global_position, knockback)
		hit.emit(area)
