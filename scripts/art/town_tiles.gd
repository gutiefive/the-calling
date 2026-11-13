class_name TownTiles
extends RefCounted
## Atlas coordinates for assets/tilesets/town_tiles.png (32x32 cells, 8 by 2).
## Row 0 keeps the outdoor indices older rooms already paint: grass, path, sidewalk, water.

const RESOURCE_PATH := "res://assets/tilesets/town_tiles.tres"
const ATLAS_PATH := "res://assets/tilesets/town_tiles.png"

const GRASS_A := Vector2i(0, 0)
const GRASS_B := Vector2i(1, 0)
const PATH := Vector2i(2, 0)
const SIDEWALK := Vector2i(3, 0)
const GRASS_C := Vector2i(4, 0)
const ROAD := Vector2i(5, 0)
const CURB := Vector2i(6, 0)
const WATER := Vector2i(7, 0)
const FENCE := Vector2i(0, 1)
const HEDGE := Vector2i(1, 1)
const FLOWER_BED := Vector2i(2, 1)
const CHURCH_FLOOR := Vector2i(3, 1)
const WOOD_FLOOR := Vector2i(4, 1)
const WALL_BASE := Vector2i(5, 1)


static func apply_to(layer: TileMapLayer) -> bool:
	if layer == null:
		return false
	var tiles: TileSet = load(RESOURCE_PATH) as TileSet
	if tiles == null:
		return false
	layer.tile_set = tiles
	return true


static func grass_at(x: int, y: int) -> Vector2i:
	var n := (x * 13 + y * 7) % 11
	if n == 0:
		return GRASS_B
	if n == 1:
		return GRASS_C
	return GRASS_A
