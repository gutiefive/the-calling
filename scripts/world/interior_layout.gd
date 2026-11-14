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
const POS_HALL_TABLE_A := Vector2(512, 544)
const POS_HALL_TABLE_B := Vector2(832, 544)
const POS_HALL_SERVING := Vector2(224, 400)
const POS_HALL_ROUND_NW := Vector2(328, 544)
const POS_HALL_ROUND_NE := Vector2(1056, 544)
const POS_HALL_ROUND_SW := Vector2(328, 728)
const POS_HALL_ROUND_SE := Vector2(1056, 728)
const POS_HALL_PUZZLE := Vector2(512, 728)
const POS_HALL_CRAFT := Vector2(832, 728)
const POS_HALL_STAGE := Vector2(1040, 410)
const POS_HALL_OSTROW := Vector2(470, 600)
const POS_HALL_RUTH := Vector2(890, 600)
const POS_HALL_DALE := Vector2(750, 580)
const POS_HALL_EXTRA_CHAIRS := Vector2(580, 500)
const POS_HALL_LIGHTS := Vector2(672, 456)
const POS_HALL_BANNER := Vector2(672, 444)
const HALL_ROUND_CHAIR_COUNT := 6
const HALL_LONG_CHAIR_COUNT := 4
const HALL_RUG_OVERLAP_MAX := 0.22
const HALL_LONG_TABLE_MIN_W := 96
const HALL_DISH_OFFSET_A := Vector2(32, 2)
const HALL_DISH_OFFSET_B := Vector2(-32, 2)
const HALL_CENTER_OFFSET := Vector2(0, 1)

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
		"sitting": Vector2(260, 800),
		"stage_front": Vector2(960, 458),
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
		"Chalkboard", "CrayonBox", "MealTrain", "WelcomeTable",
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
		"main": 28,
		"kitchen": 16,
		"classroom": 16,
		"hall_storage": 8,
		"hall_hallway": 6,
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
		POS_HALL_TABLE_A + Vector2(0, 88),
		POS_HALL_TABLE_B + Vector2(0, 88),
		Vector2(280, 420),
		Vector2(512, 640),
		Vector2(832, 640),
		POS_HALL_OSTROW,
		POS_HALL_RUTH,
		POS_HALL_DALE,
		Vector2(200, 170),
		Vector2(1056, 180),
		POS_HALL_SERVING + Vector2(40, 36),
		POS_HALL_STAGE + Vector2(-80, 48),
		Vector2(260, 800),
	]
	return spots


static func hall_tables() -> Array:
	var rows: Array = [
		_hall_table("RoundTableC", "round", POS_HALL_ROUND_NW),
		_hall_table("TableA", "long", POS_HALL_TABLE_A),
		_hall_table("TableB", "long", POS_HALL_TABLE_B),
		_hall_table("RoundTableD", "round", POS_HALL_ROUND_NE),
		_hall_table("RoundTable", "round", POS_HALL_ROUND_SW),
		_hall_table("PuzzleTable", "long", POS_HALL_PUZZLE),
		_hall_table("CraftTable", "long", POS_HALL_CRAFT),
		_hall_table("RoundTableB", "round", POS_HALL_ROUND_SE),
	]
	return rows


static func _hall_table(table_id: String, kind: String, pos: Vector2) -> Dictionary:
	var row: Dictionary = {
		"id": table_id,
		"kind": kind,
		"pos": pos,
	}
	return row


static func hall_table_count() -> int:
	return hall_tables().size()


static func hall_chair_count_for(kind: String) -> int:
	if kind == "round":
		return HALL_ROUND_CHAIR_COUNT
	return HALL_LONG_CHAIR_COUNT


static func hall_chair_offsets(kind: String) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	if kind == "round":
		offsets.append(Vector2(0, -38))
		offsets.append(Vector2(34, -20))
		offsets.append(Vector2(38, 18))
		offsets.append(Vector2(6, 40))
		offsets.append(Vector2(-32, 24))
		offsets.append(Vector2(-38, -14))
	else:
		offsets.append(Vector2(-44, -32))
		offsets.append(Vector2(42, -30))
		offsets.append(Vector2(-42, 30))
		offsets.append(Vector2(44, 32))
	return offsets


static func hall_chair_frame(offset: Vector2) -> String:
	if offset.y < -16.0:
		return "hall_chair_back"
	if offset.y > 16.0:
		return "hall_chair_front"
	return "hall_chair"


static func hall_table_block(kind: String) -> Vector2:
	if kind == "round":
		return Vector2(56, 18)
	return Vector2(100, 16)


static func hall_table_frame(table_id: String, kind: String) -> String:
	if table_id == "CraftTable":
		return "craft_table"
	if table_id == "PuzzleTable":
		return "puzzle_table"
	if table_id == "TableB":
		return "long_table_runner"
	if kind == "round":
		return "round_table"
	return "long_table"


static func hall_table_clutter(table_id: String) -> PackedStringArray:
	match table_id:
		"RoundTableC":
			return PackedStringArray(["napkin_holder", "coffee_mug", "flower_vase"])
		"TableA":
			return PackedStringArray(["salt_pepper", "hymnal_stack", "coffee_mug"])
		"TableB":
			return PackedStringArray(["napkin_holder", "clipboard", "laptop"])
		"RoundTableD":
			return PackedStringArray(["coffee_mug", "flower_vase"])
		"PuzzleTable":
			return PackedStringArray(["card_game", "board_game"])
		"CraftTable":
			return PackedStringArray(["paper_stack", "crayons"])
		"RoundTable":
			return PackedStringArray(["bible", "coffee_mug"])
		"RoundTableB":
			return PackedStringArray(["flower_vase"])
		_:
			return PackedStringArray()


static func hall_clutter_offset(index: int, count: int) -> Vector2:
	var span := 72.0
	var ox := 0.0
	if count > 1:
		ox = -span * 0.5 + span * float(index) / float(count - 1)
	return Vector2(ox, -14.0)


static func hall_walkway_rects() -> Array[Rect2i]:
	var rects: Array[Rect2i] = [
		Rect2i(20, 12, 2, 16),
		Rect2i(5, 13, 15, 2),
		Rect2i(22, 14, 8, 2),
		Rect2i(8, 19, 12, 2),
		Rect2i(22, 19, 12, 2),
		Rect2i(19, 24, 4, 4),
		Rect2i(7, 16, 2, 8),
		Rect2i(35, 17, 2, 6),
	]
	return rects


static func hall_rug_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = [
		Vector2(672, 640),
		Vector2(1040, 430),
		Vector2(210, 810),
	]
	return spots


static func hall_close_view() -> Rect2:
	var center: Vector2 = Vector2(672, 620)
	return Rect2(center.x - 320.0, center.y - 180.0, 640.0, 360.0)


static func hall_rug_zone_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = [
		Rect2(632, 400, 80, 500),
		Rect2(960, 384, 200, 80),
		Rect2(128, 752, 200, 144),
	]
	return rects


static func hall_zone_names() -> PackedStringArray:
	return PackedStringArray([
		"sitting", "welcome", "coffee", "kids", "stage", "piano", "trophy", "storage_wall",
	])


static func hall_zone_min_props() -> Dictionary:
	return {
		"sitting": 5,
		"welcome": 2,
		"coffee": 3,
		"kids": 3,
		"stage": 4,
		"piano": 2,
		"trophy": 2,
		"storage_wall": 3,
	}


static func hall_zone_prop_names() -> Dictionary:
	return {
		"sitting": PackedStringArray(["SittingCouch", "SittingChair", "SittingTable", "SittingLamp", "SittingShelf"]),
		"welcome": PackedStringArray(["WelcomeTable", "DoorCoatRack"]),
		"coffee": PackedStringArray(["CoffeeStation", "DonutBox", "CupStack"]),
		"kids": PackedStringArray(["KidsEasel", "KidsBlocks", "KidsCornerBin"]),
		"stage": PackedStringArray(["Stage", "Podium", "StageCurtain", "MicStand"]),
		"piano": PackedStringArray(["HallPiano", "HallPianoBench"]),
		"trophy": PackedStringArray(["TrophyShelf", "PhotoWall"]),
		"storage_wall": PackedStringArray(["StackedHallChairs", "ChairCart", "FoldedTableRack"]),
	}


static func hall_shot_points() -> Dictionary:
	var probes: Dictionary = hall_probes()
	return {
		"main": probes["main"],
		"kitchen": probes["kitchen"],
		"classroom": probes["classroom"],
		"hallway": probes["hallway"],
		"sitting": probes["sitting"],
		"stage": probes["stage_front"],
	}


static func hall_named_chair(table_id: String, index: int) -> String:
	if table_id == "TableA" and index == 2:
		return "ChairA"
	if table_id == "TableA" and index == 3:
		return "ChairB"
	if table_id == "TableB" and index == 2:
		return "ChairC"
	if table_id == "TableB" and index == 3:
		return "ChairD"
	return "%sChair%d" % [table_id, index]


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
		"stain_pool_aisle", "napkin_holder", "salt_pepper", "board_game", "table_bulletin",
		"table_shadow_round", "table_shadow_long", "long_table_runner", "hall_chair_back",
		"hall_chair_front", "rug_aisle_runner", "rug_stage", "rug_sitting", "rug_class_pattern",
		"rug_hallway", "flower_vase", "hymnal_stack", "card_game", "clipboard", "laptop",
		"donut_box", "cup_stack", "coffee_urn", "couch", "floor_lamp", "mic_stand",
		"pa_speaker", "trophy_shelf", "photo_wall", "folded_table_rack", "alphabet_strip",
		"hanging_utensils", "backsplash", "kitchen_window", "meal_train", "labeled_bin",
		"window_pool", "kids_easel", "toy_blocks", "snack_counter",
	])
