class_name InteriorLayout
extends RefCounted
## Shared sanctuary and Fellowship Hall room geometry. Tile rects are floor cells.

const TILE := 32

const TILE_WALL := Vector2i(0, 0)
const TILE_WOOD := Vector2i(1, 0)
const TILE_KITCHEN := Vector2i(2, 0)
const TILE_CARPET := Vector2i(3, 0)
const TILE_RUNNER := Vector2i(4, 0)
const TILE_STONE := Vector2i(5, 0)
const TILE_LINO := Vector2i(6, 0)
const TILE_STAIN := Vector2i(7, 0)

const SANCTUARY_SIZE := Vector2i(46, 38)
const HALL_SIZE := Vector2i(42, 32)

const SANCTUARY_AISLE_CELL := Vector2i(22, 18)

const SANCT_OFFICE := Rect2i(1, 1, 10, 5)
const SANCT_PRAYER := Rect2i(12, 1, 9, 5)
const SANCT_CHOIR := Rect2i(22, 1, 10, 5)
const SANCT_STORAGE := Rect2i(34, 1, 10, 5)
const SANCT_HALLWAY := Rect2i(1, 7, 44, 2)
const SANCT_WORSHIP := Rect2i(6, 10, 34, 17)
const SANCT_NARTHEX := Rect2i(10, 28, 26, 9)

const HALL_KITCHEN := Rect2i(1, 1, 12, 7)
const HALL_STORAGE := Rect2i(14, 1, 10, 7)
const HALL_CLASS := Rect2i(26, 1, 14, 7)
const HALL_HALLWAY := Rect2i(1, 9, 40, 2)
const HALL_MAIN := Rect2i(4, 12, 34, 19)

const POS_SANCT_DOOR := Vector2(736, 1192)
const POS_SANCT_SPAWN := Vector2(736, 1088)
const POS_SANCT_ALTAR := Vector2(736, 360)
const POS_SANCT_CROSS := Vector2(736, 328)
const POS_SANCT_PULPIT := Vector2(640, 380)
const POS_SANCT_PIANO := Vector2(1080, 380)
const POS_SANCT_FLOWERS := Vector2(1200, 400)
const POS_SANCT_LEDGER := Vector2(220, 148)
const POS_SANCT_KEYS := Vector2(960, 160)
const POS_SANCT_HAROLD := Vector2(280, 520)
const POS_SANCT_MARGARET := Vector2(1200, 430)
const POS_SANCT_THOMAS := Vector2(1000, 780)
const POS_SANCT_FRANK := Vector2(500, 780)
const POS_SANCT_SARAH := Vector2(680, 840)
const POS_SANCT_MARGARET_SUN := Vector2(800, 820)
const POS_SANCT_HAROLD_SUN := Vector2(640, 820)

const POS_HALL_DOOR := Vector2(672, 1008)
const POS_HALL_SPAWN := Vector2(672, 860)
const POS_HALL_TABLE_A := Vector2(480, 560)
const POS_HALL_TABLE_B := Vector2(864, 560)
const POS_HALL_SERVING := Vector2(224, 400)


static func sanctuary_bounds() -> Rect2:
	return Rect2(0, 0, SANCTUARY_SIZE.x * TILE, SANCTUARY_SIZE.y * TILE)


static func hall_bounds() -> Rect2:
	return Rect2(0, 0, HALL_SIZE.x * TILE, HALL_SIZE.y * TILE)


static func tile_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE * 0.5, cell.y * TILE + TILE * 0.5)


static func room_center(rect: Rect2i) -> Vector2:
	return Vector2(
		(float(rect.position.x) + float(rect.size.x) * 0.5) * TILE,
		(float(rect.position.y) + float(rect.size.y) * 0.5) * TILE
	)


static func sanctuary_rooms() -> Dictionary:
	return {
		"narthex": SANCT_NARTHEX,
		"worship": SANCT_WORSHIP,
		"office": SANCT_OFFICE,
		"prayer": SANCT_PRAYER,
		"choir": SANCT_CHOIR,
		"storage": SANCT_STORAGE,
		"hallway": SANCT_HALLWAY,
	}


static func hall_rooms() -> Dictionary:
	return {
		"main": HALL_MAIN,
		"kitchen": HALL_KITCHEN,
		"classroom": HALL_CLASS,
		"storage": HALL_STORAGE,
		"hallway": HALL_HALLWAY,
	}


static func sanctuary_doorways() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [
		Vector2i(5, 6), Vector2i(6, 6),
		Vector2i(15, 6), Vector2i(16, 6),
		Vector2i(26, 6), Vector2i(27, 6),
		Vector2i(38, 6), Vector2i(39, 6),
		Vector2i(22, 9), Vector2i(23, 9),
		Vector2i(22, 27), Vector2i(23, 27),
		Vector2i(22, 37), Vector2i(23, 37),
	]
	return cells


static func hall_doorways() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [
		Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
		Vector2i(18, 8), Vector2i(19, 8),
		Vector2i(32, 8), Vector2i(33, 8),
		Vector2i(20, 11), Vector2i(21, 11),
		Vector2i(20, 31), Vector2i(21, 31),
	]
	return cells


static func contains_cell(rect: Rect2i, cell: Vector2i) -> bool:
	return cell.x >= rect.position.x and cell.y >= rect.position.y and cell.x < rect.end.x and cell.y < rect.end.y


static func is_listed(cell: Vector2i, cells: Array[Vector2i]) -> bool:
	for item in cells:
		if item == cell:
			return true
	return false


static func pew_rows() -> Array[float]:
	var rows: Array[float] = [448.0, 544.0, 640.0, 736.0]
	return rows


static func sanctuary_probes() -> Dictionary:
	return {
		"narthex": Vector2(736, 1024),
		"worship": Vector2(736, 600),
		"office": Vector2(240, 110),
		"prayer": Vector2(560, 110),
		"choir": Vector2(860, 110),
		"storage": Vector2(1240, 110),
		"hallway": Vector2(736, 256),
	}


static func hall_probes() -> Dictionary:
	return {
		"main": Vector2(672, 640),
		"kitchen": Vector2(224, 160),
		"classroom": Vector2(1056, 180),
		"storage": Vector2(608, 160),
		"hallway": Vector2(672, 320),
	}


static func weekdays() -> PackedStringArray:
	return PackedStringArray(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])


static func sanctuary_interactables() -> PackedStringArray:
	return PackedStringArray([
		"BulletinBoard", "GuestBook", "SanctuaryPiano", "StainedGlassLook",
		"HymnBoardLook", "VisionSketch", "OfficePhoto", "RestroomLook",
	])


static func hall_interactables() -> PackedStringArray:
	return PackedStringArray([
		"HallBulletin", "CoffeeStation", "LostAndFound", "HallSpeaker",
		"Chalkboard", "CrayonBox",
	])

