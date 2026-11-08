# Arcade Game

Streets of Rage–style belt-scroller × Vampire Survivors upgrades (**Street Arsenal**). Godot 4 vertical slice.

## Vertical slice loop

**Hub → Dumpster King reveal → Neon Alley Crawl → Plaza Swarm → Dumpster King boss → Hub Coins**

## How to run

1. Install **Godot 4.3+** ([godotengine.org](https://godotengine.org/download)).
2. Open this folder as a project (`project.godot`).
3. Press **F5** (main scene: `scenes/boot/Boot.tscn`).

### Controls

| Action | Keys |
| --- | --- |
| Move | WASD / Arrows |
| Punch | J / Z |
| Kick | K / X |
| Grab / throw | L / C |
| Special (stub) | I / V |

### Boss tip

Dumpster King punishes pure single-target DPS. Pick **Pipe Orbit** / **Dumpster Charge** (AoE) and **grab on recovery**. Wrong build (no AoE/orbit + no grabs) faces denser trash waves and a tougher fight.

## Export

Presets in `export_presets.cfg`:

```bash
# HTML5
godot4 --headless --export-release "HTML5" export/web/index.html

# Windows
godot4 --headless --export-release "Windows Desktop" export/windows/ArcadeGame.exe
```

Requires Godot 4.3 export templates installed (`Editor → Manage Export Templates`).

## Project layout

See `systems/`, `actors/`, `scenes/`, `data/` — modules kept small (GDScript). `player_index` on Rook is reserved for future co-op (unused in MVP).
