# Art Bible — The Calling (v0.1, 2026-11-11)

## 1. Direction
**Original** pixel art combining the **top-down readability of classic Pokémon** with the **environmental density and
atmosphere of Graveyard Keeper**. These are references for *feel only*: never copy or trace sprites, tiles, maps,
characters, logos, UI, music, or exact tile arrangements. No AI-generated images in production assets.

Mood: a warm, lived-in, slightly worn American small town. Mornings hopeful, evenings melancholy, nights quiet and safe.

## 2. Perspective and grid
- Top-down / three-quarter **art perspective** (building faces drawn on), rendered in pure 2D; no 3D camera.
- **Tile size: 32×32 px.** All terrain, walls and floor tiles align to this grid.
- Props snap to the 32 grid where possible; small props may use 16 px offsets.
- Y-sorting: characters pass behind trees/building tops and in front of bases. Put the sprite origin at the feet.

## 3. Characters
- Footprint ≈ **32×48 px** (one tile wide, 1.5 tiles tall); tune against doors (≈32×48–64 opening) and furniture.
- **4 facing directions initially** (down, up, left, right; right may be a mirrored left only if the design is symmetric).
  Movement may be 8-way; animation uses the nearest of 4 facings (see GAME_DESIGN open decision D1).
- Initial animation sets: idle (1–2 frames), walk (4 frames) per direction. 8–10 fps for walk.
- Readable silhouettes at 1×: distinct hair/hat shapes and clothing color blocks per named NPC.
- Outline: dark, hue-shifted outline (not pure black); selective inner lines.

## 4. Palette direction
- Limited master palette (target **32–48 colors**), stored as `assets/source/palette/the_calling_master.gpl` once
  defined. Every asset uses only master-palette colors.
- Warm natural greens, earthy browns, brick reds, weathered whites/creams, muted blues for sky/shadow.
- Hue-shift ramps: shadows toward cool purple/blue, highlights toward warm yellow. Avoid pure #000000 and #FFFFFF.
- Signs of age: faded paint, cracked pavement, moss, rust on utility boxes.
- Interactables must not rely on color alone (accessibility): use shape, outline highlight, or prompt icon.

## 5. Camera and resolution
- Internal viewport **640×360**, window 1280×720 default, stretch mode `viewport`, scale `integer` → pixel-perfect at
  2×/3× (1080p = 3×).
- `Camera2D` follows the player within map bounds; no rotation/zoom systems in M1.
- Pixel snapping on (transforms and vertices). If smoothed camera motion shows jitter, test alternatives and record the
  choice; do not mix sub-pixel positions on pixel art.

## 6. Texture filtering
- Project default canvas texture filter = **Nearest**. Never enable Linear filtering or mipmaps on pixel art.
- Imported PNGs: lossless compression, no mipmaps, no "fix alpha border" artifacts on tiles.

## 7. Lighting and day/night
- Use **CanvasModulate** for ambient time-of-day color (day ≈ neutral warm, evening ≈ amber/rose, night ≈ deep blue,
  never so dark that paths or the player are unreadable).
- **DirectionalLight2D** for global sun/moon tint where useful; **PointLight2D** for lamps, windows, porch lights,
  stained glass; **LightOccluder2D** on buildings/large props for stylized shadows.
- Keep dynamic lights few (performance on ordinary laptops). Prefer authored shadow sprites under trees/props.
- Light textures: soft but low-resolution; avoid banding by using palette-friendly falloff.

## 8. Asset pipeline
1. Draw in **LibreSprite** (or Aseprite later); save editable source `assets/source/<category>/<name>.ase`.
2. Export PNG to `assets/<category>/<name>.png` (sheets: `<name>_sheet.png`, fixed cell size, no padding unless noted).
3. Godot imports with Nearest filtering automatically. Commit the `.png`, its `.import`, and the `.ase` source.
4. Naming: `snake_case`, category prefix optional (`tile_grass_01`, `npc_margaret_walk_down`).
5. Tilesets: 32×32 cells in `assets/tilesets/`, one TileSet resource per biome/area.

## 9. Consistency checklist (every asset)
- [ ] Original work, license recorded if third-party.
- [ ] Correct dimensions (32×32 tile / ~32×48 character cell).
- [ ] Master palette only.
- [ ] Light source assumed **top-left** for baked shading.
- [ ] Outline style consistent with existing assets.
- [ ] Readable at 1× and at 3× scale.
- [ ] Source `.ase` saved alongside exported PNG.
