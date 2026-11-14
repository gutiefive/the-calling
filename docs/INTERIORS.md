# Interiors — Sanctuary and Fellowship Hall (M13 / M13B / M13C / M13D / M13E / M13F)

Status: M13 implemented 2026-11-13. M13B furniture and clutter density pass implemented 2026-11-13. M13C Fellowship Hall tables and main-hall fill implemented 2026-11-13. M13D Fellowship Hall final polish implemented 2026-11-13. M13E sanctuary finish and Fellowship Hall gameplay polish implemented 2026-11-13. M13F interior rough-spot patch implemented 2026-11-14. One scene per building. Doorways, not separate rooms. Save stays v11. The north sanctuary rooms are seven tiles tall.

## Sanctuary (`scenes/world/sanctuary.tscn`)

Walk in from the courtyard. South door returns to the grounds.

| Room | What's in it |
|---|---|
| Narthex | Doormat, rug with border and fringe, welcome table with bulletins, coat rack and wall hooks with coats, umbrella stand, plants, a tract rack, a donation box (no dollar text), a prayer-request box, framed photos of church history, a lost umbrella, a side table with a lamp, guest book, community bulletin, benches |
| Worship hall | Center aisle and carpet runner with stained-glass color on the floor, five pew rows with end caps and hymnal racks, side-aisle rugs, plants and flower stands, wall sconces, pendant lights, a baptism font and baptistry, flags, a sound desk at the back, banners, a projector screen, candle stands, piano and bench with sheet music, chairs on the platform, pulpit, altar with cloth, candles and flowers, wooden cross, offering plates, hymn board, Margaret's flowers when that ask is done |
| Pastor's office | Rug, desk with lamp, papers, Bible, mug and phone, chair, two guest armchairs, three bookshelves with mixed spines, filing cabinet, **the church ledger**, a coat on a hook, wall calendar, diploma, radiator, plant, window, framed picnic photo, a pencil sketch of extra wings |
| Prayer room | Rug, kneeler, candles, a quiet bench, prayer request board with pinned notes, a small table with an open book, a small cross, cushions, a journal on a stand, a plant. Someone may be praying. Not frightening. |
| Choir | Piano, chairs in rows on a riser, music stands, a robe rack, a shelf of folders, a practice-schedule board, the spare key ring |
| Storage | Shelves, boxes, labeled bins, folding tables, stacked chairs, a vacuum, Christmas decoration bins, a mop and bucket, a ladder |
| Hallway | Framed photos, a coat rack, a fire extinguisher, a plant, a water fountain. A restroom door that does not open |

Sunday still seats the named people and twelve congregants in the pews. After the service they stand in the south of the worship hall, off the aisle door. Harold's weekday post is the west side of the pews (tidying hymnals). Margaret's is the east window (the flowers).

## Fellowship Hall (`scenes/world/fellowship_hall.tscn`)

Walk in from the west-wing door after the hall is repaired and celebrated. South door returns to the grounds. The two interiors do not connect to each other. The main hall is a little shorter than the M13 placeholder so the furniture can fill it.

| Room | What's in it |
|---|---|
| Main hall | Wood floor with a muted warm center aisle runner (subtle gold border), a stage rug, and a sitting-corner rug (no floating rectangles). Two rows of larger round and long tables: cloth folds and hem, a runner on Table B, chair backs on the far side and seats on the near side, and clutter that changes by table. The south row sits far enough north to read in the close camera. Zones keep 2-tile walkways: a couch corner, a welcome table and coat rack by the south door, a coffee and snack station by the entrance in the close view, a kids' corner east of the door (play rug, small table, chairs, toy bin, books, and wall drawings) visible in the starting close camera, a stage with curtain, podium, mic, and speakers, a piano with bench, a trophy and photo wall, stacked chair carts and a folded-table rack, plants, window light pools, and banners. Wall drawings, banners, and the alphabet strip sit on the wall layer so they do not overlap trim. Wednesday still dresses Table A/B with dishes, centerpieces, spanning string lights, a banner, extra chairs, and invited guests standing at those tables |
| Kitchen | Counters with a tile backsplash, hanging utensils, a window over the sink, upper cabinets, stove with pots, fridge, dish rack, microwave, mixer, an island, pantry, cooler, mop, a meal-train board, serving table at the pass-through |
| Classroom | Small tables, kids' chairs, chalkboard, crayons, cubbies, a patterned reading rug, beanbags, a toy bin, a globe, a teacher's desk, an alphabet strip, wall art, a bookshelf |
| Storage | Shelves, boxes, labeled bins, folding tables, a vacuum, Christmas bins, a supply crate (the M8 happening crate stays outside by the hall door) |
| Hallway | A runner rug, framed photos, a coat rack, a fire extinguisher, a plant, a water fountain, the lost-and-found box |

Wednesday 11:00–16:00 still holds the potluck. Margaret stays near the serving window. Harold and Sarah stand south of tables A and B. Invited neighbors stand at those same tables, inside the close camera. Extra chairs sit just north of Table A.

## Ambient neighbors

They use the existing unnamed-townsfolk art and a small idle loop. They do not block doorways or stand inside furniture.

| Who | Where | When |
|---|---|---|
| Prayer neighbor | Prayer room | Weekdays, day and evening, hidden during the Sunday service |
| Choir helper | Choir | Mon–Wed and Friday daytime, hidden during the service |
| Kitchen volunteer | Kitchen | Weekday daytime |
| Classroom kid | Classroom | Saturday, Sunday, and Wednesday daytime |

## Flavor lines

Bulletin, guest book, piano, stained glass, hymn board, office sketch, office photo, restroom door, prayer-request box, prayer journal, choir schedule, offering plates, hall bulletin, coffee, lost-and-found, speaker, chalkboard, crayons. Short. No dollar amounts. Insiders never say "cult". The office sketch is the only quietly ambiguous beat.

## Lighting

Warm interior `CanvasModulate` already followed the clock. Sconces and lamps still brighten at night. Stained-glass lights are brighter in the day and dim at night. Window color still reaches the pews; the center aisle uses a softer, lower-alpha wash so the close camera reads as gentle colored light, not bright patches.
