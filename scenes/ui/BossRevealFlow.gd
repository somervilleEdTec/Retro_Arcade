extends Control
## Wrapper scene script for boss reveal → first level.

func _ready() -> void:
	var ui := preload("res://scenes/ui/BossReveal.tscn").instantiate()
	add_child(ui)
	ui.continue_pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/levels/NeonAlleyCrawl.tscn")
	)
