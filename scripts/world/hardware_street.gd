extends WorldRoom
## Oak Street: a two-lane main street. Buildings sit on the north sidewalk.

const MAP_SIZE := Vector2i(76, 36)
const TILE := 32
const Y_FRONT := 13 * TILE
const Y_DOOR := Y_FRONT + 24
const Y_SPAWN := Y_FRONT + 64
const Y_ROAD := 17 * TILE
const Y_SOUTH_WALK := 21 * TILE - 16
const POS_COTTAGE := Vector2(208, Y_FRONT)
const POS_POST := Vector2(384, Y_FRONT)
const POS_DINER := Vector2(592, Y_FRONT)
const POS_HARDWARE := Vector2(816, Y_FRONT)
const POS_BARBER := Vector2(1072, Y_FRONT)
const POS_VACANT := Vector2(1248, Y_FRONT)
const POS_GARAGE := Vector2(1472, Y_FRONT)
const POS_THOMAS := Vector2(816, Y_DOOR)
const POS_FRANK := Vector2(1472, Y_DOOR)
const POS_SARAH := Vector2(592, Y_DOOR)
const POS_BENCH := Vector2(700, Y_SOUTH_WALK)
const POS_LAMP := Vector2(480, Y_SOUTH_WALK)
const POS_TREE := Vector2(160, Y_SOUTH_WALK)
const POS_CRATE := Vector2(960, Y_DOOR)
const POS_MAILBOX := Vector2(330, Y_DOOR)
const POS_DOOR := Vector2(48, Y_ROAD)
const POS_SPAWN := Vector2(120, Y_ROAD)
const POS_HYDRANT := Vector2(720, Y_DOOR)
const POS_TRASH := Vector2(960, Y_SOUTH_WALK)
const Y_SOUTH_FRONT := 24 * TILE
const Y_SOUTH_DOOR := Y_SOUTH_FRONT + 24
const POS_CAR_A := Vector2(544, 18 * TILE)
const POS_CAR_B := Vector2(1056, 18 * TILE)
const POS_CAR_C := Vector2(880, 23 * TILE)
const POS_CAR_D := Vector2(1504, 23 * TILE)
const POS_MAPLE_DOOR := Vector2(1856, 34 * TILE)
const POS_MAPLE_SPAWN := Vector2(1856, 32 * TILE)
const POS_WIN_H := Vector2(780, Y_FRONT - 80)
const POS_WIN_G := Vector2(1540, Y_FRONT - 80)


func area_name() -> String:
	return "Oak Street"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * TILE, MAP_SIZE.y * TILE)
	_assign_art()
	_place_props()
	_add_living_town()
	_paint_ground()
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_creek_block()
	_add_fence_blocks()
	_place_occluders()
	NarrativeState.set_flag("seen_oak_street", true)


func rebuild_collision() -> void:
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_creek_block()
	_add_fence_blocks()
	_place_occluders()


func _assign_art() -> void:
	_set_sprite("Props/Cottage", PlaceholderArt.cottage())
	_set_sprite("Props/PostOffice", PlaceholderArt.post_office())
	_set_sprite("Props/Diner", PlaceholderArt.diner())
	_set_sprite("Props/Hardware", PlaceholderArt.hardware_store())
	_set_sprite("Props/Barber", PlaceholderArt.barber_shop())
	_set_sprite("Props/Vacant", PlaceholderArt.vacant_shop())
	_set_sprite("Props/Garage", PlaceholderArt.auto_shop())
	_set_sprite("Props/Tree", PlaceholderArt.tree(2))
	_set_sprite("Props/Bench", PlaceholderArt.bench())
	_set_sprite("Props/Lamp", PlaceholderArt.lamp_post())
	_set_sprite("Props/Crate", PlaceholderArt.crate())
	_set_sprite("Props/Mailbox", PlaceholderArt.mailbox())
	_set_sprite("Props/CarA", PlaceholderArt.parked_car(0))
	_set_sprite("Props/CarB", PlaceholderArt.parked_car(1))
	_set_sprite("Props/Hydrant", PlaceholderArt.hydrant())
	_set_sprite("Props/TrashCan", PlaceholderArt.trash_can())
	_set_light_texture("Props/Lamp/Glow")
	_set_light_texture("Lighting/HardwareWindow")
	_set_light_texture("Lighting/GarageWindow")


func _place_props() -> void:
	var feet: Array[String] = [
		"Props/Cottage", "Props/PostOffice", "Props/Diner", "Props/Hardware",
		"Props/Barber", "Props/Vacant", "Props/Garage", "Props/Tree",
		"Props/Bench", "Props/Lamp", "Props/Crate", "Props/Mailbox",
		"Props/CarA", "Props/CarB", "Props/Hydrant", "Props/TrashCan",
	]
	for path in feet:
		_feet_offset(path)
	_place("Props/Cottage", POS_COTTAGE)
	_place("Props/PostOffice", POS_POST)
	_place("Props/Diner", POS_DINER)
	_place("Props/Hardware", POS_HARDWARE)
	_place("Props/Barber", POS_BARBER)
	_place("Props/Vacant", POS_VACANT)
	_place("Props/Garage", POS_GARAGE)
	_place("Props/Thomas", POS_THOMAS)
	_place("Props/Frank", POS_FRANK)
	_place("Props/Sarah", POS_SARAH)
	_place("Props/Bench", POS_BENCH)
	_place("Props/Lamp", POS_LAMP)
	_place("Props/Tree", POS_TREE)
	_place("Props/Crate", POS_CRATE)
	_place("Props/Mailbox", POS_MAILBOX)
	_place("Props/CarA", POS_CAR_A)
	_place("Props/CarB", POS_CAR_B)
	_place("Props/Hydrant", POS_HYDRANT)
	_place("Props/TrashCan", POS_TRASH)
	_place("Props/ToChurch", POS_DOOR)
	_place("Spawns/default", POS_SPAWN)
	_place("Spawns/from_church", POS_SPAWN)
	var arrived := get_node_or_null("Spawns/from_church")
	var default_spawn := get_node_or_null("Spawns/default")
	if arrived != null:
		arrived.set_meta("facing", &"right")
	if default_spawn != null:
		default_spawn.set_meta("facing", &"right")
	_place("Lighting/HardwareWindow", POS_WIN_H)
	_place("Lighting/GarageWindow", POS_WIN_G)


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null or not TownTiles.apply_to(layer):
		push_error("Oak Street ground is missing")
		return
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, TownTiles.grass_at(x, y))
	_paint_rect(layer, 0, 15, 70, 19, TownTiles.ASPHALT)
	_paint_rect(layer, 0, 16, 70, 17, TownTiles.LINE_H)
	_paint_rect(layer, 6, 15, 8, 19, TownTiles.CROSSWALK_H)
	_paint_rect(layer, 16, 18, 18, 19, TownTiles.PARKING)
	_paint_rect(layer, 32, 18, 34, 19, TownTiles.PARKING)
	_paint_rect(layer, 0, 14, 70, 15, TownTiles.CURB_N)
	_paint_rect(layer, 0, 19, 56, 20, TownTiles.CURB_S)
	_paint_rect(layer, 60, 19, 70, 20, TownTiles.CURB_S)
	layer.set_cell(Vector2i(0, 14), 0, TownTiles.CURB_NW)
	layer.set_cell(Vector2i(69, 14), 0, TownTiles.CURB_NE)
	layer.set_cell(Vector2i(0, 19), 0, TownTiles.CURB_SW)
	layer.set_cell(Vector2i(55, 19), 0, TownTiles.CURB_SE)
	layer.set_cell(Vector2i(60, 19), 0, TownTiles.CURB_SW)
	layer.set_cell(Vector2i(69, 19), 0, TownTiles.CURB_SE)
	_paint_rect(layer, 0, 12, 70, 14, TownTiles.SIDEWALK)
	_paint_rect(layer, 0, 20, 56, 25, TownTiles.SIDEWALK)
	_paint_rect(layer, 60, 20, 70, 22, TownTiles.SIDEWALK)
	_paint_rect(layer, 4, 25, 52, 26, TownTiles.FOUNDATION)
	_paint_rect(layer, 26, 22, 30, 25, TownTiles.PARKING)
	_paint_rect(layer, 45, 25, 50, 30, TownTiles.GRASS_A)
	_paint_rect(layer, 46, 26, 49, 28, TownTiles.FLOWER_BED)
	_paint_rect(layer, 4, 11, 50, 12, TownTiles.FOUNDATION)
	_paint_rect(layer, 44, 13, 48, 15, TownTiles.DRIVEWAY)
	_paint_rect(layer, 29, 11, 31, 14, TownTiles.ALLEY)
	var planters_n: Array[int] = [2, 29, 51]
	for px in planters_n:
		layer.set_cell(Vector2i(px, 13), 0, TownTiles.PLANTER)
	var planters_s: Array[int] = [2, 28, 36, 47, 62]
	for px in planters_s:
		layer.set_cell(Vector2i(px, 21), 0, TownTiles.PLANTER)
	_paint_rect(layer, 56, 19, 60, 35, TownTiles.ASPHALT)
	_paint_rect(layer, 57, 19, 58, 35, TownTiles.LINE_V)
	_paint_rect(layer, 56, 19, 60, 21, TownTiles.CROSSWALK_V)
	_paint_rect(layer, 54, 20, 56, 35, TownTiles.SIDEWALK)
	_paint_rect(layer, 60, 20, 62, 35, TownTiles.SIDEWALK)
	_paint_rect(layer, 55, 20, 56, 35, TownTiles.CURB_E)
	_paint_rect(layer, 59, 20, 60, 35, TownTiles.CURB_W)
	_paint_rect(layer, 63, 23, 69, 33, TownTiles.GRASS_A)
	_paint_rect(layer, 64, 22, 66, 32, TownTiles.PATH)
	_paint_rect(layer, 63, 27, 69, 28, TownTiles.PATH)
	_paint_rect(layer, 63, 23, 70, 24, TownTiles.FENCE)
	_paint_rect(layer, 63, 32, 70, 33, TownTiles.FENCE)
	_paint_rect(layer, 63, 23, 64, 33, TownTiles.FENCE)
	_paint_rect(layer, 69, 23, 70, 33, TownTiles.FENCE)
	layer.set_cell(Vector2i(64, 23), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(65, 23), 0, TownTiles.PATH)
	_paint_rect(layer, 66, 24, 68, 26, TownTiles.FLOWER_BED)
	_paint_rect(layer, 70, 2, 76, 35, TownTiles.WATER)
	_paint_rect(layer, 69, 4, 71, 34, TownTiles.PATH)


func _paint_rect(layer: TileMapLayer, x0: int, y0: int, x1: int, y1: int, atlas: Vector2i) -> void:
	for y in range(y0, y1):
		for x in range(x0, x1):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			layer.set_cell(Vector2i(x, y), 0, atlas)


func _add_buildings() -> void:
	_add_footprint("Props/Cottage")
	_add_footprint("Props/PostOffice")
	_add_footprint("Props/Diner")
	_add_footprint("Props/Hardware")
	_add_footprint("Props/Barber")
	_add_footprint("Props/Vacant")
	_add_footprint("Props/Garage")


func _add_footprint(node_path: String) -> void:
	var sprite := get_node_or_null(node_path) as Sprite2D
	if sprite == null or sprite.texture == null:
		return
	var size := sprite.texture.get_size()
	var body_h := size.y - 18.0
	if body_h <= 0.0:
		return
	_add_rect(sprite.position + Vector2(0.0, -18.0 - body_h * 0.5), Vector2(size.x - 8.0, body_h))


func _place_occluders() -> void:
	_occlude("Lighting/HardwareOccluder", "Props/Hardware")
	_occlude("Lighting/GarageOccluder", "Props/Garage")
	_occlude("Lighting/DinerOccluder", "Props/Diner")
	_occlude("Lighting/PostOccluder", "Props/PostOffice")
	_occlude("Lighting/BarberOccluder", "Props/Barber")
	_occlude("Lighting/VacantOccluder", "Props/Vacant")
	_occlude("Lighting/CottageOccluder", "Props/Cottage")


func _occlude(occluder_path: String, sprite_path: String) -> void:
	var sprite := get_node_or_null(sprite_path) as Sprite2D
	var occluder := get_node_or_null(occluder_path) as LightOccluder2D
	if sprite == null or sprite.texture == null or occluder == null:
		return
	var size := sprite.texture.get_size()
	var top_left := sprite.position - Vector2(size.x * 0.5, size.y)
	var poly := OccluderPolygon2D.new()
	poly.polygon = PackedVector2Array([
		top_left,
		top_left + Vector2(size.x, 0.0),
		top_left + size,
		top_left + Vector2(0.0, size.y),
	])
	occluder.occluder = poly


func _add_creek_block() -> void:
	_add_rect(Vector2(73 * TILE, 18 * TILE), Vector2(6 * TILE, 32 * TILE))


func _add_fence_blocks() -> void:
	_add_rect(Vector2(66.5 * TILE, 23.5 * TILE), Vector2(7 * TILE, 16))
	_add_rect(Vector2(66.5 * TILE, 32.5 * TILE), Vector2(7 * TILE, 16))
	_add_rect(Vector2(63.5 * TILE, 28 * TILE), Vector2(16, 9 * TILE))
	_add_rect(Vector2(69.5 * TILE, 28 * TILE), Vector2(16, 9 * TILE))


func _add_living_town() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_solid_sprite(props, "YardFlowers", PlaceholderArt.flowers(), Vector2(250, Y_FRONT - 90), Vector2(26, 10))
	_add_solid_sprite(props, "ParkTree1", PlaceholderArt.tree(0), Vector2(2080, 900), Vector2(14, 8))
	_add_solid_sprite(props, "ParkTree2", PlaceholderArt.tree(1), Vector2(1980, 1040), Vector2(14, 8))
	_add_solid_sprite(props, "ParkTree3", PlaceholderArt.tree(2), Vector2(2160, 980), Vector2(14, 8))
	_add_solid_sprite(props, "ParkBench", PlaceholderArt.bench(), Vector2(2048, 860), Vector2(36, 10))
	_add_solid_sprite(props, "ParkBench2", PlaceholderArt.bench(), Vector2(2112, 1080), Vector2(36, 10))
	_add_solid_sprite(props, "NorthTree1", PlaceholderArt.tree(1), Vector2(80, Y_DOOR), Vector2(14, 8))
	_add_solid_sprite(props, "NorthTree2", PlaceholderArt.tree(0), Vector2(944, Y_DOOR), Vector2(14, 8))
	_add_solid_sprite(props, "NorthTree3", PlaceholderArt.tree(2), Vector2(1648, Y_DOOR), Vector2(14, 8))
	_add_solid_sprite(props, "SouthTree1", PlaceholderArt.tree(0), Vector2(400, Y_SOUTH_WALK), Vector2(14, 8))
	_add_solid_sprite(props, "SouthTree2", PlaceholderArt.tree(1), Vector2(896, Y_SOUTH_WALK), Vector2(14, 8))
	_add_solid_sprite(props, "SouthTree3", PlaceholderArt.tree(2), Vector2(1344, Y_SOUTH_WALK), Vector2(14, 8))
	_add_solid_sprite(props, "SouthBench2", PlaceholderArt.bench(), Vector2(1180, Y_SOUTH_WALK), Vector2(36, 10))
	_add_solid_sprite(props, "CarC", PlaceholderArt.parked_car(0), POS_CAR_C, Vector2(40, 14))
	_add_solid_sprite(props, "CarD", PlaceholderArt.parked_car(1), POS_CAR_D, Vector2(40, 14))
	_add_solid_sprite(props, "PaperBox", PlaceholderArt.newspaper_box(), Vector2(300, Y_SOUTH_WALK), Vector2(12, 8))
	_add_solid_sprite(props, "BikeRack", PlaceholderArt.bike_rack(), Vector2(620, Y_SOUTH_WALK), Vector2(28, 8))
	_add_solid_sprite(props, "FlowerBoxA", PlaceholderArt.flower_box(), Vector2(500, Y_SOUTH_WALK), Vector2(18, 8))
	_add_solid_sprite(props, "FlowerBoxB", PlaceholderArt.flower_box(), Vector2(1200, Y_SOUTH_WALK), Vector2(18, 8))
	_add_solid_sprite(props, "BusStop", PlaceholderArt.bus_stop(), Vector2(900, Y_SOUTH_WALK), Vector2(12, 10))
	_add_solid_sprite(props, "ParkFence", PlaceholderArt.picket_fence(), Vector2(1488, Y_SOUTH_FRONT), Vector2(48, 10))
	_add_solid_sprite(props, "ParkTreeS", PlaceholderArt.tree(1), Vector2(1488, Y_SOUTH_FRONT + 48), Vector2(14, 8))
	_add_solid_sprite(props, "ParkBenchS", PlaceholderArt.bench(), Vector2(1550, Y_SOUTH_FRONT + 20), Vector2(36, 10))
	_add_park_lamp(props, "ParkLamp", Vector2(2048, 820))
	_add_park_lamp(props, "StreetLamp2", Vector2(240, Y_SOUTH_WALK))
	_add_park_lamp(props, "StreetLamp3", Vector2(816, Y_SOUTH_WALK))
	_add_park_lamp(props, "StreetLamp4", Vector2(1472, Y_SOUTH_WALK))
	_add_park_lamp(props, "StreetLamp5", Vector2(1760, Y_SOUTH_WALK))
	_add_park_lamp(props, "NorthLamp1", Vector2(320, Y_DOOR))
	_add_park_lamp(props, "NorthLamp2", Vector2(640, Y_DOOR))
	_add_park_lamp(props, "NorthLamp3", Vector2(1120, Y_DOOR))
	_add_park_lamp(props, "NorthLamp4", Vector2(1600, Y_DOOR))
	_add_window("CottageWindow", Vector2(190, Y_FRONT - 70))
	_add_window("PostWindow", Vector2(360, Y_FRONT - 70))
	_add_window("DinerWindow", Vector2(560, Y_FRONT - 70))
	_add_window("BarberWindow", Vector2(1040, Y_FRONT - 70))
	_add_window("VacantWindow", Vector2(1220, Y_FRONT - 70))
	_add_window("ParkWindow", Vector2(2048, 780))
	_add_gate(props)
	_add_shop_doors(props)
	_add_happening(
		props,
		"FridayDelivery",
		"friday_delivery",
		Vector2(760, Y_DOOR),
		PlaceholderArt.crate(),
		Vector2i(32, 32),
		1,
		"Frank",
		"Look at the delivery",
		"happening_friday",
		"Frank sets a box down outside the store."
	)
	_add_happening(
		props,
		"SaturdayPark",
		"saturday_park",
		Vector2(2048, 920),
		PlaceholderArt.townsfolk(1),
		Vector2i(32, 48),
		2,
		"A neighbor",
		"Say hello",
		"happening_saturday",
		"The kids wanted the park before the day got away."
	)
	_add_happening(
		props,
		"SeedCreek",
		"seed_creek",
		Vector2(2176, 720),
		PlaceholderArt.townsfolk(0),
		Vector2i(32, 48),
		2,
		"A neighbor",
		"Watch the creek",
		"happening_seed_creek",
		"The creek took a toy boat this morning."
	)
	_add_happening(
		props,
		"LaterPark",
		"later_park",
		Vector2(2112, 1000),
		PlaceholderArt.townsfolk(2),
		Vector2i(32, 48),
		2,
		"A neighbor",
		"Watch the kite",
		"happening_later_park",
		"The kids found a kite in the creek grass."
	)
	_add_neighbor(props, "NeighborA", "ada", 0, 0, Vector2(360, Y_DOOR))
	_add_neighbor(props, "NeighborB", "ben", 1, 1, Vector2(800, Y_DOOR))
	_add_neighbor(props, "NeighborC", "cleo", 2, 2, Vector2(1240, Y_DOOR))
	var cross := Vector2(240, Y_ROAD)
	_add_neighbor(
		props,
		"NeighborD",
		"don",
		3,
		0,
		Vector2(100, Y_SOUTH_WALK),
		[
			Vector2(100, Y_SOUTH_WALK),
			cross,
			Vector2(240, Y_DOOR),
			Vector2(500, Y_DOOR),
			Vector2(240, Y_DOOR),
			cross,
			Vector2(100, Y_SOUTH_WALK),
		]
	)
	_add_neighbor(
		props,
		"NeighborE",
		"eve",
		4,
		1,
		Vector2(860, Y_SOUTH_WALK),
		[
			Vector2(860, Y_SOUTH_WALK),
			Vector2(860, Y_ROAD),
			Vector2(1500, Y_ROAD),
			Vector2(1500, Y_SOUTH_WALK),
		]
	)
	_add_south_street(props)
	_add_facade_details(props)


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


func _add_window(light_name: String, pos: Vector2) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var light := PointLight2D.new()
	light.name = light_name
	light.position = pos
	light.color = Color(1, 0.86, 0.62)
	light.energy = 0.0
	light.texture = PlaceholderArt.glow()
	light.texture_scale = 2.2
	light.shadow_enabled = false
	light.add_to_group("tod_window")
	lighting.add_child(light)


func _add_gate(props: Node) -> void:
	if props.get_node_or_null("MapleGate") != null:
		return
	var gate := SpeechProp.new()
	gate.name = "MapleGate"
	gate.sheet = PlaceholderArt.lane_gate()
	gate.frame_size = Vector2i(64, 32)
	gate.frame_count = 1
	gate.speaker_name = "Sign"
	gate.prompt_text = "Read the sign"
	gate.line = "The bridge is open. Frank said the boards went in this week. Maple Lane is past the sign."
	gate.blocks_movement = false
	gate.radius = 40.0
	gate.position = Vector2(1856, 1008)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	gate.add_child(sprite)
	props.add_child(gate)


func _add_shop_doors(props: Node) -> void:
	_add_scheduled_door(
		props,
		"StoreDoor",
		Vector2(POS_HARDWARE.x, Y_DOOR),
		"Hardware Store",
		"thomas",
		"res://scenes/world/hardware_interior.tscn"
	)
	_add_scheduled_door(
		props,
		"BayDoor",
		Vector2(POS_GARAGE.x, Y_DOOR),
		"Frank's bay",
		"frank",
		"res://scenes/world/bay_interior.tscn"
	)
	var lane := Door.new()
	lane.name = "MapleDoor"
	lane.position = POS_MAPLE_DOOR
	lane.place_name = "Maple Lane"
	lane.prompt_text = "Maple Lane"
	lane.radius = 26.0
	lane.destination_scene = "res://scenes/world/maple_lane.tscn"
	lane.destination_spawn = &"from_oak"
	if props.get_node_or_null("MapleDoor") == null:
		props.add_child(lane)
	else:
		var existing := props.get_node("MapleDoor") as Node2D
		existing.position = POS_MAPLE_DOOR
	_place_marker("from_store", Vector2(POS_HARDWARE.x, Y_SPAWN), &"down")
	_place_marker("from_bay", Vector2(POS_GARAGE.x, Y_SPAWN), &"down")
	_place_marker("from_maple", POS_MAPLE_SPAWN, &"up")


func _add_scheduled_door(props: Node, node_name: String, pos: Vector2, prompt: String, hours_id: String, scene_path: String) -> void:
	var existing := props.get_node_or_null(node_name) as Node2D
	if existing != null:
		existing.position = pos
		return
	var door := ScheduledDoor.new()
	door.name = node_name
	door.position = pos
	door.place_name = prompt
	door.prompt_text = prompt
	door.radius = 26.0
	door.hours_id = hours_id
	door.destination_scene = scene_path
	door.destination_spawn = &"from_street"
	props.add_child(door)


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


func _add_neighbor(
	props: Node,
	node_name: String,
	person_id: String,
	index: int,
	variant: int,
	pos: Vector2,
	route_points: Array = []
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := AmbientTownsfolk.new()
	person.name = node_name
	person.person_id = person_id
	person.crowd_index = index
	person.art_variant = variant
	person.position = pos
	person.prompt_text = "Say hello"
	person.radius = 40.0
	var route: Array[Vector2] = []
	for point in route_points:
		if point is Vector2:
			route.append(point)
	if route.is_empty():
		route = [pos, pos + Vector2(180, 0), pos + Vector2(180, 24), pos + Vector2(0, 24)]
	person.set_route(route)
	props.add_child(person)


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


func _add_happening(
	props: Node,
	node_name: String,
	happening_id: String,
	pos: Vector2,
	sheet: Texture2D,
	frame: Vector2i,
	frames: int,
	speaker: String,
	prompt: String,
	dialogue_id: String,
	fallback: String
) -> void:
	if props.get_node_or_null(node_name) != null or sheet == null:
		return
	var spot := HappeningSpot.new()
	spot.name = node_name
	spot.happening_id = happening_id
	spot.position = pos
	spot.sheet = sheet
	spot.frame_size = frame
	spot.frame_count = frames
	spot.speaker_name = speaker
	spot.prompt_text = prompt
	spot.dialogue_id = dialogue_id
	spot.line = fallback
	spot.radius = 42.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	spot.add_child(sprite)
	props.add_child(spot)


func _add_south_street(props: Node) -> void:
	for row in TownFacades.oak_storefronts():
		if str(row.get("side", "")) != "south":
			continue
		var node_name := str(row.get("node", ""))
		var art_id := str(row.get("art", ""))
		if node_name.is_empty() or art_id.is_empty():
			continue
		var texture := PlaceholderArt.facade_art(art_id)
		if texture == null:
			continue
		var pos := Vector2(float(row.get("x", 0)), Y_SOUTH_FRONT)
		var block := Vector2(texture.get_width() - 8.0, texture.get_height() - 18.0)
		_add_solid_sprite(props, node_name, texture, pos, block)
		var sprite := props.get_node_or_null(node_name) as SolidProp
		if sprite != null:
			sprite.z_index = -1
			sprite.block_offset = Vector2(0.0, -18.0 - block.y * 0.5)
		_add_window("%sWindow" % node_name, Vector2(pos.x, Y_SOUTH_FRONT - 70))
		_ensure_occluder(node_name)


func _add_facade_details(props: Node) -> void:
	var index := 0
	for row in TownFacades.oak_storefronts():
		var node_name := str(row.get("node", ""))
		var side := str(row.get("side", "north"))
		var x := float(row.get("x", 0))
		var door_y := Y_DOOR if side == "north" else Y_SOUTH_DOOR
		var sign_id := str(row.get("sign_id", ""))
		var sign_text := str(row.get("sign", ""))
		if not sign_id.is_empty():
			var sign_tex := PlaceholderArt.hanging_sign(sign_id, sign_text, index)
			var sign_y := Y_DOOR - 12.0 if side == "north" else Y_SOUTH_DOOR - 12.0
			_add_solid_sprite(props, "%sSign" % node_name, sign_tex, Vector2(x, sign_y), Vector2(8, 6))
			var sign_node := props.get_node_or_null("%sSign" % node_name) as Node2D
			if sign_node != null:
				sign_node.add_to_group("shop_sign")
		var scheduled := str(row.get("scheduled", ""))
		if not scheduled.is_empty():
			index += 1
			continue
		_add_building_door(
			props,
			"%sDoor" % node_name,
			Vector2(x, door_y),
			str(row.get("place", node_name)),
			str(row.get("flavor", "Closed for the day.")),
			str(row.get("id", "")),
			str(row.get("destination_scene", "")),
			StringName(str(row.get("destination_spawn", "from_street")))
		)
		index += 1


func _add_building_door(
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
	props.add_child(door)


func _ensure_occluder(sprite_name: String) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null:
		return
	var occ_name := "%sOccluder" % sprite_name
	if lighting.get_node_or_null(occ_name) == null:
		var occluder := LightOccluder2D.new()
		occluder.name = occ_name
		lighting.add_child(occluder)
	_occlude("Lighting/%s" % occ_name, "Props/%s" % sprite_name)
