extends Node
## Lightweight one-shot SFX player.

var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func play(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	for p in _players:
		if not p.playing:
			p.stream = load(path)
			p.play()
			return
