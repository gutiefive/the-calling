extends WorldRoom
## Multi-room sanctuary: narthex, worship hall, office, prayer room, choir, and storage.


func area_name() -> String:
	return "Sanctuary"


func _on_time_changed() -> void:
	super._on_time_changed()
	var service := get_node_or_null("SundayService")
	if service != null and service.has_method("on_clock"):
		service.call("on_clock")


func _build() -> void:
	bounds = InteriorLayout.sanctuary_bounds()
	_assign_art()
	_place_props()
	_add_furniture()
	_add_flavor_props()
	_add_ambients()
	_paint_ground()
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	_add_rect(Vector2(736, 1210), Vector2(72, 12))


func rebuild_collision() -> void:
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	_add_rect(Vector2(736, 1210), Vector2(72, 12))


func _assign_art() -> void:
	_set_sprite("Props/Window", InteriorArt.texture("stained_glass"))
	_set_sprite("Props/Cross", InteriorArt.texture("cross"))
	_set_sprite("Props/Altar", InteriorArt.texture("altar"))
	_set_sprite("Props/Chairs", InteriorArt.texture("stacked_chairs"))
	for i in 4:
		_set_sprite("Props/PewL%d" % (i + 1), InteriorArt.texture("pew"))
		_set_sprite("Props/PewR%d" % (i + 1), InteriorArt.texture("pew"))
	_set_light_texture("Lighting/SconceL")
	_set_light_texture("Lighting/SconceR")
	_set_light_texture("Lighting/SconceN")


func _place_props() -> void:
	_place("Props/Door", InteriorLayout.POS_SANCT_DOOR)
	_place("Props/Altar", InteriorLayout.POS_SANCT_ALTAR)
	_feet_offset("Props/Altar")
	_place("Props/Cross", InteriorLayout.POS_SANCT_CROSS)
	_feet_offset("Props/Cross")
	_place("Props/Window", Vector2(240, 340))
	_feet_offset("Props/Window")
	_place("Props/Chairs", InteriorLayout.POS_SANCT_KEYS + Vector2(-36, 8))
	_feet_offset("Props/Chairs")
	_place("Props/Harold", InteriorLayout.POS_SANCT_HAROLD)
	_place("Props/Margaret", InteriorLayout.POS_SANCT_MARGARET)
	_place("Props/KeyRing", InteriorLayout.POS_SANCT_KEYS)
	_place("Props/Ledger", InteriorLayout.POS_SANCT_LEDGER)
	_add_quiet_note()
	_add_sanctuary_flowers()
	_place("Props/Thomas", InteriorLayout.POS_SANCT_THOMAS)
	_place("Props/Frank", InteriorLayout.POS_SANCT_FRANK)
	_place("Props/Sarah", InteriorLayout.POS_SANCT_SARAH)
	var pew_ys := InteriorLayout.pew_rows()
	for i in pew_ys.size():
		_place("Props/PewL%d" % (i + 1), Vector2(480, pew_ys[i]))
		_place("Props/PewR%d" % (i + 1), Vector2(992, pew_ys[i]))
		_feet_offset("Props/PewL%d" % (i + 1))
		_feet_offset("Props/PewR%d" % (i + 1))
		_set_pew_block("Props/PewL%d" % (i + 1))
		_set_pew_block("Props/PewR%d" % (i + 1))
	_place("Spawns/default", InteriorLayout.POS_SANCT_SPAWN)
	_place("Spawns/from_exterior", InteriorLayout.POS_SANCT_SPAWN)
	var spawn := get_node_or_null("Spawns/default")
	var entered := get_node_or_null("Spawns/from_exterior")
	if spawn != null:
		spawn.set_meta("facing", &"up")
	if entered != null:
		entered.set_meta("facing", &"up")
	_place("Lighting/SconceL", Vector2(420, 1000))
	_place("Lighting/SconceR", Vector2(1050, 1000))
	_place("Lighting/SconceN", Vector2(736, 360))


func _set_pew_block(node_path: String) -> void:
	var pew := get_node_or_null(node_path)
	if pew != null and "block_size" in pew:
		pew.set("block_size", Vector2(200, 12))


func _refresh_living() -> void:
	super._refresh_living()
	_apply_sanctuary_flowers()


func _add_sanctuary_flowers() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("SanctuaryFlowers") != null:
		return
	var bouquet := Sprite2D.new()
	bouquet.name = "SanctuaryFlowers"
	bouquet.texture = PlaceholderArt.flowers()
	bouquet.centered = true
	bouquet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bouquet.position = InteriorLayout.POS_SANCT_FLOWERS
	if bouquet.texture != null:
		bouquet.offset = Vector2(0, -bouquet.texture.get_height() * 0.5)
	bouquet.visible = false
	props.add_child(bouquet)
	_apply_sanctuary_flowers()


func _apply_sanctuary_flowers() -> void:
	var bouquet := get_node_or_null("Props/SanctuaryFlowers") as CanvasItem
	if bouquet == null:
		return
	bouquet.visible = NarrativeState.flag_is_true("sanctuary_flowers_set")


func _add_quiet_note() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("QuietSunday") != null:
		return
	var note := SpeechProp.new()
	note.name = "QuietSunday"
	note.position = Vector2(736, 700)
	note.sheet = PlaceholderArt.ledger()
	note.frame_size = Vector2i(32, 32)
	note.frame_count = 1
	note.speaker_name = "Note"
	note.prompt_text = "Read"
	note.line = DayClock.LATER_SUNDAY_NOTE
	note.radius = 36.0
	note.visible = false
	note.enabled = false
	note.add_to_group("quiet_sunday")
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	note.add_child(sprite)
	props.add_child(note)


func _add_furniture() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_solid(props, "Pulpit", "pulpit", InteriorLayout.POS_SANCT_PULPIT, Vector2(28, 12))
	_add_solid(props, "Platform", "platform", Vector2(736, 348), Vector2(140, 10))
	_add_solid(props, "SideCandles", "candles", Vector2(680, 352), Vector2(12, 8))
	_add_solid(props, "AltarCandles", "candles", Vector2(780, 352), Vector2(12, 8))
	_add_solid(props, "WelcomeTable", "welcome_table", Vector2(560, 980), Vector2(64, 12))
	_add_solid(props, "CoatRack", "coat_rack", Vector2(400, 960), Vector2(14, 10))
	_add_solid(props, "NarthexBench", "bench", Vector2(1000, 1020), Vector2(44, 10))
	_add_solid(props, "OfficeDesk", "desk", Vector2(192, 140), Vector2(56, 14))
	_add_solid(props, "OfficeChair", "office_chair", Vector2(192, 176), Vector2(14, 10))
	_add_solid(props, "OfficeShelf", "bookshelf", Vector2(80, 80), Vector2(28, 14))
	_add_solid(props, "OfficeFiling", "filing", Vector2(300, 80), Vector2(18, 12))
	_add_solid(props, "OfficeLamp", "lamp", Vector2(120, 100), Vector2(10, 8))
	_add_solid(props, "Kneeler", "kneeler", Vector2(500, 120), Vector2(22, 10))
	_add_solid(props, "PrayerBench", "bench", Vector2(600, 150), Vector2(44, 10))
	_add_solid(props, "PrayerCandles", "candles", Vector2(460, 80), Vector2(12, 8))
	_add_solid(props, "ChoirPiano", "piano", Vector2(820, 100), Vector2(56, 14))
	_add_solid(props, "ChoirSupplies", "folding_tables", Vector2(1248, 120), Vector2(36, 12))
	_add_glass(props, "GlassE1", "stained_glass_b", Vector2(1220, 360))
	_add_glass(props, "GlassE2", "stained_glass_c", Vector2(1220, 520))
	_add_glass(props, "GlassE3", "stained_glass_b", Vector2(1220, 680))
	_add_glass(props, "GlassW1", "stained_glass_c", Vector2(250, 520))
	_add_glass(props, "GlassW2", "stained_glass", Vector2(250, 680))
	_add_stain_pool(props, "StainE", Vector2(1180, 500))
	_add_stain_pool(props, "StainW", Vector2(280, 500))
	_add_office_window(props)


func _add_flavor_props() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_flavor(props, "BulletinBoard", "bulletin", Vector2(900, 930), Vector2i(40, 48), "Board", "Read", "A potluck flyer, a lost glove, and a bake-sale date.")
	_add_flavor(props, "GuestBook", "guest_book", Vector2(640, 960), Vector2i(32, 24), "Guest book", "Read", "Last week someone wrote 'glad we came.' The ink is still shiny.")
	_add_flavor(props, "SanctuaryPiano", "piano", InteriorLayout.POS_SANCT_PIANO, Vector2i(72, 40), "Piano", "Look", "The hymn is still open to the third verse.", Vector2(56, 14))
	_add_flavor(props, "StainedGlassLook", "stained_glass", Vector2(1220, 440), Vector2i(32, 56), "Window", "Look", "Morning color pools on the carpet. It makes the room feel kept.")
	_add_flavor(props, "HymnBoardLook", "hymn_board", Vector2(260, 400), Vector2i(28, 40), "Hymn board", "Read", "Today's numbers are in Margaret's careful hand.", Vector2(16, 10))
	_add_flavor(props, "VisionSketch", "vision_sketch", Vector2(80, 140), Vector2i(28, 24), "Sketch", "Look", "A pencil drawing of extra wings and a taller roof. Somebody was dreaming on scrap paper.")
	_add_flavor(props, "OfficePhoto", "photo", Vector2(280, 60), Vector2i(20, 24), "Photo", "Look", "A faded picnic. Nobody wrote names on the back.")
	_add_flavor(props, "RestroomLook", "restroom_door", Vector2(1420, 256), Vector2i(24, 48), "Door", "Look", "The lock works. That's enough.", Vector2(16, 20))


func _add_ambients() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_ambient(
		props,
		"PrayerNeighbor",
		"prayer_neighbor",
		0,
		Vector2(528, 130),
		[Vector2(520, 128), Vector2(548, 136)],
		PackedStringArray(["Day", "Evening"]),
		InteriorLayout.weekdays(),
		8,
		18,
		true
	)
	_add_ambient(
		props,
		"ChoirHelper",
		"choir_helper",
		1,
		Vector2(864, 120),
		[Vector2(840, 118), Vector2(900, 130)],
		PackedStringArray(["Day"]),
		PackedStringArray(["Monday", "Tuesday", "Wednesday", "Friday"]),
		9,
		16,
		true
	)


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := InteriorArt.atlas()
	if layer == null or tex == null:
		push_error("Sanctuary ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in InteriorLayout.SANCTUARY_SIZE.y:
		for x in InteriorLayout.SANCTUARY_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, InteriorLayout.TILE_WALL)
	_fill_rect(layer, InteriorLayout.SANCT_OFFICE, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_PRAYER, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_CHOIR, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_STORAGE, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_HALLWAY, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_WORSHIP, InteriorLayout.TILE_CARPET)
	_fill_rect(layer, InteriorLayout.SANCT_NARTHEX, InteriorLayout.TILE_STONE)
	for cell in InteriorLayout.sanctuary_doorways():
		layer.set_cell(cell, 0, InteriorLayout.TILE_WOOD)
	for y in range(InteriorLayout.SANCT_WORSHIP.position.y, InteriorLayout.SANCT_WORSHIP.end.y):
		layer.set_cell(Vector2i(22, y), 0, InteriorLayout.TILE_RUNNER)
		layer.set_cell(Vector2i(23, y), 0, InteriorLayout.TILE_RUNNER)
	for y in [12, 16, 20, 24]:
		layer.set_cell(Vector2i(6, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(7, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(38, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(39, y), 0, InteriorLayout.TILE_STAIN)


func _add_walls() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null:
		return
	for y in InteriorLayout.SANCTUARY_SIZE.y:
		for x in InteriorLayout.SANCTUARY_SIZE.x:
			if layer.get_cell_atlas_coords(Vector2i(x, y)) == InteriorLayout.TILE_WALL:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))


func _fill_rect(layer: TileMapLayer, rect: Rect2i, tile: Vector2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile)


func _make_tileset(tex: Texture2D) -> TileSet:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(32, 32)
	for i in 8:
		atlas.create_tile(Vector2i(i, 0))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_source(atlas, 0)
	return tileset


func _add_solid(props: Node, node_name: String, frame_id: String, pos: Vector2, block: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := SolidProp.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.block_size = block
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)


func _add_glass(props: Node, node_name: String, frame_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)
	_add_stained_light(node_name + "Light", pos + Vector2(0, 36), _glass_color(frame_id))


func _add_stain_pool(props: Node, node_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture("stain_pool")
	sprite.centered = true
	sprite.z_index = -1
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)


func _add_office_window(props: Node) -> void:
	if props.get_node_or_null("OfficeWindow") != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = "OfficeWindow"
	sprite.texture = InteriorArt.texture("stained_glass_c")
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = Vector2(192, 40)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)
	_add_lamp_light("OfficeGlow", Vector2(140, 110), Color(1, 0.86, 0.62), 0.7)


func _add_flavor(
	props: Node,
	node_name: String,
	frame_id: String,
	pos: Vector2,
	frame: Vector2i,
	speaker: String,
	prompt: String,
	line: String,
	block: Vector2 = Vector2.ZERO
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sheet := InteriorArt.texture(frame_id)
	if sheet == null:
		return
	var prop := SpeechProp.new()
	prop.name = node_name
	prop.position = pos
	prop.sheet = sheet
	prop.frame_size = frame
	prop.frame_count = 1
	prop.speaker_name = speaker
	prop.prompt_text = prompt
	prop.line = line
	prop.radius = 36.0
	if block != Vector2.ZERO:
		prop.blocks_movement = true
		prop.block_size = block
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	prop.add_child(sprite)
	props.add_child(prop)


func _add_ambient(
	props: Node,
	node_name: String,
	person_id: String,
	variant: int,
	pos: Vector2,
	route_points: Array,
	phases: PackedStringArray,
	days: PackedStringArray,
	from_hour: int,
	until_hour: int,
	hide_service: bool
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := InteriorAmbient.new()
	person.name = node_name
	person.person_id = person_id
	person.crowd_index = 0
	person.art_variant = variant
	person.appear_phases = phases
	person.days = days
	person.from_hour = from_hour
	person.until_hour = until_hour
	person.hide_during_service = hide_service
	person.position = pos
	person.prompt_text = "Say hello"
	person.radius = 36.0
	person.blocks_movement = false
	if person_id == "choir_helper":
		person.idle_line = "Just stacking the music. Don't mind me."
	else:
		person.idle_line = "The room is quiet. That feels right."
	var route: Array[Vector2] = []
	for point in route_points:
		if point is Vector2:
			route.append(point)
	person.set_route(route)
	props.add_child(person)


func _add_stained_light(light_name: String, pos: Vector2, color: Color) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = light_name
	lamp.position = pos
	lamp.color = color
	lamp.energy = 0.9
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 2.8
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_stained")
	lighting.add_child(lamp)


func _add_lamp_light(light_name: String, pos: Vector2, color: Color, energy: float) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = light_name
	lamp.position = pos
	lamp.color = color
	lamp.energy = energy
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 2.4
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_lamp")
	lighting.add_child(lamp)


func _glass_color(frame_id: String) -> Color:
	if frame_id.ends_with("_b"):
		return Color(0.42, 0.52, 0.92)
	if frame_id.ends_with("_c"):
		return Color(0.95, 0.74, 0.36)
	return Color(0.86, 0.38, 0.42)
