extends WorldRoom
## Multi-room Fellowship Hall: main hall, kitchen, classroom, and storage.

const Catalog := preload("res://scripts/systems/event_catalog.gd")


func area_name() -> String:
	return "Fellowship Hall"


func _ready() -> void:
	super._ready()
	_set_inside(true)


func _exit_tree() -> void:
	_set_inside(false)
	super._exit_tree()


func _build() -> void:
	bounds = InteriorLayout.hall_bounds()
	_paint_ground()
	_place_room()
	_clear_solids()
	_add_walls()
	_add_prop_blocks()


func rebuild_collision() -> void:
	_clear_solids()
	_add_walls()
	_add_prop_blocks()


func _on_time_changed() -> void:
	super._on_time_changed()
	_refresh_gathering()


func _refresh_living() -> void:
	super._refresh_living()
	_refresh_gathering()


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := InteriorArt.atlas()
	if layer == null or tex == null:
		push_error("Fellowship Hall ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in InteriorLayout.HALL_SIZE.y:
		for x in InteriorLayout.HALL_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, InteriorLayout.TILE_WALL)
	_fill_rect(layer, InteriorLayout.HALL_KITCHEN, InteriorLayout.TILE_KITCHEN)
	_fill_rect(layer, InteriorLayout.HALL_STORAGE, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.HALL_CLASS, InteriorLayout.TILE_LINO)
	_fill_rect(layer, InteriorLayout.HALL_HALLWAY, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.HALL_MAIN, InteriorLayout.TILE_WOOD)
	for cell in InteriorLayout.hall_doorways():
		layer.set_cell(cell, 0, InteriorLayout.TILE_WOOD)


func _add_walls() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null:
		return
	for y in InteriorLayout.HALL_SIZE.y:
		for x in InteriorLayout.HALL_SIZE.x:
			if layer.get_cell_atlas_coords(Vector2i(x, y)) == InteriorLayout.TILE_WALL:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))
	_add_rect(Vector2(672, InteriorLayout.HALL_SIZE.y * 32 - 6), Vector2(64, 12))


func _fill_rect(layer: TileMapLayer, rect: Rect2i, tile: Vector2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile)


func _place_room() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	if props is Node2D:
		(props as Node2D).y_sort_enabled = true
	_add_door(props)
	_place_marker("default", InteriorLayout.POS_HALL_SPAWN, &"up")
	_place_marker("from_grounds", InteriorLayout.POS_HALL_SPAWN, &"up")
	_add_lamp(Vector2(220, 420))
	_add_lamp(Vector2(1100, 420))
	_add_lamp(Vector2(672, 500))
	_add_lamp(Vector2(224, 140))
	_add_lamp(Vector2(1056, 140))
	_add_lamp(Vector2(980, 430))
	_add_lamp(Vector2(320, 700))
	_add_lamp(Vector2(1050, 700))
	_add_lamp(Vector2(608, 140))
	_add_lamp(Vector2(210, 790))
	_add_lamp(Vector2(1040, 420))
	_add_lamp(Vector2(180, 520))
	_add_lamp(Vector2(260, 70))
	_add_lamp(Vector2(672, 320))
	_add_window_light(Vector2(180, 500))
	_add_window_light(Vector2(1180, 500))
	_add_window_light(Vector2(180, 640))
	_add_window_light(Vector2(1180, 640))
	_add_furniture(props)
	_add_flavor_props(props)
	_mark_zone_props(props)
	_add_ambients(props)
	_add_guest(props, "Margaret", "margaret", "margaret", Catalog.post("margaret"))
	_add_guest(props, "Harold", "harold", "harold", Catalog.post("harold"))
	_add_guest(props, "Sarah", "sarah", "sarah", Catalog.post("sarah"))
	_add_guest(props, "Ostrow", "ostrow", "ostrow", Catalog.post("ostrow"))
	_add_guest(props, "Ruth", "ruth", "ruth", Catalog.post("ruth"))
	_add_guest(props, "Dale", "dale", "dale", Catalog.post("dale"))
	_ensure_gathering(props)
	_refresh_gathering()


func _add_furniture(props: Node) -> void:
	_add_kitchen(props)
	_add_main_hall(props)
	_add_classroom(props)
	_add_hall_storage(props)
	_add_hall_hallway(props)
	_add_window(props, "HallWindowE", Vector2(1180, 500))
	_add_window(props, "HallWindowW", Vector2(180, 500))
	_add_window(props, "HallWindowE2", Vector2(1180, 640))
	_add_window(props, "HallWindowW2", Vector2(180, 640))


func _add_kitchen(props: Node) -> void:
	_add_solid(props, "ServingTable", InteriorArt.texture("counter"), InteriorLayout.POS_HALL_SERVING, Vector2(72, 12))
	_add_solid(props, "KitchenCounter", InteriorArt.texture("counter"), Vector2(180, 80), Vector2(80, 12))
	_add_solid(props, "Stove", InteriorArt.texture("stove"), Vector2(80, 160), Vector2(28, 14))
	_add_solid(props, "Fridge", InteriorArt.texture("fridge"), Vector2(360, 80), Vector2(18, 16))
	_add_solid(props, "Sink", InteriorArt.texture("sink"), Vector2(260, 80), Vector2(28, 12))
	_add_deco(props, "PotsOnStove", "pots", Vector2(80, 148), 1)
	_add_solid(props, "Cooler", InteriorArt.texture("cooler"), Vector2(340, 200), Vector2(22, 10))
	_add_deco(props, "UpperCabinetA", "upper_cabinet", Vector2(180, 48), 0)
	_add_deco(props, "Backsplash", "backsplash", Vector2(180, 58), 0)
	_add_deco(props, "HangingUtensils", "hanging_utensils", Vector2(210, 44), 1)
	_add_deco(props, "KitchenWindow", "kitchen_window", Vector2(260, 44), 0)
	_add_deco(props, "DishRack", "dish_rack", Vector2(260, 68), 1)
	_add_deco(props, "Microwave", "microwave", Vector2(140, 68), 1)
	_add_deco(props, "Mixer", "mixer", Vector2(200, 68), 1)
	_add_solid(props, "KitchenIsland", InteriorArt.texture("island"), Vector2(160, 130), Vector2(52, 12))
	_add_solid(props, "Pantry", InteriorArt.texture("pantry"), Vector2(380, 140), Vector2(16, 14))
	_add_solid(props, "KitchenMop", InteriorArt.texture("mop_bucket"), Vector2(70, 210), Vector2(12, 10))
	_add_deco(props, "KitchenPlant", "plant", Vector2(40, 90), 0)
	_add_flavor(props, "MealTrain", "meal_train", Vector2(320, 90), Vector2i(28, 32), "Board", "Read", "A meal-train sheet. Names and a casserole, no dollar signs.")


func _add_main_hall(props: Node) -> void:
	_add_rug(props, "HallAisleRunner", "rug_aisle_runner", Vector2(672, 640), true)
	_add_rug(props, "HallStageRug", "rug_stage", Vector2(1040, 430), true)
	_add_rug(props, "HallSittingRug", "rug_sitting", Vector2(210, 810), true)
	_add_solid(props, "Podium", InteriorArt.texture("podium"), Vector2(1000, 400), Vector2(22, 12))
	_add_solid(props, "StackedHallChairs", InteriorArt.texture("stacked_chairs"), Vector2(1180, 820), Vector2(18, 12))
	_add_solid(props, "ChairCart", InteriorArt.texture("chair_cart"), Vector2(1140, 820), Vector2(16, 12))
	_add_solid(props, "FoldedTableRack", InteriorArt.texture("folded_table_rack"), Vector2(1188, 780), Vector2(18, 12))
	_add_solid(props, "Stage", InteriorArt.texture("stage"), InteriorLayout.POS_HALL_STAGE, Vector2(96, 12))
	_add_deco(props, "StageCurtain", "stage_curtain", Vector2(1040, 392), 0)
	_add_deco(props, "MicStand", "mic_stand", Vector2(1008, 404), 1)
	_add_solid(props, "StageSpeakerL", InteriorArt.texture("pa_speaker"), Vector2(960, 420), Vector2(12, 10))
	_add_solid(props, "StageSpeakerR", InteriorArt.texture("pa_speaker"), Vector2(1120, 420), Vector2(12, 10))
	_add_solid(props, "HallPiano", InteriorArt.texture("piano"), Vector2(1188, 490), Vector2(56, 14))
	_add_deco(props, "HallPianoBench", "piano_bench", Vector2(1188, 512), 0)
	_add_deco(props, "PianoSheet", "sheet_music", Vector2(1188, 478), 1)
	_add_solid(props, "SittingCouch", InteriorArt.texture("couch"), Vector2(200, 800), Vector2(40, 12))
	_add_solid(props, "SittingChair", InteriorArt.texture("armchair"), Vector2(260, 828), Vector2(18, 10))
	_add_deco(props, "SittingTable", "side_table", Vector2(230, 780), 0)
	_add_solid(props, "SittingLamp", InteriorArt.texture("floor_lamp"), Vector2(168, 770), Vector2(10, 8))
	_add_solid(props, "SittingShelf", InteriorArt.texture("bookshelf"), Vector2(155, 740), Vector2(20, 12))
	_add_flavor(props, "WelcomeTable", "welcome_table", Vector2(560, 840), Vector2i(80, 36), "Table", "Look", "A clipboard for dishes and rides. Half the names are in Harold's hand.", Vector2(36, 10))
	_add_deco(props, "WelcomeClipboard", "clipboard", Vector2(560, 828), 1)
	_add_solid(props, "DoorCoatRack", InteriorArt.texture("coat_rack"), Vector2(780, 840), Vector2(16, 12))
	_add_deco(props, "DonutBox", "donut_box", Vector2(188, 508), 1)
	_add_deco(props, "CupStack", "cup_stack", Vector2(216, 508), 1)
	_add_deco(props, "CoffeeUrn", "coffee_urn", Vector2(168, 508), 1)
	_add_deco(props, "KidsEasel", "kids_easel", Vector2(880, 418), 0)
	_add_deco(props, "KidsBlocks", "toy_blocks", Vector2(900, 430), 1)
	_add_solid(props, "KidsCornerBin", InteriorArt.texture("toy_bin"), Vector2(918, 424), Vector2(14, 8))
	_add_deco(props, "TrophyShelf", "trophy_shelf", Vector2(780, 396), 0)
	_add_deco(props, "PhotoWall", "photo_wall", Vector2(600, 396), 0)
	_add_solid(props, "WaterCooler", InteriorArt.texture("water_cooler"), Vector2(180, 600), Vector2(14, 12))
	_add_solid(props, "TrashCan", InteriorArt.texture("trash_can"), Vector2(1188, 700), Vector2(12, 10))
	_add_solid(props, "RecyclingBin", InteriorArt.texture("recycling_bin"), Vector2(1204, 700), Vector2(12, 10))
	_add_solid(props, "HallPlantA", InteriorArt.texture("plant_tall"), Vector2(200, 440), Vector2(12, 10))
	_add_solid(props, "HallPlantB", InteriorArt.texture("plant"), Vector2(1190, 760), Vector2(12, 10))
	_add_solid(props, "HallPlantC", InteriorArt.texture("plant"), Vector2(400, 400), Vector2(12, 10))
	_add_solid(props, "HallPlantD", InteriorArt.texture("plant_tall"), Vector2(940, 400), Vector2(12, 10))
	_add_deco(props, "KidsArtA", "kids_art", Vector2(360, 400), 0)
	_add_deco(props, "KidsArtB", "kids_art", Vector2(520, 400), 0)
	_add_deco(props, "WallBannerA", "wall_banner", Vector2(860, 396), 0)
	_add_deco(props, "WallBannerB", "sanctuary_banner", Vector2(460, 396), 0)
	_add_deco(props, "WindowPoolW", "window_pool", Vector2(180, 520), -2)
	_add_deco(props, "WindowPoolE", "window_pool", Vector2(1180, 520), -2)
	_add_deco(props, "WindowPoolW2", "window_pool", Vector2(180, 660), -2)
	_add_deco(props, "WindowPoolE2", "window_pool", Vector2(1180, 660), -2)
	for row_v in InteriorLayout.hall_tables():
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		_place_hall_table(props, row)


func _add_classroom(props: Node) -> void:
	_add_solid(props, "KidsTableA", InteriorArt.texture("kids_table"), Vector2(980, 120), Vector2(36, 10))
	_add_solid(props, "KidsTableB", InteriorArt.texture("kids_table"), Vector2(1140, 120), Vector2(36, 10))
	_add_solid(props, "KidsChairA", InteriorArt.texture("kids_chair"), Vector2(960, 150), Vector2(10, 8))
	_add_solid(props, "KidsChairB", InteriorArt.texture("kids_chair"), Vector2(1000, 150), Vector2(10, 8))
	_add_solid(props, "KidsChairC", InteriorArt.texture("kids_chair"), Vector2(1120, 150), Vector2(10, 8))
	_add_solid(props, "KidsChairD", InteriorArt.texture("kids_chair"), Vector2(1160, 150), Vector2(10, 8))
	_add_solid(props, "ClassShelf", InteriorArt.texture("bookshelf"), Vector2(1210, 80), Vector2(24, 14))
	_add_solid(props, "Cubbies", InteriorArt.texture("cubbies"), Vector2(880, 80), Vector2(36, 12))
	_add_solid(props, "TeacherDesk", InteriorArt.texture("teacher_desk"), Vector2(1260, 170), Vector2(48, 12))
	_add_solid(props, "ToyBin", InteriorArt.texture("toy_bin"), Vector2(920, 180), Vector2(16, 10))
	_add_solid(props, "Globe", InteriorArt.texture("globe"), Vector2(1230, 190), Vector2(10, 8))
	_add_deco(props, "BeanbagA", "beanbag", Vector2(1000, 200), 0)
	_add_deco(props, "BeanbagB", "beanbag", Vector2(1040, 210), 0)
	_add_rug(props, "ReadingRug", "reading_rug", Vector2(1080, 200))
	_add_deco(props, "AlphabetStrip", "alphabet_strip", Vector2(1056, 48), 0)
	_add_deco(props, "ClassArtA", "kids_art", Vector2(980, 55), 0)
	_add_deco(props, "ClassArtB", "kids_art", Vector2(1140, 55), 0)
	_add_deco(props, "ClassArtC", "kids_art", Vector2(1220, 55), 0)


func _add_hall_storage(props: Node) -> void:
	_add_solid(props, "FoldingStack", InteriorArt.texture("folding_tables"), Vector2(560, 100), Vector2(36, 12))
	_add_solid(props, "SupplyCrate", PlaceholderArt.crate(), Vector2(640, 160), Vector2(16, 10))
	_add_solid(props, "HallShelfA", InteriorArt.texture("storage_shelf"), Vector2(480, 80), Vector2(28, 14))
	_add_solid(props, "HallShelfB", InteriorArt.texture("storage_shelf"), Vector2(720, 80), Vector2(28, 14))
	_add_solid(props, "HallBoxA", InteriorArt.texture("cardboard_box"), Vector2(500, 160), Vector2(16, 10))
	_add_solid(props, "HallBoxB", InteriorArt.texture("cardboard_box"), Vector2(540, 170), Vector2(16, 10))
	_add_solid(props, "LabeledBinA", InteriorArt.texture("labeled_bin"), Vector2(500, 190), Vector2(16, 10))
	_add_solid(props, "LabeledBinB", InteriorArt.texture("labeled_bin"), Vector2(620, 190), Vector2(16, 10))
	_add_solid(props, "HallVacuum", InteriorArt.texture("vacuum"), Vector2(700, 160), Vector2(14, 10))
	_add_solid(props, "HallXmas", InteriorArt.texture("decoration_bin"), Vector2(740, 170), Vector2(18, 10))


func _add_hall_hallway(props: Node) -> void:
	_add_rug(props, "HallwayRunner", "rug_hallway", Vector2(672, 320))
	_add_deco(props, "HallwayPhotoA", "photo", Vector2(300, 300), 0)
	_add_deco(props, "HallwayPhotoB", "photo", Vector2(900, 300), 0)
	_add_deco(props, "HallwayPhotoC", "photo", Vector2(500, 300), 0)
	_add_deco(props, "HallwayPhotoD", "photo", Vector2(1100, 300), 0)
	_add_deco(props, "HallwayCoat", "coat_rack", Vector2(1180, 320), 0)
	_add_deco(props, "HallwayExt", "fire_extinguisher", Vector2(200, 300), 0)
	_add_deco(props, "HallwayPlant", "plant", Vector2(760, 320), 0)
	_add_deco(props, "HallwayFountain", "water_fountain", Vector2(80, 320), 0)


func _place_hall_table(props: Node, row: Dictionary) -> void:
	var table_id := str(row.get("id", ""))
	var kind := str(row.get("kind", "long"))
	var pos_v: Variant = row.get("pos", Vector2.ZERO)
	var pos := Vector2.ZERO
	if pos_v is Vector2:
		pos = pos_v
	if table_id.is_empty():
		return
	var frame_id := InteriorLayout.hall_table_frame(table_id, kind)
	var block := InteriorLayout.hall_table_block(kind)
	_add_solid(props, table_id, InteriorArt.texture(frame_id), pos, block)
	var table := props.get_node_or_null(table_id)
	if table != null:
		if not table.is_in_group("hall_table"):
			table.add_to_group("hall_table")
		table.set_meta("table_kind", kind)
		table.set_meta("has_shadow_legs", true)
		_add_table_shadow(table, kind == "round")
	_add_table_chairs(props, table_id, kind, pos)
	_add_table_clutter(props, table_id, pos)


func _add_table_shadow(host: Node, round: bool) -> void:
	if host.get_node_or_null("Shadow") != null:
		return
	var shadow := Sprite2D.new()
	shadow.name = "Shadow"
	shadow.texture = InteriorArt.texture("table_shadow_round" if round else "table_shadow_long")
	shadow.centered = true
	shadow.position = Vector2(2, 8)
	shadow.z_index = -1
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	host.add_child(shadow)


func _add_table_chairs(props: Node, table_id: String, kind: String, table_pos: Vector2) -> void:
	var offsets: Array[Vector2] = InteriorLayout.hall_chair_offsets(kind)
	for i in offsets.size():
		var chair_name := InteriorLayout.hall_named_chair(table_id, i)
		var frame_id := InteriorLayout.hall_chair_frame(offsets[i])
		_add_solid(props, chair_name, InteriorArt.texture(frame_id), table_pos + offsets[i], Vector2(10, 8))
		var chair := props.get_node_or_null(chair_name)
		if chair != null:
			if not chair.is_in_group("hall_chair"):
				chair.add_to_group("hall_chair")
			chair.set_meta("table_id", table_id)


func _add_table_clutter(props: Node, table_id: String, table_pos: Vector2) -> void:
	var items: PackedStringArray = InteriorLayout.hall_table_clutter(table_id)
	for i in items.size():
		var item_id := items[i]
		_add_deco(props, "%sClutter%d" % [table_id, i], item_id, table_pos + InteriorLayout.hall_clutter_offset(i, items.size()), 1)


func _add_flavor_props(props: Node) -> void:
	_add_flavor(props, "HallBulletin", "bulletin", Vector2(1100, 420), Vector2i(40, 48), "Board", "Read", "A signup sheet for dishes and a note about extra chairs.")
	_add_flavor(props, "CoffeeStation", "coffee", Vector2(200, 520), Vector2i(48, 32), "Coffee", "Look", "The urn is warm. Someone left extra cups.", Vector2(36, 12))
	_add_flavor(props, "LostAndFound", "lost_box", Vector2(400, 330), Vector2i(32, 24), "Box", "Look", "A knit scarf and a single mitten. Harold will know whose.")
	_add_flavor(props, "HallSpeaker", "speaker", Vector2(1088, 448), Vector2i(24, 32), "Speaker", "Look", "A hymn from last week is still in the tray.")
	_add_flavor(props, "Chalkboard", "chalkboard", Vector2(1056, 80), Vector2i(56, 40), "Board", "Look", "A lopsided ark and a list of names in colored chalk.", Vector2(40, 12))
	_add_flavor(props, "CrayonBox", "crayons", Vector2(1080, 150), Vector2i(20, 16), "Crayons", "Look", "Half the reds are gone. The ark still got finished.")


func _add_ambients(props: Node) -> void:
	_add_ambient(
		props,
		"KitchenVolunteer",
		"kitchen_volunteer",
		2,
		Vector2(200, 170),
		[Vector2(180, 168), Vector2(250, 180)],
		PackedStringArray(["Day"]),
		InteriorLayout.weekdays(),
		9,
		16,
		"The rolls can wait. I'm just keeping the pots moving."
	)
	_add_ambient(
		props,
		"ClassroomKid",
		"classroom_kid",
		3,
		Vector2(1056, 180),
		[Vector2(1020, 176), Vector2(1100, 188)],
		PackedStringArray(["Day"]),
		PackedStringArray(["Saturday", "Sunday", "Wednesday"]),
		8,
		16,
		"I'm drawing the boat. The animals keep falling off."
	)


func _ensure_gathering(props: Node) -> void:
	_sprite_prop(props, "TableA", "table_modest", InteriorLayout.POS_HALL_TABLE_A, Vector2(80, 14))
	_sprite_prop(props, "TableB", "table_modest", InteriorLayout.POS_HALL_TABLE_B, Vector2(80, 14))
	_sprite_prop(props, "ChairA", "chair", InteriorLayout.POS_HALL_TABLE_A + Vector2(-28, 26), Vector2(12, 8))
	_sprite_prop(props, "ChairB", "chair", InteriorLayout.POS_HALL_TABLE_A + Vector2(32, 28), Vector2(12, 8))
	_sprite_prop(props, "ChairC", "chair", InteriorLayout.POS_HALL_TABLE_B + Vector2(-28, 26), Vector2(12, 8))
	_sprite_prop(props, "ChairD", "chair", InteriorLayout.POS_HALL_TABLE_B + Vector2(32, 28), Vector2(12, 8))
	_sprite_prop(props, "CenterA", "centerpiece", InteriorLayout.POS_HALL_TABLE_A + InteriorLayout.HALL_CENTER_OFFSET, Vector2(10, 8))
	_sprite_prop(props, "CenterB", "centerpiece", InteriorLayout.POS_HALL_TABLE_B + InteriorLayout.HALL_CENTER_OFFSET, Vector2(10, 8))
	_sprite_prop(props, "DishesA", "dishes_simple", InteriorLayout.POS_HALL_TABLE_A + InteriorLayout.HALL_DISH_OFFSET_A, Vector2(20, 8))
	_sprite_prop(props, "DishesB", "dishes_simple", InteriorLayout.POS_HALL_TABLE_B + InteriorLayout.HALL_DISH_OFFSET_B, Vector2(20, 8))
	_sprite_prop(props, "Lights", "string_lights", InteriorLayout.POS_HALL_LIGHTS, Vector2(12, 8))
	_sprite_prop(props, "Banner", "banner", InteriorLayout.POS_HALL_BANNER, Vector2(12, 8))
	_sprite_prop(props, "ExtraChairs", "chairs_extra", InteriorLayout.POS_HALL_EXTRA_CHAIRS, Vector2(24, 8))
	for node_name in PackedStringArray(["DishesA", "DishesB", "CenterA", "CenterB"]):
		var item := props.get_node_or_null(node_name) as CanvasItem
		if item != null:
			item.z_index = 2


func _refresh_gathering() -> void:
	var events := _events()
	var live := events != null and bool(events.call("is_live"))
	var veggies := live and events != null and bool(events.call("has_varied_dishes"))
	var flowers := live and events != null and bool(events.call("has_centerpieces"))
	var lights := live and events != null and bool(events.call("has_lights"))
	var chairs := live and events != null and bool(events.call("has_extra_chairs"))
	_set_table("TableA", veggies)
	_set_table("TableB", veggies)
	_show("CenterA", live and flowers)
	_show("CenterB", live and flowers)
	_set_dishes("DishesA", live, veggies)
	_set_dishes("DishesB", live, veggies)
	_show("Lights", live and lights)
	_show("Banner", live and lights)
	_show("ExtraChairs", live and chairs)
	_show("ChairA", true)
	_show("ChairB", true)
	_show("ChairC", true)
	_show("ChairD", true)


func _set_table(node_name: String, full: bool) -> void:
	var sprite := get_node_or_null("Props/%s" % node_name) as Sprite2D
	if sprite == null:
		return
	sprite.visible = true
	var events := _events()
	var live := events != null and bool(events.call("is_live"))
	if live:
		var frame_id := "table_full" if full else "table_modest"
		sprite.texture = PotluckArt.texture(frame_id)
	else:
		var idle_id := "long_table_runner" if node_name == "TableB" else "long_table"
		sprite.texture = InteriorArt.texture(idle_id)
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)


func _set_dishes(node_name: String, live: bool, varied: bool) -> void:
	var sprite := get_node_or_null("Props/%s" % node_name) as Sprite2D
	if sprite == null:
		return
	sprite.visible = live
	if not live:
		return
	var frame_id := "dishes_varied" if varied else "dishes_simple"
	sprite.texture = PotluckArt.texture(frame_id)
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)


func _show(node_name: String, shown: bool) -> void:
	var node := get_node_or_null("Props/%s" % node_name) as CanvasItem
	if node != null:
		node.visible = shown
	var body := get_node_or_null("Props/%s" % node_name)
	if body != null and "enabled" in body:
		body.set("enabled", shown)


func _add_door(props: Node) -> void:
	if props.get_node_or_null("Door") != null:
		var existing := props.get_node("Door") as Node2D
		existing.position = InteriorLayout.POS_HALL_DOOR
		return
	var door := Door.new()
	door.name = "Door"
	door.position = InteriorLayout.POS_HALL_DOOR
	door.place_name = "Church grounds"
	door.prompt_text = "Church grounds"
	door.radius = 26.0
	door.destination_scene = "res://scenes/world/church_exterior.tscn"
	door.destination_spawn = &"from_hall"
	props.add_child(door)


func _add_guest(props: Node, node_name: String, npc_id: String, dialogue_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := DialogueNpc.new()
	person.name = node_name
	person.position = pos
	person.npc_id = npc_id
	person.dialogue_id = dialogue_id
	if CharacterSheets.is_named(npc_id):
		person.art_id = npc_id
	else:
		person.sheet = PlaceholderArt.townsfolk(1 if npc_id == "ruth" else 0)
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = node_name
	person.prompt_text = "Talk"
	person.radius = 40.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


func _sprite_prop(props: Node, node_name: String, frame_id: String, pos: Vector2, block: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := SolidProp.new()
	sprite.name = node_name
	sprite.texture = PotluckArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.block_size = block
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_solid(props: Node, node_name: String, texture: Texture2D, pos: Vector2, block: Vector2) -> void:
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
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_deco(props: Node, node_name: String, frame_id: String, pos: Vector2, z: int) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.z_index = z
	if z < 0:
		sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_rug(props: Node, node_name: String, frame_id: String, pos: Vector2, grouped: bool = false) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	sprite.z_index = -2
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	if grouped and not sprite.is_in_group("hall_rug"):
		sprite.add_to_group("hall_rug")
	props.add_child(sprite)


func _mark_prop(node: Node) -> void:
	if node != null and not node.is_in_group("interior_prop"):
		node.add_to_group("interior_prop")


func _add_window(props: Node, node_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture("stained_glass_c")
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


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
	_mark_prop(prop)
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
	line: String
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
	person.hide_during_service = false
	person.idle_line = line
	person.position = pos
	person.prompt_text = "Say hello"
	person.radius = 36.0
	person.blocks_movement = false
	var route: Array[Vector2] = []
	for point in route_points:
		if point is Vector2:
			route.append(point)
	person.set_route(route)
	props.add_child(person)


func _add_lamp(pos: Vector2) -> void:
	_add_point_light(pos, Color(1, 0.86, 0.62), 0.9, 3.2)


func _add_window_light(pos: Vector2) -> void:
	_add_point_light(pos, Color(1, 0.92, 0.72), 0.7, 2.6)


func _add_point_light(pos: Vector2, color: Color, energy: float, texture_scale: float) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null:
		return
	var lamp_name := "Lamp%d" % lighting.get_child_count()
	if lighting.get_node_or_null(lamp_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = lamp_name
	lamp.position = pos
	lamp.color = color
	lamp.energy = energy
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = texture_scale
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_lamp")
	lighting.add_child(lamp)


func _mark_zone_props(props: Node) -> void:
	var zones: Dictionary = InteriorLayout.hall_zone_prop_names()
	for zone_id in zones.keys():
		var names_v: Variant = zones[zone_id]
		if not names_v is PackedStringArray:
			continue
		var names: PackedStringArray = names_v
		for node_name in names:
			var node := props.get_node_or_null(node_name)
			if node == null:
				continue
			node.set_meta("hall_zone", str(zone_id))
			var group_name := "hall_zone_%s" % str(zone_id)
			if not node.is_in_group(group_name):
				node.add_to_group(group_name)


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


func _set_inside(inside: bool) -> void:
	var events := _events()
	if events != null and events.has_method("set_inside"):
		events.call("set_inside", inside)


func _events() -> Node:
	return get_node_or_null("/root/EventState")
