# AGENTS.md — Standing instructions for AI agents working on The Calling

You are working in a **Godot 4.7.2** project for an original, story-driven top-down pixel-art RPG.
The primary agent is Claude (Opus) inside Cursor. These rules persist across sessions.

## 1. Read first
1. `docs/GAME_DESIGN.md`, `docs/ART_BIBLE.md`, `docs/DEVELOPMENT_ROADMAP.md`.
2. The original brief `docs/The_Calling_Godot_Codex_Project_Brief.md` (Section 0 + current milestone are the contract).
3. `docs/ENVIRONMENT_SETUP.md` if a tool or MCP server misbehaves.

## 2. Scope discipline
- Work only on the milestone Nathan has approved. As of 2026-11-11 **no milestone is started**; environment only.
- Do not silently add dialogue frameworks, quest systems, inventory, economy, saving, combat, multiplayer,
  procedural generation, or weather before their milestone.
- Not a church tycoon/finance sim. People before numbers (see GAME_DESIGN pillars).
- Record decisions and open questions in `docs/GAME_DESIGN.md` → "Open decisions" (or a `docs/DECISIONS.md` once M1 starts).

## 3. Engineering rules
- **Typed GDScript** (`var speed: float = 80.0`, typed function signatures). No C#.
- Small, focused scenes and scripts; one responsibility each. Descriptive snake_case file names.
- Use `res://` paths only. No absolute Windows paths in code or scenes.
- Native 2D nodes: `TileMapLayer` (not the deprecated `TileMap`), `CharacterBody2D`, `Camera2D`,
  `PointLight2D`, `DirectionalLight2D`, `CanvasModulate`, `LightOccluder2D`, `NavigationAgent2D`.
- Defensive null checks; comments for non-obvious logic; externalize data (Resources/JSON) when it grows.
- Add an autoload only when cross-scene state truly needs it. `BeckettRuntime` is the MCP bridge; leave it.
- Keep the project Windows-compatible (paths, line endings handled by git, no shell-only tooling in game code).

## 4. Tools available (MCP)
- **beckett** (Godot editor, Streamable HTTP `http://127.0.0.1:8770/mcp`): requires the Godot editor to be open on this
  project. Use `get_scene_tree`, `read_script`, `validate_script` / `write_script` (validate-before-write),
  `open_scene` / `create_node` / `set_property` / `save_scene`, `play_scene` → `wait_until` → `logs_read` / `game_logs`
  → `screenshot`, `stop_scene`, and `doctor` for self-diagnosis. Lite edition: it can *see* the running game but not drive input.
- **libresprite** (pixel art, stdio `uvx libresprite-mcp`): requires LibreSprite running with the `mcp.js` script
  connected (see ENVIRONMENT_SETUP). Brittle by its author's own description: verify every result by re-reading the
  exported PNG.
- Terminal: `godot --headless --path . --import` and the toolchain smoke test (see README) are cheap validation.

## 5. Art and asset pipeline
- **Original art only.** Never copy or trace Pokémon, Graveyard Keeper, or any other game's assets. No AI image
  generation for production assets.
- Editable source in `assets/source/<category>/name.ase`; exported PNG in the matching `assets/<category>/` folder.
- 32×32 tiles; characters ~32×48; sprite sheets as horizontal strips or grids with a fixed cell size.
- PNGs import with Nearest filtering (project default). Do not enable mipmaps or filter on pixel art.
- Follow `docs/ART_BIBLE.md` for palette, lighting and consistency rules. Track licenses of any third-party asset.

## 6. Safety and secrets
- **Never commit or print tokens.** `.beckett/`, `.mcp.json`, `.cursor/mcp.json`, `.vscode/mcp.json` are gitignored
  because Beckett embeds its auth token in them. Use `.cursor/mcp.example.json` as the token-free template.
- Do not install paid tools/editions (Beckett Full, Aseprite) or enable API billing without Nathan's approval.
- Do not modify other projects or the global `~/.cursor/mcp.json`.

## 7. Verification
- Never claim something works without running it. After changes: headless import (no parse errors), run the scene,
  and when the editor is open use Beckett `play_scene` + `logs_read` + `screenshot`.
- Report what was actually tested vs. what still needs manual playtesting.
- Keep `tests/toolchain/` as the environment smoke test; game tests go elsewhere under `tests/`.
