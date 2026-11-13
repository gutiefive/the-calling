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
const VEG_GARDEN := Rect2i(39, 32, 9, 9)
const VEG_PLOT_ORIGIN := Vector2(1344, 1120)
const VEG_PLOT_STRIDE := 48.0
const VEG_CRATE := Vector2(1288, 1168)
const VEG_NOTE := Vector2(1288, 1136)
const VEG_FENCE_MEND := Vector2(1248, 1120)
const VEG_BARREL := Vector2(1296, 1072)
const VEG_WHEELBARROW := Vector2(1488, 1072)
const VEG_COMPOST := Vector2(1488, 1264)
const VEG_GARDEN_BENCH := Vector2(1392, 1264)
const REVERT_DAYS := 3
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


static func veg_plot_position(index: int) -> Vector2:
	var col := index % 3
	var row := int(index / 3)
	return VEG_PLOT_ORIGIN + Vector2(float(col) * VEG_PLOT_STRIDE, float(row) * VEG_PLOT_STRIDE)


static func veg_interior() -> Rect2i:
	var garden := VEG_GARDEN
	return Rect2i(garden.position.x + 1, garden.position.y + 1, garden.size.x - 2, garden.size.y - 2)


static func veg_reserved_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [
		Vector2i(40, 34),
		Vector2i(40, 35),
		Vector2i(40, 36),
		Vector2i(40, 33),
		Vector2i(46, 33),
		Vector2i(46, 39),
		Vector2i(43, 39),
	]
	return cells


static func veg_path_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [
		Vector2i(39, 34),
		Vector2i(39, 35),
		Vector2i(39, 36),
		Vector2i(40, 34),
		Vector2i(40, 35),
		Vector2i(40, 36),
	]
	return cells


static func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / float(TILE))), int(floor(pos.y / float(TILE))))


static func cell_id(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


static func parse_cell_id(plot_id: String) -> Vector2i:
	var parts := plot_id.split(",")
	if parts.size() < 2:
		return Vector2i(-1, -1)
	return Vector2i(int(parts[0]), int(parts[1]))


static func facing_cell(pos: Vector2, facing: StringName) -> Vector2i:
	var cell := world_to_cell(pos)
	match facing:
		&"up":
			cell.y -= 1
		&"down":
			cell.y += 1
		&"left":
			cell.x -= 1
		&"right":
			cell.x += 1
	return cell


static func is_veg_reserved(cell: Vector2i) -> bool:
	for reserved in veg_reserved_cells():
		if reserved == cell:
			return true
	return false


static func is_veg_tillable(cell: Vector2i) -> bool:
	var interior := veg_interior()
	if not interior.has_point(cell):
		return false
	return not is_veg_reserved(cell)


static func legacy_bed_cell(index: int) -> Vector2i:
	return world_to_cell(veg_plot_position(index))


static func legacy_bed_id(index: int) -> String:
	return cell_id(legacy_bed_cell(index))


static func north_border_center() -> Vector2:
	return Vector2(map_px().x * 0.5, 8.0)


static func north_border_size() -> Vector2:
	return Vector2(map_px().x, 16.0)
