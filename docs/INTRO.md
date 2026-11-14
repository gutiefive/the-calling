# Opening intro — editing `data/intro.json`

New Game (and Restart from the chapter ending) plays `scenes/intro/intro_cutscene.tscn` before Thursday 2:00 p.m. on the church grounds. Continue and Load skip it. Lines, panel ids, and the goals/primer copy live in `data/intro.json` so they can be rewritten without touching scripts.

## Beats

Each object in `beats` is one text box:

| Field | What it does |
|---|---|
| `id` | Stable name. Capture shots and tests jump to this. |
| `panel` | Which procedural picture to draw. Must be one of the ids in `IntroData.PANEL_IDS` / `scripts/art/intro_frames.gd`. |
| `motion` | `fade`, `pan_right`, `pan_up`, `drive`, `leaves`, `birds`, or `flicker`. |
| `voice` | `narration` (warm cream) or `inner` (softer, for the closing hope). |
| `text` | One or two short sentences. No `$`, no digits, no `cult` / `ledger` / `debt` / `money`. |

Keep **12–20** beats. E, Space, or Enter finishes the typewriter, then advances. Hold Esc to skip to Thursday.

## Goals and primer

`goals` and `primer` are the two cards that appear once on the church grounds after the cutscene. `title`, `lines`, and `dismiss` are what the player reads. The primer should keep naming the real bindings: WASD/arrows, E, J, I, T, Esc.

## Test hook

Headless suites that still expect New Game or Restart to spawn on the grounds set `SaveGame.bypass_intro = true` before calling `begin_new_game`. That leaves Thursday 2:00 p.m. and the usual starting flags, with no intro and no primer. `tests/m4/m4_validation.gd` is the one older suite that uses it (title New Game and the chapter-ending Restart).
