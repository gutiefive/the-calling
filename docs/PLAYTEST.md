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
| T03 | Walk into the church wall, a tree, the bench, and a pew inside | The body stops. Walking into the south church door enters the sanctuary |
| T04 | Walk the grounds and the sanctuary | The camera follows, stays inside the map, and does not shake |
| T05 | Walk toward Margaret, the notice, and a door, then walk away | The `E  …` prompt appears only in range of people and objects. A door shows the place name with no E |
| T06 | Hold E, release, press E again | One line per press, not a stream of repeats. Doors do not use E |
| T07 | Walk into the sanctuary and walk back outside, several times | You arrive at the matching marker and do not bounce straight back through the door |
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
It checks sleep and the morning card, Maple Lane both ways and on the map, open and shut shops, the soft church words, the grounds and the garden, a chapter ending that skipped both jobs, Frank across Friday and Saturday, a current-version round trip, and a version 2 file migrating forward.
The M3 run still prints `Save is missing a version` before the check that rejects it. The M5A run prints `Save version 6 is not supported` before the check that rejects a newer file. Both suites then exit 0. Save files are version 5 as of M8.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T39 | From the church grounds, enter the parsonage and press E on the bed. Close the card with E | The screen fades. It is 6:00 a.m. the next morning, or this morning if you were already up. A card names the weekday and a few things you might do. Nothing on it is required. |
| T40 | On the first Sunday, before the chapter ending, sleep again | The clock stays on Sunday. It does not invent a Monday. After Continue, the same sleep reaches Monday. See T48. |
| T41 | Walk east on Oak Street to the bridge sign, then past it. Come back | The sign says the bridge is open. Maple Lane has houses, fences, a bus stop, and a garden. The banner names the lane. Walking back puts you on Oak Street. M shows the lane. |
| T42 | On Friday morning, walk into the hardware store and the bay. Press T until night and walk into the doors again | Thomas is at the counter in the morning, and the shelves can be read. Frank is in the bay. At night both doors stay shut and say when they open. |
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
It samples every named person on every weekday, including a second week, and checks that the schedule and the loaded rooms agree on at most one place. It continues past the ledger, sleeps through a full week into the next Monday, checks that a second Sunday morning before 10:00 still shows the quiet aisle note (the weekly service starts at 10:00; see T61), and round-trips a save on Friday of that second week. It also checks the shop-door lip, the named prompt, the fade, and Esc on the journal and the map.
The M3 run still prints `Save is missing a version` before the check that rejects it. The M5A run prints `Save version 6 is not supported` before the check that rejects a newer file. Both suites then exit 0. M3 now prints 109 checks because the Friday shop check looks inside and also asserts the sidewalk copies are hidden. Save files are version 5 as of M8.

## Manual

Launch with `godot --path .` from the repo, or press F5 in the editor.

| ID | Do this | Expect |
|---|---|---|
| T47 | On Friday morning, look at the hardware sidewalk, then enter the store and the bay | Thomas is behind the counter, not also outside. Frank is in the bay, not also on the walk. |
| T48 | Finish the ledger. Choose Continue in Oakridge. Sleep at the parsonage | You stay in town with the week you already lived. The next morning is Monday. Sleep again on each day, including the next Sunday. The clock keeps moving. |
| T49 | On a later Sunday morning before 10:00, enter the sanctuary | A note says the next chapter is still being written. The pews are not filled with the first Sunday's crowd. At 10:00 after Continue, see T61. |
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
It checks that the tileset PNG is 256×128 and palette-only, that `town_tiles.tres` loads, that each environment PNG exists at its placeholder size and uses only palette colors, that the church grounds, Oak Street, and Maple Lane boot with that TileSet, and that church and prop collisions are unchanged.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T53 | Walk the church grounds | Grass, path, and sidewalk tiles. The church face, trees, bench, lamp, notice, and mailbox are PNGs. You still cannot walk through them. |
| T54 | Walk Oak Street and Maple Lane | Road, curb, sidewalk, and the creek water tile. Oak Street shops use authored storefronts from M10. |

## M6A2 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m6a2/m6a2_validation.tscn` printed 128 `CHECK OK` lines and `M6A2_OK`, and exited 0. The same binary printed `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, and `TOOLCHAIN_OK`, each exiting 0. T53–T54 were not played in a window.

# Milestone 7 test plan

These checks cover hidden Pull, save v4, Chapter 1 seeds, Dell Ostrow, the inner voice, and the no-cult scan. Chapter 1 still plays start to finish.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
```

`m7_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M7_OK` or `M7_FAIL`.
It checks that InfluenceState starts at 0, that add_pull and the new dialogue conditions work, that Pull is not printed in the journal or HUD, that save v4 round-trips and v3 migrates, that each seed line and flag is present, that Ostrow's sheet is palette-only and wired with idle/walk, that Frank and Sarah's choices move Pull, that the no-cult scan passes, and that the ledger still ends Chapter 1.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T55 | Return the spare keys to Margaret | She still thanks you. She also mentions an old key that fits nothing, and that Pastor Reece kept it. |
| T56 | Talk to Margaret after the first Sunday | She still points to the ledger. She also says "Thank you, Shepherd," then corrects to Pastor. |
| T57 | Read the ledger | She still names the oil bill. She also names unrecognized deposits the week before a council vote. The chapter ending still opens. Continue in Oakridge still works. |
| T58 | Saturday daytime on the church walk | Councilman Dell Ostrow is there. He is friendly and a little too familiar. Pastor Reece and he "got a lot done together." |
| T59 | Talk to Ruth at the Maple Lane garden | She mentions Pastor Reece and how you learn who'll show up. |
| T60 | After the sermon, and on the pause menu | An italic thought may follow the sermon choice. Pause, Inner voice, toggles it. The journal and HUD never show Pull as a number. |

## M7 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m7/m7_validation.tscn` printed 93 `CHECK OK` lines and `M7_OK`, and exited 0. The same binary printed `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, and `M6A2_OK`, each exiting 0. T55–T60 were not played in a window. As of M8, the M5A run prints `Save version 6 is not supported` before the check that rejects a newer file, then exits 0.

# Milestone 8 test plan

These checks cover the weekly loop after Chapter 1, church funds, the ledger screen, and the Fellowship Hall repair. Chapter 1 still plays start to finish.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
```

`m8_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M8_OK` or `M8_FAIL`.
It checks seeded attendance and offering math, weekly expenses, none/half/all project contributions, hall completion and the exterior flip, save v5 round-trip plus v4 and v3 migration, that L opens the ledger, that dialogue has no `$` or dollar amounts, that Pull and trust are never numbers on screen, and that Chapter 1 still completes from the old ledger.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T61 | Finish Chapter 1. Choose Continue in Oakridge. Sleep through to the next Sunday. Enter the sanctuary at 10:00 | A short service offers hope, forgiveness, or service. Margaret may propose opening the Fellowship Hall. No dollar amounts in that talk. The ledger screen opens afterward. |
| T62 | On the ledger, send all, half, or none of the surplus to the hall. Press L later in the week | Dollars show here. The last weeks are listed. J does not show dollar amounts. Trust and Pull stay words. |
| T63 | Play 2–3 more weeks of talking, inviting, and Sundays. Fund the hall, then wait a week | Harold works on the hall. The boarded exterior becomes an open hall. He mentions a Wednesday potluck. |

## M8 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (74), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (128), `M7_OK` (93), and `M8_OK` (80), each exiting 0. `--quit-after 120` exited 0 with no script errors. T61–T63 were not played in a window. The M3 run still prints `Save is missing a version` before the check that rejects it. As of M9, the M5A and M8 runs print `Save version 7 is not supported` before the check that rejects a newer file.

# Milestone 9 test plan

The lists above still apply. These checks cover hidden leanings, story threads, a per-save run seed, and save v6.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
```

`m9_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M9_OK` or `M9_FAIL`.
It checks nudge / dominant logic, dialogue conditions and effects, a Shepherd playthrough vs a Builder playthrough, thread open / advance / miss, the journal Threads section, run-seed determinism, save v6 plus v5 / v4 / v3 migration, no "cult" in insider lines, no dollar amounts in dialogue, and that the default Chapter 1 path is unchanged.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T64 | Play Chapter 1 gently: listen to Frank, ask Sarah what the week needs, stay polite with Ostrow, preach hope. Open J after the spare keys. Continue into week 2 or 3. | Frank may later mention a porch light. Sarah's later line remembers the nursery. The journal Threads page is words, not numbers. A Friday neighbor on the church walk talks about sitting with someone rather than filling a pew. |
| T65 | New Game. Play Chapter 1 pushy: ask Frank to come Sunday, invite Sarah, welcome Ostrow's help, preach service. Continue into week 2 or 3. | Frank does not share the porch-light memory. Ostrow hints at people who like to see a church doing well, with no amounts. The Friday walk line is about a church that means to grow. Compare with T64; the two weeks should not feel identical. |

Leanings, Pull, and relationships stay hidden. Dollars stay on the ledger.

## M9 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (74), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (128), `M7_OK` (93), `M8_OK` (80), and `M9_OK` (105), each exiting 0. `--quit-after 120` exited 0 with no script errors. T64–T65 were not played in a window. The M3 run still prints `Save is missing a version` before the check that rejects it. The M5A, M8, and M9 runs print `Save version 7 is not supported` before the check that rejects a newer file.

# Milestone 9B test plan

The lists above still apply. These checks cover walk-in doors. E stays for talking and inspecting.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
```

`m9b_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M9B_OK` or `M9B_FAIL`.
It enumerates every scene door, walks in to the matching spawn, checks that arriving does not bounce, bumps a shut shop, keeps doors inert during dialogue and menus, and still talks with E.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T66 | Walk into the church, back out, east to Oak Street, into the store while it is open, and home to the parsonage. At night, walk into the store. Talk to Margaret with E. | Room changes happen on contact, with a short fade, and you do not ping-pong. The hover names the place. A shut shop stays put and says when it opens. E still talks. |

## M9B results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (128), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), and `M9B_OK` (156), each exiting 0. `--quit-after 120` exited 0 with no script errors. T66 was not played in a window. M1 gained two checks: walking in requests the sanctuary, and E on a door does not change rooms.

# Milestone 10 test plan

These checks cover the Oak Street redesign. The earlier lists still apply.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
godot --headless --path . res://tests/m10/m10_validation.tscn
godot --path . res://tests/m10/capture_oak.tscn
```

`m10_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M10_OK` or `M10_FAIL`.
It checks road, sidewalk, and curb tiles, that shop doors sit on the sidewalk, that buildings do not overlap the road, that Oak Street doors and spawns still route, that NPC posts are walkable, that the player cannot walk through a shop or a parked car, that camera limits contain the street, and that an old in-wall save snaps to a spawn.

`capture_oak.tscn` writes PNGs to `tests/m10/shots/` and needs a display.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T67 | Walk Oak Street from the church gate to the creek | A two-lane road, sidewalks, a crosswalk, storefronts on the sidewalk, Bright's Diner, parked cars, then the park and creek. About 20–30 seconds end to end. |
| T68 | Walk into the hardware store, Frank's bay, Maple Lane, and back to the church | The same doors as M9B, now at the new facades. Spawns sit outside the triggers. |

## M10 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), and `M10_OK` (91), each exiting 0 with zero `CHECK FAIL`, `SCRIPT ERROR`, or Parse Error. `--quit-after 120` exited 0. `tests/m10/capture_oak.tscn` wrote before and after shots under `tests/m10/shots/`. T67–T68 were not played in a window.

# Milestone 11 test plan

These checks cover Oak Street's south side and the Maple Lane rework. The earlier lists still apply.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
godot --headless --path . res://tests/m10/m10_validation.tscn
godot --headless --path . res://tests/m11/m11_validation.tscn
godot --path . res://tests/m11/capture_m11.tscn
```

`m11_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M11_OK` or `M11_FAIL`.
It checks south-side doors on the sidewalk, hanging-sign size, Maple house count and unique facades, garden tasks, door routes, NPC posts, collision, camera limits, and old-save snaps on both streets.

`capture_m11.tscn` writes PNGs to `tests/m11/shots/` and needs a display.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T69 | Walk Oak Street's south sidewalk from the church end to the boarded shop | Credit union, pharmacy, thrift, a parking strip, feed store, town hall, a pocket park, then a boarded shop. Signs readable at the normal camera. Walk into a door: a one-line closed message, no room change. |
| T70 | Walk Maple Lane from Oak Street to the far houses and tend the garden | A residential road, distinct houses, front yards, the garden behind a fence with a gate. House doors talk, they do not enter. Garden tasks still work. |

## M11 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), and `M11_OK` (202), each exiting 0 with zero `CHECK FAIL`, `SCRIPT ERROR`, or Parse Error. `--quit-after 120` exited 0. `tests/m11/capture_m11.tscn` wrote before and after shots under `tests/m11/shots/`. T69–T70 were not played in a window.

# Milestone 11B test plan

These checks cover the M11 polish: one name per shop, Maple Lane yards, and evening life. The earlier lists still apply.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
godot --headless --path . res://tests/m10/m10_validation.tscn
godot --headless --path . res://tests/m11/m11_validation.tscn
godot --headless --path . res://tests/m11b/m11b_validation.tscn
godot --path . res://tests/m11/capture_m11.tscn
godot --path . res://tests/m11b/capture_m11b.tscn
```

`m11b_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M11B_OK` or `M11B_FAIL`.
It checks one hanging sign per named storefront, Maple yard fill and collisions, evening and night ambient people, window lights, and that new text has no dollar amounts.

`capture_m11b.tscn` writes PNGs to `tests/m11b/shots/` and needs a display.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T71 | Walk Oak Street's south and north shops at the game camera | Each storefront shows its name once, on the storefront sign. Facades have windows and trim, not a second painted name. |
| T72 | Walk Maple Lane end to end, then press T to evening | Yards, hedges, a vacant lot with a for-sale sign, and a seventh house. Paths and doors stay open. Evening: a porch sitter on Maple, people near Bright's and a dog walker on Oak. Windows glow. |

## M11B results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), and `M11B_OK` (196), each exiting 0 with zero `CHECK FAIL`, `SCRIPT ERROR`, or Parse Error. `--quit-after 120` exited 0. `tests/m11/capture_m11.tscn` and `tests/m11b/capture_m11b.tscn` wrote after shots. T71–T72 were not played in a window.

# Milestone 11C test plan

These checks cover rooftop storefront signs and evening posts that no longer cover the letters. The earlier lists still apply.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
godot --headless --path . res://tests/m10/m10_validation.tscn
godot --headless --path . res://tests/m11/m11_validation.tscn
godot --headless --path . res://tests/m11b/m11b_validation.tscn
godot --headless --path . res://tests/m11c/m11c_validation.tscn
godot --path . res://tests/m11c/capture_m11c.tscn
```

`m11c_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M11C_OK` or `M11C_FAIL`.
It checks one rooftop sign per named storefront, that each sign sits above the door and misses the sidewalk in front, a minimum readable size, no hanging board in front of the entrance, and that evening townsfolk stand off the signs and doors.

`capture_m11c.tscn` writes PNGs to `tests/m11c/shots/` and needs a display.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T73 | Walk Oak Street's north and south shops at the game camera | Each storefront shows its name once, on a rooftop / parapet board. Doors and the sidewalk in front of them stay clear. |
| T74 | Press T to evening on Oak Street, walk Hardware and Bright's | Neighbors stand to the side on the sidewalk. They do not cover the letters or block the doors. |

## M11C results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), and `M11C_OK` (246), each exiting 0 with zero `CHECK FAIL`, `SCRIPT ERROR`, or Parse Error. `--quit-after 120` exited 0. `tests/m11c/capture_m11c.tscn` wrote after shots under `tests/m11c/shots/`. T73–T74 were not played in a window.

# Milestone 12 test plan

The lists above still apply. These checks cover the church grounds campus: perimeter and gate, courtyard, expansion plots, and the Fellowship Hall still swapping looks.

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
godot --headless --path . res://tests/m7/m7_validation.tscn
godot --headless --path . res://tests/m8/m8_validation.tscn
godot --headless --path . res://tests/m9/m9_validation.tscn
godot --headless --path . res://tests/m9b/m9b_validation.tscn
godot --headless --path . res://tests/m10/m10_validation.tscn
godot --headless --path . res://tests/m11/m11_validation.tscn
godot --headless --path . res://tests/m11b/m11b_validation.tscn
godot --headless --path . res://tests/m11c/m11c_validation.tscn
godot --headless --path . res://tests/m12/m12_validation.tscn
godot --path . res://tests/m12/capture_grounds.tscn
```

`m12_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M12_OK` or `M12_FAIL`.
It checks the fence except at the gates, that the east drive meets a sidewalk, that doors sit on the path network, that expansion plots load from data with number-free inspect lines, that the Fellowship Hall still swaps worn and repaired looks, that spawns stay outside door triggers, that NPC posts are walkable, that walls and cars still block, that the camera fits the new bounds, and that an old save inside the church snaps to a valid spawn.

`capture_grounds.tscn` writes PNGs to `tests/m12/shots/` and needs a display.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T75 | Walk the grounds from the Oak Street gate to the sanctuary, hall, and parsonage | One main gate, a courtyard in front of the church, connected paths, no floating buildings. |
| T76 | Read the monument sign and a staked lot | The sign says Grace Community Church. A plot says something quiet and has no dollars. |
| T77 | Press T through evening and night | Lamps and windows glow warm. The campus stays readable. |

## M12 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), and `M12_OK` (165), each exiting 0 with zero `CHECK FAIL`, `SCRIPT ERROR`, or Parse Error. `--quit-after 120` exited 0. `tests/m12/capture_grounds.tscn` wrote before and after shots under `tests/m12/shots/`. T75–T77 were not played in a window.

# Gameplay A — Inventory and items

The lists above still apply. These checks cover the pack, the personal wallet, the hardware shop, starter grants, and save v7.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpa/gpa_validation.tscn
godot --path . res://tests/gpa/capture_gpa.tscn
```

`gpa_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPA_OK` or `GPA_FAIL`.
It checks add / remove / stack limits / capacity / invalid items, wallet vs ChurchFunds, shop purchase and overspend, starter grants firing exactly once, save/load, and version-6 migration.

`capture_gpa.tscn` writes PNGs to `tests/gpa/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T78 | Walk into the parsonage. E on the toolbox, then I | Watering Can, Hoe, and Basic Hand Tools are in the pack. The wallet shows $20. Taking the crate again does nothing. |
| T79 | Walk to the church vegetable garden crate (east of the picnic lawn), E, then I | Four seed packets are in the pack. The Maple Lane Chapter 1 weeds are still there until you tend that plot. |
| T80 | Walk into the hardware store. E on the shelves. Buy wood. Try to buy with too little cash | The wallet drops. Wood is in the pack. Overspend is refused. Thomas's talk still has no prices. |
| T81 | Esc, Save, Load | The pack and wallet come back. Church ledger money is unchanged. |

## Gameplay A results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPA_OK` with zero `CHECK FAIL` (the expected `Save version 8 is not supported` push_error before the newer-save rejection, matching M8/M9). Every existing suite still printed its `_OK` line and exited 0: `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, `M6A2_OK`, `M7_OK`, `M8_OK`, `M9_OK`, `M9B_OK`, `M10_OK`, `M11_OK`, `M11B_OK`, `M11C_OK`, `M12_OK`. `--quit-after 120` exited 0. `tests/gpa/capture_gpa.tscn` wrote `inventory_ui.png` and `shop_ui.png` under `tests/gpa/shots/`. T78–T81 were not played in a window.

# Gameplay B — Gardening

The lists above still apply. These checks cover the church vegetable garden, overnight growth, harvest, Chapter 1 Maple Lane flags, and save v8.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpb/gpb_validation.tscn
godot --path . res://tests/gpb/capture_gpb.tscn
```

`gpb_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPB_OK` or `GPB_FAIL`.
It checks the till / plant / water / grow / harvest cycle for every crop, wrong tool and missing seed, unwatered pause, seed use and yield, no Pull / attendance / ChurchFunds change, Chapter 1 garden flags, save/load, and version-7 migration.

`capture_gpb.tscn` writes PNGs to `tests/gpb/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

Exact walkthrough:

1. New Game. Walk into the parsonage. E on the toolbox. I, highlight the Hoe, E to equip. Esc.
2. From the courtyard, walk south onto the picnic lawn, then east into the fenced garden. E on Ruth's card if you want the five steps.
3. E on the seed crate. I, highlight Lettuce Seeds, E to prepare them. Esc.
4. Stand on an untilled bed. E tills. E plants. Equip the Watering Can (1/2/3 or I then E). E waters.
5. Walk home. E on the bed. Close the morning card. The watered lettuce has grown. Water again, sleep again. E harvests into the pack.
6. Leave an unwatered bed overnight: it waits. Equip the Hoe on a planted bed: it explains and does nothing.
7. Esc, Save, Load. The beds are as you left them. The Maple Lane weeds still need the Chapter 1 neighbor to plant.

| ID | Do this | Expect |
|---|---|---|
| T82 | Church garden, Hoe, E on an empty bed | Soil tills. Prompt becomes Plant. |
| T83 | Prepare lettuce seeds, E on tilled soil, water, sleep twice | Harvests 1 Lettuce. Wallet and church books unchanged. |
| T84 | Plant without watering, sleep | Crop is still there, not grown. |
| T85 | Maple Lane garden plot, E | Weeds clear. It still wants the neighbor's seed. Church beds did not change that flag. |

## Gameplay B results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPB_OK` with zero `CHECK FAIL` (the expected `Save version 9 is not supported` push_error before the newer-save rejection). Every existing suite still printed its `_OK` line and exited 0: `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, `M6A2_OK`, `M7_OK`, `M8_OK`, `M9_OK`, `M9B_OK`, `M10_OK`, `M11_OK`, `M11B_OK`, `M11C_OK`, `M12_OK`, `GPA_OK`. `--quit-after 120` exited 0. `tests/gpb/capture_gpb.tscn` wrote `garden_day.png`, `shop_ui.png`, and `inventory_ui.png` under `tests/gpb/shots/`. T82–T85 were not played in a window.

# Gameplay C — Community requests

The lists above still apply. These checks cover optional asks, the journal, in-ground church garden tiles, Maple Lane flags, and save v9.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpc/gpc_validation.tscn
godot --path . res://tests/gpc/capture_gpc.tscn
```

`gpc_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPC_OK` or `GPC_FAIL`.
It checks unlock and accept for each request, the 3-active limit, item tracking and delivery, missing-item failure, no duplicate rewards, completion and history, expiry, no Pull / attendance / ChurchFunds change, Ruth's Maple Lane flags, save/load, version-8 bed-to-tile migration, tilling arbitrary tiles, and rejecting reserved tiles.

`capture_gpc.tscn` writes PNGs to `tests/gpc/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

Exact walkthrough:

1. Finish Chapter 1 and choose Continue in Oakridge (or load a continued save).
2. Walk into the parsonage. E on the toolbox. I, highlight the Hoe, E to equip.
3. Walk south to the picnic lawn, then east into the fenced garden. A corner marker shows the tile you face. E tills grass. I, prepare Lettuce Seeds, E plants. Equip the Watering Can, E waters (the soil darkens). The path, gate, crate, and Ruth's card do not till.
4. Sleep twice, watering each morning. E harvests into the pack. Grow carrots the same way until you have 2 Lettuce and 2 Carrots.
5. Find Sarah on Oak Street (morning) or Maple Lane (afternoon). She asks for vegetables. Accept. J shows the ask, the counts, and where to return. Talk to her again to deliver. The pack loses exactly those crops. The wallet may tick up. Church books do not.
6. Talk to Margaret about flowers, Harold about wood and nails (buy at Thomas's shelves if needed), and Ruth on Maple Lane about the community plot. At most three asks at once. Ruth wants the Maple Lane weeds and the neighbor's seed, not the church garden.
7. After Harold, look at the garden fence: a patched stretch. After Margaret, the sanctuary east window has flowers. Esc, Save, Load. The asks and tiles are as you left them.

| ID | Do this | Expect |
|---|---|---|
| T86 | After Continue, talk to Sarah, accept, J | Journal lists Fresh for the Table, 0/2 Lettuce, where to return. No quest marker in the world. |
| T87 | Deliver lettuce and carrots to Sarah | Pack loses those crops. Wallet may rise. Pull, attendance, and the ledger do not. |
| T88 | Hoe a grass tile inside the church garden fence, then the path by the crate | Grass tills. The path refuses. A facing marker shows the cell. |
| T89 | Accept four asks | The fourth person says you're already busy. |
| T90 | Maple Lane garden after accepting Ruth's ask | Weeds and the neighbor still set `garden_planted`. Church tiles do not. |

## Gameplay C results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPC_OK` (123 `CHECK OK`) with zero `CHECK FAIL` (the expected `Save version 10 is not supported` push_error before the newer-save rejection). Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125). `--quit-after 120` exited 0. `tests/gpc/capture_gpc.tscn` wrote `garden_day.png`, `journal_requests.png`, and `request_dialogue.png` under `tests/gpc/shots/`. T86–T90 were not played in a window.

# Gameplay C2 — Garden and journal polish

The lists above still apply. These checks cover dirt tiles, crop readability, journal sections, and garden props.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpc2/gpc2_validation.tscn
godot --path . res://tests/gpc2/capture_gpc2.tscn
```

`gpc2_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPC2_OK` or `GPC2_FAIL`.
It checks dry vs watered soil, neighbor blending, crop-stage bounding boxes, journal empty-copy per section, the area label hiding while J is open, and garden props staying off the path and gate.

`capture_gpc2.tscn` writes PNGs to `tests/gpc2/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T91 | Till a 3×3 patch in the church garden | One dirt field, not a grid of boards. Watering darkens the patch. |
| T92 | Grow lettuce, carrot, tomato, and flower to harvest | Each crop is readable at sprout. Late stages fill the tile. Tomatoes climb a stake. |
| T93 | Accept Sarah's ask with no story quest, press J | Requests lists the ask. Story says no active quests. "Church grounds" is not sitting on the panel. |
| T94 | Walk the garden path through the west gate | Barrel, wheelbarrow, compost, and bench are visible and do not block the path. |

## Gameplay C2 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPC2_OK` (101 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (123). `--quit-after 120` exited 0. `tests/gpc2/capture_gpc2.tscn` wrote `garden_patch.png` and `journal_open.png` under `tests/gpc2/shots/`. T91–T94 were not played in a window.

# Gameplay D — Interactive repairs

The lists above still apply. These checks cover worksites on the church grounds, the staged garden fence, Harold's ask, GroundsChore, and save v10.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpd/gpd_validation.tscn
godot --path . res://tests/gpd/capture_gpd.tscn
```

`gpd_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPD_OK` or `GPD_FAIL`.
It checks each repair type, fence stages and materials, the `Missing: 3 Wood` line, wrong-tool no-ops, Harold's ask with no double reward, GroundsChore and the Maple Lane plot, persistence, Pull / attendance / ChurchFunds staying put, and v9→v10 migration.

`capture_gpd.tscn` writes PNGs to `tests/gpd/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

Walkthrough: Continue in Oakridge (or load a week-continues save). Take the parsonage toolbox if you do not have Basic Hand Tools. Buy 3 Wood and 2 Nails at Thomas's shelves. Talk to Harold and accept The Broken Fence. Walk to the west garden fence, three tiles south of the gate (not the gate opening). Equip Basic Hand Tools (I, then E). Press E to pull the old boards, E to set the wood, E to nail them. If a stage is short, the line is `Missing: 3 Wood` or `Missing: 2 Nails`. Talk to Harold again for the scrap. Optional: clear picnic weeds, pick up the utility litter, restore the picnic flower bed. Sleep, leave the grounds, save and load: the fence stays finished. J still lists Harold until you talk to him after the job.

| ID | Do this | Expect |
|---|---|---|
| T95 | Equip Basic Hand Tools, E on the damaged garden fence with no wood | Boards come off. Next E prints `Missing: 3 Wood`. Pack unchanged. |
| T96 | Buy 3 Wood and 2 Nails, finish the three fence stages | Damaged, empty posts, new boards, then a finished stretch. Wood then nails leave the pack once. |
| T97 | Talk to Harold with the wood before mending, then after | He will not take the boards first. After the fence is set he thanks you once and you get one Scrap. |
| T98 | Hoe the fence, or E with no tool | Nothing is consumed. The fence stays as it was. |
| T99 | Clear Chapter 1 litter and the courtyard bed without tools | `grounds_tidy` still sets. Maple Lane weeds are still the Chapter 1 plot. |
| T100 | Sleep, leave, save, load after a finished fence | The finished stretch is still there. Pull, attendance, and the ledger do not move. |

## Gameplay D results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPD_OK` (145 `CHECK OK`) with zero `CHECK FAIL` (the expected `Save version 11 is not supported` push_error before the newer-save rejection). Every existing suite still printed its `_OK` line and exited 0: `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, `M6A2_OK`, `M7_OK`, `M8_OK`, `M9_OK`, `M9B_OK`, `M10_OK`, `M11_OK`, `M11B_OK`, `M11C_OK`, `M12_OK`, `GPA_OK`, `GPB_OK`, `GPC_OK`, `GPC2_OK`. `--quit-after 120` exited 0. `tests/gpd/capture_gpd.tscn` wrote `fence_damaged.png`, `fence_cleared.png`, `fence_new_wood.png`, `fence_finished.png`, `grounds_before.png`, and `grounds_after.png` under `tests/gpd/shots/`. T95–T100 were not played in a window.

# Gameplay D2 — Repair worksite art

The lists above still apply. These checks cover the 3-tile garden-fence stretch, clearer weed / litter / flower-bed stages, and save compatibility. No Phase E.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpd2/gpd2_validation.tscn
godot --path . res://tests/gpd2/capture_gpd2.tscn
```

`gpd2_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPD2_OK` or `GPD2_FAIL`.
It checks fence-stage pixel deltas, a 2+ tile stretch that does not overlap the garden gate, a walkable gate, weed / litter / bed before-and-after, and that RepairState flags and v9→v10 saves still work.

`capture_gpd2.tscn` writes PNGs to `tests/gpd2/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T101 | Stand at the west garden fence, south of the gate | A 3-tile broken stretch with posts, snapped rail, and splinters. Not a crate. The gate is still a path. |
| T102 | Pull boards, set wood, nail | Bare posts with a plank stack; pale new rails and a nail box; then a continuous fence, slightly lighter. |
| T103 | Clear picnic weeds, utility litter, and the picnic bed | Tall weeds become cut grass. Scattered trash vanishes and a bag sits by the bin. The bed blooms in more than one color. |
| T104 | Face a worksite with Basic Hand Tools | The sprite warms slightly. `E  …` is the prompt. No extra markers. |

## Gameplay D2 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPD2_OK` (100 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (156), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148). `--quit-after 120` exited 0. `tests/gpd2/capture_gpd2.tscn` wrote fence stages plus weeds / litter / bed before-and-after under `tests/gpd2/shots/`. T101–T104 were not played in a window.

# Gameplay E — Weekly potluck

The lists above still apply. These checks cover the Fellowship Hall gathering, optional prep, Sarah's framing, small action toasts, and save v11. No Phase F.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpe/gpe_validation.tscn
godot --path . res://tests/gpe/capture_gpe.tscn
```

`gpe_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPE_OK` or `GPE_FAIL`.
It checks unlock timing, each prep category, skip and recurrence, no-prep vs full-prep visuals, both framing branches, no Pull for success, no duplicate rewards, Sunday / M8 / Chapter 1 isolation, save/load, and v10→v11. Toasts must last at most 1.5s, replace in place, and ignore the mouse.

`capture_gpe.tscn` writes PNGs to `tests/gpe/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

| ID | Do this | Expect |
|---|---|---|
| T105 | Till, water, or pick up an item | A small one-line toast at the bottom-left, about a second, then gone. Walking still works. A new line replaces the old one. Dialogue boxes are unchanged. |
| T106 | Continue, repair the hall, wait for Harold's celebration, walk in on Wednesday after 11 | Margaret, Harold, and Sarah are at a modest table. No extra guests, flowers, lights, or extra chairs if you skipped prep. |
| T107 | Deliver Sarah vegetables, set sanctuary flowers, tend the grounds, restore the picnic bed, and invite Ostrow, Ruth, and Dale | Varied dishes, centerpieces, lights, extra chairs, and those three neighbors. |
| T108 | Talk to Sarah after the hall is repaired | Two unlabeled framings: open to everyone, or church-centered. The journal does not print Pull or a score. |
| T109 | Skip Wednesday, then come back the next Wednesday | The gathering is there again. One attendance note per week. |
| T110 | Save on Wednesday, load, then go to Sunday | The hall state survives. Sunday service and the Chapter 1 ending are unchanged. |

## Gameplay E results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPE_OK` (131 `CHECK OK`) with zero `CHECK FAIL` (the expected `Save version 12 is not supported` push_error before the newer-save rejection). Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK`, `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100). `--quit-after 120` exited 0. `tests/gpe/capture_gpe.tscn` wrote `toast_till.png`, `potluck_none.png`, `potluck_full.png`, and `sarah_choice.png` under `tests/gpe/shots/`. T105–T110 were not played in a window.

# Gameplay F — Integration, polish, and the full loop

The lists above still apply. These checks cover the connected A–E loop, DayClock budget, balance review, HUD and worksite polish, Dale and Ruth, and save v11. No sanctuary or Fellowship Hall interior redesign.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/gpf/gpf_validation.tscn
godot --path . res://tests/gpf/capture_gpf.tscn
```

`gpf_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `GPF_OK` or `GPF_FAIL`.
It walks the full loop (inventory, seeds, till, plant, water, sleep, growth, harvest, a request, shop materials, repair, potluck prep and attendance, save, load, continue), the DayClock walking budget, toast vs prompt overlap, no automatic Pull / attendance / ChurchFunds, no duplicate rewards, Ruth's Maple Lane ask vs the church garden, and Dale / Ruth sheets.

`capture_gpf.tscn` writes PNGs to `tests/gpf/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual

Walkthrough: Continue in Oakridge. Take the parsonage toolbox and the church-garden seed crate. Equip the Hoe, till, plant, water. Sleep two or three mornings. Harvest. Talk to Sarah and deliver vegetables. Buy 3 Wood and 2 Nails. Mend the west garden fence. Optional: picnic weeds, utility litter, picnic bed. On Wednesday 11:00–16:00 walk into the Fellowship Hall. Save, quit, load, keep walking. The toast stays in the bottom-left gutter and does not cover `E  …`. Dale and Ruth should not look like the generic sidewalk neighbors.

| ID | Do this | Expect |
|---|---|---|
| T111 | Till with the prompt showing | The toast is bottom-left. It never covers `E  Till`. It fades in about a second. |
| T112 | Clear picnic weeds and look from the path | Cut stubble on the lawn, not a light-green rectangle on the pavement. |
| T113 | Pick up utility litter | Trash sits on the ground with no green mat. A bag is by the bin after. |
| T114 | Restore the picnic bed, then step back | Blooms read from a distance. Several colors. |
| T115 | Look at Dale and Ruth on Maple Lane | Distinct from each other and from unnamed townsfolk. |
| T116 | Plant the church garden, then talk to Ruth about her ask | Her ask still wants the Maple Lane plot, not the church tiles. |

## Gameplay F results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `GPF_OK` (119 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131). `--quit-after 120` exited 0. `tests/gpf/capture_gpf.tscn` wrote `garden_growth_toast.png`, `picnic_after.png`, `litter_after.png`, `fence_repaired.png`, `dale_ruth.png`, and `loop_end.png` under `tests/gpf/shots/`. T111–T116 were not played in a window.

# Milestone 13 — Sanctuary and Fellowship Hall interiors

The lists above still apply. These checks cover the multi-room sanctuary and Fellowship Hall, ambient neighbors, flavor props, and the old gameplay hooks.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13/m13_validation.tscn
godot --path . res://tests/m13/capture_m13.tscn
```

`m13_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13_OK` or `M13_FAIL`.
It checks every room is reachable from the entrance, doors and spawns sit outside collision, each flavor prop answers, ambient neighbors stay off doorways, Sunday service still starts, the ledger still appears, Margaret's flowers still appear, the potluck still shows prep differences and Sarah's framing, M8 and the Chapter 1 ending stay in place, and save stays v11.

`capture_m13.tscn` writes PNGs to `tests/m13/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`.

## Manual walkthrough

From the courtyard, walk into the sanctuary. You arrive in the narthex. Read the guest book and the bulletin. Walk north up the aisle into the worship hall: pews, a runner, stained-glass color on the carpet, the cross, the piano. Margaret's flowers sit by the east window after that ask. Take the north hallway into the pastor's office (the ledger is on the desk), the prayer room, the choir (spare keys on the stacked chairs), and storage. The restroom door does not open. Walk back out to the grounds.

After the hall is repaired, walk into the Fellowship Hall. The main room has tables and a coffee station. The kitchen is north, with a serving window into the hall. The classroom has a chalkboard. Storage holds folding tables. On Wednesday 11:00–16:00 the potluck still fills the main hall. Sunday at 10:00 the sanctuary still holds the service.

| ID | Do this | Expect |
|---|---|---|
| T117 | Walk the sanctuary from the narthex to the office, prayer room, choir, and storage | Every doorway is readable. Nothing blocks the aisle. |
| T118 | Read the guest book, bulletin, piano, stained glass, and office sketch | Short lines. No dollars. The sketch is only a drawing of extra wings. |
| T119 | Sunday 10:00 in the worship hall | The service still runs. People sit in the pews. The ledger is in the office afterward. |
| T120 | Walk the Fellowship Hall kitchen, classroom, and storage | Wood or tile floors. The potluck tables are in the main hall. |
| T121 | Wednesday potluck with and without prep | Modest table vs dishes, centerpieces, lights, extra chairs, extra guests. Sarah's two framings still exist. |

## M13 results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13_OK` (189 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131), `GPF_OK` (119). `--quit-after 120` exited 0. `tests/m13/capture_m13.tscn` wrote `sanctuary_worship.png`, `sanctuary_narthex.png`, `sanctuary_office.png`, `sanctuary_prayer.png`, `sanctuary_overview.png`, `fellowship_main.png`, `fellowship_potluck.png`, `fellowship_kitchen.png`, `fellowship_classroom.png`, and `fellowship_overview.png` under `tests/m13/shots/`. T117–T121 were not played in a window.

# Milestone 13B — Furniture and clutter density

The lists above still apply. These checks cover denser rooms, right-sized Fellowship Hall, aisle light, and the old gameplay hooks.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13b/m13b_validation.tscn
godot --path . res://tests/m13b/capture_m13b.tscn
```

`m13b_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13B_OK` or `M13B_FAIL`.
It checks a minimum decorative-prop count and a maximum bare-floor ratio per room, every room still reachable, doorways and the aisle clear, interactables and spawn/NPC posts not inside collision, Sunday seating anchors on pew rows, potluck prep still swaps, and save stays v11.

`capture_m13b.tscn` writes PNGs to `tests/m13b/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`. Shots: both overviews, worship hall, narthex, office, prayer room, choir, storage, fellowship main (normal day), fellowship potluck, kitchen, classroom.

## Manual walkthrough

Walk the sanctuary. The narthex and north rooms should feel furnished, not empty. Colored light should sit on the center aisle. Sit through Sunday: people still occupy the pews. After Continue, walk the Fellowship Hall on a Monday and on Wednesday potluck. Tables are out on a normal day; potluck still adds dishes, flowers, lights, extra chairs, and guests.

| ID | Do this | Expect |
|---|---|---|
| T122 | Walk narthex, worship, office, prayer, choir, storage | Furniture is character-scale. Doorways and the aisle stay open. |
| T123 | Stand in the worship aisle at midday | Soft stained-glass color on the runner, not only under the windows. |
| T124 | Sunday 10:00 | Service still runs. Named people and twelve congregants sit in the pews. Ledger still in the office afterward. |
| T125 | Fellowship Hall on a weekday | Round and long tables, stage, kitchen island, classroom cubbies. Not a bare wood floor. |
| T126 | Wednesday potluck with full prep | Dishes, centerpieces, lights, extra chairs, extra guests still swap. Sarah's two framings still exist. |

## M13B results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13B_OK` (310 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK`, `M2_OK`, `M3_OK`, `M4_OK`, `M4_5_OK`, `M5A_OK`, `M5B_OK`, `M6A_OK`, `M6A2_OK`, `M7_OK`, `M8_OK`, `M9_OK`, `M9B_OK`, `M10_OK`, `M11_OK`, `M11B_OK`, `M11C_OK`, `M12_OK`, `M13_OK`, `GPA_OK`, `GPB_OK`, `GPC_OK`, `GPC2_OK`, `GPD_OK`, `GPD2_OK`, `GPE_OK`, `GPF_OK`. `--quit-after 120` exited 0. `tests/m13b/capture_m13b.tscn` wrote `sanctuary_worship.png`, `sanctuary_narthex.png`, `sanctuary_office.png`, `sanctuary_prayer.png`, `sanctuary_choir.png`, `sanctuary_storage.png`, `sanctuary_overview.png`, `fellowship_main.png`, `fellowship_potluck.png`, `fellowship_kitchen.png`, `fellowship_classroom.png`, and `fellowship_overview.png` under `tests/m13b/shots/`. T122–T126 were not played in a window.

# Milestone 13C — Fellowship Hall tables and main-hall fill

The lists above still apply. These checks cover readable banquet and round tables, chairs, walkways, and the potluck still dressing Table A/B.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13c/m13c_validation.tscn
godot --path . res://tests/m13c/capture_m13c.tscn
```

`m13c_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13C_OK` or `M13C_FAIL`.
It checks table and chair counts, that table sprites are not rugs and have a shadow/legs layer, rugs do not swallow table footprints, 2-tile walkways from the door to the stage / kitchen / hallway / interactables, spawn and NPC posts stay clear, potluck dishes sit on table tops with and without prep, and save stays v11.

`capture_m13c.tscn` writes PNGs to `tests/m13c/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`. Shots: fellowship main (normal day, close), fellowship overview, potluck no-prep, potluck full-prep.

## Manual walkthrough

After Continue, walk the Fellowship Hall on a Monday. Tables should read as furniture, not rugs. Walk the center aisle to the hallway, then to the stage and the kitchen pass-through. On Wednesday, a modest table is already a gathering; full prep puts dishes on the tops.

| ID | Do this | Expect |
|---|---|---|
| T127 | Stand in the Fellowship main hall on a weekday | Round tables look round. Long tables have cloth, a lip, legs, and a shadow. Chairs sit at every table. |
| T128 | Walk from the south door to the stage, kitchen window, and hallway | Paths stay at least two tiles wide. Nothing blocks a door or an interactable. |
| T129 | Look at the floor | Rugs are a cooler color than the tables and are not stacked under every table. |
| T130 | Wednesday potluck with no prep, then with full prep | Food sits on the banquet tables. Modest stays modest. Full prep still adds dishes, flowers, lights, extra chairs, and guests. |

## M13C results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13C_OK` (177 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `M13_OK` (189), `M13B_OK` (318), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131), `GPF_OK` (119). `--quit-after 120` exited 0. `tests/m13c/capture_m13c.tscn` wrote `fellowship_main.png`, `fellowship_overview.png`, `potluck_none.png`, and `potluck_full.png` under `tests/m13c/shots/`. T127–T130 were not played in a window.

# Milestone 13D — Fellowship Hall final polish

The lists above still apply. These checks cover larger tables, purposeful rugs, room zones, potluck guests in the close camera, and a finishing pass on the kitchen, classroom, storage, and hallway.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13d/m13d_validation.tscn
godot --path . res://tests/m13d/capture_m13d.tscn
```

`m13d_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13D_OK` or `M13D_FAIL`.
It checks zone prop minimums, table size and chair counts, a center aisle runner with no floating rugs, 2-tile walkways, door and interactable reachability, spawn/NPC/potluck posts off collision, invited guests and extra chairs inside the close camera around tables A/B on full prep, dishes on tabletops, and save stays v11.

`capture_m13d.tscn` writes PNGs to `tests/m13d/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`. Shots: fellowship main (normal day, close), fellowship overview, potluck full-prep, potluck no-prep, kitchen, classroom, sitting corner, stage area, hallway.

## Manual walkthrough

After Continue, walk the Fellowship Hall on a Monday. The close camera should show banquet tables with cloth and chairs, a runner down the aisle, and furnished corners rather than empty floor. On Wednesday with full prep, invited neighbors and extra chairs should be visible at tables A and B without walking south.

| ID | Do this | Expect |
|---|---|---|
| T131 | Stand in the Fellowship main hall on a weekday | Long tables look four tiles long. Chair backs face north, seats face south. The aisle has a runner, not scattered blue rectangles. |
| T132 | Walk the sitting corner, coffee station, kids' corner, stage, and piano | Each zone has its furniture. Walkways stay two tiles. Every door still opens. |
| T133 | Walk the kitchen, classroom, storage, and hallway | Backsplash and a window over the sink. Alphabet strip and a patterned rug. Labeled bins. Hallway photos, a runner, and the lost-and-found. |
| T134 | Wednesday potluck with no prep, then with full prep | Guests and extra chairs are in the close view at tables A/B. Food sits on the tops. Lights span the hall. Modest stays modest. |

## M13D results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13D_OK` (181 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `M13_OK` (203), `M13B_OK` (360), `M13C_OK` (182), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131), `GPF_OK` (119). `--quit-after 120` exited 0. `tests/m13d/capture_m13d.tscn` wrote `fellowship_main.png`, `fellowship_overview.png`, `potluck_full.png`, `potluck_none.png`, `kitchen.png`, `classroom.png`, `sitting_corner.png`, `stage_area.png`, and `hallway.png` under `tests/m13d/shots/`. T131–T134 were not played in a window.

# Milestone 13E — Church interiors gameplay polish

The lists above still apply. These checks cover a finished sanctuary (taller north rooms, pews, altar, stained-glass light) and Fellowship Hall fixes (muted runner, larger kids' corner, coffee in the close camera, south tables readable).

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13e/m13e_validation.tscn
godot --path . res://tests/m13e/capture_m13e.tscn
```

`m13e_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13E_OK` or `M13E_FAIL`.
It checks north-room heights, worship pews/altar/pulpit/stained-glass light, a muted warm aisle runner, kids' corner size, coffee inside the starting close camera, 2-tile walkways, door and interactable reachability, spawn/NPC/Sunday/potluck spots off collision, the office ledger, and save stays v11.

`capture_m13e.tscn` writes PNGs to `tests/m13e/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`. Shots: worship close, worship overview, narthex, office, prayer room, choir room, storage, fellowship main close, fellowship kids corner, potluck full-prep.

## Manual walkthrough

After Continue, walk the sanctuary on a weekday. The north rooms should feel like rooms, not a strip. Pews should show end caps. Color from the windows should fall on the aisle. In the Fellowship Hall, the runner should be a quiet warm strip, coffee should be visible from the door, and the kids' corner should look like a place to sit.

| ID | Do this | Expect |
|---|---|---|
| T135 | Walk the sanctuary narthex, worship hall, office, prayer room, choir, and storage | North rooms are deep enough to turn around in. The altar has cloth. Pews have ends and hymnals. The ledger still opens in the office. |
| T136 | Stand in the worship aisle at day | Stained-glass color pools on the runner. Pendant lights and sconces keep the hall from going flat. |
| T137 | Enter the Fellowship Hall and stand at the south door | Coffee is in the close view. The runner is muted and warm. The south tables are fully on screen. |
| T138 | Walk the kids' corner, then Wednesday with full prep | Play rug, small table, chairs, toys, and drawings. Potluck guests still stand at tables A/B in the close camera. |

## M13E results

On 2026-11-13, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13E_OK` (207 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `M13_OK` (223), `M13B_OK` (384), `M13C_OK` (182), `M13D_OK` (181), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131), `GPF_OK` (119). `--quit-after 120` exited 0 with no `CHECK FAIL`, `SCRIPT ERROR`, or `Parse Error`. `tests/m13e/capture_m13e.tscn` wrote `worship_close.png`, `worship_overview.png`, `narthex.png`, `office.png`, `prayer_room.png`, `choir_room.png`, `storage.png`, `fellowship_main.png`, `fellowship_kids.png`, and `potluck_full.png` under `tests/m13e/shots/`. T135–T138 were not played in a window.

# Milestone 13F — Interior rough-spot patch

The lists above still apply. These checks cover softer aisle stained-glass light, a kids' corner visible on Fellowship Hall entry, and wall-decor layering.

## Automated

```powershell
godot --headless --path . --import
godot --headless --path . res://tests/m13f/m13f_validation.tscn
godot --path . res://tests/m13f/capture_m13f.tscn
```

`m13f_validation.tscn` prints `CHECK OK` / `CHECK FAIL` lines and exits with `M13F_OK` or `M13F_FAIL`.
It checks aisle stain-pool alpha and aisle light energy under a soft threshold, the kids' corner inside the starting close camera on entry, wall-decor rects that do not overlap each other or sit on the wrong layer, 2-tile walkways, reachability, spawn/NPC/Sunday/potluck spots off collision, and save stays v11.

`capture_m13f.tscn` writes PNGs to `tests/m13f/shots/` and needs a display. It skips with `CAPTURE_SKIPPED` under `--headless`. Shots: worship close, worship overview, fellowship main (starting view), fellowship kids corner, potluck full-prep.

## Manual walkthrough

Walk the sanctuary aisle at day. Colored light should tint the runner without turning into bright blobs. Enter the Fellowship Hall from the grounds: the kids' corner should already be on screen, east of the door, with drawings on the south wall.

| ID | Do this | Expect |
|---|---|---|
| T139 | Stand in the worship aisle at day, close camera then overview | Soft stained-glass color on the runner. Still readable from the overview. Not bright patches. |
| T140 | Enter the Fellowship Hall and stand at the south door | The kids' corner (rug, table, chairs, toys, books, wall drawings) is in the close view. Coffee, the door, and walkways stay clear. |
| T141 | Look at kids' corner wall drawings, the north trophy wall, and the classroom alphabet strip | Wall decor sits on the wall. No overlapping trim or stacked strips. |
| T142 | Wednesday with full prep | Potluck guests still stand at tables A/B in the close camera. Walkways stay two tiles. |

## M13F results

On 2026-11-14, `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` exited 0. The same binary then printed `M13F_OK` (459 `CHECK OK`) with zero `CHECK FAIL`. Every existing suite still printed its `_OK` line and exited 0: `M1_OK` (76), `M2_OK` (113), `M3_OK` (109), `M4_OK` (90), `M4_5_OK` (90), `M5A_OK` (103), `M5B_OK` (1491), `M6A_OK` (219), `M6A2_OK` (130), `M7_OK` (93), `M8_OK` (80), `M9_OK` (105), `M9B_OK` (176), `M10_OK` (91), `M11_OK` (210), `M11B_OK` (196), `M11C_OK` (246), `M12_OK` (165), `M13_OK` (223), `M13B_OK` (384), `M13C_OK` (182), `M13D_OK` (181), `M13E_OK` (207), `GPA_OK` (204), `GPB_OK` (125), `GPC_OK` (126), `GPC2_OK` (101), `GPD_OK` (148), `GPD2_OK` (100), `GPE_OK` (131), `GPF_OK` (119). `--quit-after 120` exited 0 with no `CHECK FAIL`, `SCRIPT ERROR`, or `Parse Error`. `tests/m13f/capture_m13f.tscn` wrote `worship_close.png`, `worship_overview.png`, `fellowship_main.png`, `fellowship_kids.png`, and `potluck_full.png` under `tests/m13f/shots/`. T139–T142 were not played in a window.


