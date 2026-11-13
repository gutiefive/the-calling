extends WorldRoom
## A lived-in residential street south of Oak Street, with the community garden.

const MAP_SIZE := Vector2i(46, 50)
const TILE := 32
const WEST_WALK := 640.0
const EAST_WALK := 832.0
const ROAD_MID := 736.0
const POS_TO_OAK := Vector2(ROAD_MID, 40)
const POS_FROM_OAK := Vector2(ROAD_MID, 120)
const POS_GARDEN := Vector2(1088, 736)
const POS_GARDEN_GATE := Vector2(EAST_WALK, 736)
const POS_HELPER := Vector2(860, 700)
const POS_BUS := Vector2(WEST_WALK, 520)
const POS_BENCH := Vector2(EAST_WALK, 520)


func area_name() -> String:
	return "Maple Lane"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * TILE, MAP_SIZE.y * TILE)
	_paint_ground()
	_place_lane()
	_clear_solids()
	_add_footprints()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_garden_fence_blocks()
	_add_yard_fence_blocks()


func rebuild_collision() -> void:
	_clear_solids()
	_add_footprints()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_garden_fence_blocks()
	_add_yard_fence_blocks()


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null or not TownTiles.apply_to(layer):
		push_error("Maple Lane ground is missing")
		return
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, TownTiles.grass_at(x, y))
	_paint_rect(layer, 21, 0, 25, 47, TownTiles.ASPHALT)
	_paint_rect(layer, 19, 1, 21, 47, TownTiles.SIDEWALK)
	_paint_rect(layer, 25, 1, 27, 47, TownTiles.SIDEWALK)
	_paint_rect(layer, 20, 1, 21, 47, TownTiles.CURB_E)
	_paint_rect(layer, 24, 1, 25, 47, TownTiles.CURB_W)
	_paint_rect(layer, 21, 0, 25, 2, TownTiles.CROSSWALK_H)
	for row in TownFacades.maple_houses():
		_paint_house_lot(layer, row)
	_paint_rect(layer, 28, 18, 41, 29, TownTiles.GRASS_A)
	_paint_rect(layer, 29, 19, 40, 28, TownTiles.FENCE)
	_paint_rect(layer, 30, 20, 39, 27, TownTiles.GRASS_B)
	_paint_rect(layer, 31, 21, 38, 26, TownTiles.FLOWER_BED)
	_paint_rect(layer, 27, 22, 30, 24, TownTiles.PATH)
	layer.set_cell(Vector2i(26, 22), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(26, 23), 0, TownTiles.SIDEWALK)
	_paint_rect(layer, 17, 24, 21, 26, TownTiles.DRIVEWAY)
	_paint_rect(layer, 25, 36, 29, 38, TownTiles.DRIVEWAY)
	for row in TownFacades.maple_houses():
		var side := str(row.get("side", "west"))
		var cell_y := int(float(row.get("y", 0.0)) / float(TILE))
		var door_x := 19 if side == "west" else 26
		layer.set_cell(Vector2i(door_x, cell_y), 0, TownTiles.SIDEWALK)
		layer.set_cell(Vector2i(door_x + (1 if side == "west" else -1), cell_y), 0, TownTiles.PATH)
	_paint_rect(layer, 21, 46, 25, 47, TownTiles.ASPHALT)
	_paint_yards(layer)


func _paint_yards(layer: TileMapLayer) -> void:
	_paint_rect(layer, 4, 8, 7, 48, TownTiles.PATH)
	_paint_rect(layer, 0, 8, 3, 48, TownTiles.HEDGE)
	_paint_rect(layer, 0, 8, 1, 48, TownTiles.FENCE)
	_paint_rect(layer, 0, 1, 18, 3, TownTiles.HEDGE)
	_paint_rect(layer, 8, 3, 10, 8, TownTiles.HEDGE)
	_paint_rect(layer, 0, 5, 18, 7, TownTiles.FLOWER_BED)
	_paint_rect(layer, 28, 1, 45, 3, TownTiles.HEDGE)
	_paint_rect(layer, 36, 3, 38, 8, TownTiles.HEDGE)
	_paint_rect(layer, 28, 5, 45, 7, TownTiles.FLOWER_BED)
	_paint_rect(layer, 0, 47, 18, 49, TownTiles.HEDGE)
	_paint_rect(layer, 28, 47, 45, 49, TownTiles.FLOWER_BED)
	for y in range(8, 48):
		if y >= 18 and y < 29:
			continue
		layer.set_cell(Vector2i(42, y), 0, TownTiles.HEDGE)
		layer.set_cell(Vector2i(43, y), 0, TownTiles.HEDGE)
		layer.set_cell(Vector2i(44, y), 0, TownTiles.FENCE)
		layer.set_cell(Vector2i(45, y), 0, TownTiles.HEDGE)
	_paint_rect(layer, 40, 4, 42, 17, TownTiles.PATH)
	_paint_rect(layer, 40, 30, 42, 48, TownTiles.PATH)
	_paint_rect(layer, 7, 27, 18, 33, TownTiles.GRASS_B)
	for x in range(7, 18):
		for y in range(27, 33):
			var n := (x * 11 + y * 5) % 7
			if n == 0:
				layer.set_cell(Vector2i(x, y), 0, TownTiles.GRASS_C)
			elif n == 1 or n == 4:
				layer.set_cell(Vector2i(x, y), 0, TownTiles.FLOWER_BED)
	_paint_rect(layer, 7, 27, 18, 28, TownTiles.FENCE)
	_paint_rect(layer, 7, 32, 18, 33, TownTiles.FENCE)
	_paint_rect(layer, 7, 27, 8, 33, TownTiles.HEDGE)
	_paint_rect(layer, 8, 17, 18, 18, TownTiles.HEDGE)
	_paint_rect(layer, 8, 40, 18, 41, TownTiles.HEDGE)
	_paint_rect(layer, 28, 16, 40, 17, TownTiles.HEDGE)
	_paint_rect(layer, 34, 40, 40, 41, TownTiles.HEDGE)
	_paint_rect(layer, 27, 40, 34, 41, TownTiles.PATH)
	_paint_rect(layer, 8, 9, 12, 11, TownTiles.FLOWER_BED)
	_paint_rect(layer, 8, 21, 11, 23, TownTiles.GRASS_C)
	_paint_rect(layer, 8, 36, 12, 38, TownTiles.FLOWER_BED)
	_paint_rect(layer, 8, 46, 12, 48, TownTiles.GRASS_B)
	_paint_rect(layer, 36, 8, 40, 10, TownTiles.FLOWER_BED)
	_paint_rect(layer, 36, 32, 40, 34, TownTiles.GRASS_C)
	_paint_rect(layer, 36, 46, 40, 48, TownTiles.FLOWER_BED)


func _paint_house_lot(layer: TileMapLayer, row: Dictionary) -> void:
	var side := str(row.get("side", "west"))
	var door_y := int(float(row.get("y", 0.0)))
	var cell_y := int(door_y / TILE)
	if side == "west":
		_paint_rect(layer, 8, cell_y, 19, cell_y + 1, TownTiles.PATH)
		_paint_rect(layer, 10, cell_y - 2, 16, cell_y - 1, TownTiles.FLOWER_BED)
	else:
		_paint_rect(layer, 27, cell_y, 34, cell_y + 1, TownTiles.PATH)
		_paint_rect(layer, 30, cell_y - 2, 36, cell_y - 1, TownTiles.FLOWER_BED)


func _paint_rect(layer: TileMapLayer, x0: int, y0: int, x1: int, y1: int, atlas: Vector2i) -> void:
	for y in range(y0, y1):
		for x in range(x0, x1):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			layer.set_cell(Vector2i(x, y), 0, atlas)


func _place_lane() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	if props is Node2D:
		(props as Node2D).y_sort_enabled = true
	_add_houses(props)
	_add_yard_life(props)
	_add_garden(props)
	_add_seed_crate(props)
	_add_helper(props)
	_add_person(props, "Sarah", "sarah", "sarah", Vector2(EAST_WALK, 720))
	_add_person(props, "Thomas", "thomas", "thomas", Vector2(WEST_WALK, 500))
	_add_neighbor(props, "NeighborDale", "dale", 0, 0, Vector2(WEST_WALK, 360), [
		Vector2(WEST_WALK, 360),
		Vector2(WEST_WALK, 520),
		Vector2(WEST_WALK + 16, 520),
		Vector2(WEST_WALK + 16, 360),
	])
	_add_neighbor(props, "NeighborRuth", "ruth", 1, 1, Vector2(WEST_WALK, 736), [
		Vector2(WEST_WALK, 736),
		Vector2(WEST_WALK, 900),
		Vector2(WEST_WALK + 16, 900),
		Vector2(WEST_WALK + 16, 736),
	])
	_add_neighbor(
		props,
		"NeighborPorch",
		"nora",
		10,
		2,
		Vector2(500, 1144),
		[Vector2(500, 1144)],
		PackedStringArray(["Evening", "Night"])
	)
	_add_door(props)
	_place_marker("default", POS_FROM_OAK, &"down")
	_place_marker("from_oak", POS_FROM_OAK, &"down")
	_add_lamp(Vector2(WEST_WALK, 240))
	_add_lamp(Vector2(EAST_WALK, 240))
	_add_lamp(Vector2(WEST_WALK, 720))
	_add_lamp(Vector2(EAST_WALK, 720))
	_add_lamp(Vector2(WEST_WALK, 1200))
	_add_lamp(Vector2(EAST_WALK, 1200))
	_add_park_lamp(props, "StreetLampN", Vector2(WEST_WALK, 180))
	_add_park_lamp(props, "StreetLampS", Vector2(EAST_WALK, 1400))


func _add_houses(props: Node) -> void:
	for row in TownFacades.maple_houses():
		var node_name := str(row.get("node", ""))
		if node_name.is_empty():
			continue
		var variant := int(row.get("variant", 0))
		var side := str(row.get("side", "west"))
		var door_east := side == "west"
		var texture := PlaceholderArt.house(variant, door_east)
		var pos := Vector2(float(row.get("x", 0.0)), float(row.get("y", 0.0)))
		var body_h := 78.0
		if texture != null:
			body_h = maxf(24.0, texture.get_height() - 18.0)
		_add_solid_sprite(props, node_name, texture, pos, Vector2(136, body_h))
		var house := props.get_node_or_null(node_name) as SolidProp
		if house != null:
			house.block_offset = Vector2(0.0, -18.0 - body_h * 0.5)
			house.set_meta("facade_variant", variant)
			house.set_meta("resident", str(row.get("resident", "")))
			house.set_meta("house_id", str(row.get("id", "")))
		var door_x := 19 * TILE + 16.0 if side == "west" else 26 * TILE + 16.0
		_add_house_door(
			props,
			"%sDoor" % node_name,
			Vector2(door_x, pos.y),
			str(row.get("resident", "House")),
			str(row.get("flavor", "Nobody seems to be home.")),
			str(row.get("id", "")),
			str(row.get("destination_scene", "")),
			StringName(str(row.get("destination_spawn", "from_street")))
		)
		_add_porch_light(props, "%sPorch" % node_name, Vector2(pos.x + (36.0 if door_east else -36.0), pos.y - 28.0))
		var win_x := pos.x + (-28.0 if door_east else 28.0)
		_add_window_light("%sWindow" % node_name, Vector2(win_x, pos.y - 52.0))


func _add_house_door(
	props: Node,
	node_name: String,
	pos: Vector2,
	place: String,
	flavor: String,
	building_id: String,
	scene_path: String,
	spawn: StringName
) -> void:
	var existing := props.get_node_or_null(node_name) as Node2D
	if existing != null:
		existing.position = pos
		return
	var door := BuildingDoor.new()
	door.name = node_name
	door.position = pos
	door.place_name = place
	door.prompt_text = place
	door.radius = 26.0
	door.flavor_line = flavor
	door.building_id = building_id
	door.destination_scene = scene_path
	door.destination_spawn = spawn
	door.add_to_group("house_door")
	props.add_child(door)


func _add_yard_life(props: Node) -> void:
	_add_solid_sprite(props, "FenceDale", PlaceholderArt.picket_fence(), Vector2(480, 400), Vector2(48, 10))
	_add_solid_sprite(props, "FenceVoss", PlaceholderArt.picket_fence(), Vector2(480, 780), Vector2(48, 10))
	_add_solid_sprite(props, "FenceMargaret", PlaceholderArt.picket_fence(), Vector2(480, 1160), Vector2(48, 10))
	_add_solid_sprite(props, "FenceHarold", PlaceholderArt.picket_fence(), Vector2(980, 400), Vector2(48, 10))
	_add_solid_sprite(props, "FenceEllis", PlaceholderArt.picket_fence(), Vector2(980, 1160), Vector2(48, 10))
	_add_solid_sprite(props, "FenceCalhoun", PlaceholderArt.picket_fence(), Vector2(980, 1500), Vector2(48, 10))
	_add_solid_sprite(props, "FenceWhitaker", PlaceholderArt.picket_fence(), Vector2(480, 1500), Vector2(48, 10))
	_add_solid_sprite(props, "MailDale", PlaceholderArt.mailbox(), Vector2(600, 416), Vector2(12, 8))
	_add_solid_sprite(props, "MailVoss", PlaceholderArt.mailbox(), Vector2(600, 800), Vector2(12, 8))
	_add_solid_sprite(props, "MailMargaret", PlaceholderArt.mailbox(), Vector2(600, 1184), Vector2(12, 8))
	_add_solid_sprite(props, "MailHarold", PlaceholderArt.mailbox(), Vector2(864, 416), Vector2(12, 8))
	_add_solid_sprite(props, "MailEllis", PlaceholderArt.mailbox(), Vector2(864, 1184), Vector2(12, 8))
	_add_solid_sprite(props, "MailCalhoun", PlaceholderArt.mailbox(), Vector2(864, 1520), Vector2(12, 8))
	_add_solid_sprite(props, "MailWhitaker", PlaceholderArt.mailbox(), Vector2(600, 1520), Vector2(12, 8))
	_add_solid_sprite(props, "TreeDale", PlaceholderArt.tree(0), Vector2(280, 400), Vector2(14, 8))
	_add_solid_sprite(props, "TreeHarold", PlaceholderArt.tree(1), Vector2(1180, 400), Vector2(14, 8))
	_add_solid_sprite(props, "TreeEllis", PlaceholderArt.tree(2), Vector2(1200, 1200), Vector2(14, 8))
	_add_solid_sprite(props, "TreeSouth", PlaceholderArt.tree(0), Vector2(200, 1500), Vector2(14, 8))
	_add_solid_sprite(props, "Rocker", PlaceholderArt.rocking_chair(), Vector2(500, 1144), Vector2(12, 8))
	_add_solid_sprite(props, "DogHouse", PlaceholderArt.dog_house(), Vector2(220, 780), Vector2(22, 12))
	_add_solid_sprite(props, "Hose", PlaceholderArt.garden_hose(), Vector2(1240, 1180), Vector2(16, 6))
	_add_solid_sprite(props, "Swing", PlaceholderArt.swing_set(), Vector2(1240, 1480), Vector2(36, 12))
	_add_solid_sprite(props, "KidsBike", PlaceholderArt.kids_bike(), Vector2(1020, 1488), Vector2(16, 8))
	_add_solid_sprite(props, "DriveCar", PlaceholderArt.parked_car(1), Vector2(560, 800), Vector2(40, 14))
	_add_solid_sprite(props, "EllisCar", PlaceholderArt.parked_car(0), Vector2(920, 1184), Vector2(40, 14))
	_add_solid_sprite(props, "BinDale", PlaceholderArt.trash_can(), Vector2(WEST_WALK - 28, 380), Vector2(12, 8))
	_add_solid_sprite(props, "BinEllis", PlaceholderArt.trash_can(), Vector2(EAST_WALK + 28, 1150), Vector2(12, 8))
	_add_solid_sprite(props, "FlowersDale", PlaceholderArt.flower_box(), Vector2(450, 340), Vector2(18, 8))
	_add_solid_sprite(props, "FlowersCalhoun", PlaceholderArt.flower_box(), Vector2(1020, 1430), Vector2(18, 8))
	_add_solid_sprite(props, "BusStop", PlaceholderArt.bus_stop(), POS_BUS, Vector2(12, 10))
	_add_solid_sprite(props, "Bench", PlaceholderArt.bench(), POS_BENCH, Vector2(36, 10))
	_add_yard_prop(props, "ShedDale", PlaceholderArt.garden_shed(0), Vector2(200, 360), Vector2(28, 16))
	_add_yard_prop(props, "ShedHarold", PlaceholderArt.garden_shed(1), Vector2(1280, 360), Vector2(28, 16))
	_add_yard_prop(props, "ShedWhitaker", PlaceholderArt.garden_shed(0), Vector2(200, 1480), Vector2(28, 16))
	_add_yard_prop(props, "SaleSign", PlaceholderArt.for_sale_sign(), Vector2(560, 944), Vector2(14, 10))
	_add_yard_prop(props, "BushDaleA", PlaceholderArt.hedge_bush(0), Vector2(240, 460), Vector2(18, 10))
	_add_yard_prop(props, "BushDaleB", PlaceholderArt.hedge_bush(1), Vector2(300, 480), Vector2(18, 10))
	_add_yard_prop(props, "BushVoss", PlaceholderArt.hedge_bush(1), Vector2(260, 860), Vector2(18, 10))
	_add_yard_prop(props, "BushMargaret", PlaceholderArt.hedge_bush(0), Vector2(250, 1220), Vector2(18, 10))
	_add_yard_prop(props, "BushHaroldA", PlaceholderArt.hedge_bush(0), Vector2(1220, 300), Vector2(18, 10))
	_add_yard_prop(props, "BushHaroldB", PlaceholderArt.hedge_bush(1), Vector2(1300, 460), Vector2(18, 10))
	_add_yard_prop(props, "BushEllis", PlaceholderArt.hedge_bush(0), Vector2(1280, 1240), Vector2(18, 10))
	_add_yard_prop(props, "BushCalhoun", PlaceholderArt.hedge_bush(1), Vector2(1300, 1540), Vector2(18, 10))
	_add_yard_prop(props, "BushWhitaker", PlaceholderArt.hedge_bush(1), Vector2(260, 1540), Vector2(18, 10))
	_add_yard_prop(props, "BushVacantA", PlaceholderArt.hedge_bush(0), Vector2(280, 920), Vector2(18, 10))
	_add_yard_prop(props, "BushVacantB", PlaceholderArt.hedge_bush(1), Vector2(360, 1000), Vector2(18, 10))
	_add_yard_prop(props, "TreeDaleB", PlaceholderArt.tree(1), Vector2(180, 480), Vector2(14, 8))
	_add_yard_prop(props, "TreeVoss", PlaceholderArt.tree(2), Vector2(180, 820), Vector2(14, 8))
	_add_yard_prop(props, "TreeMargaret", PlaceholderArt.tree(0), Vector2(180, 1180), Vector2(14, 8))
	_add_yard_prop(props, "TreeWhitaker", PlaceholderArt.tree(2), Vector2(300, 1540), Vector2(14, 8))
	_add_yard_prop(props, "TreeHaroldB", PlaceholderArt.tree(0), Vector2(1320, 300), Vector2(14, 8))
	_add_yard_prop(props, "TreeEllisB", PlaceholderArt.tree(1), Vector2(1320, 1120), Vector2(14, 8))
	_add_yard_prop(props, "TreeCalhounB", PlaceholderArt.tree(2), Vector2(1320, 1420), Vector2(14, 8))
	_add_yard_prop(props, "TreeVacant", PlaceholderArt.tree(1), Vector2(220, 980), Vector2(14, 8))
	_add_yard_prop(props, "FlowersMargaret", PlaceholderArt.flower_box(), Vector2(450, 1220), Vector2(18, 8))
	_add_yard_prop(props, "FlowersHarold", PlaceholderArt.flower_box(), Vector2(1020, 320), Vector2(18, 8))
	_add_yard_prop(props, "BinWhitaker", PlaceholderArt.trash_can(), Vector2(240, 1420), Vector2(12, 8))
	_add_yard_prop(props, "HoseWhitaker", PlaceholderArt.garden_hose(), Vector2(300, 1420), Vector2(16, 6))


func _add_footprints() -> void:
	pass


func _add_garden_fence_blocks() -> void:
	_add_rect(Vector2(34.5 * TILE, 19.5 * TILE), Vector2(11 * TILE, 12))
	_add_rect(Vector2(34.5 * TILE, 28.5 * TILE), Vector2(11 * TILE, 12))
	_add_rect(Vector2(29.5 * TILE, 20.5 * TILE), Vector2(12, 3 * TILE))
	_add_rect(Vector2(29.5 * TILE, 26.5 * TILE), Vector2(12, 4 * TILE))
	_add_rect(Vector2(40.5 * TILE, 24 * TILE), Vector2(12, 9 * TILE))


func _add_yard_fence_blocks() -> void:
	_add_rect(Vector2(1.5 * TILE, 28 * TILE), Vector2(24, 40 * TILE))
	_add_rect(Vector2(44.5 * TILE, 10.5 * TILE), Vector2(24, 13 * TILE))
	_add_rect(Vector2(44.5 * TILE, 39 * TILE), Vector2(24, 18 * TILE))
	_add_rect(Vector2(12.5 * TILE, 17.5 * TILE), Vector2(10 * TILE, 12))
	_add_rect(Vector2(12.5 * TILE, 27.5 * TILE), Vector2(10 * TILE, 12))
	_add_rect(Vector2(12.5 * TILE, 32.5 * TILE), Vector2(10 * TILE, 12))
	_add_rect(Vector2(12.5 * TILE, 40.5 * TILE), Vector2(10 * TILE, 12))
	_add_rect(Vector2(34 * TILE, 16.5 * TILE), Vector2(12 * TILE, 12))
	_add_rect(Vector2(37 * TILE, 40.5 * TILE), Vector2(6 * TILE, 12))


func _add_garden(props: Node) -> void:
	if props.get_node_or_null("Garden") != null:
		return
	var plot := GardenPlot.new()
	plot.name = "Garden"
	plot.position = POS_GARDEN
	plot.prompt_text = "Tend the garden"
	plot.radius = 44.0
	plot.blocks_movement = true
	plot.block_size = Vector2(40, 14)
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	plot.add_child(sprite)
	props.add_child(plot)


func _add_seed_crate(props: Node) -> void:
	if props.get_node_or_null("SeedCrate") != null:
		return
	var crate := ItemPickup.new()
	crate.name = "SeedCrate"
	crate.position = POS_GARDEN + Vector2(72, -40)
	crate.starter_id = "seeds"
	crate.speaker_name = "Seed crate"
	crate.take_line = "Paper packets: lettuce, carrot, tomato, and flower. Enough to start the beds."
	crate.empty_line = "The crate holds a little dirt and nothing else."
	crate.sheet = PlaceholderArt.crate()
	crate.frame_size = Vector2i(32, 32)
	crate.prompt_text = "Take"
	crate.radius = 36.0
	crate.blocks_movement = true
	crate.block_size = Vector2(16, 10)
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	crate.add_child(sprite)
	props.add_child(crate)


func _add_helper(props: Node) -> void:
	if props.get_node_or_null("GardenNeighbor") != null:
		return
	var person := DialogueNpc.new()
	person.name = "GardenNeighbor"
	person.position = POS_HELPER
	person.dialogue_id = "garden_help"
	person.sheet = PlaceholderArt.townsfolk(2)
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = "A neighbor"
	person.prompt_text = "Talk"
	person.radius = 42.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


func _add_person(props: Node, node_name: String, npc_id: String, dialogue_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := DialogueNpc.new()
	person.name = node_name
	person.position = pos
	person.npc_id = npc_id
	person.dialogue_id = dialogue_id
	person.art_id = npc_id
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = node_name
	person.prompt_text = "Talk"
	person.radius = 40.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


func _add_neighbor(
	props: Node,
	node_name: String,
	person_id: String,
	index: int,
	variant: int,
	pos: Vector2,
	route_points: Array = [],
	phases: PackedStringArray = PackedStringArray()
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := AmbientTownsfolk.new()
	person.name = node_name
	person.person_id = person_id
	person.crowd_index = index
	person.art_variant = variant
	person.appear_phases = phases
	person.position = pos
	person.prompt_text = "Say hello"
	person.radius = 40.0
	var route: Array[Vector2] = []
	for point in route_points:
		if point is Vector2:
			route.append(point)
	if route.is_empty():
		route = [pos, pos + Vector2(80, 0), pos + Vector2(80, 28), pos + Vector2(0, 28)]
	person.set_route(route)
	props.add_child(person)


func _add_door(props: Node) -> void:
	if props.get_node_or_null("ToOak") != null:
		var existing := props.get_node("ToOak") as Node2D
		existing.position = POS_TO_OAK
		return
	var door := Door.new()
	door.name = "ToOak"
	door.position = POS_TO_OAK
	door.place_name = "Oak Street"
	door.prompt_text = "Oak Street"
	door.radius = 26.0
	door.destination_scene = "res://scenes/world/hardware_street.tscn"
	door.destination_spawn = &"from_maple"
	props.add_child(door)


func _add_solid_sprite(props: Node, node_name: String, texture: Texture2D, pos: Vector2, block: Vector2) -> void:
	if props.get_node_or_null(node_name) != null or texture == null:
		return
	var sprite := SolidProp.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.centered = true
	sprite.offset = Vector2(0, -texture.get_height() * 0.5)
	sprite.position = pos
	sprite.block_size = block
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)


func _add_yard_prop(props: Node, node_name: String, texture: Texture2D, pos: Vector2, block: Vector2) -> void:
	_add_solid_sprite(props, node_name, texture, pos, block)
	var sprite := props.get_node_or_null(node_name) as Node2D
	if sprite != null:
		sprite.set_meta("m11b_yard", true)
		sprite.add_to_group("maple_yard_prop")


func _add_window_light(light_name: String, pos: Vector2) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var light := PointLight2D.new()
	light.name = light_name
	light.position = pos
	light.color = Color(1, 0.86, 0.62)
	light.energy = 0.0
	light.texture = PlaceholderArt.glow()
	light.texture_scale = 2.0
	light.shadow_enabled = false
	light.add_to_group("tod_window")
	lighting.add_child(light)


func _add_lamp(pos: Vector2) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null:
		return
	var lamp_name := "Lamp_%d_%d" % [int(pos.x), int(pos.y)]
	if lighting.get_node_or_null("Lamp") == null:
		lamp_name = "Lamp"
	if lighting.get_node_or_null(lamp_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = lamp_name
	lamp.position = pos
	lamp.color = Color(1, 0.84, 0.58)
	lamp.energy = 0.0
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 3.0
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_lamp")
	lighting.add_child(lamp)


func _add_porch_light(props: Node, lamp_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(lamp_name) != null:
		return
	var glow := PointLight2D.new()
	glow.name = lamp_name
	glow.position = pos
	glow.color = Color(1, 0.86, 0.62)
	glow.energy = 0.0
	glow.texture = PlaceholderArt.glow()
	glow.texture_scale = 1.8
	glow.shadow_enabled = false
	glow.add_to_group("tod_lamp")
	props.add_child(glow)


func _add_park_lamp(props: Node, lamp_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(lamp_name) != null:
		return
	var lamp := SolidProp.new()
	lamp.name = lamp_name
	lamp.texture = PlaceholderArt.lamp_post()
	lamp.centered = true
	lamp.offset = Vector2(0, -lamp.texture.get_height() * 0.5)
	lamp.position = pos
	lamp.block_size = Vector2(10, 8)
	lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var glow := PointLight2D.new()
	glow.name = "Glow"
	glow.position = Vector2(0, -44)
	glow.color = Color(1, 0.84, 0.58)
	glow.energy = 0.8
	glow.texture = PlaceholderArt.glow()
	glow.texture_scale = 4.0
	glow.shadow_enabled = false
	glow.add_to_group("tod_lamp")
	lamp.add_child(glow)
	props.add_child(lamp)


func _place_marker(id: String, pos: Vector2, facing: StringName) -> void:
	var spawns := get_node_or_null("Spawns")
	if spawns == null:
		return
	var marker := spawns.get_node_or_null(id) as Node2D
	if marker == null:
		var created := Marker2D.new()
		created.name = id
		spawns.add_child(created)
		marker = created
	marker.position = pos
	marker.set_meta("facing", facing)
