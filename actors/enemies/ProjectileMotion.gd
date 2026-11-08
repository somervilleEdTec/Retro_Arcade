extends Area2D
## Enemy bottle projectile motion + player hit.

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body)

func _physics_process(delta: float) -> void:
	if has_meta("vel"):
		global_position += get_meta("vel") * delta
	if abs(global_position.x) > 2000.0:
		queue_free()

func _on_body(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(float(get_meta("dmg")), "projectile")
	queue_free()
