# Milestone 1 test plan

Automated checks do not press keys in a real window. The manual list is still required.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . --quit-after 30
godot --path . res://tests/m1/capture_shots.tscn
```

`m1_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M1_OK` or `M1_FAIL`.
`--quit-after 30` boots `scenes/main.tscn` for 30 frames.
`capture_shots.tscn` writes PNGs to `tests/m1/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual (T01–T10)

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T01 | Launch the project | Church grounds, no missing-resource or script errors in the output |
| T02 | Hold W A S D and the arrow keys, including two at once, then let go | 8-way movement, diagonals no faster than straight lines, full stop on release |
| T03 | Walk into the church wall, a tree, the bench, and a pew inside | The body stops. The south church door and the sanctuary aisle can be walked up to the inner stopper |
| T04 | Walk the grounds and the sanctuary | The camera follows, stays inside the map, and does not shake |
| T05 | Walk toward Margaret, the notice, and a door, then walk away | The `E  …` prompt appears only in range |
| T06 | Hold E, release, press E again | One line (or one room change) per press, not a stream of repeats |
| T07 | Enter the sanctuary and step back outside, several times | You arrive at the matching marker and do not bounce straight back through the door |
| T08 | Press T | Day, evening, and night are visibly different. Night is dim but the path, the player, and the interior floor stay readable. The lamp and windows are obvious at night |
| T09 | Close the game and launch it again | You start outside, in daytime, at the front path |
| T10 | Read `README.md` | Run steps, controls, layout, and limitations match the build |

Esc pauses and resumes. That is the whole pause screen.

## Results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m1/m1_validation.tscn` printed 74 `CHECK OK` lines and `M1_OK`, and exited 0. Import of the project exited 0 with no script errors. T01–T10 were not played in a window. `capture_shots.tscn` was not run.

# Milestone 2 test plan

The M1 list above still applies. These checks cover dialogue, the spare-key quest, and the journal.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
```

`m2_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M2_OK` or `M2_FAIL`.
It drives the dialogue box with the input actions, walks both quest endings, and changes rooms through `SceneRouter`.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T11 | Talk to Margaret | Her name is on the panel. The line fills in. E, Space, or Enter finishes the line, then continues. |
| T12 | Reach her question. Press Up/Down or W/S, then confirm | The marker moves. One choice asks Harold. The other searches. Walking does nothing while the panel is open. |
| T13 | Press J, then J again | The journal lists The Spare Keys and the current objective, then closes. You can walk again. |
| T14 | Enter the sanctuary and leave | The quest is still active. J still shows it. |
| T15 | If you asked Harold, talk to him. Either way, take the ring on the stacked chairs and return it to Margaret | The quest completes. Her thanks is different if you asked Harold than if you searched. |
| T16 | Read the notice, then press Esc | The notice is still one line. Esc pauses and resumes. |
| T17 | Quit and launch again | You start outside, in daytime, with no quest and no flags. |

## M2 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m2/m2_validation.tscn` printed `M2_OK` and exited 0. The run covered both endings, a real sanctuary transition, the journal, and the movement lock. T11–T17 were not played in a window.

# Milestone 3 test plan

The M1 and M2 lists still apply. These checks cover the clock, Oak Street, schedules, relationships, the save file, and the week through Saturday.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
```

`m3_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M3_OK` or `M3_FAIL`.
It advances the clock, checks who is present at two times of day, walks to Oak Street and back, saves and loads after a scene change, and plays the week through Saturday evening.

A versionless dictionary is rejected on purpose. That call prints one engine error, then a `CHECK OK`.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T18 | Launch and look at the top of the screen | Thursday 2:00 PM, and the phase still says Day. Walk for a few seconds. The minutes move. Open dialogue or press Esc. The clock holds. |
| T19 | Press T | The clock jumps to 5:00 PM and the light becomes evening. T again is night, with the lamp brighter. Another T is Friday morning. |
| T20 | Finish the spare keys, then take the east side of the lot | You arrive on Oak Street, facing the street. Thomas is at the hardware store. The return puts you back on the church lot, facing into the grounds. |
| T21 | Talk to Frank. Choose to listen, then talk to him again. Load a different choice in a new game if you want the other line | His later line is different if you listened than if you invited him to Sunday. |
| T22 | Skip to Friday morning on Oak Street | Sarah is there. She is not there Thursday afternoon. |
| T23 | Skip to Saturday evening and talk to Margaret on the church walk. Press T from Saturday night | She names Sunday at ten. The week quest completes. Another T enters Sunday morning. |
| T24 | Esc, Save, walk into the sanctuary, Esc, Load | You are back where you saved, with the same quest, clock, and conversation flags. |
| T25 | Read `README.md` | Controls, the clock rate, and the one save slot match the build. |

## M3 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m3/m3_validation.tscn` printed `M3_OK` and exited 0. The Saturday-cap checks now expect Sunday morning (see `docs/DECISIONS.md` D20). The check count was not increased. The same binary then printed `M1_OK` and `M2_OK`, each exiting 0. T18–T25 were not played in a window.

# Milestone 4 test plan

The M1–M3 lists still apply. These checks cover Sunday, the service, the sermon, the ledger, the ending, and the title screen.

## A short way through the demo

Launch the project. Choose New Game.

1. Talk to Margaret. Either ask Harold or search. Bring her the spare key ring.
2. She sends you to Oak Street. Talk to Thomas, then Frank. Listen, or invite him. Both finish the errand.
3. Press T until Friday morning. Talk to Sarah on Oak Street.
4. Press T until Saturday evening. Talk to Margaret on the church walk. She names Sunday at ten.
5. Press T once for Sunday 6:00 a.m., and again for Sunday 10:00 a.m. Walk into the sanctuary.
6. Advance the service with E, Space, or Enter. Choose hope, forgiveness, or service.
7. Talk to Margaret, Harold, and whoever is still in the room. Their lines follow the sermon and, for Frank and Sarah, the earlier choice.
8. After Margaret, the ledger is on the west table. Read it.
9. The chapter screen summarizes the week. Restart from the beginning, or Quit.

Reading every line and using T for the long nights is the 15–20 minute path. Walking the clock without T takes longer than that. There is no audio.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
```

`m4_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M4_OK` or `M4_FAIL`.
It reaches Sunday 10:00, plays each sermon through the sanctuary UI, checks follow-up lines, reads the ledger through the chapter ending, restarts, and checks New Game, Continue, a version 2 save, and a version 1 migration.

M3 still prints one engine error on purpose when a versionless save is rejected.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor. The first screen is the title.

| ID | Do this | Expect |
|---|---|---|
| T26 | Launch | Title: New Game, Quit, and Continue only if a save exists. No script errors. |
| T27 | New Game. Press T from Saturday night, then again | Sunday 6:00 a.m., then Sunday 10:00 a.m. The grounds are morning light. |
| T28 | Enter the sanctuary at 10:00 | The service starts. E, Space, or Enter moves it. You cannot walk out of it. It ends on its own after the closing. |
| T29 | Count the room during the service | Margaret, Harold, Thomas, Frank, Sarah, and unnamed people in the pews. About seventeen, plus you at the front. |
| T30 | Replay, or load, and choose each sermon once | Hope, forgiveness, and service each change what Margaret and Harold say afterward. Frank and Sarah also change if Thursday or Friday went differently. |
| T31 | Talk to Margaret, then read the ledger on the west table | She names the oil bill. Harold answers. The chapter screen lists your choices and offers Restart or Quit. |
| T32 | Restart | Thursday 2:00 p.m. on the church grounds. No sermon, no quest, no relationships. Continue on a later launch does not restore the ending. |
| T33 | Save on Sunday, quit, launch, Continue | Same place, clock, sermon, and quests. The file is version 2. |

## M4 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m4/m4_validation.tscn` printed 90 `CHECK OK` lines and `M4_OK`, and exited 0. The same binary then printed `M1_OK`, `M2_OK`, and `M3_OK`, each exiting 0. A 30-frame boot of the title scene exited 0. T26–T33 were not played in a window.

# Milestone 4.5 test plan

The M1–M4 lists still apply. These checks cover the way to Oak Street, the wider street, people who move, and the optional days.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
godot --headless --path . res://tests/m4_5/m4_5_validation.tscn
```

`m4_5_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M4_5_OK` or `M4_5_FAIL`.
It checks the sign and the east path, the area name, the town map and the player marker, Margaret's walk and a blocked-path fallback, neighbor barks, each day's optional moment, a chapter ending that never found those moments, and a save that still round-trips at version 2.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T34 | New Game. Look east of the church, and press J | A path, arrows, and a sign toward Oak Street. The journal names that lane. The top of the screen says Church grounds when you arrive. |
| T35 | Press M. Walk. Press M again. Esc, then Map | A sketch of the church grounds, the sanctuary, and Oak Street, with a marker that moves with you. Esc or M closes it. |
| T36 | Walk the east path to Oak Street. Continue past the shops | You arrive facing the street. Farther east are a park, a creek bank, and a short lane with a sign about the bridge. |
| T37 | On Thursday, press T once while Margaret is on the grounds. Talk to a neighbor on Oak Street. Press T into evening, then night | Margaret walks to a new spot instead of vanishing on the spot. The neighbor has one line. Evening lights windows and leaves fewer people out. Night is quieter. |
| T38 | Find the flowers Thursday afternoon, the crates outside the store on Friday, and the park on Saturday morning. Skip all three on another run and still read the ledger | Each moment is a short conversation. Sunday still ends from the ledger if you never found them. |

## M4.5 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m4_5/m4_5_validation.tscn` printed 90 `CHECK OK` lines and `M4_5_OK`, and exited 0. The same binary then printed `M1_OK` (74 checks), `M2_OK`, `M3_OK`, and `M4_OK` (90 checks), each exiting 0. T34–T38 were not played in a window.

# Milestone 5A test plan

The earlier lists still apply. These checks cover sleep, Maple Lane, the shop interiors, church growth, the two optional jobs, and Frank's first longer conversation.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
godot --headless --path . res://tests/m4_5/m4_5_validation.tscn
godot --headless --path . res://tests/m5a/m5a_validation.tscn
```

`m5a_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M5A_OK` or `M5A_FAIL`.
It checks sleep and the morning card, Maple Lane both ways and on the map, open and shut shops, the soft church words, the grounds and the garden, a chapter ending that skipped both jobs, Frank across Friday and Saturday, a version 3 round trip, and a version 2 file migrating forward.
The M3 run still prints `Save is missing a version` before the check that rejects it. The M5A run prints `Save version 4 is not supported` before the check that rejects a newer file. Both suites then exit 0.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T39 | From the church grounds, enter the parsonage and press E on the bed. Close the card with E | The screen fades. It is 6:00 a.m. the next morning, or this morning if you were already up. A card names the weekday and a few things you might do. Nothing on it is required. |
| T40 | On the first Sunday, before the chapter ending, sleep again | The clock stays on Sunday. It does not invent a Monday. After Continue, the same sleep reaches Monday. See T48. |
| T41 | Walk east on Oak Street to the bridge sign, then past it. Come back | The sign says the bridge is open. Maple Lane has houses, fences, a bus stop, and a garden. The banner names the lane. The return door puts you back on Oak Street. M shows the lane. |
| T42 | On Friday morning, enter the hardware store and the bay. Press T until night and try the doors again | Thomas is at the counter in the morning, and the shelves can be read. Frank is in the bay. At night both doors stay shut and say when they open. |
| T43 | Press J after a sermon, and again after tidying the church walk | The church section uses words such as Strained, Steady, or Growing. It does not show a score. |
| T44 | Pick up the litter and tend the flower bed. On Maple Lane, clear the garden and talk to the neighbor about planting. Sleep to another morning | The walk looks tidier. The garden changes, then looks further along the next day. Skip both on another run and the ledger still ends the chapter. |
| T45 | After Thursday with Frank, visit the bay Friday morning, then again Friday afternoon or Saturday before 2:00. Choose to listen. On another run, press him about Sunday | The morning visit asks you to come back. Listening hears why he stopped. Sunday mentions that. Pressing him does not raise the relationship, and Sunday says so. |
| T46 | Save from the pause menu, quit, and Continue. Also load an older slot if you have one | Continue restores the room, the clock, and the work you did. A version 2 save still loads. |

## M5A results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m5a/m5a_validation.tscn` printed 103 `CHECK OK` lines and `M5A_OK`, and exited 0. The same binary printed `M1_OK` (74), `M2_OK` (113), `M3_OK` (108), `M4_OK` (90), and `M4_5_OK` (90), each exiting 0. T39–T46 were not played in a window. M5B later moved the M3 count to 109. See D36.

# Milestone 5B test plan

The earlier lists still apply. These checks cover one place per person, the week after Chapter 1, and the small fixes in that pass.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
godot --headless --path . res://tests/m4_5/m4_5_validation.tscn
godot --headless --path . res://tests/m5a/m5a_validation.tscn
godot --headless --path . res://tests/m5b/m5b_validation.tscn
```

`m5b_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M5B_OK` or `M5B_FAIL`.
It samples every named person on every weekday, including a second week, and checks that the schedule and the loaded rooms agree on at most one place. It continues past the ledger, sleeps through a full week into the next Monday, checks the quiet second Sunday, and round-trips a save on Friday of that second week. It also checks the shop-door lip, the named prompt, the fade, and Esc on the journal and the map.
The M3 run still prints `Save is missing a version` before the check that rejects it. The M5A run prints `Save version 4 is not supported` before the check that rejects a newer file. Both suites then exit 0. M3 now prints 109 checks because the Friday shop check looks inside and also asserts the sidewalk copies are hidden.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T47 | On Friday morning, look at the hardware sidewalk, then enter the store and the bay | Thomas is behind the counter, not also outside. Frank is in the bay, not also on the walk. |
| T48 | Finish the ledger. Choose Continue in Oakridge. Sleep at the parsonage | You stay in town with the week you already lived. The next morning is Monday. Sleep again on each day, including the next Sunday. The clock keeps moving. |
| T49 | On a later Sunday morning, enter the sanctuary | No sermon starts. A note says the next chapter is still being written. The pews are not filled with the first Sunday's crowd. |
| T50 | Stand near someone and read the prompt. Open the journal and the map. Press Esc for each | The prompt includes their name. Esc closes the journal. Esc closes the map. Neither press opens the pause menu. Walking into a new room fades briefly. |

## M5B results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m5b/m5b_validation.tscn` printed 1311 `CHECK OK` lines and `M5B_OK`, and exited 0. The same binary then printed `M1_OK` (74), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), and `M5A_OK` (103), each exiting 0. T47–T50 were not played in a window.

# Milestone 6A part 1 test plan

These checks cover the authored character sheets. The earlier lists still apply.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
godot --headless --path . res://tests/m4_5/m4_5_validation.tscn
godot --headless --path . res://tests/m5a/m5a_validation.tscn
godot --headless --path . res://tests/m5b/m5b_validation.tscn
godot --headless --path . res://tests/m6a/m6a_validation.tscn
```

`m6a_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M6A_OK` or `M6A_FAIL`.
It checks that each sheet exists, is 192×192, uses only master-palette colors, and that the player and five named people use SpriteFrames with idle and walk in four facings.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T51 | Walk the grounds and look at the pastor | A 32×48 sheet, four facings, idle and walk. Origin at the feet. Collision feels the same. |
| T52 | Look at Margaret, Harold, Thomas, Frank, and Sarah | Each has a distinct silhouette and color block. Walk plays when they move between posts. |

## M6A results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m6a/m6a_validation.tscn` printed 219 `CHECK OK` lines and `M6A_OK`, and exited 0. The same binary printed `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, and `TOOLCHAIN_OK`, each exiting 0. T51–T52 were not played in a window.

# Milestone 6A part 2 test plan

These checks cover the outdoor tileset and church-lot props. The earlier lists still apply.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m1/m1_validation.tscn
godot --headless --path . res://tests/m2/m2_validation.tscn
godot --headless --path . res://tests/m3/m3_validation.tscn
godot --headless --path . res://tests/m4/m4_validation.tscn
godot --headless --path . res://tests/m4_5/m4_5_validation.tscn
godot --headless --path . res://tests/m5a/m5a_validation.tscn
godot --headless --path . res://tests/m5b/m5b_validation.tscn
godot --headless --path . res://tests/m6a/m6a_validation.tscn
godot --headless --path . res://tests/m6a2/m6a2_validation.tscn
```

`m6a2_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M6A2_OK` or `M6A2_FAIL`.
It checks that the tileset PNG is 256×64 and palette-only, that `town_tiles.tres` loads, that each environment PNG exists at its placeholder size and uses only palette colors, that the church grounds, Oak Street, and Maple Lane boot with that TileSet, and that church and prop collisions are unchanged.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T53 | Walk the church grounds | Grass, path, and sidewalk tiles. The church face, trees, bench, lamp, notice, and mailbox are PNGs. You still cannot walk through them. |
| T54 | Walk Oak Street and Maple Lane | Road, curb, sidewalk, and the creek water tile. Shop buildings are still placeholders. |

## M6A2 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m6a2/m6a2_validation.tscn` printed 128 `CHECK OK` lines and `M6A2_OK`, and exited 0. The same binary printed `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, and `TOOLCHAIN_OK`, each exiting 0. T53–T54 were not played in a window.
