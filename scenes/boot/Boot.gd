extends Node
## Boots into hub.

func _ready() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
