# Interiors — Sanctuary and Fellowship Hall (M13 / M13B / M13C)

Status: M13 implemented 2026-11-13. M13B furniture and clutter density pass implemented 2026-11-13. M13C Fellowship Hall tables and main-hall fill implemented 2026-11-13. One scene per building. Doorways, not separate rooms. Save stays v11.

## Sanctuary (`scenes/world/sanctuary.tscn`)

Walk in from the courtyard. South door returns to the grounds.

| Room | What's in it |
|---|---|
| Narthex | Doormat, rug, welcome table, coat rack and wall hooks with coats, umbrella stand, plants, a tract rack, a donation box (no dollar text), framed photos, a lost umbrella, a side table with a lamp, guest book, community bulletin, a bench |
| Worship hall | Center aisle and carpet runner with stained-glass color on the floor, five pew rows with hymnals, side-aisle rugs, plants and flower stands, wall sconces, a baptism font, a sound desk at the back, banners, a projector screen, candle stands, piano and bench with sheet music, chairs on the platform, pulpit, altar, wooden cross, Margaret's flowers when that ask is done |
| Pastor's office | Rug, desk, chair, visitor armchair, two bookshelves, filing cabinet, **the church ledger**, lamp, mug and papers, a coat on a hook, wall calendar, radiator, plant, window, framed picnic photo, a pencil sketch of extra wings |
| Prayer room | Rug, kneeler, candles, a quiet bench, prayer request board with pinned notes, a small table with an open book, a plant. Someone may be praying. Not frightening. |
| Choir | Piano, chairs in rows, music stands, a robe rack, a shelf of folders, the spare key ring |
| Storage | Shelves, boxes, folding tables, a vacuum, Christmas decoration bins, a mop and bucket |
| Hallway | Framed photos, a coat rack, a fire extinguisher, a plant, a water fountain. A restroom door that does not open |

Sunday still seats the named people and twelve congregants in the pews. After the service they stand in the south of the worship hall, off the aisle door. Harold's weekday post is the west side of the pews (tidying hymnals). Margaret's is the east window (the flowers).

## Fellowship Hall (`scenes/world/fellowship_hall.tscn`)

Walk in from the west-wing door after the hall is repaired and celebrated. South door returns to the grounds. The two interiors do not connect to each other. The main hall is a little shorter than the M13 placeholder so the furniture can fill it.

| Room | What's in it |
|---|---|
| Main hall | Wood floor with a few cool-blue rugs (not under the tables). Two rows of round and long tables with chairs and light clutter, plus 2-tile walkways from the south door to the stage, kitchen pass-through, hallway, and interactables. Stacked chair carts, a small stage with a curtain, podium, piano, bulletin, coffee station, lost-and-found, speaker, craft table, puzzle table, water cooler, trash and recycling, plants, windows, kids' art and banners. Potluck dishes, centerpieces, lights, banner, and extra chairs still swap with prep and sit on the banquet tables |
| Kitchen | Counters, upper cabinets, stove with pots, fridge, sink with a dish rack, microwave, mixer, an island, pantry, cooler, mop, serving table at the pass-through |
| Classroom | Small tables, kids' chairs, chalkboard, crayons, cubbies, a reading rug, beanbags, a toy bin, a globe, a teacher's desk, wall art, a bookshelf |
| Storage | Shelves, boxes, folding tables, a vacuum, Christmas bins, a supply crate (the M8 happening crate stays outside by the hall door) |
| Hallway | Photos, a coat rack, a fire extinguisher, a plant, a water fountain |

Wednesday 11:00–16:00 still holds the potluck. Margaret, Harold, and Sarah stand in the main hall near the serving table. Invited neighbors join them.

## Ambient neighbors

They use the existing unnamed-townsfolk art and a small idle loop. They do not block doorways or stand inside furniture.

| Who | Where | When |
|---|---|---|
| Prayer neighbor | Prayer room | Weekdays, day and evening, hidden during the Sunday service |
| Choir helper | Choir | Mon–Wed and Friday daytime, hidden during the service |
| Kitchen volunteer | Kitchen | Weekday daytime |
| Classroom kid | Classroom | Saturday, Sunday, and Wednesday daytime |

## Flavor lines

Bulletin, guest book, piano, stained glass, hymn board, office sketch, office photo, restroom door, hall bulletin, coffee, lost-and-found, speaker, chalkboard, crayons. Short. No dollar amounts. Insiders never say "cult". The office sketch is the only quietly ambiguous beat.

## Lighting

Warm interior `CanvasModulate` already followed the clock. Sconces and lamps still brighten at night. Stained-glass lights are brighter in the day and dim at night, and they tint the worship floor including the center aisle.
