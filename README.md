# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**, a congregation that has shrunk
from over 200 members to 17.

> **Status (2026-11-11):** development environment set up and verified. **No gameplay has been built yet.**
> The next step is Milestone 1 (see `docs/DEVELOPMENT_ROADMAP.md`), started only when Nathan says go.

## Quick start (Windows)

```powershell
# Open the project in the Godot editor (this also starts the Beckett MCP server on 127.0.0.1:8770)
godot --editor --path C:\Users\natha\Projects\the-calling

# Open the project in Cursor
cursor C:\Users\natha\Projects\the-calling

# Headless import / parse check
godot --headless --path C:\Users\natha\Projects\the-calling --import

# Toolchain smoke test (prints TOOLCHAIN_OK and exits)
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

`godot` is a shim at `C:\Tools\Godot\4.7.2\godot.cmd` (on your user PATH) that runs the console build.

## Documents

| File | Purpose |
|---|---|
| `AGENTS.md` | Standing instructions for AI agents (Claude in Cursor) |
| `docs/GAME_DESIGN.md` | Condensed game design (source: the original brief) |
| `docs/ART_BIBLE.md` | Visual style, sprite sizes, palette, camera, lighting, asset rules |
| `docs/DEVELOPMENT_ROADMAP.md` | Milestones M1–M5 |
| `docs/ENVIRONMENT_SETUP.md` | Installed tools, MCP servers, how to reconnect, troubleshoot, reproduce |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Copy of the original master brief (reference) |

## Layout

```
assets/   source/ (editable .ase), characters/, environments/, tilesets/, ui/, audio/
scenes/   player/, npcs/, world/, interiors/, ui/
scripts/  core/, systems/, resources/
tests/    toolchain/ (environment smoke test only)
addons/   beckett/ (Beckett Lite MCP editor plugin, MIT)
```

## Display settings (project.godot)

- Base viewport 640×360, window 1280×720, stretch mode `viewport`, scale mode `integer` (pixel-perfect).
- Default canvas texture filter = Nearest.
- 2D transform and vertex snapping to pixel enabled (revisit after M1 camera tests if smooth movement jitters).
- Renderer: Forward+ (2D lights and shadows supported; switch to Compatibility later if low-end hardware needs it).
