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
const HALL_SIZE := Vector2i(42, 29)

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
const HALL_MAIN := Rect2i(4, 12, 34, 16)

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

const POS_HALL_DOOR := Vector2(672, 912)
const POS_HALL_SPAWN := Vector2(672, 784)
const POS_HALL_TABLE_A := Vector2(480, 560)
const POS_HALL_TABLE_B := Vector2(864, 560)
const POS_HALL_SERVING := Vector2(224, 400)

const PEW_LEFT_X := 440.0
const PEW_RIGHT_X := 1032.0
const PEW_BLOCK := Vector2(260, 12)

const PROP_COVER_PAD := 36.0


static func sanctuary_bounds() -> Rect2:
	return Rect2(0, 0, SANCTUARY_SIZE.x * TILE, SANCTUARY_SIZE.y * TILE)


static func hall_bounds() -> Rect2:
	return Rect2(0, 0, HALL_SIZE.x * TILE, HALL_SIZE.y * TILE)


static func tile_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE * 0.5, cell.y * TILE + TILE * 0.5)


static func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / float(TILE))), int(floor(pos.y / float(TILE))))


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
		Vector2i(20, 28), Vector2i(21, 28),
	]
	return cells


static func sanctuary_aisle_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	# Skip the platform and altar at the north end of the runner.
	for y in range(SANCT_WORSHIP.position.y + 3, SANCT_WORSHIP.end.y):
		cells.append(Vector2i(22, y))
		cells.append(Vector2i(23, y))
	return cells


static func contains_cell(rect: Rect2i, cell: Vector2i) -> bool:
	return cell.x >= rect.position.x and cell.y >= rect.position.y and cell.x < rect.end.x and cell.y < rect.end.y


static func is_listed(cell: Vector2i, cells: Array[Vector2i]) -> bool:
	for item in cells:
		if item == cell:
			return true
	return false


static func pew_rows() -> Array[float]:
	var rows: Array[float] = [400.0, 448.0, 544.0, 640.0, 736.0]
	return rows


static func sunday_pew_rows() -> Array[float]:
	var rows: Array[float] = [448.0, 544.0, 640.0, 736.0]
	return rows


static func sunday_seats() -> Dictionary:
	return {
		"harold": Vector2(420, 448),
		"margaret": Vector2(1030, 448),
		"sarah": Vector2(420, 544),
		"thomas": Vector2(1030, 544),
		"frank": Vector2(420, 736),
	}


static func sunday_crowd() -> Array[Vector2]:
	var seats: Array[Vector2] = [
		Vector2(500, 448), Vector2(1100, 448),
		Vector2(500, 544), Vector2(1100, 544),
		Vector2(420, 640), Vector2(500, 640),
		Vector2(1030, 640), Vector2(1100, 640),
		Vector2(500, 736), Vector2(1030, 736),
		Vector2(1100, 736), Vector2(560, 736),
	]
	return seats


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
		"main": Vector2(672, 620),
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


static func min_prop_counts() -> Dictionary:
	return {
		"narthex": 12,
		"worship": 22,
		"office": 12,
		"prayer": 9,
		"choir": 9,
		"storage": 8,
		"hallway": 5,
		"main": 22,
		"kitchen": 12,
		"classroom": 12,
		"hall_storage": 6,
		"hall_hallway": 4,
	}


static func max_bare_ratios() -> Dictionary:
	return {
		"narthex": 0.55,
		"worship": 0.58,
		"office": 0.48,
		"prayer": 0.50,
		"choir": 0.50,
		"storage": 0.48,
		"hallway": 0.72,
		"main": 0.50,
		"kitchen": 0.48,
		"classroom": 0.50,
		"hall_storage": 0.52,
		"hall_hallway": 0.72,
	}


static func sanctuary_clear_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = [
		POS_SANCT_SPAWN,
		POS_SANCT_HAROLD,
		POS_SANCT_MARGARET,
		POS_SANCT_THOMAS,
		POS_SANCT_FRANK,
		POS_SANCT_SARAH,
		POS_SANCT_MARGARET_SUN,
		POS_SANCT_HAROLD_SUN,
		POS_SANCT_LEDGER + Vector2(0, 26),
		POS_SANCT_KEYS + Vector2(0, 26),
		POS_SANCT_FLOWERS + Vector2(0, 24),
		Vector2(528, 130),
		Vector2(864, 120),
	]
	return spots


static func hall_clear_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = [
		POS_HALL_SPAWN,
		POS_HALL_TABLE_A + Vector2(0, 40),
		POS_HALL_TABLE_B + Vector2(0, 40),
		Vector2(280, 420),
		Vector2(520, 620),
		Vector2(820, 520),
		Vector2(400, 780),
		Vector2(960, 740),
		Vector2(560, 820),
		Vector2(200, 170),
		Vector2(1056, 180),
	]
	return spots


static func clutter_frame_ids() -> PackedStringArray:
	return PackedStringArray([
		"doormat", "rug_narthex", "coat_hooks", "umbrella_stand", "plant", "plant_tall",
		"tract_rack", "donation_box", "lost_umbrella", "side_table", "hymnal", "bible",
		"flower_stand", "sconce", "baptism_font", "sound_desk", "sanctuary_banner",
		"projector_screen", "candle_stand", "piano_bench", "sheet_music", "platform_chair",
		"rug_office", "armchair", "coffee_mug", "paper_stack", "book_stack", "coat_hook",
		"calendar", "radiator", "rug_prayer", "prayer_board", "open_book", "music_stand",
		"robe_rack", "folder_shelf", "storage_shelf", "cardboard_box", "vacuum",
		"decoration_bin", "mop_bucket", "chair_cart", "stage", "stage_curtain", "kids_art",
		"wall_banner", "craft_table", "puzzle_table", "water_cooler", "trash_can",
		"recycling_bin", "rug_hall", "upper_cabinet", "dish_rack", "microwave", "mixer",
		"island", "pantry", "cubbies", "reading_rug", "beanbag", "toy_bin", "globe",
		"teacher_desk", "fire_extinguisher", "water_fountain", "long_table", "hall_chair",
		"stain_pool_aisle",
	])
