# Decisions — The Calling

Milestone 1 choices. Open questions that did not block M1 stay at the bottom.
Longer design context lives in `docs/GAME_DESIGN.md` and the original brief.

## D1 — Movement and facing (resolved for M1)

The brief asks for normalized 8-direction movement. The setup notes ask for 4-direction animations first. M1 does both: `Input.get_vector` plus an extra normalize, and the walk cycle uses the nearest of down / up / left / right. Right-facing frames are a mirror of left. Walk playback is 8 fps.

## Camera

`Camera2D` position smoothing is **off**. The project already snaps 2D transforms and vertices to pixels; smoothing on top of that shimmers.

The camera's `offset` is `(0, -96)`. That is a framing bias, not a zoom: the player sits in the lower part of the 640×360 view so the church front fits on the first screen. Limits match each room's map rectangle, and limit smoothing is off. Revisit the offset if a later map needs the player centered.

## Rooms and doors

No new autoload. `SceneRouter` is a static class that remembers the next spawn id across one `change_scene_to_file`.

Doors open only when the player presses E. They are not area triggers, so loading a room cannot immediately send the player back. Spawn markers stand outside the door's radius, and the player ignores E for 0.35 s after spawning. Headless tests set `SceneRouter.suppress_change` so they can read the requested path without unloading themselves.

Returning outdoors loads `church_exterior.tscn` directly. `main.tscn` only instances that scene so the project has a single launch scene.

## Collision

`TileMapLayer` is visual only. One `StaticBody2D` per room holds rectangle shapes: the church footprint (with a south doorway), prop feet, the sanctuary wall ring, a stopper in the sanctuary doorway, and a thin border so the player cannot walk off the grounds.

Props and the player share a y-sort parent. Sort origin is the feet, so the player passes behind trees and in front of the church face.

## Time of day

T cycles Day → Evening → Night → Day. The phase is static for the session and resets to Day when the process starts. There is no clock and no weather.

`CanvasModulate` carries the time color. A `DirectionalLight2D` adds a little exterior sun and is off indoors. The lamp post is a shadowed `PointLight2D`; church windows and sanctuary sconces are unshadowed pools. Night exteriors stay near `(0.52, 0.58, 0.78)` and night interiors near `(0.64, 0.58, 0.50)` so paths and the player stay readable. Shadow filtering is off so the shadow stays hard.

## Art

M1 art is original and drawn at runtime by `scripts/art/placeholder_art.gd` (flat palette colors, no traced sprites, no generated images). The palette file is `assets/source/palette/the_calling_master.gpl`. LibreSprite was not connected for this session, so there are no `.ase` sources yet. `tools/generate_placeholders.py` is an optional PNG exporter of the same drawings; the game does not need those files.

The light cookie uses five alpha steps of one lamp color so nearest-neighbor filtering does not invent new hues.

## What M1 deliberately does not include

Dialogue choices, quests, schedules, inventory, saving, sermons, audio, a settings menu, and controller bindings. Esc only pauses and resumes. The notice board and Margaret each say one line.

## Still open

| # | Question | Notes |
|---|---|---|
| D2 | Final game title | Unchanged. |
| D3 | Protagonist gender / name customization | Neutral placeholder. No creator. |
| D4 | Exact pixel scale | 640×360, integer scale, still the working choice. |
| D5 | Optional driveable vehicle | Open. |
| D6 | Denomination / theological specificity | Open. |
| D7 | Full NPC daily schedules | M3. |
| D8 | Lightweight minigames | Open. |
| D9 | Controller / Steam Deck | Later. |
| D10 | Forward+ vs Compatibility | Forward+ remains. Revisit for low-end laptops. |
