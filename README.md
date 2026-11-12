# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**.

> **Status (2026-11-12):** Milestone 3 is playable. The week runs Thursday afternoon through Saturday night.
> Walk to Oak Street, meet Thomas, Frank, and Sarah, and save from the pause menu. Sunday service is not in yet.

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
| Pause | Esc. Up / Down or W / S choose. E, Space, or Enter confirms Resume, Save, or Load. |
| Skip to the next part of the day | T (debug). Day starts at 6:00, evening at 5:00, night at 8:00. |

The clock in the top right advances while you walk: four in-game minutes each real second.
It holds still during dialogue, the journal, and pause. It starts Thursday at 2:00 p.m. and stops
Saturday at 11:59 p.m. It does not roll into Sunday.

Walk up the path to the church. Stand near Margaret or the notice board and press E.
You cannot walk while a conversation or the journal is open.

Margaret's spare key ring is the first quest. Harold is in the sanctuary on Thursday.
The east side of the lot walks to Oak Street: the hardware store, Frank's bay, and a cottage.
J lists the current objective. Save and Load are on the pause menu. There is one slot.

## Checks

```powershell
godot --headless --path C:\Users\natha\Projects\the-calling --import
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m1/m1_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m2/m2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m3/m3_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

The manual list is `docs/PLAYTEST.md`. Placeholder sprites are drawn in code by `scripts/art/placeholder_art.gd` when a room starts.

## Layout

```
scenes/main.tscn                     launch scene
scenes/world/church_exterior.tscn    grounds, with the walk to Oak Street
scenes/world/sanctuary.tscn          interior
scenes/world/hardware_street.tscn    Oak Street: hardware store, auto bay, cottage
scenes/actors/player.tscn
scenes/ui/hud.tscn
scripts/actors/                      player, prop collision
data/dialogue/                       Margaret, Harold, Thomas, Frank, and Sarah
data/schedules/week.json             where each of them stands, by day and time
data/quests/                         quest titles and objectives
data/interactions/                   the spare key ring
scripts/interactions/                interactable, door, one-line speech, dialogue, key ring
scripts/dialogue/                    conversation runner
scripts/systems/                     scene router, narrative state, day clock, schedules, save, time of day
scripts/world/                       room bootstrap and the three layouts
scripts/ui/                          prompt, dialogue box, journal, pause
assets/                              png placeholders and the master palette
tools/generate_placeholders.py       draws those pngs
tests/toolchain/                     environment smoke test (leave it)
tests/m1/                            milestone 1 checks and screenshot capture
tests/m2/                            milestone 2 checks
tests/m3/                            milestone 3 checks
```

## Documents

| File | Purpose |
|---|---|
| `AGENTS.md` | Standing instructions for AI agents |
| `docs/GAME_DESIGN.md` | Condensed game design |
| `docs/ART_BIBLE.md` | Palette, scale, lighting, asset rules |
| `docs/DEVELOPMENT_ROADMAP.md` | Milestones M0–M5 |
| `docs/ROADMAP.md` | Current cut line |
| `docs/DECISIONS.md` | Choices and open questions |
| `docs/PLAYTEST.md` | Automated commands and the T01–T25 checklist |
| `docs/ENVIRONMENT_SETUP.md` | Tools, MCP, troubleshooting |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Original brief (reference) |

## Display

- Viewport 640×360, window 1280×720, stretch `viewport`, scale `integer`.
- Default canvas texture filter is Nearest. 2D pixel snap is on.
- Renderer is Forward+.
- The follow camera does not smooth, and it is biased 96 px upward so the church front fits in frame. See `docs/DECISIONS.md`.

## Limitations

- Art is an original blockout drawn in code when the scene starts, not final illustration. There are no `.ase` sources yet. The Oak Street buildings and Thomas, Frank, and Sarah are the same kind of placeholder.
- The notice board is still one line. There is no inventory, sermon, or audio. The hardware store and the bay are exteriors only.
- One save slot, `user://the_calling_save.json`, version 1. Esc, then Save or Load. Relaunching without loading starts Thursday at 2:00 p.m. again.
- The clock does not enter Sunday. T is a debug skip to the next light, not a wait-until-morning action. A single frame never moves the clock more than one minute.
- Esc opens the pause menu. There is no settings menu, no text-speed slider, and no controller bindings.
- The maps are painted when the scene starts, from `scripts/world/church_exterior.gd`, `scripts/world/sanctuary.gd`, and `scripts/world/hardware_street.gd`.
