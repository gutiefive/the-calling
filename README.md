# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**.

> **Status (2026-11-12):** Milestone 6A part 1 is playable. The player and the five named people use
> authored 32×48 sheets. Buildings and tiles are still the old placeholders. After the ledger you can stay
> in Oakridge. A suggested path is in `docs/PLAYTEST.md`.

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
| Interact | E. The prompt names who or what you are using. |
| Advance dialogue / confirm a choice | E, Space, or Enter. The first press finishes a line that is still revealing. |
| Move the dialogue selection | Up / Down, or W / S, while choices are on screen. |
| Journal | J. Esc closes it. Early on, a note names the lane east to Oak Street. |
| Town map | M. Esc closes it. Also the Map row on the pause menu. It shows the church grounds, the sanctuary, Oak Street, the parsonage, Maple Lane, the hardware store, Frank's bay, and where you are. |
| Pause | Esc, when the journal and the map are closed. Up / Down or W / S choose. E, Space, or Enter confirms Resume, Save, Load, or Map. |
| Skip to the next part of the day | T (debug). Day starts at 6:00, evening at 5:00, night at 8:00. On the first Sunday before 10:00 a.m., T lands on 10:00. |
| Sleep | E on the bed in the parsonage. The morning card closes with E, Space, or Enter. |
| Title, sermon choice, and chapter ending | Up / Down or W / S choose. E, Space, or Enter confirms. The ending offers Continue in Oakridge, Restart, and Quit. |

The clock in the top right advances while you walk: four in-game minutes each real second.
It holds still during dialogue, the journal, the morning card, pause, and the chapter ending. It starts Thursday at 2:00 p.m.
Changing rooms fades briefly. Until you continue past the ledger, the clock stops on Sunday night, and sleeping on Sunday does not add a Monday.
Continue in Oakridge keeps the story and lets sleep and the clock run into Monday, then a repeating week. Later Sunday mornings at the church are quiet.

Walk up the path to the church. Stand near Margaret or the notice board and press E.
You cannot walk while a conversation, the journal, the morning card, the town map, the Sunday service, or the chapter ending is open.

Margaret's spare key ring is the first quest. Harold is in the sanctuary on Thursday.
The east side of the lot walks to Oak Street. A sign and a path point that way. The street has the hardware store, Frank's bay, a cottage, a park, and a creek bank. The bridge sign past the shops opens onto Maple Lane. The store and the bay have doors. They are open while Thomas or Frank is inside, and a shut door says when to come back. During those hours they are behind the counter, not also on the sidewalk. A few neighbors wander the sidewalks. Thursday, Friday, and Saturday each have one small moment you can find by looking around. The church walk can be tidied, and the Maple Lane garden can be cleared and replanted. None of that is required for Sunday.
The parsonage is on the church grounds. The bed sleeps until morning and shows a short card of things you might do.
J lists the current objective and, under The church, a few words for how the week feels. Save and Load are on the pause menu. There is one slot, version 3.
A version 1 or version 2 save still loads. On Sunday at 10:00 a.m., go into the sanctuary for the service.
After it, talk to Margaret. The ledger is on the west table and ends the chapter. Continue keeps you in town. Restart returns to Thursday. Frank's longer story is at the bay on Friday and again before Saturday afternoon. You can skip it.

## Checks

```powershell
godot --headless --path C:\Users\natha\Projects\the-calling --import
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m1/m1_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m2/m2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m3/m3_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m4/m4_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m4_5/m4_5_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m5a/m5a_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m5b/m5b_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m6a/m6a_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

The manual list is `docs/PLAYTEST.md`. Named character sheets live in `assets/characters/` and are rebuilt by `tools/art/author_sprites.gd`. Buildings and tiles are still drawn in code by `scripts/art/placeholder_art.gd` when a room starts.

## Layout

```
scenes/main.tscn                     title screen (New Game / Continue / Quit)
scenes/world/church_exterior.tscn    grounds, with the walk to Oak Street
scenes/world/sanctuary.tscn          interior, Sunday service, ledger
scenes/world/hardware_street.tscn    Oak Street: shops, park, creek, the bridge
scenes/world/parsonage.tscn          the pastor's house
scenes/world/maple_lane.tscn         houses, the bus stop, the community garden
scenes/world/hardware_interior.tscn  Thomas's counter
scenes/world/bay_interior.tscn       Frank's bay
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
scripts/world/                       room bootstrap, the church, Oak Street, Maple Lane, and the interiors
scripts/ui/                          prompt, dialogue box, journal, pause, town map, morning card, title, chapter ending, scene fade
assets/                              character sheets, png placeholders, and the master palette
tools/art/                           character sheet generator (see tools/art/README.md)
tools/generate_placeholders.py       draws the older placeholder pngs
tests/toolchain/                     environment smoke test (leave it)
tests/m1/                            milestone 1 checks and screenshot capture
tests/m2/                            milestone 2 checks
tests/m3/                            milestone 3 checks
tests/m4/                            milestone 4 checks
tests/m4_5/                          milestone 4.5 checks
tests/m5a/                           milestone 5A checks
tests/m5b/                           milestone 5B checks
tests/m6a/                           milestone 6A character-sheet checks
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
| `docs/PLAYTEST.md` | Automated commands, the T01–T46 checklist, and a path through the demo |
| `docs/ENVIRONMENT_SETUP.md` | Tools, MCP, troubleshooting |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Original brief (reference) |

## Display

- Viewport 640×360, window 1280×720, stretch `viewport`, scale `integer`.
- Default canvas texture filter is Nearest. 2D pixel snap is on.
- Renderer is Forward+.
- The follow camera does not smooth, and it is biased 96 px upward so the church front fits in frame. See `docs/DECISIONS.md`.

## Limitations

- The player and the five named people use authored 32×48 sheets. Buildings, tiles, and unnamed townsfolk are still the original blockout drawn in code. There are no `.ase` sources yet.
- The notice board is still one line. There is no inventory or audio.
- One save slot, `user://the_calling_save.json`, version 3. A version 1 or version 2 file loads. Esc, then Save or Load. New Game does not delete the slot. Restart on the chapter screen does.
- The clock enters Sunday and stops at Sunday 11:59 p.m. T is a debug skip. Before 10:00 a.m. on Sunday it stops at 10:00. A single frame never moves the clock more than one minute.
- The Sunday service and the chapter ending use the same confirm keys as dialogue. There is no settings menu, no text-speed slider, and no controller bindings.
- Unnamed congregants are placeholders. They do not speak. Named people use a seated bust during the service and their standing sheet afterward.
- The maps are painted when the scene starts, from the room scripts under `scripts/world/`.
- Named people walk between posts in the room you are in. Entering a room places them where the schedule already says. If the way is blocked, they are placed at the post.
- During open hours Thomas and Frank can stand on the Oak Street sidewalk and also appear behind the counter. The sidewalk post is the one their schedule uses.
- The town map is a sketch. It now includes the parsonage, Maple Lane, and the two shops.
- The Thursday flowers, Friday delivery, Saturday park, church-walk cleanup, and Maple Lane garden are optional. The chapter still ends from the ledger if you never find them.
- Sleep does not continue past this Sunday.
