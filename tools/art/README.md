# Character art

Milestone 6A part 1 writes six 32×48 character sheets:

- `assets/characters/player_sheet.png`
- `assets/characters/npc_margaret_sheet.png`
- `assets/characters/npc_harold_sheet.png`
- `assets/characters/npc_thomas_sheet.png`
- `assets/characters/npc_frank_sheet.png`
- `assets/characters/npc_sarah_sheet.png`

Each sheet is 192×192: four rows (down, up, left, right) and six columns (idle, idle, walk ×4). Colors come from `assets/source/palette/the_calling_master.gpl`.

## Regenerate

From the repo root, with the Godot 4.7.2 console binary:

```powershell
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_sprites.gd
C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
```

The generator lives in `scripts/art/character_frames.gd`. It stamps a shared body, then hair and a small extra (collar, glasses, apron, bag, cap). Walk frames offset the marked limbs. Do not copy another game's sprites.

## LibreSprite is the source of truth for an edited PNG

If you open a sheet in LibreSprite (`C:\Tools\LibreSprite`) and save over that PNG, the PNG is now the source of truth. Do not re-run the generator for that file unless you mean to throw the hand edits away. Record that in `docs/DECISIONS.md`.
