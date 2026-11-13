# Interiors — Sanctuary and Fellowship Hall (M13)

Status: implemented 2026-11-13. One scene per building. Doorways, not separate rooms. Save stays v11.

## Sanctuary (`scenes/world/sanctuary.tscn`)

Walk in from the courtyard. South door returns to the grounds.

| Room | What's in it |
|---|---|
| Narthex | Entry, welcome table with bulletins, coat rack, guest book, community bulletin, a bench |
| Worship hall | Center aisle and carpet runner, four pew rows, platform, altar, pulpit, wooden cross, stained-glass windows and colored light on the floor, piano, hymn board, candles, Margaret's flowers when that ask is done |
| Pastor's office | Desk, chair, bookshelf, filing cabinet, **the church ledger**, window, lamp, framed picnic photo, a pencil sketch of extra wings |
| Prayer room | Kneeler, candles, a quiet bench. Someone may be praying. Not frightening. |
| Choir | Piano, stacked chairs, the spare key ring |
| Storage | Folding tables and supplies |
| Hallway | Connects the north rooms. A restroom door that does not open |

Sunday still seats the named people and twelve congregants in the pews. After the service they stand in the south of the worship hall, off the aisle door. Harold's weekday post is the west side of the pews (tidying hymnals). Margaret's is the east window (the flowers).

## Fellowship Hall (`scenes/world/fellowship_hall.tscn`)

Walk in from the west-wing door after the hall is repaired and celebrated. South door returns to the grounds. The two interiors do not connect to each other.

| Room | What's in it |
|---|---|
| Main hall | Wood floor, round and long tables, chairs, a podium, bulletin, windows, coffee station, lost-and-found, a speaker, stacked chairs. Potluck dishes, centerpieces, lights, banner, and extra chairs still swap with prep |
| Kitchen | Counters, stove, fridge, sink, pots, cooler, serving table at the pass-through |
| Classroom | Small tables, kids' chairs, chalkboard, crayons, a bookshelf |
| Storage | Folding tables and a supply crate (the M8 happening crate stays outside by the hall door) |
| Hallway | Connects kitchen, storage, classroom, and the main hall |

Wednesday 11:00–16:00 still holds the potluck. Margaret, Harold, and Sarah stand in the main hall near the serving table. Invited neighbors join them.

## Ambient neighbors

They use the existing unnamed-townsfolk art and a small idle loop. They do not block doorways.

| Who | Where | When |
|---|---|---|
| Prayer neighbor | Prayer room | Weekdays, day and evening, hidden during the Sunday service |
| Choir helper | Choir | Mon–Wed and Friday daytime, hidden during the service |
| Kitchen volunteer | Kitchen | Weekday daytime |
| Classroom kid | Classroom | Saturday, Sunday, and Wednesday daytime |

## Flavor lines

Bulletin, guest book, piano, stained glass, hymn board, office sketch, office photo, restroom door, hall bulletin, coffee, lost-and-found, speaker, chalkboard, crayons. Short. No dollar amounts. Insiders never say "cult". The office sketch is the only quietly ambiguous beat.

## Lighting

Warm interior `CanvasModulate` already followed the clock. Sconces and lamps still brighten at night. Stained-glass lights are brighter in the day and dim at night, and they tint the worship floor.
