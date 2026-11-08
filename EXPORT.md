# Export guide

Godot **4.3** templates required (`Editor → Manage Export Templates`, or install `4.3.stable` templates under `~/.local/share/godot/export_templates/`).

Presets are defined in `export_presets.cfg`.

```bash
mkdir -p export/web export/windows

# HTML5 / Web
godot4 --headless --path . --export-release "HTML5" export/web/index.html

# Windows Desktop (.exe, pck embedded)
godot4 --headless --path . --export-release "Windows Desktop" export/windows/ArcadeGame.exe
```

Smoke-tested in this environment: both presets export successfully (Web WASM + Windows x86_64 exe).
