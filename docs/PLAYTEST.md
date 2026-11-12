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
