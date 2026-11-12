# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**.

> **Status (2026-11-12):** Milestone 4.5 is playable. The demo still runs from the title screen through the
> first Sunday. Oak Street is easier to find, and the town has more to wander through between Thursday and Sunday.
> A suggested path is in `docs/PLAYTEST.md`.

## Play (Windows)

```powershell
godot --path C:\Users\natha\Projects\the-calling
```

That opens the title screen: `scenes/main.tscn`. New Game starts on the church grounds, Thursday at 2:00 p.m.
Continue appears when `user://the_calling_save.json` exists. In the editor, open the project and press F5.

`godot` is `C:\Tools\Godot\4.7.2\godot.cmd` (console build, on the user PATH).

## Controls

| Action | Keys |
|---|---|
| Move | W A S D or arrow keys. Diagonals are normalized. |
| Interact | E |
| Advance dialogue / confirm a choice | E, Space, or Enter. The first press finishes a line that is still revealing. |
| Move the dialogue selection | Up / Down, or W / S, while choices are on screen. |
| Journal | J. Early on, a note names the lane east to Oak Street. |
| Town map | M. Also the Map row on the pause menu. It shows the church grounds, the sanctuary, Oak Street, and where you are. |
| Pause | Esc. Up / Down or W / S choose. E, Space, or Enter confirms Resume, Save, Load, or Map. |
| Skip to the next part of the day | T (debug). Day starts at 6:00, evening at 5:00, night at 8:00. On Sunday before 10:00 a.m., T lands on 10:00. |
| Title, sermon choice, and chapter ending | Up / Down or W / S choose. E, Space, or Enter confirms. |

The clock in the top right advances while you walk: four in-game minutes each real second.
It holds still during dialogue, the journal, pause, and the chapter ending. It starts Thursday at 2:00 p.m.
and runs through Sunday night.

Walk up the path to the church. Stand near Margaret or the notice board and press E.
You cannot walk while a conversation, the journal, the town map, the Sunday service, or the chapter ending is open.

Margaret's spare key ring is the first quest. Harold is in the sanctuary on Thursday.
The east side of the lot walks to Oak Street. A sign and a path point that way. The street has the hardware store, Frank's bay, a cottage, a park, a creek bank, and a short lane that stops at a gate. A few neighbors wander the sidewalk. Thursday, Friday, and Saturday each have one small moment you can find by looking around. None of them is required for Sunday.
J lists the current objective. Save and Load are on the pause menu. There is one slot, version 2.
A version 1 save still loads. On Sunday at 10:00 a.m., go into the sanctuary for the service.
After it, talk to Margaret. The ledger is on the west table and ends the chapter.

## Checks

```powershell
godot --headless --path C:\Users\natha\Projects\the-calling --import
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m1/m1_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m2/m2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m3/m3_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m4/m4_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m4_5/m4_5_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

The manual list is `docs/PLAYTEST.md`. Placeholder sprites are drawn in code by `scripts/art/placeholder_art.gd` when a room starts.

## Layout

```
scenes/main.tscn                     title screen (New Game / Continue / Quit)
scenes/world/church_exterior.tscn    grounds, with the walk to Oak Street
scenes/world/sanctuary.tscn          interior, Sunday service, ledger
scenes/world/hardware_street.tscn    Oak Street: shops, park, creek, gated lane
scenes/actors/player.tscn
scenes/ui/hud.tscn
scripts/actors/                      player, prop collision
data/dialogue/                       weekday lines, the Sunday service, follow-ups, and the ledger
data/schedules/week.json             where each of them stands, by day and time, including Sunday
data/quests/                         quest titles and objectives
data/interactions/                   the spare key ring
scripts/interactions/                interactable, door, one-line speech, dialogue, key ring
scripts/dialogue/                    conversation runner
scripts/systems/                     scene router, narrative state, day clock, schedules, save, time of day
scripts/services/                    Sunday gathering in the sanctuary
scripts/world/                       room bootstrap and the three layouts
scripts/ui/                          prompt, dialogue box, journal, pause, town map, title, chapter ending
assets/                              png placeholders and the master palette
tools/generate_placeholders.py       draws those pngs
tests/toolchain/                     environment smoke test (leave it)
tests/m1/                            milestone 1 checks and screenshot capture
tests/m2/                            milestone 2 checks
tests/m3/                            milestone 3 checks
tests/m4/                            milestone 4 checks
tests/m4_5/                          milestone 4.5 checks
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
| `docs/PLAYTEST.md` | Automated commands, the T01–T38 checklist, and a path through the demo |
| `docs/ENVIRONMENT_SETUP.md` | Tools, MCP, troubleshooting |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Original brief (reference) |

## Display

- Viewport 640×360, window 1280×720, stretch `viewport`, scale `integer`.
- Default canvas texture filter is Nearest. 2D pixel snap is on.
- Renderer is Forward+.
- The follow camera does not smooth, and it is biased 96 px upward so the church front fits in frame. See `docs/DECISIONS.md`.

## Limitations

- Art is an original blockout drawn in code when the scene starts, not final illustration. There are no `.ase` sources yet. The Oak Street buildings and Thomas, Frank, and Sarah are the same kind of placeholder.
- The notice board is still one line. There is no inventory or audio. The hardware store and the bay are exteriors only.
- One save slot, `user://the_calling_save.json`, version 2. A version 1 file loads and gains an empty sermon theme. Esc, then Save or Load. New Game does not delete the slot. Restart on the chapter screen does.
- The clock enters Sunday and stops at Sunday 11:59 p.m. T is a debug skip. Before 10:00 a.m. on Sunday it stops at 10:00. A single frame never moves the clock more than one minute.
- The Sunday service and the chapter ending use the same confirm keys as dialogue. There is no settings menu, no text-speed slider, and no controller bindings.
- Unnamed congregants are placeholders. They do not speak. Named people use a seated bust during the service and their standing sheet afterward.
- The maps are painted when the scene starts, from `scripts/world/church_exterior.gd`, `scripts/world/sanctuary.gd`, and `scripts/world/hardware_street.gd`.
- Named people walk between posts in the room you are in. Entering a room places them where the schedule already says. If the way is blocked, they are placed at the post.
- The town map is a sketch of three places. Maple Lane does not open onto another scene yet.
- The Thursday flowers, Friday delivery, and Saturday park are optional. The chapter still ends from the ledger if you never find them.
