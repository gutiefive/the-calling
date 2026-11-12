# Development Roadmap

Source: brief Sections 8–10. **Status 2026-11-12: M0 complete; M1, M2, and M3 implemented (see `docs/ROADMAP.md` and `docs/PLAYTEST.md`). M4 not started.**

## M0 — Environment (done 2026-11-11)
Godot 4.7.2, Cursor, Beckett Lite MCP, LibreSprite + LibreSprite-MCP, git repo, docs, toolchain smoke test.
See `docs/ENVIRONMENT_SETUP.md`.

## M1 — Playable World Foundation
**Goal:** launch, walk church grounds, see atmospheric lighting, interact with something, enter a basic sanctuary, return.

Must have: bootable project; keyboard-driven normalized 8-way movement + collisions (see open decision D1 for
animation directions); follow camera with readable pixel presentation; handcrafted church exterior blockout (church,
path/parking, trees/props); one stationary character or prop with prompt and response (e.g. Margaret or a notice
board); day/evening/night demonstration that stays legible; one door to the sanctuary with a safe return; README
controls and launch steps; manual test checklist + automated validation where feasible.

Out of scope: full town, quests, branching dialogue, NPC schedules, inventory, economy, character creator, sermons,
saving, crafting, combat, multiplayer, complex weather.

Build order: (1) audit & bootstrap (2) main scene & environment blockout (3) player & camera (4) interaction system
(5) sanctuary + two-way doors + spawn markers (6) lighting demo (7) polish & validation.

Input map (M1 needs only): move_up W/Up, move_down S/Down, move_left A/Left, move_right D/Right, interact E, pause Esc.

### M1 acceptance tests
- T01 Launch: main scene runs outdoors, no missing resources or script errors.
- T02 Movement: WASD + arrows; diagonals normalized; release stops.
- T03 Collision: can't pass walls, trees, obstacles.
- T04 Camera: follows, stays in bounds, no visible shake.
- T05 Interaction range: prompt appears only near target.
- T06 Single action: E triggers once per press.
- T07 Doors: church ↔ sanctuary both ways, no re-entry loop.
- T08 Lighting: day/evening/night cycle, never unplayably dark.
- T09 Restart: predictable state.
- T10 Documentation: README run steps, controls, layout, known limitations.

## M2 — Conversation & Quest Slice
Implemented. Dialogue UI (name, advance/skip, choices); Margaret and Harold; the spare key ring quest; quest state
and a journal; narrative flags kept across the sanctuary door. No clock, schedules, or save files (those are M3).

## M3 — Clock, Story Consequences & Town Block
Implemented. Day clock; simple schedules for Margaret, Harold, Thomas, Frank, and Sarah; the Oak Street block;
relationship values with dialogue consequences; one versioned save; opening story chain through Saturday evening.
No Sunday service.

## M4 — First Sunday Vertical Slice
Sunday service sequence; sermon theme choice with modest narrative impact; follow-up interactions; end-of-chapter
financial discovery; 15–20 minute replayable demo with start and ending.

## M5+ — Only after prototype feedback
More town blocks, deeper arcs, community tasks, restoration, events, church progression, more chapters, improved
art/audio, accessibility, balancing, distribution planning.

## Risks (from brief)
Massive scope → one neighborhood, one chapter first. Muddy pixel lighting → restrained lights, readable silhouettes.
Dialogue-only VN drift → physical interactions and tasks. NPCs as points → model relationships separately from
attendance. 2D/3D contradiction → 2D-native; 3D only as an isolated spike. Narrative before gameplay → playtest
controls/camera first. Legal risk from generated assets → original placeholders, track licenses.
