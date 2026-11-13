extends WorldRoom
## Oak Street block: hardware store, Frank's bay, and a cottage. The west edge returns to the church.

const MAP_SIZE := Vector2i(64, 40)
const POS_COTTAGE := Vector2(340, 300)
const POS_HARDWARE := Vector2(680, 320)
const POS_GARAGE := Vector2(1080, 320)
const POS_THOMAS := Vector2(680, 430)
const POS_FRANK := Vector2(1000, 440)
const POS_SARAH := Vector2(480, 520)
const POS_BENCH := Vector2(400, 560)
const POS_LAMP := Vector2(820, 500)
const POS_TREE := Vector2(240, 640)
const POS_CRATE := Vector2(760, 440)
const POS_MAILBOX := Vector2(300, 430)
const POS_DOOR := Vector2(96, 500)
const POS_SPAWN := Vector2(210, 500)
const POS_WIN_H := Vector2(620, 260)
const POS_WIN_G := Vector2(1120, 270)


func area_name() -> String:
	return "Oak Street"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_assign_art()
	_place_props()
	_add_living_town()
	_paint_ground()
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_creek_block()
	_place_occluders()
	NarrativeState.set_flag("seen_oak_street", true)


func rebuild_collision() -> void:
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_add_creek_block()
	_place_occluders()


func _assign_art() -> void:
	_set_sprite("Props/Cottage", PlaceholderArt.cottage())
	_set_sprite("Props/Hardware", PlaceholderArt.hardware_store())
	_set_sprite("Props/Garage", PlaceholderArt.auto_shop())
	_set_sprite("Props/Tree", PlaceholderArt.tree(2))
	_set_sprite("Props/Bench", PlaceholderArt.bench())
	_set_sprite("Props/Lamp", PlaceholderArt.lamp_post())
	_set_sprite("Props/Crate", PlaceholderArt.crate())
	_set_sprite("Props/Mailbox", PlaceholderArt.mailbox())
	_set_light_texture("Props/Lamp/Glow")
	_set_light_texture("Lighting/HardwareWindow")
	_set_light_texture("Lighting/GarageWindow")


func _place_props() -> void:
	var feet: Array[String] = [
		"Props/Cottage", "Props/Hardware", "Props/Garage", "Props/Tree",
		"Props/Bench", "Props/Lamp", "Props/Crate", "Props/Mailbox",
	]
	for path in feet:
		_feet_offset(path)
	_place("Props/Cottage", POS_COTTAGE)
	_place("Props/Hardware", POS_HARDWARE)
	_place("Props/Garage", POS_GARAGE)
	_place("Props/Thomas", POS_THOMAS)
	_place("Props/Frank", POS_FRANK)
	_place("Props/Sarah", POS_SARAH)
	_place("Props/Bench", POS_BENCH)
	_place("Props/Lamp", POS_LAMP)
	_place("Props/Tree", POS_TREE)
	_place("Props/Crate", POS_CRATE)
	_place("Props/Mailbox", POS_MAILBOX)
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
	# The street runs east from the church gate and stops at the creek bank.
	for x in range(1, 57):
		layer.set_cell(Vector2i(x, 12), 0, TownTiles.CURB)
		layer.set_cell(Vector2i(x, 17), 0, TownTiles.CURB)
	for y in range(13, 17):
		for x in range(1, 57):
			layer.set_cell(Vector2i(x, y), 0, TownTiles.ROAD)
	for y in range(18, 22):
		for x in range(8, 56):
			layer.set_cell(Vector2i(x, y), 0, TownTiles.SIDEWALK)
	# Maple Lane, a short stub south of the street. The gate sits on it.
	for y in range(17, 36):
		for x in range(46, 50):
			layer.set_cell(Vector2i(x, y), 0, TownTiles.PATH)
	# A park path south of the shops.
	for x in range(16, 42):
		layer.set_cell(Vector2i(x, 28), 0, TownTiles.PATH)
	for y in range(24, 34):
		layer.set_cell(Vector2i(28, y), 0, TownTiles.PATH)
	for y in range(4, 38):
		for x in range(58, 64):
			layer.set_cell(Vector2i(x, y), 0, TownTiles.WATER)


func _add_buildings() -> void:
	_add_footprint("Props/Cottage")
	_add_footprint("Props/Hardware")
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
	# The creek is a bank you can walk up to. The water itself is solid.
	_add_rect(Vector2(1952, 672), Vector2(192, 1088))


func _add_living_town() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_solid_sprite(props, "YardFlowers", PlaceholderArt.flowers(), Vector2(480, 230), Vector2(26, 10))
	_add_solid_sprite(props, "ParkTree1", PlaceholderArt.tree(0), Vector2(880, 900), Vector2(14, 8))
	_add_solid_sprite(props, "ParkTree2", PlaceholderArt.tree(1), Vector2(1400, 1120), Vector2(14, 8))
	_add_solid_sprite(props, "ParkTree3", PlaceholderArt.tree(2), Vector2(620, 1040), Vector2(14, 8))
	_add_solid_sprite(props, "ParkBench", PlaceholderArt.bench(), Vector2(1000, 940), Vector2(36, 10))
	_add_solid_sprite(props, "ParkBench2", PlaceholderArt.bench(), Vector2(1240, 1020), Vector2(36, 10))
	_add_solid_sprite(props, "ParkMailbox", PlaceholderArt.mailbox(), Vector2(720, 880), Vector2(12, 8))
	_add_park_lamp(props)
	_add_window("CottageWindow", Vector2(300, 250))
	_add_window("ParkWindow", Vector2(1100, 820))
	_add_gate(props)
	_add_shop_doors(props)
	_add_happening(
		props,
		"FridayDelivery",
		"friday_delivery",
		Vector2(760, 500),
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
		Vector2(1100, 980),
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
		Vector2(1500, 980),
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
		Vector2(1180, 1000),
		PlaceholderArt.townsfolk(2),
		Vector2i(32, 48),
		2,
		"A neighbor",
		"Watch the kite",
		"happening_later_park",
		"The kids found a kite in the creek grass."
	)
	_add_neighbor(props, "NeighborA", "ada", 0, 0, Vector2(420, 620))
	_add_neighbor(props, "NeighborB", "ben", 1, 1, Vector2(860, 620))
	_add_neighbor(props, "NeighborC", "cleo", 2, 2, Vector2(1280, 620))


func _add_park_lamp(props: Node) -> void:
	if props.get_node_or_null("ParkLamp") != null:
		return
	var lamp := SolidProp.new()
	lamp.name = "ParkLamp"
	lamp.texture = PlaceholderArt.lamp_post()
	lamp.centered = true
	lamp.offset = Vector2(0, -lamp.texture.get_height() * 0.5)
	lamp.position = Vector2(1100, 860)
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
	gate.position = Vector2(1520, 1024)
	gate.sheet = PlaceholderArt.lane_gate()
	gate.frame_size = Vector2i(64, 32)
	gate.frame_count = 1
	gate.speaker_name = "Sign"
	gate.prompt_text = "Read the sign"
	gate.line = "The bridge is open. Frank said the boards went in this week. Maple Lane is past the sign."
	gate.blocks_movement = false
	gate.radius = 40.0
	gate.position = Vector2(1400, 980)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	gate.add_child(sprite)
	props.add_child(gate)


func _add_shop_doors(props: Node) -> void:
	_add_scheduled_door(
		props,
		"StoreDoor",
		Vector2(540, 530),
		"Enter the store",
		"thomas",
		"res://scenes/world/hardware_interior.tscn"
	)
	_add_scheduled_door(
		props,
		"BayDoor",
		Vector2(1160, 480),
		"Enter the bay",
		"frank",
		"res://scenes/world/bay_interior.tscn"
	)
	var lane := Door.new()
	lane.name = "MapleDoor"
	lane.position = Vector2(1536, 1104)
	lane.prompt_text = "Walk to Maple Lane"
	lane.radius = 42.0
	lane.destination_scene = "res://scenes/world/maple_lane.tscn"
	lane.destination_spawn = &"from_oak"
	if props.get_node_or_null("MapleDoor") == null:
		props.add_child(lane)
	_place_marker("from_store", Vector2(540, 610), &"down")
	_place_marker("from_bay", Vector2(1160, 570), &"down")
	_place_marker("from_maple", Vector2(1536, 1008), &"up")


func _add_scheduled_door(props: Node, node_name: String, pos: Vector2, prompt: String, hours_id: String, scene_path: String) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var door := ScheduledDoor.new()
	door.name = node_name
	door.position = pos
	door.prompt_text = prompt
	door.radius = 40.0
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


func _add_neighbor(props: Node, node_name: String, person_id: String, index: int, variant: int, pos: Vector2) -> void:
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
	var route: Array[Vector2] = [pos, pos + Vector2(160, 0), pos + Vector2(160, 36), pos + Vector2(0, 36)]
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


