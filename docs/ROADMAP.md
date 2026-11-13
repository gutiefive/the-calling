# Roadmap — The Calling

Status date: 2026-11-13. The long milestone list is `docs/DEVELOPMENT_ROADMAP.md`. This file is the current cut line. M12 (church grounds campus) is implemented. Gameplay A–F (inventory through the connected weekly loop) are implemented. M13 (sanctuary and Fellowship Hall interiors) is implemented. Next: planning board / Tier 1 unless Nathan sends the work elsewhere. Chapter 2 storylines are not started.

| Milestone | Status |
|---|---|
| M0 Environment | Done (2026-11-11) |
| M1 Playable world foundation | Implemented. See `docs/PLAYTEST.md` for what was run. |
| M2 Conversation and quest slice | Implemented. Dialogue, the spare-key quest, and a journal. |
| M3 Clock, consequences, town block | Implemented. Weekday clock, Oak Street, schedules, relationships, and one save slot. |
| M4 First Sunday vertical slice | Implemented. Sunday service, sermon theme, follow-ups, the ledger, and a title screen. |
| M4.5 Living town | Implemented. Wayfinding to Oak Street, a wider street, people who move, and one optional moment each on Thursday, Friday, and Saturday. |
| M5A A town to come home to | Implemented. Parsonage and sleep, Maple Lane, shop interiors, soft church growth, two optional tasks, and the first step of Frank's arc. |
| M5B Polish | Implemented. One place for each person, a week that continues after Chapter 1, and a quiet later Sunday. |
| M6A part 1 Character sprites | Implemented. Player plus Margaret, Harold, Thomas, Frank, and Sarah use 32×48 sheets. |
| M6A part 2 Environment art | Implemented. Outdoor tileset plus church face, tree, bench, lamp, notice board, and mailbox. Remaining buildings and unnamed townsfolk stay placeholder. |
| M7 Seeds and influence | Implemented. Hidden Pull, save v4, Chapter 1 seeds, Dell Ostrow, inner voice, and the no-cult scan. Chapter 1 still plays start to finish. |
| M8 Weekly loop, funds, first project | Implemented. Later Sundays run a short service, ChurchFunds and the ledger screen, save v5, and the Fellowship Hall repair. Chapter 1 still plays identically until Continue. |
| M9 Branching foundation | Implemented. Hidden Shepherd / Builder / Skeptic leanings, story threads, a per-save run seed, and save v6. Chapter 1 still plays the same default path. A few Chapter 1 and weekly-loop branches prove the model. |
| M9B Walk-in doors | Implemented. Doors change rooms on contact. E still talks and inspects. |
| M10 Oak Street redesign | Implemented. Two-lane asphalt, sidewalks, storefronts on a building line, Bright's Diner and filler shops, park and creek at the east end. |
| M11 Oak south + Maple Lane | Implemented. South-side storefronts and civic buildings, larger hanging signs, Maple Lane as a residential street with houses and the garden kept. |
| M11B Oak and Maple polish | Implemented. One name per shop, Maple lots filled, evening and night ambient people, warm windows. |
| M11C Rooftop signs | Implemented. Storefront names sit on the parapet, not hanging in front of the door. Evening townsfolk stand off to the side. |
| M12 Church grounds campus | Implemented. Perimeter and one main gate, courtyard, parking, garden, picnic lawn, and data-driven expansion plots. Fellowship Hall repair unchanged. |
| Gameplay A Inventory and items | Implemented. Data-driven catalog, pack, personal wallet, I-panel, hardware shop, starter tools and seeds, save v7. See `docs/GAMEPLAY_LOOPS.md`. |
| Gameplay B Gardening | Implemented. Nine church-grounds plots east of the picnic lawn, hoe / seed / water / harvest, morning growth, save v8. Maple Lane Chapter 1 plot unchanged. See `docs/GAMEPLAY_LOOPS.md`. |
| Gameplay C Community requests | Implemented. Four optional asks, journal tracking, in-ground church garden tiles, save v9. See `docs/GAMEPLAY_LOOPS.md`. |
| Gameplay D Interactive repairs | Implemented. Data-driven worksites, staged garden fence, weeds, litter, flower bed, save v10. GroundsChore flags kept. See `docs/GAMEPLAY_LOOPS.md`. |
| Gameplay E Weekly potluck | Implemented. Fellowship Hall gathering, optional prep, Sarah's framing, save v11. See `docs/GAMEPLAY_LOOPS.md`. |
| Gameplay F Integration and polish | Implemented. Full-loop playthrough, DayClock review, balance review, HUD and worksite polish, Dale and Ruth sheets. Save stays v11. See `docs/GAMEPLAY_LOOPS.md`. |
| Sanctuary + Fellowship Hall interiors | Implemented. Multi-room sanctuary and Fellowship Hall, ambient neighbors, flavor props, stained-glass light. Save stays v11. See `docs/INTERIORS.md`. |
| Planning board and Tier 1 | Later. Attach the first expansion project to a plot (workshop, greenhouse, or dorms). |
| Next story | Chapter 2 is not started. Full Chapter 2 storylines build on M9 leanings, threads, and the run seed. |
| M11 Night layer | Not started. Spirit framework, two Lingerers, prayer-lights, steeple light. |
| M12 Chapter 2, part A | Not started. June, the deposits, Reece's file box, Ostrow's favor, inner voice in play. |
| M13 Gathered v1 | Not started. Town helpers, notice board, Garden and Upkeep roles. |
| M14 Invited guest | Not started. Fence dispute and town hall interior. |
| M15 Chapter 2, part B | Not started. First fundraiser, the Sunday, Frank's wife, chapter close. |
| M16 Tier 2 and live-ins | Not started. Fellowship House, dining hall, live-in Gathered. |
| M17 Council meetings | Not started. Tuesday scenes, Cal's diner, Pearl's column. |
| M18 onward | Not started. Chapters 3 to 5, Tier 3, the seat, tells pass. Endings wait for Nathan. |

## M1 includes

Launch into the church grounds. Normalized 8-direction walking, 4-direction animation, collisions, a follow camera, Margaret and the notice board, a two-way sanctuary door, and a T-key day / evening / night demo.

## M1 does not include

The rest of Oakridge, dialogue choices, quests, schedules, inventory, money, sermons, saving, combat, weather, or audio.

## M2 includes

Branching dialogue for Margaret and for Harold, the deacon, who waits in the sanctuary. The first quest is the spare key ring: Margaret asks, the player either talks to Harold or searches the stacked chairs, picks the ring up, and brings it back. Her thanks depends on that earlier choice. J opens a journal. Flags and quest state survive the sanctuary door. They are not written to disk.

## M2 does not include

A clock, NPC schedules, the hardware store, Frank, save/load, inventory, sermons, or audio.

## M3 includes

A weekday clock from Thursday 2:00 p.m. through Saturday night. It drives the existing day, evening, and night lights. T skips ahead. Oak Street sits east of the church lot: a hardware store, Frank Miller's bay, and a cottage. Margaret, Harold, Thomas, Frank, and Sarah keep simple schedules. Dialogue can raise a relationship, and later lines change because of it. The pause menu saves and loads one versioned JSON file. The opening chain runs from the spare keys through Saturday evening and stops short of Sunday.

## M3 does not include

Sunday service, a sermon theme, the financial reveal, shop interiors, inventory, or audio. M4 adds the service, the theme, and the ledger. M5A adds the shop interiors. Inventory and audio are still out.

## M4 includes

A title screen (New Game, Continue when a save exists, Quit). The week continues from Saturday night into Sunday. At 10:00 a.m. the sanctuary holds the five named people and twelve unnamed congregants. A short service (gathering, welcome, hymn, sermon, closing) advances on E, Space, or Enter. The sermon is hope, forgiveness, or service. Afterward Margaret, Harold, Thomas, Frank, and Sarah have lines that follow that choice and, where it matters, Thursday and Friday. Margaret's line opens the ledger. The ledger ends Chapter 1. Restart returns to Thursday and clears the story. Quit leaves.

## M4 does not include

Another chapter, shop interiors, inventory, audio, or a second Sunday. M5A adds the store and the bay.

## M4.5 includes

A sign, arrows, and a path on the east side of the church lot. An area name when you enter a room. A town map on M and on the pause menu. A journal note that names Oak Street until you have been there. Oak Street continues east into a park and a creek, with a gated stub of Maple Lane. Named people walk to a new post in the room you are standing in. A few unnamed neighbors wander the sidewalk and say one line that changes with the day and the light. Evening lights the windows and thins the sidewalk. Night clears it. Thursday has Margaret's flowers, Friday has Frank's delivery, and Saturday morning has neighbors at the park. Each can add a short conversation, a small relationship change, and a journal note. The Sunday chain does not require them.

## M4.5 does not include

Another chapter, shop interiors, inventory, audio, or a second town block you can enter. Maple Lane stops at the gate. M5A opens the lane and the shops.

## M5A includes

A parsonage on the church grounds. The bed sleeps until the next morning, with a short fade and a card that names the weekday and up to three things you might do. None of them are required. T still skips the clock, and walking still advances it. The Maple Lane bridge is open. The lane has houses, fences, a bus stop, an overgrown community garden, and people on a schedule. The hardware store and Frank's bay have interiors that open during their existing hours and say when they are shut. The journal's church page uses words (Strained, Steady, Growing) for congregation health, trust, impact, and the building. Attendance stays a phrase. Two optional jobs change the town: tidy the church walk, and clear and replant the garden so it grows over later mornings. Frank can be visited at the bay on Friday and again on Saturday. Listening learns why he stopped coming. Pressing him for Sunday does not. The ledger still ends the chapter if you skip the new work. Saves are version 3. A version 2 file still loads.

## M5A does not include

Another chapter, inventory, money, audio, or a Monday past this week's cap. M5B adds the Monday.

## M5B includes

A polish pass. Thomas and Frank keep shop hours inside the store and the bay, and the sidewalk copies are hidden for those hours. Margaret, Harold, Sarah, Dale, and Ruth were already one schedule entry at a time. The same posts now cover Monday, Tuesday, and Wednesday by reusing the Friday pattern. After the ledger, Continue in Oakridge sits with Restart and Quit. Continue keeps the story. Sleep and the clock then run into Monday and repeat the week. Later Sunday mornings in the sanctuary are quiet: no second sermon, and a short note that the next chapter is still being written. Room changes fade. The interact prompt names its target. Esc closes the journal and the map. A missed Friday or Saturday errand leaves the active journal list when that day has passed. Saves stay version 3. The new flag is `week_continues`.

## M5B does not include

Another chapter, a second sermon system, inventory, money, or audio.

## M6A part 1 includes

Authored 32×48 character sheets for the player and the five named people. Four facings, two idle frames and four walk frames each. A headless generator under `tools/art/` stamps a shared body plus hair and a small extra. Named people walk with those frames. Tiles, buildings, and unnamed townsfolk stay the old placeholders.

## M6A part 1 does not include

Tilesets, building art, unnamed neighbors, portraits, or a LibreSprite pass. Editing a generated PNG in LibreSprite makes that PNG the source of truth.

## M6A part 2 includes

A 32×32 outdoor tileset (`town_tiles.png` / `town_tiles.tres`) used on the church grounds, Oak Street, and Maple Lane. Authored PNGs for the church front, a tree, a bench, a lamp post, the notice board, and a mailbox, wired in place of those placeholder drawings. Character drop shadows sit under the feet. Collision shapes are unchanged.

## M6A part 2 does not include

Shop and house exteriors, sanctuary furniture, unnamed townsfolk, portraits, or a LibreSprite pass. Interiors still paint from the old placeholder atlas. M10 authors the Oak Street storefronts.

## M10 includes

Rebuild Oak Street as a two-lane asphalt main street with curbs, sidewalks, a crosswalk, and a Maple Lane T-junction. Hardware and Frank's bay stay enterable. Bright's Diner, a post office, a barber, and a for-lease shop fill the block. They are not enterable. Park and creek stay at the east end.

## M10 does not include

Diner, post office, barber, or vacant-shop interiors. No new story.

## M11 includes

Fill Oak Street's south sidewalk with a second building line (credit union, pharmacy, thrift, feed store, town hall, boarded shop), intentional gaps, larger hanging signs on both sides, and a few more parked cars and sidewalk props. Rework Maple Lane into a north–south residential street with houses, front yards, and the community garden as a fenced lot. Facades are data-driven with optional interior scenes. Next: enterable buildings, starting with Bright's Diner and one house.

## M11 does not include

Enterable south shops or house interiors. No new story, no dollar amounts in flavor text, no cult or power content.

## M11B includes

One name per storefront (hanging sign, no painted duplicate on the facade). Maple Lane lots filled with hedges, sheds, trees, a vacant for-sale lot, backyard edges, and a seventh house. Evening and night ambient people on Oak and Maple, plus warm window lights. No new story.

## M11B does not include

Enterable interiors, new story flags, or changes to named NPC schedules.

## M11C includes

Storefront names on a rooftop / parapet board above the facade. One sign per building, readable at the game camera, never covering the door or the sidewalk in front of it. Evening townsfolk on Oak Street stand beside Hardware and Bright's instead of on the letters. No new story.

## M11C does not include

Enterable interiors, new story flags, or changes to named NPC schedules.

## Gameplay A includes

A data-driven item catalog, a 16-slot pack, a personal wallet separate from ChurchFunds, an I-key inventory, a small equipped-tool strip, starter tools in the parsonage, starter seeds at the Maple Lane garden crate, and a hardware-store buy UI for seeds, Wood, and Nails. Saves are version 7. A version 6 file loads with an empty pack and starting cash. Chapter 1 lines, flags, and leanings are unchanged. Dollars never appear in dialogue.

## Gameplay A does not include

Planting, watering, harvest, community requests, staged repairs, or the potluck. Those are B–E. Scrap has no source yet.

## Gameplay B includes

Nine individually interactable plots in a fenced vegetable garden on the church grounds (east of the picnic lawn, not the memorial garden and not a Future Site lot). Hoe, seed, water, overnight growth if watered, harvest into the pack. Crop data in `data/crops/catalog.json`. The Maple Lane Chapter 1 plot and flags stay as they were. The starter seed crate sits in the church garden. Saves are version 8. A version 7 file loads with empty untilled plots. Gardening does not raise Pull, attendance, or ChurchFunds.

## Gameplay B does not include

Community requests, staged repairs, or the potluck. Those are C–E. Harvests are items with no automatic story effect.

## Gameplay C includes

A data-driven request catalog with four optional asks: Sarah's vegetables, Margaret's sanctuary flowers, Harold's fence (3 Wood, 2 Nails), and Ruth's Maple Lane garden. Accept through dialogue. Up to three active. The journal lists required items, progress, where to return, and a short history. Delivering removes the items. Rewards vary (a thank-you, a small personal tip, an item, a remembered flag, a later line, a visible place change). Completing an ask does not raise Pull, attendance, or ChurchFunds. The church garden is in-ground tile farming inside the fence, with a facing-tile marker. Saves are version 9. A version 8 file loads with no active asks; old beds map onto tiles.

## Gameplay C does not include

Staged repairs as a player interaction (Harold's ask only delivers materials) or the weekly potluck. Those are D–E. Insiders still never say "cult".

## Gameplay D includes

A data-driven worksite catalog: clearing picnic weeds, picking up utility litter, restoring a picnic flower bed, and a four-stage garden fence (damaged, boards off, new wood, finished) that uses 3 Wood and 2 Nails. Basic Hand Tools, short E presses, `Missing: 3 Wood` when stock is short. Harold's fence ask completes after the player mends the stretch; no double scrap. `GroundsChore` and the Maple Lane Chapter 1 plot stay. Repairs do not raise Pull, attendance, or ChurchFunds. Saves are version 10. A version 9 file loads; an already-mended fence starts finished.

## Gameplay D does not include

The weekly potluck. That is E. Insiders still never say "cult".

## Gameplay E includes

The M8 Wednesday happening, extended into a walk-in Fellowship Hall interior after Continue and after the hall is repaired. Optional prep (vegetables, flowers, grounds, the picnic bed, invites) changes dishes, centerpieces, lights, chairs, and guests. Sarah's once-only framing (open vs church-centered) uses hidden leanings. A successful gathering does not raise Pull and does not touch ChurchFunds. Small action toasts replace the old full-width farming banners. Saves are version 11. A version 10 file loads.

## Gameplay E does not include

A second Sunday, a Chapter 1 rewrite, a morality meter, or Phase F's full-loop balance pass. Insiders still never say "cult".

## Gameplay F includes

A connected daily/weekly loop: inventory, church garden, four asks, four repairs, potluck prep and attendance, save/load. DayClock stays at 4 in-game minutes per real second after a scripted walking budget (a packed morning is about four in-game hours). Catalog prices and crop times stay. Toasts no longer overlap the prompt. Picnic weeds, utility litter, picnic blooms, and fence debris were cleaned up. Dale and Ruth have named sheets. Ruth's Maple Lane ask still does not complete from the church garden. Saves stay version 11.

## Gameplay F does not include

A sanctuary or Fellowship Hall interior redesign. That is M13. No save bump, no new items, no automatic Pull from the loop. Insiders still never say "cult".

## M13 includes

A complete interior redesign of the sanctuary (narthex, worship hall, pastor's office, prayer room, choir, storage, hallway) and the Fellowship Hall (main hall, kitchen, classroom, storage, hallway). Ambient neighbors on short idle loops. Short flavor lines. Warm interior light and stained-glass color in the sanctuary. Sunday seating, the ledger, Margaret's flowers, the potluck, M8, and the Chapter 1 ending stay in place.

## M13 does not include

A save bump, new story flags, automatic Pull / attendance / ChurchFunds, combat, or connecting the two interiors into one map. The buildings still open from the grounds.
