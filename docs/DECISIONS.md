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

T cycles Day → Evening → Night → Day. For M1 the phase was static for the session. M3's `DayClock` now drives it. See D15. There is still no weather.

`CanvasModulate` carries the time color. A `DirectionalLight2D` adds a little exterior sun and is off indoors. The lamp post is a shadowed `PointLight2D`; church windows and sanctuary sconces are unshadowed pools. Night exteriors stay near `(0.52, 0.58, 0.78)` and night interiors near `(0.64, 0.58, 0.50)` so paths and the player stay readable. Shadow filtering is off so the shadow stays hard.

## Art

M1 art is original and drawn at runtime by `scripts/art/placeholder_art.gd` (flat palette colors, no traced sprites, no generated images). The palette file is `assets/source/palette/the_calling_master.gpl`. LibreSprite was not connected for this session, so there are no `.ase` sources yet. `tools/generate_placeholders.py` is an optional PNG exporter of the same drawings; the game does not need those files.

The light cookie uses five alpha steps of one lamp color so nearest-neighbor filtering does not invent new hues.

## What M1 deliberately does not include

Dialogue choices, quests, schedules, inventory, saving, sermons, audio, a settings menu, and controller bindings. Esc only pauses and resumes. The notice board and Margaret each say one line. M2 replaces Margaret's line. The notice board is still that one line.

## D11 — Spare keys, and the door stays open

Chapter 1 starts with a locked front door and Margaret. The hardware store, Frank, and a supply run need the town block, which is M3. The quest is the spare key ring for the church office.

The sanctuary door from M1 is not locked behind the quest. Gating it would break the doorway walk and the door check already in `tests/m1/`. The ring is a story object on the stacked chairs, not a key to the room the player can already enter.

## D12 — Harold is the second voice

Harold, the longtime deacon, stands in the sanctuary. Frank Miller and Thomas belong on the hardware street, which M2 does not build. Harold is proud of the building and wary of new hardware. He is not a villain, and he has a line even if the quest has not started.

## D13 — NarrativeState, not a save file

`NarrativeState` is an autoload. It holds flags, quest records, and, as of M3, relationship values. `to_dictionary()` / `from_dictionary()` are what the save file writes. Room changes go through `SceneRouter` as before; the autoload is what survives them. Disk writes are D18.

Dialogue text is JSON under `data/dialogue/`. Quest titles and objectives are JSON under `data/quests/`. The key ring's lines are JSON under `data/interactions/`. The notice board is still a one-line prop.

## D14 — How a conversation is driven

The bottom panel shows the speaker and reveals one character per physics frame. E, Space, or Enter skips the rest of the line, then advances. On a choice, Up/Down or W/S moves the marker and E, Space, or Enter confirms. J toggles the journal.

Walking is locked while the dialogue box or the journal is open. E still reaches the focused interactable, which is how the M1 "second press" and door checks keep working. Margaret and Harold do not stand inside a door's radius, and the player cannot walk onto a door while a conversation is open.

There is no text-speed setting and no portrait yet. Esc opens the pause menu (D18).

## D15 — The clock (M3)

`DayClock` is an autoload. The opening week starts Thursday at 2:00 p.m. M4 continues it through Sunday. See D20.

While the player is walking, four in-game minutes pass each real second. Dialogue, the journal, and pause hold the clock. One frame moves it at most one minute, so a hitch cannot skip a visit. Hours map to the M1 lights: day is 6:00 a.m. to 4:59 p.m., evening is 5:00 p.m. to 7:59 p.m., night is 8:00 p.m. to 5:59 a.m. T skips to the next of those boundaries. The phase label still says Day, Evening, or Night. The clock itself is the top-right HUD label.

## D16 — Schedules

Five NPCs, all from the brief: Margaret, Harold, Thomas, Frank Miller, and Sarah. No one new was invented. Rows live in `data/schedules/week.json`: day, from, until, scene, position. A window is half-open. No matching row means the NPC is hidden and cannot be talked to.

Thursday they keep the M1 posts all day, so the spare-key quest is not interrupted by the clock. From Friday on, Margaret and Harold split time between the grounds and the sanctuary. Thomas and Frank work Oak Street. Sarah is there Friday morning and Saturday late morning.

## D17 — Relationships

Each NPC has an integer on `NarrativeState`, starting at 0. Dialogue can add to it. The number is not shown, and it is not a moral score. Listening to Frank sets his to 1. That changes his later line and Margaret's Saturday evening line. Asking him to come on Sunday leaves it at 0 and uses the other lines.

## D18 — The save file

One slot, `user://the_calling_save.json`. It holds the narrative dictionary (flags, quests, relationships), the clock, the scene path, and the player's position and facing. Load applies the autoloads, then changes scene on the next frame so the pause menu is not freed mid-callback. Esc opens Resume, Save, and Load. No new input actions were required. M4 sets the file version to 2 and migrates version 1. See D23.

## D19 — Oak Street and the week

The church lot's east side walks to `hardware_street.tscn` and back. Spawns stand outside the door radius. The store, the bay, and the cottage are exteriors. The story chain is the spare keys, then Oak Street: Thomas, Frank, Sarah on Friday morning, and Margaret on the church walk Saturday evening. That last line names Sunday at ten. The service itself is D21.

## D20 — Sunday on the clock (M4)

The opening week no longer stops at Saturday 11:59 p.m. Saturday night rolls into Sunday morning, and the clock stops at this Sunday 11:59 p.m. Calendar weekday 0 would sort before Thursday, so this Sunday is stored as weekday 7. `set_time(0, …)` means that same Sunday. T still skips to the next light, except on Sunday before 10:00 a.m., where it lands on 10:00 so the service is not skipped. The M3 checks that expected a Saturday cap now expect Sunday morning. The check count is unchanged.

## D21 — The three sermon themes

The brief lists hope, forgiveness, service, and perseverance. This chapter uses the first three. Perseverance can wait. Each theme sets `sermon_theme` and moves one relationship, not all of them. Hope raises Sarah. Forgiveness raises Frank. Service raises Harold and Thomas. Margaret and Harold say different things for each theme. Frank's Sunday line also depends on whether Thursday was listening or an invitation. Sarah's line depends on whether Friday asked what the week needs (`sarah_heard`). None of the three is the correct sermon.

The service is data in `data/dialogue/sunday_service.json`. It is pinned, so walking away cannot close it. E, Space, or Enter advances. If it closes before a theme, it reopens once. If a theme was already chosen, it does not play again, so the relationship is not added twice.

## D22 — Follow-ups, then the ledger

After the service the five named people stand in the sanctuary until midnight. Twelve unnamed congregants sit in the pews from 10:00 on. They are not characters and cannot be talked to. Speaking with Margaret after the service opens the ledger on the west table. The other conversations can happen before or after hers. The chapter ending appears when the ledger dialogue closes. It summarizes the spare-key approach, Frank, Sarah, the sermon, and the oil bill. Restart deletes the one save and returns to Thursday 2:00 p.m. with flags, quests, and relationships cleared. New Game from the title does not delete a save, so Continue still works.

## D23 — Save version 2

The file version is 2. A version 1 file is copied forward: its flags, quests, relationships, clock, scene, and position stay, and `sermon_theme` is set to an empty string when it is missing. A missing version is still rejected. Newer versions are still rejected. `SaveGame.migrate` is what load uses, so an old file does not need to be rewritten before it can be read.

## D24 — The title screen is the launch scene

`scenes/main.tscn` is the title. New Game loads the church grounds at Thursday 2:00 p.m. Continue calls the same load as the pause menu. The title holds `DayClock` until a room starts. No new input actions were added. Up and Down choose. E, Space, or Enter confirms.

## D25 — Finding Oak Street (M4.5)

The church lot stays 36 by 26 tiles, so the M1 camera limits stay put. The east exit was hard to see, so the gravel there is now a path, with arrows and a sign you can read. Entering a room shows its name for a moment: Church grounds, Sanctuary, or Oak Street. M, and the Map row on the pause menu, open a sketch of those three places and a marker for the player. The new input action is `town_map`. Until you have been on Oak Street, the journal keeps one line about the lane east of the church. Resume, Save, and Load stay the first three pause rows, so the older save checks still land on the same choices.

## D26 — Walking between posts (M4.5)

A schedule change inside the room you are in starts a short walk: straight, or one corner, around the solid rectangles already in the room. Entering a room still places people on the post for that hour, which is what the older presence checks measure. If the segment is blocked, the person is placed on the post and marked as a fallback, so a bench cannot trap them. Leaving the schedule hides them. Thursday evening Margaret walks south on the grounds; after 8:00 p.m. she is indoors. `NpcSchedule.debug_blocks` is only there so a test can wall off that walk.

Frank's conversation checks the Oak Street step before his relationship. The Friday delivery can raise that relationship without skipping the Thursday choice.

## D27 — Optional days (M4.5)

Thursday afternoon, the flowers by the east wall. Friday, crates outside the hardware store. Saturday morning, neighbors at the park. Each is a short conversation, a relationship of 1, and a journal note. The hours live in `data/happenings/week.json`. They are absent on the other days. The ledger still ends the chapter if none of them happened.

Three unnamed neighbors walk the Oak Street sidewalk. Their one line depends on the day and on Day, Evening, or Night. Evening keeps one of them out. Night keeps none, and the windows are lit. They are not characters and they are not on the week schedule.

Oak Street is 64 by 40 tiles. East of the shops are a park, a creek bank, and Maple Lane, which stops at a sign. The bridge is not a scene.

## D28 — Notes in the same save

The file version stays 2. Journal notes are an extra list inside the narrative dictionary. A file that has no list loads with an empty one. The Oak Street hint is derived from `seen_oak_street`, so it does not need its own version.

## Still open

| # | Question | Notes |
|---|---|---|
| D2 | Final game title | Unchanged. |
| D3 | Protagonist gender / name customization | Neutral placeholder. No creator. |
| D4 | Exact pixel scale | 640×360, integer scale, still the working choice. |
| D5 | Optional driveable vehicle | Open. |
| D6 | Denomination / theological specificity | Open. |
| D7 | Full NPC daily schedules | Simple windows are in (D16). M4.5 walks between posts in the current room (D26). A full simulated day is still open. |
| D8 | Lightweight minigames | Open. |
| D9 | Controller / Steam Deck | Later. |
| D10 | Forward+ vs Compatibility | Forward+ remains. Revisit for low-end laptops. |
