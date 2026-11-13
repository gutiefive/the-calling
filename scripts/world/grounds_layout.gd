class_name GroundsLayout
extends RefCounted
## Shared church-campus geometry. ChurchExterior paints from these numbers;
## tests read the same constants so a layout change cannot drift.

const TILE := 32
const MAP_SIZE := Vector2i(64, 48)

const POS_CHURCH := Vector2(912, 576)
const POS_DOOR := Vector2(912, 562)
const POS_MAT := Vector2(912, 592)
const POS_SPAWN := Vector2(912, 720)
const POS_RETURN := Vector2(912, 620)
const POS_MARGARET := Vector2(1040, 640)
const POS_MARGARET_EVENING := Vector2(1040, 880)
const POS_NOTICE := Vector2(1680, 820)
const POS_BENCH := Vector2(800, 688)
const POS_LAMP := Vector2(848, 640)
const POS_FLOWERS := Vector2(1024, 688)
const POS_WIN_L := Vector2(792, 532)
const POS_WIN_R := Vector2(1032, 532)
const POS_STREET_DOOR := Vector2(2016, 864)
const POS_FROM_STREET := Vector2(1860, 864)
const POS_HAROLD := Vector2(848, 704)
const POS_OSTROW := Vector2(912, 800)
const POS_HALL := Vector2(448, 704)
const POS_PARSONAGE := Vector2(256, 1216)
const POS_HOME_DOOR := Vector2(256, 1232)
const POS_FROM_PARSONAGE := Vector2(256, 1296)
const POS_CROSS := Vector2(912, 672)
const POS_MONUMENT := Vector2(1760, 780)
const POS_GATE_N := Vector2(1968, 800)
const POS_GATE_S := Vector2(1968, 928)
const POS_SIGNPOST := Vector2(1840, 900)
const POS_MAILBOX := Vector2(320, 1264)
const POS_BELL := Vector2(1008, 640)

const PATH_CHURCH := Vector2i(28, 20)
const PATH_TO_STREET := Vector2i(50, 27)

const MAIN_GATE := Rect2i(63, 22, 1, 11)
const SIDE_GATE := Rect2i(0, 37, 1, 2)

const COURTYARD := Rect2i(22, 19, 14, 8)
const PARKING := Rect2i(42, 18, 14, 6)
const PICNIC := Rect2i(20, 32, 18, 10)
const GARDEN := Rect2i(3, 3, 9, 8)
const DRIVE := Rect2i(36, 25, 28, 5)


static func map_px() -> Vector2:
	return Vector2(MAP_SIZE.x * TILE, MAP_SIZE.y * TILE)


static func tile_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE * 0.5, cell.y * TILE + TILE * 0.5)


static func is_path_atlas(atlas: Vector2i) -> bool:
	return atlas == TownTiles.PATH or atlas == TownTiles.SIDEWALK or atlas == TownTiles.PARKING or atlas == TownTiles.DRIVEWAY or atlas == TownTiles.ASPHALT or atlas == TownTiles.CROSSWALK_H or atlas == TownTiles.CROSSWALK_V or atlas == TownTiles.LINE_H or atlas == TownTiles.LINE_V


static func is_perimeter_atlas(atlas: Vector2i) -> bool:
	return atlas == TownTiles.FENCE or atlas == TownTiles.HEDGE


static func is_gate_cell(cell: Vector2i) -> bool:
	if cell.x == MAIN_GATE.position.x and cell.y >= MAIN_GATE.position.y and cell.y < MAIN_GATE.position.y + MAIN_GATE.size.y:
		return true
	if cell.x == SIDE_GATE.position.x and cell.y >= SIDE_GATE.position.y and cell.y < SIDE_GATE.position.y + SIDE_GATE.size.y:
		return true
	return false


static func is_perimeter_cell(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= MAP_SIZE.x or cell.y >= MAP_SIZE.y:
		return false
	if is_gate_cell(cell):
		return false
	return cell.x == 0 or cell.y == 0 or cell.x == MAP_SIZE.x - 1 or cell.y == MAP_SIZE.y - 1


static func church_body_center() -> Vector2:
	return POS_CHURCH + Vector2(0.0, -28.0 - 132.0 * 0.5)


static func church_body_size() -> Vector2:
	return Vector2(384, 132)


static func church_west_jamb_center() -> Vector2:
	return POS_CHURCH + Vector2(-(64.0 + 160.0) * 0.5, -28.0 * 0.5)


static func church_east_jamb_center() -> Vector2:
	return POS_CHURCH + Vector2((64.0 + 160.0) * 0.5, -28.0 * 0.5)


static func church_jamb_size() -> Vector2:
	return Vector2(160, 28)


static func north_border_center() -> Vector2:
	return Vector2(map_px().x * 0.5, 8.0)


static func north_border_size() -> Vector2:
	return Vector2(map_px().x, 16.0)
