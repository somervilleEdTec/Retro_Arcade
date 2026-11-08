extends Node
## Spawns / refreshes autonomous Street Arsenal weapons on the player.

const WEAPON_SCRIPTS := {
	"pipe_orbit": "res://systems/arsenal/weapons/PipeOrbit.gd",
	"neon_zap": "res://systems/arsenal/weapons/NeonZap.gd",
	"dumpster_charge": "res://systems/arsenal/weapons/DumpsterCharge.gd",
	"razor_gyre": "res://systems/arsenal/weapons/RazorGyre.gd",
}

var _host: Node2D

func bind_player(player: Node2D) -> void:
	_host = player
	refresh()
	if not GameState.arsenal_changed.is_connected(refresh):
		GameState.arsenal_changed.connect(refresh)

func refresh() -> void:
	if _host == null:
		return
	for child in _host.get_children():
		if child.is_in_group("arsenal_weapon"):
			child.queue_free()
	for id in GameState.arsenal.keys():
		var path: String = WEAPON_SCRIPTS.get(id, "")
		if path == "":
			continue
		var w: Node = load(path).new()
		w.name = id
		w.add_to_group("arsenal_weapon")
		_host.add_child(w)
