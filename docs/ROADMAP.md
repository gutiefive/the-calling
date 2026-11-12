# Roadmap — The Calling

Status date: 2026-11-12. The long milestone list is `docs/DEVELOPMENT_ROADMAP.md`. This file is the current cut line.

| Milestone | Status |
|---|---|
| M0 Environment | Done (2026-11-11) |
| M1 Playable world foundation | Implemented. See `docs/PLAYTEST.md` for what was run. |
| M2 Conversation and quest slice | Implemented. Dialogue, the spare-key quest, and a journal. |
| M3 Clock, consequences, town block | Not started. Do not begin until Nathan asks. |
| M4 First Sunday vertical slice | Not started |
| M5+ | Only after prototype feedback |

## M1 includes

Launch into the church grounds. Normalized 8-direction walking, 4-direction animation, collisions, a follow camera, Margaret and the notice board, a two-way sanctuary door, and a T-key day / evening / night demo.

## M1 does not include

The rest of Oakridge, dialogue choices, quests, schedules, inventory, money, sermons, saving, combat, weather, or audio.

## M2 includes

Branching dialogue for Margaret and for Harold, the deacon, who waits in the sanctuary. The first quest is the spare key ring: Margaret asks, the player either talks to Harold or searches the stacked chairs, picks the ring up, and brings it back. Her thanks depends on that earlier choice. J opens a journal. Flags and quest state survive the sanctuary door. They are not written to disk.

## M2 does not include

A clock, NPC schedules, the hardware store, Frank, save/load, inventory, sermons, or audio.
