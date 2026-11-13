# Authored art

Headless generators write PNG files from palette-only pixel maps. Do not copy another game's art.

## Characters (M6A part 1)

Named 32×48 sheets at `assets/characters/`:

- `player_sheet.png`
- `npc_margaret_sheet.png`
- `npc_harold_sheet.png`
- `npc_thomas_sheet.png`
- `npc_frank_sheet.png`
- `npc_sarah_sheet.png`
- `npc_ostrow_sheet.png` (Dell Ostrow, M7)

Each sheet is 192×192: four rows (down, up, left, right) and six columns (idle, idle, walk ×4). Colors come from `assets/source/palette/the_calling_master.gpl`.

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_sprites.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

The generator lives in `scripts/art/character_frames.gd`. It stamps a shared body, then hair and a small extra (collar, glasses, apron, bag, cap). Walk frames offset the marked limbs. The drop shadow sits under the feet.

## Environment (M6A part 2)

Tileset, 32×32 cells:

- `assets/tilesets/town_tiles.png` (256×128, eight columns, four rows)
- `assets/tilesets/town_tiles.tres`

Church-lot props in `assets/environments/`:

- `church_front.png` (384×160)
- `tree.png` (48×80)
- `bench.png` (48×32)
- `lamp_post.png` (24×56)
- `notice_board.png` (32×48)
- `mailbox.png` (32×40)

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_environment.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

Oak Street buildings and street props in `assets/environments/`:

- `hardware_store.png` (224×128)
- `auto_shop.png` (256×128)
- `cottage.png` (160×112)
- `brights_diner.png` (224×128)
- `post_office.png` (192×128)
- `barber_shop.png` (160×128)
- `vacant_shop.png` (192×128)
- `parked_car_a.png` / `parked_car_b.png` (64×32)
- `trash_can.png` (16×24)
- `fire_hydrant.png` (16×24)

M11 south-side shops, rooftop signs, houses, and street props:

- `credit_union.png` (192×128), `pharmacy.png` (176×128), `thrift_shop.png` (160×128)
- `feed_store.png` (192×128), `town_hall.png` (208×128), `boarded_shop.png` (160×128)
- `sign_*.png` rooftop / parapet signs (128×32)
- `house_0_east.png` through `house_5_west.png` (144×96)
- `newspaper_box.png`, `bike_rack.png`, `flower_box.png`, `swing_set.png`, `kids_bike.png`, `garden_hose.png`, `dog_house.png`, `rocking_chair.png`, `picket_fence.png`
- `garden_shed.png`, `garden_shed_b.png`, `hedge_bush.png`, `hedge_bush_b.png`, `for_sale_sign.png`, `dog.png`

Maps and helpers live in `scripts/art/environment_frames.gd`, `scripts/art/street_frames.gd`, and `scripts/art/pixel_draw.gd`. Atlas coordinates are `scripts/art/town_tiles.gd`. Sanctuary floors, shop interiors, and unnamed townsfolk still use `PlaceholderArt`.

## Items (Gameplay A)

16×16 icons in `assets/items/`, one PNG per catalog id. Maps live in `scripts/art/item_frames.gd`. `author_environment.gd` writes them with the rest of the outdoor set. To write only items:

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_items.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

## Garden (Gameplay B)

32×32 soil, crop stages, and action flashes in `assets/garden/`. Maps live in `scripts/art/crop_frames.gd`.

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_crops.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

## Repairs (Gameplay D)

32×32 fence, weeds, litter, and flower-bed stages in `assets/repairs/`. Maps live in `scripts/art/repair_frames.gd`.

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_repairs.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

## LibreSprite is the source of truth for an edited PNG

If you open a sheet in LibreSprite (`C:\Tools\LibreSprite`) and save over that PNG, the PNG is now the source of truth. Do not re-run the generator for that file unless you mean to throw the hand edits away. Record that in `docs/DECISIONS.md`.
