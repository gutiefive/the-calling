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

The file version was 2. A version 1 file is copied forward: its flags, quests, relationships, clock, scene, and position stay, and `sermon_theme` is set to an empty string when it is missing. A missing version is still rejected. Newer versions are still rejected. `SaveGame.migrate` is what load uses, so an old file does not need to be rewritten before it can be read. D33 moves the file version to 3.

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

Journal notes are an extra list inside the narrative dictionary. A file that has no list loads with an empty one. The Oak Street hint is derived from `seen_oak_street`, so it does not need its own version. The file version itself moved in D33.

## D29 — Sleep and the morning card (M5A)

The parsonage is a small house on the church grounds, with a bed inside. E on the bed fades out, sets the clock to 6:00 a.m., and fades in. If it is already morning, that is this morning. Otherwise it is the next morning. Sunday after 6:00 a.m. does not invent a Monday. The week still ends Sunday night. D37 lifts that cap after Continue. The card names the weekday and up to three things you might do. It never says you must. E, Space, or Enter closes it. The clock holds while the card is up, the same way it holds for dialogue. T is still the debug skip. No new input action was added.

## D30 — Maple Lane is open (M5A)

The bridge sign stays on Oak Street, and it still says the bridge was repaired. The lane past it is now a room: houses, fences, a bus stop, a bench, and the community garden. The door both ways uses the same spawn rules as the church gate. The town map adds the parsonage, Maple Lane, the hardware store, and Frank's bay. Sarah is on the lane Friday afternoon, after her Oak Street morning. Thomas is there Saturday from 3:00 to 5:00, after the store closes. Two neighbors, Dale and Ruth, keep weekday hours on the lane.

## D31 — Shops, without moving the sidewalk posts (M5A)

Thomas and Frank stood on the Oak Street sidewalk during shop hours, and a second copy stood behind the counter. D36 removes that duplicate. The hours themselves are unchanged: Thomas from 9:00, Frank from 8:00. A shut door still says when to come back.

## D32 — Church growth is words (M5A)

Four measures start at Strained: congregation health, community trust, community impact, and the building. One step is Steady. Two is Growing. The journal prints those words. It does not print the numbers. Attendance stays the phrase "a small gathering." Hope, forgiveness, and service each move one measure, along with the relationship they already moved. Listening to Frank on Thursday, hearing Sarah on Friday, tidying the church walk, and planting the garden each move one measure once.

## D33 — Save version 3 (M5A)

The file version is 3. Version 2 gains the four measures at Strained and the attendance phrase, and it keeps its story. Version 1 still gains an empty sermon theme, then the same measures. A missing version is still rejected. A newer version is still rejected. Load does not rewrite the file, so a version 2 slot stays version 2 until something saves over it. The M4 check that a migrated file "is version 2" now compares against the current version. The M4.5 check that a fresh save "stays version 2" does the same. The M4 check that Continue leaves a version 2 file on disk is unchanged, because Continue does not save.

## D34 — Two jobs you can skip (M5A)

Litter and the flower bed on the church walk, then the Maple Lane garden. Clearing all three grounds pieces tidies the walk and moves the building once. The garden is cleared by hand, then planted with a neighbor. After that it grows on later mornings. Thomas and a neighbor mention the work if you did it. The ledger still ends the chapter if both jobs are untouched.

## D35 — Frank, listening first (M5A)

After Thursday, a Friday morning visit only asks you to come back. The bay is quieter Friday afternoon or Saturday before 2:00. Listening learns about the hospital week and raises Frank and community trust. Pressing him toward Sunday does neither. Sunday says a different line for each. If you never start this, his old Sunday lines stay. The new condition is `hour_before`. It does not replace `hour_at_least`.

## D36 — One place at a time (M5B)

The week schedule is the only copy of a named person. During open hours Thomas is in the hardware store at the counter, and Frank is in the bay. The sidewalk nodes stay in the street scene and are hidden for those hours. Margaret, Harold, and Sarah were already a single window at a time. Dale and Ruth were too. Monday, Tuesday, and Wednesday reuse the Friday posts: Margaret and Harold split the morning grounds and the afternoon sanctuary, Thomas and Frank keep shop hours, and Sarah splits Oak Street and Maple Lane. Dale and Ruth keep their lane hours on those days as well. Harold's Friday gap from noon to 1:00 is closed, and Sarah's Friday hour on the lane now starts at noon, so neither vanishes between windows. The M3 checks that used to find Thomas and Frank on the sidewalk now find them inside. That suite prints 109 `CHECK OK` lines. The story check walks in through the shop doors.

## D37 — The week continues (M5B)

The ledger still opens the ending. The first row is Continue in Oakridge. Restart is the second row, which is why the M4 ending check presses Down once before E. Continue sets `week_continues` and closes the menu. It does not clear the story and it does not change rooms. Until that flag is set, Sunday after dawn still does not add a Monday, and the clock still stops at Sunday 11:59 p.m. After it, sleep and the clock keep going. Weekday numbers climb. Names repeat every seven days: 8 is Monday, 14 is the next Sunday. T on the first Sunday morning still lands on 10:00. Later Sundays do not. The save stays version 3. The flag lives in the narrative dictionary, so an older file simply has no continued week.

## D38 — Later Sundays stay quiet (M5B)

The first Sunday service is unchanged. A later Sunday does not start it again, and the twelve congregants do not stay in the pews after that first Sunday. From 6:00 a.m. until noon, a note in the sanctuary aisle reads that the room is quiet and the next chapter is still being written. The morning card can say the same. Margaret and Sarah no longer talk as if Sunday is still tomorrow once the week has continued. If the Oak Street errand is still "find Sarah on Friday" after Friday, the journal moves on to Saturday. If Saturday evening has passed, that quest completes so it does not stay active into Sunday.

## D39 — Small fixes found in the pass (M5B)

The shop, bay, and parsonage south door was a gap in the wall with nothing past it. A lip now stops a walk off the map. E on the door still leaves. Room changes fade for a fraction of a second. The fade does not delay the scene load. The interact prompt names the person when the line does not already. Esc closes the journal, and Esc closes the map, and neither of those opens the pause menu. Neighbors on Monday, Tuesday, and Wednesday use a weekday line instead of falling through to a Thursday sentence. Map regions already matched the interiors. Spawns in those rooms were already on open floor. New weekday posts reuse coordinates that already had a clear walk, and a blocked walk still teleports rather than cutting through a solid.

## D40 — Authored character sheets (M6A part 1)

The player and the five named people use 192×192 PNG sheets at `assets/characters/`. Cells are 32×48. Rows are down, up, left, right. Columns are idle, idle, then four walk frames. Walk plays at 8 fps. The sprite origin stays at the feet. Right-facing frames are a mirror of left, same as D1.

Pixels come from `scripts/art/character_frames.gd`: one body template per silhouette (slim, stocky, skirt), then hair and a small extra (collar, glasses, apron, bag, cap). Colors are only those in `assets/source/palette/the_calling_master.gpl`. The headless writer is `tools/art/author_sprites.gd`. How to regenerate is `tools/art/README.md`.

If a sheet is opened in LibreSprite (`C:\Tools\LibreSprite`) and saved over that PNG, the PNG is the source of truth. Do not re-run the generator for that file unless the hand edits are meant to be discarded.

Tiles, buildings, and unnamed townsfolk still used `PlaceholderArt` until D41.

## D41 — Outdoor tiles and church-lot props (M6A part 2)

Church grounds, Oak Street, and Maple Lane paint from `assets/tilesets/town_tiles.tres` (32×32 cells). The atlas is 8×2 so older path and water coordinates stay put: dirt path is still `(2, 0)`, water is still `(7, 0)`. Grass has three variants. Sidewalk, cracked road, curb, wood fence, hedge, flower bed, church floor, wood floor, and an interior wall base sit in the same sheet. Sanctuary and shop interiors still use the old `PlaceholderArt` atlas.

The church face, one tree, the bench, the lamp post, the notice board, and the mailbox are PNGs under `assets/environments/`. They keep the placeholder pixel sizes so church collision, occluders, and prop `block_size` values do not change. Origins stay at the feet. Pixels come from `scripts/art/environment_frames.gd` plus `scripts/art/pixel_draw.gd`. The headless writer is `tools/art/author_environment.gd`.

Character drop shadows moved up from a few pixels below the shoes to sit under the feet. The outline still runs first so the shadow does not get a hard ring.

Unnamed townsfolk, remaining buildings, and interior furniture stay on `PlaceholderArt`.

## D42 — The quiet ambition (new direction)

Nathan approved `docs/SPIRITUAL_TURN_PROPOSAL.md`. The surface stays a cozy pastor RPG. Underneath, Chapter 2 onward is about whether the player feeds a hunger to have the town run through the church. Faith is not the villain. Insiders never say "cult". Pull is hidden. Influence climbs a ladder from personal trust to a voice on the council. M7 only seeds Chapter 1 and records Pull. Later milestones in that proposal are not started.

## D43 — Save version 4 and Chapter 1 seeds (M7)

The file version is 4. It adds hidden influence (seats, storefronts, dependents, a general total, ladder stage) and an empty `chapter` field. Version 3 gains those at zero / trust / "". Version 2 still gains the church measures, then the same influence defaults. Version 1 still gains an empty sermon theme first. A missing version is still rejected. A newer version is still rejected.

The M5A checks that a migrated or fresh file "is version 3" now compare against `SaveGame.SAVE_VERSION`. The M5A check that a newer file is rejected now uses version 5, so the engine still prints `Save version 5 is not supported` before that `CHECK OK`.

Chapter 1 still plays as before. The seeds are extra lines and one Saturday visitor, Dell Ostrow. Returning the spare keys sets `has_reece_key` for a file box that does not exist yet. Pull changes on the Frank and Sarah choices do not change those outcomes. Inner-voice thoughts are optional italic lines after a choice, default on, toggled from the pause menu after Map so Resume / Save / Load stay the first three rows.

## D44 — Weekly loop, money visibility, and a quiet dark arc (M8)

D43 already recorded M7, so the weekly loop is D44.

After Continue in Oakridge, each later Sunday runs a short repeatable service: hope, forgiveness, or service, a described-in-words reaction, then the ledger screen. Attendance is core regulars plus people whose trust or invite flags qualify, plus a seeded variance. Offerings and weekly expenses live in `data/economy/economy.json`. Influence may nudge turnout; it is never shown.

**Money.** Exact dollar amounts appear only on the ledger screen and on project costs. Dialogue never names amounts. Trust, Pull, and relationships stay words and tells.

**The first project.** Margaret proposes repairing the Fellowship Hall on the first Sunday after Chapter 1, with no dollars in that conversation. The player sends none, half, or all of each week's surplus to the hall from the ledger. Around $2,500, tuned for about 4–6 decent weeks. When it is funded, Harold repairs it over the next week, the exterior swaps from boarded to open, and Wednesday can hold a potluck.

**Dark arc.** No new cult hints, spirits, or Shepherd lines in this milestone. The ledger may keep one tiny neutral line about a deposit Margaret does not recognize. Insiders still never say "cult".

**Saves.** Version 5 stores funds, week, and project state. Version 4 and 3 files migrate. Continue sets `weekly_loop` and chapter `"2"`. Chapter 1 still plays identically until that Continue.

**Revisit after playtest:** starting balance, per-person giving, expenses, and the hall cost.

## D45 — Branching foundation (M9)

Replayability is three hidden systems, not a visible alignment meter.

**Leanings.** `PastorPath` (its own autoload, not `InfluenceState`) tracks three small integer tracks: Shepherd (listening, humility, quiet help), Builder (growth, pressing, alliances), Skeptic (honest questions, privately wavering faith). `nudge(leaning, amount, reason_id)` is idempotent on `reason_id`. `dominant()` returns the unique leader, or `""` on a tie or when all are at zero. Dialogue may use `lean_at_least` and `dominant_is`. Effects may use `nudge`. The integers never print.

**Sermon mapping.** Hope nudges Shepherd. Forgiveness nudges Skeptic. Service nudges Builder. The first Sunday applies the nudge on the preach node, after the inner-voice thought, so the default thought stays "They listened. That felt good. Maybe too good." when no leaning leads yet. Weekly sermons use the same mapping with separate reason ids.

**Threads.** `data/story/threads.json` plus `StoryThreads`. A thread can be opened, advanced, closed, or permanently missed. Missed threads never reopen. The journal's Threads section lists open threads as one line of words each. Chapter 1 seeds: `frank_grief` (listen opens, press misses; a later memory of Frank's wife if it stays open), `sarah_belonging` (welcome vs invite), `ostrow_alliance` (cool / open / guarded), `reece_mystery` (inspecting the extra key in the journal), `garden_growth` (planting the plot).

**Run seed.** New Game rolls a per-save seed. It varies which unnamed neighbor stays out in the evening, which of two Monday happenings appears, and the slight attendance swing already in `ChurchFunds`. Tests set the seed. Reset restores seed 8 so older attendance checks stay deterministic.

**Saves.** Version 6 stores `pastor_path`, `threads`, and `run_seed`. Version 5, 4, and 3 files migrate. A newer file is still rejected.

## D46 — Walk-in doors (M9B)

Doors, doorways, and street exits change rooms when the player walks into them. E is no longer used for travel. E still talks to people and inspects objects: the notice board, the ledger desk, the bed, the Fellowship Hall, signs, and chores.

`Door` is an `Area2D` on the player collision layer. `ScheduledDoor` still extends it and stays shut outside shop hours. One script covers every scene: the church grounds and sanctuary, the parsonage, Oak Street, Maple Lane, the hardware store, Frank's bay. The park and creek are still stubs, not rooms. The Fellowship Hall is still an inspectable.

The trigger fires only if the player is moving toward it. Arriving inside or next to a door does not bounce back: spawn markers sit outside the circle, the player keeps the short spawn lock, and the area must be left before it will fire again. A 0.4 s re-arm follows a successful walk-in. Shut or locked doors stay put and show the existing closed line once per bump.

Walk-in is ignored during dialogue, the journal, the town map, the morning card, the ledger, the chapter ending, and pause. Room changes still fade. A nearby door shows the place name on the prompt, with no E.

## D47 — Oak Street redesign (M10)

Playtest: the shops sat on grass, the road was a gravel strip, and the block did not read as a town street.

Oak Street is now a two-lane asphalt road with a painted center line, curbs, sidewalks on both sides, a crosswalk at the church end, and a T-junction where Maple Lane heads south. The hardware store and Frank's bay stay the anchors. Between the west cottage and the bay, the north sidewalk fronts a post office, Bright's Diner, an alley, a barber, and a for-lease shop. Facades share a building line. Doors meet the sidewalk. Frank's bay has a driveway apron cut through the curb. The park and creek sit at the east end. Street trees sit in sidewalk planters, with lamps, benches, a hydrant, a mailbox, a trash can, and two parked cars.

The outdoor tileset grew from 8×2 to 8×4 (256×128). Old atlas coordinates are unchanged: path is still `(2, 0)`, water is still `(7, 0)`. New cells cover asphalt, center lines, directional curbs, crosswalks, driveway, planters, foundation, parking, and alley. Storefronts, cars, the hydrant, and the trash can are authored PNGs from `scripts/art/environment_frames.gd`.

Shop hours, walk-in doors, Thomas behind the counter, Frank in the bay, and the M5B one-person-one-place rule are unchanged. Sarah's Oak Street post moved onto the diner sidewalk. A loaded save whose Oak Street coordinates sit in a collider or off the map snaps to the nearest spawn.

Bright's Diner is named and visible. It is not enterable yet.

## D48 — Oak Street south side and Maple Lane (M11)

Playtest after M10: Oak's south sidewalk was empty grass, and Maple Lane felt boring.

Oak Street keeps the M10 road. A second building line fronts the south sidewalk: Oakridge Credit Union, Pearl's Pharmacy, Second Chance Thrift, a parking strip, Hollis Feed and Seed, Town Hall, a pocket park, and a boarded shop. Doors meet the sidewalk. Walking in (or E) shows a short ordinary line. None of those interiors exist yet. Hanging signs sit at sidewalk height on both sides of the street so names read at the game camera. Two more neighbors walk the sidewalks and the church-end crosswalk during the day.

Maple Lane is a quiet north–south street off the Oak T-junction: two lanes, no center line, sidewalks, six houses with front yards, and the community garden as a fenced lot with a gate on the east sidewalk. House and shop facades are data in `data/world/maple_houses.json` and `data/world/oak_storefronts.json`. Each row has an optional `destination_scene`. Empty means a `BuildingDoor` stays closed with flavor text; a later milestone can set the path to make that building enterable. Dale, Ruth, Margaret, Harold, Mrs. Ellis, and Ned Voss are assigned in data only. Schedules and story flags do not change.

Shop hours, walk-in travel, Thomas at the counter, Frank at the bay, and one-person-one-place stay as they were. A loaded save whose coordinates sit in a collider still snaps to the nearest spawn, on both streets.

## D49 — Oak and Maple polish (M11B)

Playtest after M11: south-side shops showed the name twice (facade paint plus hanging sign), Maple Lane still read as empty grass, and evenings looked like the old street.

Each storefront keeps one name, on the hanging or awning sign. Facade art lost the duplicate letters and gained windows, transoms, and trim. Maple Lane fills the lots: backyard hedges and a back path, sheds, tree clusters, a vacant lot with a for-sale sign, and a seventh house on the west side. Garden, doors, the T-junction, and NPC walks stay clear. Collisions follow the new fences and props.

Evening adds unnamed people with the existing ambient system: a dog walker and diner-goers on Oak Street, a neighbor on a Maple porch. Night keeps two of them out. Storefront and house windows use the existing `tod_window` lights. Lines are short greetings. No new story, no dollar amounts, no cult or power talk. Named people stay one-place.

## D50 — Signs on top of the buildings (M11C)

Playtest after M11B: hanging boards sat in front of the doors and two evening neighbors covered Hardware and Bright's.

Each named storefront still has one name, now on a rooftop / parapet board above the facade, on the cornice. The hanging sign in front of the door is gone. Facades still have no painted duplicate. Evening townsfolk stand to the side on the sidewalk, off the signs and off the doors. Hardware, Bright's, and Frank's bay use the same rooftop style. No new story.

## D51 — Church grounds campus (M12)

Playtest: the lot felt open and chaotic. The grounds are now a small campus with a clear perimeter, one main gate off Oak Street, and a courtyard in front of the sanctuary.

The sanctuary sits at the head of a paved plaza (paths, a cross, benches, flower beds). The Fellowship Hall is a west wing on a covered walk. The parsonage has its own hedged yard and a side gate. A parking lot sits by the entrance. A quiet memorial garden, a utility corner, and a picnic lawn fill the rest. Lamps, trees, and planters follow a regular rhythm. The Oak Street exit is a real drive with pillars and a monument sign reading Grace Community Church. No hanging board in front of a door.

**Expansion plots.** Five empty lots live in `data/grounds/plots.json`: id, tile rect, a neutral display name, an inspect line, and optional `project_id` / `built_scene` for a later milestone. They paint as cleared ground with survey stakes and a small Future Site post. Inspecting one is a short line with no dollars, no counts, and no talk of followers or power. The Fellowship Hall repair stays the only funded project. A future milestone can attach "build dorms" (or the farm, workshop, chapel, extra hall) to a plot and swap in the building.

The compound reading is the layout: a fence, one public gate, a courtyard, and staked lots waiting. Insiders still never say "cult".

## D52 — Inventory, wallet, and the hardware shop (Gameplay A)

The first repeatable loop needs a pack before it needs a farm. Phase A adds items and a personal wallet without touching Chapter 1 lines, ChurchFunds, or the ledger.

**Catalog.** `data/items/catalog.json` is the only item list: three tools, four seed packets, four crops, wood, nails, scrap. No extras. Stacks and capacity (16 slots) live in that file.

**Wallet.** Personal cash starts at `$20` on the `Inventory` autoload. `ChurchFunds` is never read or written by add, remove, or buy. Dollar amounts print on the inventory panel, the shop, and the wallet line. Dialogue JSON still has none.

**How you get things.** Starter tools come from a toolbox in the parsonage (the kit Margaret left with the house). Starter seeds come from a crate beside the Maple Lane garden plot. Each grant sets `starter_tools_taken` or `starter_seeds_taken` and will not fire again. Thomas's spoken lines are unchanged; a shelf interactable inside the store opens a small buy UI for seeds, Wood, and Nails at fixed prices.

**UI.** I toggles the pack. Keyboard highlight, descriptions, a Tool vs consumable tag, and capacity. A small equipped-tool strip sits at the bottom left; 1/2/3 pick among carried tools. Esc closes inventory and shop before pause, same as the journal.

**Save.** Version 7. A version 6 file gains an empty pack and starting cash. Flags, funds, leanings, and threads pass through.

Phases C–F (requests, repairs, potluck, integration) are specified in `docs/GAMEPLAY_LOOPS.md` and are not built.

## D53 — Church vegetable garden (Gameplay B)

The repeatable garden is on the **church grounds**, not Maple Lane. Nine plots sit in a tidy fenced bed east of the picnic lawn, south of the drive, inside the campus fence (`GroundsLayout.VEG_GARDEN`). The memorial garden, parking lot, main paths, doors, and the five Future Site lots in `data/grounds/plots.json` stay clear. The Phase A seed crate moved here. Maple Lane's Chapter 1 plot, weeds, and `garden_cleared` / `garden_planted` / `garden_growth` are untouched.

**Loop.** Hoe tills, a prepared seed packet plants (one consumed), watering can marks watered, growth ticks once per morning if watered, harvest yields catalog crops. Unwatered crops pause and never die. Ready crops need no water. Sunday does not destroy them. `last_processed_day` stops double-counting. No energy bar. Wrong tool names what would help and changes nothing.

**Onboarding.** Ruth still walks Maple Lane (one place). She left a skippable card at the church garden with the five steps. Plot prompts carry the rest. A neighbor by the gate may comment if the beds look tended, with no numbers.

**Story.** Growing food is neutral. Gardening does not raise Pull, attendance, dependents, or ChurchFunds.

**Save.** Version 8. A version 7 file gains empty untilled plots and keeps everything else.

## D54 — Community requests and in-ground garden (Gameplay C)

Optional asks, not a quest log with markers. Definitions live in `data/requests/catalog.json`. Accept in dialogue. Cap of three active. History of completed (and expired) asks. Delivering uses `Inventory.remove`. Sarah wants lettuce and carrots for a table; Margaret wants flowers for the sanctuary (they appear by the east window); Harold wants wood and nails and mends a stretch of garden fence; Ruth wants the Maple Lane plot productive and reads `garden_cleared` / `garden_planted`, not the church tiles. Rewards are mixed and personal. No Pull, attendance, dependents, loyalty, or ChurchFunds from finishing an ask. Insiders never say "cult". No dollar amounts in dialogue JSON.

**Garden.** The nine raised wooden beds are gone. Open grass inside `GroundsLayout.VEG_GARDEN` is a tillable grid. Path, gate, Ruth's card, and the seed crate stay clear. The Hoe tills a facing tile; a corner marker shows the cell. Watered soil is darker and dries in the morning. Empty tilled soil reverts after three mornings. Old version-8 beds map onto the matching tiles so in-progress crops survive.

**Save.** Version 9. A version 8 file gains an empty request list and converted tiles.

## D55 — Garden dirt, crops, and journal (Gameplay C2)

A polish pass on Phase C. No new systems and no save bump.

**Soil.** Tilled ground is dirt, not boards. Procedural tiles use clods, pebbles, and short hoe marks, with a darker wet state. Neighbor masks skip internal grass borders so a 3×3 patch is one field.

**Crops.** Every growth stage is larger and higher contrast. Mature plants fill most of the tile; tomatoes are staked and may overhang the tile above.

**Journal.** Sections are labeled Story and Requests. Empty copy is per-section. The panel fits 640×360 with a scroll box, and the area title hides while J is open.

**Garden.** A barrel, wheelbarrow, compost bin, and bench sit along the fence. Reserved tiles keep them off the path and gate.

## D56 — Interactive repairs (Gameplay D)

The first physical repair loop is on the church grounds, not a second chore list. Definitions live in `data/repairs/catalog.json`. Autoload `RepairState`. Four worksites: weeds on the west picnic lawn, litter by the utility shed, a neglected picnic flower bed, and the west garden fence south of the gate. None sit on a path, a door, or a Future Site lot. Maple Lane Chapter 1 weeds stay on `GardenPlot`. The original `GroundsChore` litter and courtyard bed still set `grounds_tidy`.

**Fence.** Four visible stages: damaged, boards off, new wood, finished. 3 Wood then 2 Nails, consumed only on the stage that uses them. Missing stock prints `Missing: 3 Wood`. Basic Hand Tools must be equipped; the hoe and an empty hand change nothing.

**Harold.** His ask still lists the wood and nails. Delivering them to him no longer mends the fence. The player mends it. `church_fence_mended` keeps its meaning. Harold's thank-you still grants one Scrap, once. A version-9 save that already has the flag starts with the finished fence.

**Story.** Repairs do not raise Pull, attendance, dependents, loyalty, or ChurchFunds. A neighbor may remark when the grounds look cared for. Kindness flags stay hidden. No decay.

**Save.** Version 10. A version 9 file gains worksites.

## D57 — Repair worksite art (Gameplay D2)

A polish pass on Phase D. No new systems and no save bump. Phase E is not started.

**Fence.** The worksite is a 3-tile stretch of the west garden fence, south of the gate, not the gate opening and not a 1-tile crate. Stages use the same posts-and-rails language as `TownTiles.FENCE`. `church_fence`, `church_fence_mended`, and save v10 stay as they were. Layout lives in `GroundsLayout.VEG_FENCE_MEND`.

**Other sites.** Picnic weeds read as tall growth, then cut grass. Utility litter is scattered trash; when it is gone a tied bag sits by the shed bin. The picnic bed goes from a broken, weedy box to a mulched bed with several flower colors.

**Hint.** Facing a worksite in range tints the sprite slightly. The existing `E  …` prompt is unchanged. No map markers.

## D58 — Weekly Fellowship Hall potluck (Gameplay E)

The M8 Wednesday happening stays. The gathering itself is a walk-in Fellowship Hall interior after Continue and after the hall is repaired. Prep is optional. A modest table with Margaret, Harold, and Sarah is already a gathering.

**Prep.** Vegetables (Sarah's ask), sanctuary flowers, tended grounds, the picnic flower bed, and talking Ostrow / Ruth / Dale into coming. At least dishes, centerpieces, lights, extra chairs, and extra guests change the room. Journal lines stay short. Prep is not a failure state.

**Framing.** Sarah asks once whether the table is open to everyone or leans toward Grace. Open nudges Shepherd and Sarah's relationship. Church-centered nudges Builder and can add one Pull. No new meter, no visible score, no Pull for showing up. `ChurchFunds` are untouched. Later dialogue can read `potluck_framing_open` / `potluck_framing_church`.

**Recurrence.** Wednesday 11:00–16:00. First live window is the first continuing Wednesday. Attendance and skips are stored by week id. One journal note per attended week. The clock holds inside the hall during the window; walking is not locked.

**Save.** Version 11. A version 10 file loads.

**Toasts.** Farming, repair, chore, and pickup lines use a small bottom-left toast (about 1.2s, then fade). Dialogue boxes are unchanged.

## D59 — Integration, clock, and polish (Gameplay F)

Phases A–E are one connected loop. No new systems. Save stays version 11.

**Clock.** `MINUTES_PER_REAL_SECOND` stays 4.0 (15 real seconds per in-game hour). A packed morning of garden, shop, and home is about four in-game hours; a waking day is fourteen. Sunday 10:00, the M8 Wednesday crate, the potluck window (11:00–16:00), and the Chapter 1 ending still trigger.

**Balance.** Catalog numbers stay. Starting `$20` covers one fence shop visit (`$18`). Starter seeds cover the first planting. First harvest is 2–3 mornings. Gardening, asks, repairs, and a successful gathering still do not raise Pull, attendance, or ChurchFunds. Only Sarah's framing may nudge a leaning and Pull.

**Polish.** Toast and hotbar stay in the left gutter so they never cover the `E  …` prompt. Picnic weeds sit on lawn, not the parsonage walk. Litter has no grass mat. Restored picnic blooms read from a distance. Fence debris is a small pile. Dale and Ruth have named sheets. Ruth's church-garden card is one short line. The Maple Lane plot and `garden_planted` stay separate from the church tiles.

**Next.** Sanctuary and Fellowship Hall interior redesign. Not a church tycoon pass.

## D60 — Sanctuary and Fellowship Hall interiors (M13)

Playtest: both interiors were one-room placeholders. The player spends a lot of time in them, so they are now multi-room buildings in the existing interior-scene pattern (one scene per building, doorways between rooms).

**Sanctuary.** Narthex (welcome table, coat rack, guest book, bulletin, bench), worship hall (aisle, pews, runner, platform, altar, pulpit, wooden cross, stained-glass light, piano, hymn board, Margaret's flowers), pastor's office (desk, ledger, bookshelf, filing, lamp, photo, a quiet sketch of extra wings), prayer room (kneeler, candles, bench), choir, storage, a hallway, and a non-enterable restroom door. The ledger moved into the office. Spare keys stay on the stacked chairs in the choir room.

**Fellowship Hall.** Main hall with real wood floor, tables the potluck still uses, a podium, coffee, lost-and-found, bulletin, and a speaker; a kitchen with a serving pass-through; a Sunday-school classroom; storage for folding tables; a connecting hallway. The M8 crate stays on the grounds by the door.

**Alive, not busy.** Named people keep their schedules (Margaret by the flowers, Harold by the hymnals). Unnamed neighbors idle in the prayer room, choir, kitchen, and classroom, off the doorways. Short flavor lines. No dollars. Insiders never say "cult". One quietly ambiguous office sketch. Faith is not the villain. No automatic Pull, attendance, loyalty, or ChurchFunds from the new props.

**Save.** Version 11. No migration. Sunday, the ledger, the potluck, M8, and the Chapter 1 ending keep their flags.

## D61 — Furniture and clutter density (M13B)

The M13 rooms read clearly but felt tidy and empty. This pass fills them and slightly shortens the Fellowship main hall (19 tiles tall to 16) so the furniture can occupy the floor. Sanctuary room rects and the aisle cell stay put.

**Sanctuary.** Longer pews plus a front row; narthex rugs, coats, umbrella stand, tract rack, donation box, plants; worship side rugs, sconces, baptism font, sound desk, banners, piano bench; office armchair, second shelf, papers, calendar, radiator; prayer board and extra candles; choir chairs, stands, robe rack; storage shelves and bins. Stained-glass color now pools on the center aisle too.

**Fellowship Hall.** Normal-day tables and chairs (the potluck still dresses Table A/B), a stage and curtain, piano, craft and puzzle tables, water cooler, trash/recycling, kitchen island and upper cabinets, classroom cubbies, rug, and beanbags.

**Collision.** Big furniture blocks; small clutter does not. Doorways, the aisle, potluck table access, the ledger, and the spare keys stay clear. NPC idle posts stay off furniture. Save stays v11. No story, Pull, attendance, or ChurchFunds changes.

## D62 — Fellowship Hall tables (M13C)

Playtest after M13B: round and long tables read as dark-red rugs, and the middle of the hall was empty.

Tables are now raised furniture: light cloth or wood tops, a highlight, a front lip, legs, and a drop shadow. Round tables have six chairs; long tables have four, a few pulled slightly askew. Everyday clutter (napkins, salt and pepper, a mug, a bible, a board game, craft paper) sits on some of them. Rugs are fewer, cooler blue, flat, and not parked under the tables.

The normal-day layout is two rows with a 2-tile center aisle from the south door to the hallway, plus walks to the stage, kitchen pass-through, and interactables. Wednesday still dresses Table A and Table B: modest vs full cloth, dishes on the tops, centerpieces, lights, extra chairs, extra guests. Save stays v11. No story, Pull, attendance, or ChurchFunds changes.

## D63 — Fellowship Hall final polish (M13D)

Playtest after M13C: tables still read small at the close camera, the blue rugs looked scattered, and potluck guests plus extra chairs stood south of the view.

Tables are now about four tiles long with cloth folds, a hanging hem, a runner on Table B, and chair backs vs seats. Rugs are purposeful: an aisle runner from the door toward the stage, a rug under the stage, a cozy rug in the southwest sitting corner. The hall is zoned (sitting, welcome, coffee, kids, stage, piano, trophy wall, chair carts) with 2-tile walks kept. Kitchen, classroom, storage, and hallway get a matching finishing pass. Invited guests and extra chairs stand at tables A/B in the close camera. String lights span the hall. Save stays v11. No story, Pull, attendance, or ChurchFunds changes.

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
