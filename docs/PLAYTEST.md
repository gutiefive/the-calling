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
| T23 | Skip to Saturday evening and talk to Margaret on the church walk | She names Sunday at ten. The week quest completes. T will not roll the clock into Sunday. |
| T24 | Esc, Save, walk into the sanctuary, Esc, Load | You are back where you saved, with the same quest, clock, and conversation flags. |
| T25 | Read `README.md` | Controls, the clock rate, and the one save slot match the build. |

## M3 results

On 2026-11-12, `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/m3/m3_validation.tscn` printed 108 `CHECK OK` lines and `M3_OK`, and exited 0. The same binary then printed `M1_OK` and `M2_OK`, each exiting 0. T18–T25 were not played in a window.
