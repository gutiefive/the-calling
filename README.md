# The Calling

A story-driven, top-down pixel-art RPG made in **Godot 4.7**. You play a young pastor who arrives in
the fictional town of **Oakridge** to lead **Grace Community Church**.

> **Status (2026-11-13):** Milestone 12 is playable, plus Gameplay A–F (inventory through the connected weekly loop). Chapter 1 still plays
> start to finish. Choices leave hidden leanings and story threads, and a per-save seed varies small town texture.
> After Chapter 1 you can Continue in Oakridge and keep a weekly loop. A suggested path, including two contrasting
> runs, is in `docs/PLAYTEST.md`. Inventory and shop notes are in `docs/GAMEPLAY_LOOPS.md`.

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
| Interact | E. Talk to people and inspect objects. The prompt names who or what you are using. Doors and street exits are walk-in; they show the place name with no E. |
| Advance dialogue / confirm a choice | E, Space, or Enter. The first press finishes a line that is still revealing. |
| Move the dialogue selection | Up / Down, or W / S, while choices are on screen. |
| Journal | J. Esc closes it. Early on, a note names the lane east to Oak Street. |
| Town map | M. Esc closes it. Also the Map row on the pause menu. It shows the church grounds, the sanctuary, Oak Street, the parsonage, Maple Lane, the hardware store, Frank's bay, and where you are. |
| Pause | Esc, when the journal, the map, and the ledger are closed. Up / Down or W / S choose. E, Space, or Enter confirms Resume, Save, Load, or Map. |
| Church ledger | L, after Chapter 1. Esc or L closes it. Dollar amounts live here. |
| Inventory | I. Esc or I closes it. Arrows or WASD move the highlight. E equips a tool or prepares a seed packet. The wallet prints here. |
| Hardware shop | E on the shelves inside Thomas's store. E buys. Esc closes. Prices print here, not in talk. |
| Garden | Face a grass tile inside the church garden fence. The corner marker shows the cell. Hoe tills, a prepared seed plants, watering can waters, E harvests when ready. Sleep advances a watered crop. |
| Equipped tool | 1 / 2 / 3 pick among tools you are carrying. A small strip at the bottom left names the current tool. |
| Skip to the next part of the day | T (debug). Day starts at 6:00, evening at 5:00, night at 8:00. On Sunday before 10:00 a.m., T lands on 10:00. |
| Sleep | E on the bed in the parsonage. The morning card closes with E, Space, or Enter. |
| Title, sermon choice, and chapter ending | Up / Down or W / S choose. E, Space, or Enter confirms. The ending offers Continue in Oakridge, Restart, and Quit. |

The clock in the top right advances while you walk: four in-game minutes each real second.
It holds still during dialogue, the journal, the inventory, the shop, the morning card, pause, and the chapter ending. It starts Thursday at 2:00 p.m.
Changing rooms fades briefly. Until you continue past the ledger, the clock stops on Sunday night, and sleeping on Sunday does not add a Monday.
Continue in Oakridge keeps the story and lets sleep and the clock run into Monday, then a repeating week. Later Sundays at ten run a short service, then the ledger.

Walk up the path into the church. Stand near Margaret or the notice board and press E.
You cannot walk while a conversation, the journal, the inventory, the shop, the morning card, the town map, the ledger, the Sunday service, or the chapter ending is open.

Margaret's spare key ring is the first quest. Harold is in the sanctuary on Thursday.
The east side of the lot walks to Oak Street. A sign and a path point that way. Oak Street is a two-lane road with sidewalks: a cottage, the post office, Bright's Diner, the hardware store, an alley, a barber, a for-lease shop, and Frank's bay, then a park and creek. The bridge sign opens onto Maple Lane. Walk into the store and the bay. They are open while Thomas or Frank is inside, and a shut door says when to come back. During those hours they are behind the counter, not also on the sidewalk. A few neighbors wander the sidewalks. Thursday, Friday, and Saturday each have one small moment you can find by looking around. The church walk can be tidied, the Maple Lane garden can be cleared and replanted, and after Chapter 1 continues the church grounds have weeds, litter, a picnic flower bed, and a tired garden fence you can mend with Basic Hand Tools. None of that is required for Sunday.
The parsonage is on the church grounds. The bed sleeps until morning and shows a short card of things you might do.
J lists the current objective, a Requests section for community asks, a short gathering line after Continue, a Threads section in words, and under The church, a few words for how the week feels. I opens the pack. L opens the ledger after Chapter 1. Save and Load are on the pause menu. There is one slot, version 11.
A version 1, 2, 3, 4, 5, 6, 7, 8, or 9 save still loads. Starter tools are in the parsonage toolbox. Starter seeds sit in a crate in the church vegetable garden, east of the picnic lawn. Equip the Hoe and till the open ground inside the fence; a facing-tile marker shows which cell E will act on. The Maple Lane plot is still the Chapter 1 weeds. After Chapter 1 continues, Sarah, Margaret, Harold, and Ruth can ask for help through dialogue. Harold's fence is a job you do yourself with wood, nails, and Basic Hand Tools. After the hall is repaired, Wednesday late morning is a potluck in the Fellowship Hall; prep is optional. Thomas's shelves sell seed, wood, and nails from a personal wallet, not the church books. On Sunday at 10:00 a.m., go into the sanctuary for the service.
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
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m6a2/m6a2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m7/m7_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m8/m8_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m9/m9_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m9b/m9b_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m10/m10_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m11/m11_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m11b/m11b_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m11c/m11c_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/m12/m12_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpa/gpa_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpb/gpb_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpc/gpc_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpc2/gpc2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpd/gpd_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpd2/gpd2_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpe/gpe_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/gpf/gpf_validation.tscn
godot --headless --path C:\Users\natha\Projects\the-calling res://tests/toolchain/toolchain_test.tscn --quit-after 5
```

The manual list is `docs/PLAYTEST.md`. Named character sheets live in `assets/characters/` and are rebuilt by `tools/art/author_sprites.gd`. Outdoor tiles, church-lot props, and Oak Street buildings are rebuilt by `tools/art/author_environment.gd`. Item icons are rebuilt by `tools/art/author_items.gd`. Garden soil and crop frames are rebuilt by `tools/art/author_crops.gd`. Repair stages are rebuilt by `tools/art/author_repairs.gd`. Potluck tables and dishes are rebuilt by `tools/art/author_potluck.gd`. Unnamed townsfolk and interior furniture still come from `scripts/art/placeholder_art.gd`.

## Layout

```
scenes/main.tscn                     title screen (New Game / Continue / Quit)
scenes/world/church_exterior.tscn    grounds, with the walk to Oak Street
scenes/world/sanctuary.tscn          interior, Sunday service, ledger
scenes/world/fellowship_hall.tscn    walk-in hall after repair; Wednesday potluck
scenes/world/hardware_street.tscn    Oak Street: the main street, shops, park, creek, Maple Lane
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
data/story/                          named story threads for the journal
data/items/                          item catalog, shop prices, starter grants
data/interactions/                   the spare key ring
scripts/interactions/                interactable, walk-in door, one-line speech, dialogue, key ring, item pickup, shop
scripts/dialogue/                    conversation runner
scripts/systems/                     scene router, narrative state, day clock, schedules, save, funds, inventory, time of day
scripts/services/                    Sunday gathering in the sanctuary
scripts/world/                       room bootstrap, the church, Oak Street, Maple Lane, and the interiors
scripts/ui/                          prompt, dialogue box, journal, inventory, shop, hotbar, pause, town map, morning card, ledger, title, chapter ending, scene fade
assets/                              character sheets, outdoor tiles, church-lot props, and the master palette
tools/art/                           character and environment generators (see tools/art/README.md)
tools/generate_placeholders.py       draws the older placeholder pngs
tests/toolchain/                     environment smoke test (leave it)
tests/m1/                            milestone 1 checks and screenshot capture
tests/m2/                            milestone 2 checks
tests/m3/                            milestone 3 checks
tests/m4/                            milestone 4 checks
tests/m4_5/                          milestone 4.5 checks
tests/m5a/                           milestone 5A checks
tests/m5b/                           milestone 5B checks
tests/m6a/                           milestone 6A part 1 character-sheet checks
tests/m6a2/                          milestone 6A part 2 environment-art checks
tests/m7/                            milestone 7 checks
tests/m8/                            milestone 8 weekly loop, funds, and hall checks
tests/m9/                            milestone 9 branching, leanings, threads, and save v6
tests/m9b/                           milestone 9B walk-in doors
tests/gpa/                           Gameplay A inventory, wallet, shop, and save v7
tests/gpb/                           Gameplay B church garden and save v8
tests/gpc/                           Gameplay C community requests, in-ground tiles, and save v9
tests/gpc2/                          Gameplay C2 in-ground garden art
tests/gpd/                           Gameplay D interactive repairs and save v10
tests/gpd2/                          Gameplay D2 worksite art
tests/gpe/                           Gameplay E weekly potluck, action toasts, and save v11
tests/gpf/                           Gameplay F full-loop integration, polish, and DayClock budget
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
| `docs/GAMEPLAY_LOOPS.md` | Inventory architecture, item catalog, and the A–F gameplay plan |
| `docs/ENVIRONMENT_SETUP.md` | Tools, MCP, troubleshooting |
| `docs/The_Calling_Godot_Codex_Project_Brief.md` | Original brief (reference) |

## Display

- Viewport 640×360, window 1280×720, stretch `viewport`, scale `integer`.
- Default canvas texture filter is Nearest. 2D pixel snap is on.
- Renderer is Forward+.
- The follow camera does not smooth, and it is biased 96 px upward so the church front fits in frame. See `docs/DECISIONS.md`.

## Limitations

- The player, the five named townspeople, and Dell Ostrow use authored 32×48 sheets. Outdoor tiles, the church face, trees, benches, lamps, the notice board, and mailboxes are authored PNGs. Remaining buildings, sanctuary furniture, and unnamed townsfolk are still the original blockout drawn in code. There are no `.ase` sources yet.
- The notice board is still one line. There is no audio. I opens the pack. Open ground inside the church garden fence can be tilled, planted, watered, and harvested.
- One save slot, `user://the_calling_save.json`, version 11. A version 1, 2, 3, 4, 5, 6, 7, 8, 9, or 10 file loads. Esc, then Save or Load. Inner voice is a pause-menu toggle after Map. L opens the church ledger after Chapter 1. I opens the personal pack. J lists community requests after you accept them. Equip Basic Hand Tools and mend the west garden fence in short steps. After Continue, Wednesday in the Fellowship Hall is a potluck. New Game does not delete the slot. Restart on the chapter screen does.
- The clock enters Sunday and stops at Sunday 11:59 p.m. T is a debug skip. Before 10:00 a.m. on Sunday it stops at 10:00. A single frame never moves the clock more than one minute.
- The Sunday service and the chapter ending use the same confirm keys as dialogue. There is no settings menu, no text-speed slider, and no controller bindings.
- Unnamed congregants are placeholders. They do not speak. Named people use a seated bust during the service and their standing sheet afterward.
- The maps are painted when the scene starts, from the room scripts under `scripts/world/`.
- Named people walk between posts in the room you are in. Entering a room places them where the schedule already says. If the way is blocked, they are placed at the post.
- During open hours Thomas and Frank can stand on the Oak Street sidewalk and also appear behind the counter. The sidewalk post is the one their schedule uses.
- The town map is a sketch. It now includes the parsonage, Maple Lane, and the two shops.
- The Thursday flowers, Friday delivery, Saturday park, church-walk cleanup, and Maple Lane garden are optional. The chapter still ends from the ledger if you never find them.
- Sleep does not continue past this Sunday.
