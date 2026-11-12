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

Not run yet. On 2026-11-12 the implementation session could not start a terminal, so Godot import, `m1_validation.tscn`, the 30-frame boot, and the screenshot capture were not executed. Do not treat T01–T10 as passed until those commands have been run and this section lists their output.
