# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**.

> **Status (2026-11-12):** Milestone 2 is playable. Walk the church grounds, talk to Margaret and Harold,
> finish the spare-key quest, and open the journal. There is still no clock and no save file.

## Play (Windows)

```powershell
godot --path C:\Users\natha\Projects\the-calling
```

That opens the main scene: `scenes/main.tscn`, which instances the church grounds.
In the editor, open the project and press F5.

`godot` is `C:\Tools\Godot\4.7.2\godot.cmd` (console build, on the user PATH).

## Controls

| Action | Keys |
|---|---|
| Move | W A S D or arrow keys. Diagonals are normalized. |
| Interact | E |
| Advance dialogue / confirm a choice | E, Space, or Enter. The first press finishes a line that is still revealing. |
| Move the dialogue selection | Up / Down, or W / S, while choices are on screen. |
| Journal | J |
| Pause | Esc |
| Cycle day / evening / night | T (debug) |

Walk up the path to the church. Stand near Margaret or the notice board and press E.
You cannot walk while a conversation or the journal is open. Esc still pauses.

Margaret's spare key ring is the first quest. Harold is in the sanctuary, by the west side of the pews.
The ring is on the stacked chairs. J lists the current objective. The sanctuary door still opens either way.

## Checks

```powershell
godot --headless --path C:\Users\natha\Projects\the-calling --import
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m1/m1_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m2/m2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

The manual list is `docs/PLAYTEST.md`. Placeholder sprites are drawn in code by `scripts/art/placeholder_art.gd` when a room starts.

## Layout

```
scenes/main.tscn                     launch scene
scenes/world/church_exterior.tscn    grounds
scenes/world/sanctuary.tscn          interior
scenes/actors/player.tscn
scenes/ui/hud.tscn
scripts/actors/                      player, prop collision
data/dialogue/                       Margaret and Harold, JSON
data/quests/                         quest titles and objectives
data/interactions/                   the spare key ring
scripts/interactions/                interactable, door, one-line speech, dialogue, key ring
scripts/dialogue/                    conversation runner
scripts/systems/                     scene router, narrative state, time of day
scripts/world/                       room bootstrap and the two layouts
scripts/ui/                          prompt, dialogue box, journal, pause
assets/                              png placeholders and the master palette
tools/generate_placeholders.py       draws those pngs
tests/toolchain/                     environment smoke test (leave it)
tests/m1/                            milestone 1 checks and screenshot capture
tests/m2/                            milestone 2 checks
```

## Documents

| File | Purpose |
|---|---|
| `AGENTS.md` | Standing instructions for AI agents |
| `docs/GAME_DESIGN.md` | Condensed game design |
| `docs/ART_BIBLE.md` | Palette, scale, lighting, asset rules |
| `docs/DEVELOPMENT_ROADMAP.md` | Milestones M0–M5 |
| `docs/ROADMAP.md` | Current cut line |
| `docs/DECISIONS.md` | M1 choices and open questions |
| `docs/PLAYTEST.md` | Automated commands and the T01–T10 checklist |
| `docs/ENVIRONMENT_SETUP.md` | Tools, MCP, troubleshooting |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Original brief (reference) |

## Display

- Viewport 640×360, window 1280×720, stretch `viewport`, scale `integer`.
- Default canvas texture filter is Nearest. 2D pixel snap is on.
- Renderer is Forward+.
- The follow camera does not smooth, and it is biased 96 px upward so the church front fits in frame. See `docs/DECISIONS.md`.

## Limitations

- Art is an original blockout drawn in code when the scene starts, not final illustration. There are no `.ase` sources yet. Harold and the key ring are the same kind of placeholder.
- The notice board is still one line. Margaret and Harold use the dialogue files. There is no inventory, sermon, or audio.
- Quest flags live in memory for the session. Relaunching clears them. There is no save file yet.
- Time of day is a debug cycle, not a clock. It resets to day when you relaunch.
- Esc pauses. There is no settings menu, no text-speed slider, and no controller bindings.
- The map is painted when the scene starts, from `scripts/world/church_exterior.gd` and `scripts/world/sanctuary.gd`.
