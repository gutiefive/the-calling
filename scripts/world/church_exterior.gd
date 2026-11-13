extends WorldRoom
## Church campus. Positions live in GroundsLayout so doors, paths, and tests stay aligned.

const TILE := GroundsLayout.TILE
const MAP_SIZE := GroundsLayout.MAP_SIZE
const POS_CHURCH := GroundsLayout.POS_CHURCH
const POS_DOOR := GroundsLayout.POS_DOOR
const POS_MAT := GroundsLayout.POS_MAT
const POS_SPAWN := GroundsLayout.POS_SPAWN
const POS_RETURN := GroundsLayout.POS_RETURN
const POS_MARGARET := GroundsLayout.POS_MARGARET
const POS_NOTICE := GroundsLayout.POS_NOTICE
const POS_BENCH := GroundsLayout.POS_BENCH
const POS_LAMP := GroundsLayout.POS_LAMP
const POS_FLOWERS := GroundsLayout.POS_FLOWERS
const POS_WIN_L := GroundsLayout.POS_WIN_L
const POS_WIN_R := GroundsLayout.POS_WIN_R
const POS_STREET_DOOR := GroundsLayout.POS_STREET_DOOR
const POS_FROM_STREET := GroundsLayout.POS_FROM_STREET
const POS_HAROLD := GroundsLayout.POS_HAROLD
const POS_OSTROW := GroundsLayout.POS_OSTROW


func area_name() -> String:
	return "Church grounds"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * TILE, MAP_SIZE.y * TILE)
	_assign_art()
	_place_props()
	_add_wayfinding()
	_add_home()
	_add_fellowship_hall()
	_add_campus_props()
	_add_expansion_plots()
	_add_grounds_work()
	_add_church_garden()
	_add_sunday_gathering()
	_paint_ground()
	_clear_solids()
	_add_church_collision()
	_add_parsonage_block()
	_add_hall_block()
	_add_campus_blocks()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_place_occluder()


func rebuild_collision() -> void:
	_clear_solids()
	_add_church_collision()
	_add_parsonage_block()
	_add_hall_block()
	_add_campus_blocks()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_place_occluder()


func _assign_art() -> void:
	_set_sprite("Props/Church", PlaceholderArt.church_front())
	_set_sprite("Props/Mat", PlaceholderArt.door_mat())
	_set_sprite("Props/Tree1", PlaceholderArt.tree(0))
	_set_sprite("Props/Tree2", PlaceholderArt.tree(1))
	_set_sprite("Props/Tree3", PlaceholderArt.tree(2))
	_set_sprite("Props/Tree4", PlaceholderArt.tree(0))
	_set_sprite("Props/Tree5", PlaceholderArt.tree(1))
	_set_sprite("Props/Bench", PlaceholderArt.bench())
	_set_sprite("Props/Flowers", PlaceholderArt.overgrown_bed())
	_set_sprite("Props/Lamp", PlaceholderArt.lamp_post())
	_set_light_texture("Props/Lamp/Glow")
	_set_light_texture("Lighting/WindowL")
	_set_light_texture("Lighting/WindowR")


func _place_props() -> void:
	_place("Props/Church", POS_CHURCH)
	_feet_offset("Props/Church")
	_place("Props/Door", POS_DOOR)
	_place("Props/StreetDoor", POS_STREET_DOOR)
	_place("Props/Mat", POS_MAT)
	_feet_offset("Props/Mat")
	_place("Props/Margaret", POS_MARGARET)
	_place("Props/Harold", POS_HAROLD)
	_place("Props/Ostrow", POS_OSTROW)
	_place("Props/Notice", POS_NOTICE)
	_place("Props/Bench", POS_BENCH)
	_feet_offset("Props/Bench")
	_place("Props/Lamp", POS_LAMP)
	_feet_offset("Props/Lamp")
	_place("Props/Flowers", POS_FLOWERS)
	_feet_offset("Props/Flowers")
	var trees: Array[Vector2] = [
		Vector2(160, 720), Vector2(1600, 200), Vector2(180, 1100), Vector2(1648, 1264), Vector2(1280, 560),
	]
	for i in trees.size():
		var path := "Props/Tree%d" % (i + 1)
		_place(path, trees[i])
		_feet_offset(path)
	_place("Spawns/default", POS_SPAWN)
	_place("Spawns/from_sanctuary", POS_RETURN)
	_place("Spawns/from_street", POS_FROM_STREET)
	var default_spawn := get_node_or_null("Spawns/default")
	var returned := get_node_or_null("Spawns/from_sanctuary")
	var from_street := get_node_or_null("Spawns/from_street")
	if default_spawn != null:
		default_spawn.set_meta("facing", &"up")
	if returned != null:
		returned.set_meta("facing", &"down")
	if from_street != null:
		from_street.set_meta("facing", &"left")
	_place("Lighting/WindowL", POS_WIN_L)
	_place("Lighting/WindowR", POS_WIN_R)


func _refresh_living() -> void:
	super._refresh_living()
	_apply_grounds_look()


func _apply_grounds_look() -> void:
	var flowers := get_node_or_null("Props/Flowers") as Sprite2D
	if flowers != null:
		var tidy := NarrativeState.flag_is_true("grounds_bed") or NarrativeState.flag_is_true("grounds_tidy")
		flowers.texture = PlaceholderArt.flowers() if tidy else PlaceholderArt.overgrown_bed()
		_feet_offset("Props/Flowers")
	var mend := get_node_or_null("Props/FenceMend") as CanvasItem
	if mend != null:
		var fixed := NarrativeState.flag_is_true("church_fence_mended")
		mend.visible = fixed
		if "enabled" in mend:
			mend.set("enabled", fixed)
	_apply_sunday_crowd()
	for node in get_tree().get_nodes_in_group("day_world"):
		if is_ancestor_of(node) and node.has_method("apply_clock"):
			node.call("apply_clock")


func _apply_sunday_crowd() -> void:
	var clock := get_node_or_null("/root/DayClock")
	var show := false
	if clock != null:
		show = str(clock.call("weekday_name")) == "Sunday" and int(clock.get("hour")) < 10
	for node in get_tree().get_nodes_in_group("sunday_courtyard"):
		if not is_ancestor_of(node):
			continue
		if node is CanvasItem:
			(node as CanvasItem).visible = show
		if "enabled" in node:
			node.set("enabled", show)


func _add_fellowship_hall() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("FellowshipHall") != null:
		return
	var hall := FellowshipHall.new()
	hall.name = "FellowshipHall"
	hall.position = GroundsLayout.POS_HALL
	props.add_child(hall)


func _add_home() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("Parsonage") != null:
		return
	var house := Sprite2D.new()
	house.name = "Parsonage"
	house.texture = PlaceholderArt.parsonage()
	house.centered = true
	house.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	house.position = GroundsLayout.POS_PARSONAGE
	if house.texture != null:
		house.offset = Vector2(0, -house.texture.get_height() * 0.5)
	props.add_child(house)
	var door := Door.new()
	door.name = "HomeDoor"
	door.position = GroundsLayout.POS_HOME_DOOR
	door.place_name = "Parsonage"
	door.prompt_text = "Parsonage"
	door.radius = 26.0
	door.destination_scene = "res://scenes/world/parsonage.tscn"
	door.destination_spawn = &"from_grounds"
	props.add_child(door)
	_place_marker("from_parsonage", GroundsLayout.POS_FROM_PARSONAGE, &"down")


func _add_parsonage_block() -> void:
	var house := get_node_or_null("Props/Parsonage") as Sprite2D
	if house == null or house.texture == null:
		return
	var size := house.texture.get_size()
	var body_h := size.y - 20.0
	if body_h <= 0.0:
		return
	_add_rect(house.position + Vector2(0.0, -20.0 - body_h * 0.5), Vector2(size.x - 12.0, body_h))


func _add_hall_block() -> void:
	var hall := get_node_or_null("Props/FellowshipHall") as Node2D
	if hall == null:
		return
	var size := Vector2(168, 36)
	var offset := Vector2(0, -8)
	var raw_size: Variant = hall.get("block_size")
	var raw_offset: Variant = hall.get("block_offset")
	if raw_size is Vector2:
		size = raw_size
	if raw_offset is Vector2:
		offset = raw_offset
	_add_rect(hall.position + offset, size)


func _add_grounds_work() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_chore(props, "LitterA", "litter_a", Vector2(1200, 800), "Pick up the scrap", "A torn paper and a bottle cap. You pocket them.")
	_add_chore(props, "LitterB", "litter_b", Vector2(1440, 736), "Pick up the scrap", "A cup and a bit of wire. The walk is clearer.")
	_add_chore(props, "FlowerBed", "bed", Vector2(1104, 688), "Trim the bed", "You cut the weeds back. The flowers can breathe.")


func _add_church_garden() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	if get_node_or_null("FarmSoil") == null:
		var soil_root := Node2D.new()
		soil_root.name = "FarmSoil"
		soil_root.z_index = -9
		add_child(soil_root)
		move_child(soil_root, 1)
	if props.get_node_or_null("FarmField") == null:
		var field := FarmField.new()
		field.name = "FarmField"
		field.soil_root = get_node_or_null("FarmSoil") as Node2D
		props.add_child(field)
	if props.get_node_or_null("SeedCrate") == null:
		var crate := ItemPickup.new()
		crate.name = "SeedCrate"
		crate.position = GroundsLayout.VEG_CRATE
		crate.starter_id = "seeds"
		crate.speaker_name = "Seed crate"
		crate.take_line = "Paper packets: lettuce, carrot, tomato, and flower. Enough to start the garden."
		crate.empty_line = "The crate holds a little dirt and nothing else."
		crate.sheet = PlaceholderArt.crate()
		crate.frame_size = Vector2i(32, 32)
		crate.prompt_text = "Take"
		crate.radius = 36.0
		crate.blocks_movement = true
		crate.block_size = Vector2(16, 10)
		var crate_sprite := Sprite2D.new()
		crate_sprite.name = "Sprite"
		crate.add_child(crate_sprite)
		props.add_child(crate)
	if props.get_node_or_null("GardenNote") == null:
		var note := SpeechProp.new()
		note.name = "GardenNote"
		note.position = GroundsLayout.VEG_NOTE
		note.sheet = PlaceholderArt.notice_board()
		note.frame_size = Vector2i(32, 48)
		note.frame_count = 1
		note.speaker_name = "Ruth"
		note.prompt_text = "Read the card"
		note.line = "Ruth left a card. Till the ground with the hoe. Plant a seed packet. Water. Come back after a morning. Then pick."
		note.blocks_movement = true
		note.block_size = Vector2(14, 8)
		note.radius = 36.0
		var note_sprite := AnimatedSprite2D.new()
		note_sprite.name = "Sprite"
		note.add_child(note_sprite)
		props.add_child(note)
	if props.get_node_or_null("GardenRemark") == null:
		var remark := GardenRemark.new()
		remark.name = "GardenRemark"
		remark.position = Vector2(1224, 1168)
		remark.sheet = PlaceholderArt.townsfolk(1)
		remark.frame_size = Vector2i(32, 48)
		remark.frame_count = 2
		remark.speaker_name = "A neighbor"
		remark.prompt_text = "Say hello"
		remark.line = GardenRemark.QUIET
		remark.blocks_movement = false
		remark.block_size = Vector2(12, 8)
		remark.radius = 36.0
		var remark_sprite := AnimatedSprite2D.new()
		remark_sprite.name = "Sprite"
		remark.add_child(remark_sprite)
		props.add_child(remark)
	_add_fence_mend(props)


func _add_fence_mend(props: Node) -> void:
	if props.get_node_or_null("FenceMend") != null:
		return
	var patch := Sprite2D.new()
	patch.name = "FenceMend"
	patch.texture = CropFrames.texture("fence_patch")
	patch.centered = true
	patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	patch.position = GroundsLayout.VEG_FENCE_MEND
	if patch.texture != null:
		patch.offset = Vector2(0, -patch.texture.get_height() * 0.5)
	patch.visible = false
	props.add_child(patch)


func _add_chore(props: Node, node_name: String, chore_id: String, pos: Vector2, prompt: String, line: String) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var chore := GroundsChore.new()
	chore.name = node_name
	chore.chore_id = chore_id
	chore.position = pos
	chore.prompt_text = prompt
	chore.work_line = line
	chore.done_line = "That part is done."
	chore.radius = 40.0
	if chore_id.begins_with("litter"):
		var sprite := Sprite2D.new()
		sprite.name = "Sprite"
		sprite.texture = PlaceholderArt.litter()
		sprite.centered = true
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if sprite.texture != null:
			sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
		chore.add_child(sprite)
	props.add_child(chore)


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


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null or not TownTiles.apply_to(layer):
		push_error("Church exterior ground is missing")
		return
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, TownTiles.grass_at(x, y))
	_paint_courtyard(layer)
	_paint_paths(layer)
	_paint_parking(layer)
	_paint_drive(layer)
	_paint_garden(layer)
	_paint_veg_garden(layer)
	_paint_parsonage_yard(layer)
	_paint_plots(layer)
	_paint_utility(layer)
	_paint_perimeter(layer)


func _paint_courtyard(layer: TileMapLayer) -> void:
	var plaza := GroundsLayout.COURTYARD
	_paint_rect(layer, plaza.position.x, plaza.position.y, plaza.end.x, plaza.end.y, TownTiles.SIDEWALK)
	_paint_rect(layer, 27, 18, 30, 27, TownTiles.PATH)
	layer.set_cell(Vector2i(24, 21), 0, TownTiles.FLOWER_BED)
	layer.set_cell(Vector2i(33, 21), 0, TownTiles.FLOWER_BED)
	layer.set_cell(Vector2i(24, 24), 0, TownTiles.PLANTER)
	layer.set_cell(Vector2i(33, 24), 0, TownTiles.PLANTER)


func _paint_paths(layer: TileMapLayer) -> void:
	# Axis south from the courtyard to the picnic lawn.
	_paint_rect(layer, 27, 26, 30, 42, TownTiles.PATH)
	# Covered walkway from the hall to the courtyard.
	_paint_rect(layer, 12, 21, 23, 23, TownTiles.PATH)
	# North walk in front of the expansion lots, touching their south edge.
	_paint_rect(layer, 10, 8, 36, 11, TownTiles.PATH)
	_paint_rect(layer, 27, 8, 30, 19, TownTiles.PATH)
	# Garden connector.
	_paint_rect(layer, 11, 11, 13, 19, TownTiles.PATH)
	_paint_rect(layer, 11, 18, 23, 20, TownTiles.PATH)
	# Farm-field connector. Starts on the east edge of the open field, not inside it.
	_paint_rect(layer, 10, 16, 13, 22, TownTiles.PATH)
	# Workshop connector.
	_paint_rect(layer, 36, 8, 56, 11, TownTiles.PATH)
	_paint_rect(layer, 47, 8, 49, 10, TownTiles.PATH)
	# Parking to courtyard.
	_paint_rect(layer, 35, 21, 43, 24, TownTiles.PATH)
	# Parsonage walk.
	_paint_rect(layer, 7, 38, 28, 40, TownTiles.PATH)
	_paint_rect(layer, 7, 39, 9, 42, TownTiles.PATH)
	# Picnic spur, extended east to the church garden gate.
	_paint_rect(layer, 22, 34, 40, 36, TownTiles.PATH)
	# Side gate walk.
	_paint_rect(layer, 1, 37, 8, 39, TownTiles.PATH)


func _paint_parking(layer: TileMapLayer) -> void:
	var lot := GroundsLayout.PARKING
	_paint_rect(layer, lot.position.x, lot.position.y, lot.end.x, lot.end.y, TownTiles.PARKING)
	for x in range(lot.position.x + 1, lot.end.x - 1, 2):
		layer.set_cell(Vector2i(x, lot.position.y + 2), 0, TownTiles.LINE_V)
		layer.set_cell(Vector2i(x, lot.position.y + 3), 0, TownTiles.LINE_V)
	_paint_rect(layer, lot.position.x, lot.end.y - 1, lot.end.x, lot.end.y, TownTiles.CURB_S)
	_paint_rect(layer, lot.position.x, lot.position.y, lot.end.x, lot.position.y + 1, TownTiles.CURB_N)


func _paint_drive(layer: TileMapLayer) -> void:
	var drive := GroundsLayout.DRIVE
	_paint_rect(layer, drive.position.x, drive.position.y, drive.end.x, drive.end.y, TownTiles.DRIVEWAY)
	_paint_rect(layer, drive.position.x, 27, 58, 28, TownTiles.PATH)
	_paint_rect(layer, 58, 25, 64, 30, TownTiles.ASPHALT)
	_paint_rect(layer, 60, 25, 64, 26, TownTiles.CROSSWALK_H)
	# Sidewalk stubs so the east edge meets Oak Street's walk.
	_paint_rect(layer, 60, 22, 64, 25, TownTiles.SIDEWALK)
	_paint_rect(layer, 60, 30, 64, 33, TownTiles.SIDEWALK)
	layer.set_cell(Vector2i(59, 24), 0, TownTiles.CURB_N)
	layer.set_cell(Vector2i(59, 30), 0, TownTiles.CURB_S)


func _paint_garden(layer: TileMapLayer) -> void:
	var garden := GroundsLayout.GARDEN
	_paint_rect(layer, garden.position.x, garden.position.y, garden.end.x, garden.end.y, TownTiles.HEDGE)
	_paint_rect(layer, garden.position.x + 1, garden.position.y + 1, garden.end.x - 1, garden.end.y - 1, TownTiles.GRASS_A)
	layer.set_cell(Vector2i(5, 6), 0, TownTiles.FLOWER_BED)
	layer.set_cell(Vector2i(8, 6), 0, TownTiles.FLOWER_BED)
	layer.set_cell(Vector2i(6, 8), 0, TownTiles.PATH)
	# Gate toward the courtyard.
	layer.set_cell(Vector2i(11, 10), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(11, 11), 0, TownTiles.PATH)


func _paint_veg_garden(layer: TileMapLayer) -> void:
	var garden := GroundsLayout.VEG_GARDEN
	_paint_rect(layer, garden.position.x, garden.position.y, garden.end.x, garden.end.y, TownTiles.FENCE)
	_paint_rect(layer, garden.position.x + 1, garden.position.y + 1, garden.end.x - 1, garden.end.y - 1, TownTiles.GRASS_B)
	# West gate onto the picnic spur (y 34–36).
	layer.set_cell(Vector2i(garden.position.x, 34), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(garden.position.x, 35), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(garden.position.x, 36), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(garden.position.x + 1, 34), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(garden.position.x + 1, 35), 0, TownTiles.PATH)
	layer.set_cell(Vector2i(garden.position.x + 1, 36), 0, TownTiles.PATH)


func _paint_parsonage_yard(layer: TileMapLayer) -> void:
	_paint_rect(layer, 4, 34, 16, 46, TownTiles.HEDGE)
	_paint_rect(layer, 5, 35, 15, 45, TownTiles.GRASS_B)
	_paint_rect(layer, 7, 38, 16, 40, TownTiles.PATH)
	_paint_rect(layer, 7, 40, 9, 42, TownTiles.PATH)


func _paint_plots(layer: TileMapLayer) -> void:
	for row in GroundsPlots.all_plots():
		var rect := GroundsPlots.plot_rect(row)
		if rect.size.x <= 0:
			continue
		_paint_rect(layer, rect.position.x, rect.position.y, rect.end.x, rect.end.y, TownTiles.FOUNDATION)
		if rect.size.x > 2 and rect.size.y > 2:
			_paint_rect(layer, rect.position.x + 1, rect.position.y + 1, rect.end.x - 1, rect.end.y - 1, TownTiles.GRASS_A)


func _paint_utility(layer: TileMapLayer) -> void:
	_paint_rect(layer, 56, 4, 62, 11, TownTiles.ALLEY)
	_paint_rect(layer, 58, 10, 61, 12, TownTiles.PATH)


func _paint_perimeter(layer: TileMapLayer) -> void:
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var cell := Vector2i(x, y)
			if not GroundsLayout.is_perimeter_cell(cell):
				continue
			var hedge := x == 0 or (y == MAP_SIZE.y - 1 and x < 20)
			layer.set_cell(cell, 0, TownTiles.HEDGE if hedge else TownTiles.FENCE)
	# Main gate opening reads as drive meeting the street sidewalk.
	for y in range(GroundsLayout.MAIN_GATE.position.y, GroundsLayout.MAIN_GATE.end.y):
		var edge := Vector2i(MAP_SIZE.x - 1, y)
		if y >= 25 and y < 30:
			layer.set_cell(edge, 0, TownTiles.ASPHALT)
			layer.set_cell(Vector2i(MAP_SIZE.x - 2, y), 0, TownTiles.DRIVEWAY)
		else:
			layer.set_cell(edge, 0, TownTiles.SIDEWALK)
			layer.set_cell(Vector2i(MAP_SIZE.x - 2, y), 0, TownTiles.SIDEWALK)
	for y in range(GroundsLayout.SIDE_GATE.position.y, GroundsLayout.SIDE_GATE.end.y):
		layer.set_cell(Vector2i(0, y), 0, TownTiles.PATH)
		layer.set_cell(Vector2i(1, y), 0, TownTiles.PATH)


func _paint_rect(layer: TileMapLayer, x0: int, y0: int, x1: int, y1: int, atlas: Vector2i) -> void:
	for y in range(y0, y1):
		for x in range(x0, x1):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			layer.set_cell(Vector2i(x, y), 0, atlas)


func _add_church_collision() -> void:
	var church := get_node_or_null("Props/Church") as Sprite2D
	if church == null or church.texture == null:
		push_error("Church sprite missing")
		return
	var size := church.texture.get_size()
	var gap_h := 28.0
	var gap_w := 64.0
	var body_h := size.y - gap_h
	var jamb_w := (size.x - gap_w) * 0.5
	_add_rect(POS_CHURCH + Vector2(0.0, -gap_h - body_h * 0.5), Vector2(size.x, body_h))
	_add_rect(POS_CHURCH + Vector2(-(gap_w + jamb_w) * 0.5, -gap_h * 0.5), Vector2(jamb_w, gap_h))
	_add_rect(POS_CHURCH + Vector2((gap_w + jamb_w) * 0.5, -gap_h * 0.5), Vector2(jamb_w, gap_h))


func _add_campus_blocks() -> void:
	_add_perimeter_blocks()
	_add_garden_fence_blocks()
	_add_veg_garden_fence_blocks()
	_add_parsonage_hedge_blocks()
	_add_car_blocks()


func _add_perimeter_blocks() -> void:
	var thick := 16.0
	var width := float(MAP_SIZE.x * TILE)
	var height := float(MAP_SIZE.y * TILE)
	var main_top := float(GroundsLayout.MAIN_GATE.position.y * TILE)
	var main_bot := float(GroundsLayout.MAIN_GATE.end.y * TILE)
	var side_top := float(GroundsLayout.SIDE_GATE.position.y * TILE)
	var side_bot := float(GroundsLayout.SIDE_GATE.end.y * TILE)
	_add_rect(Vector2(width * 0.5, thick * 0.5), Vector2(width, thick))
	_add_rect(Vector2(width * 0.5, height - thick * 0.5), Vector2(width, thick))
	# West fence split around the side gate.
	_add_rect(Vector2(thick * 0.5, side_top * 0.5), Vector2(thick, side_top))
	_add_rect(Vector2(thick * 0.5, (side_bot + height) * 0.5), Vector2(thick, height - side_bot))
	# East fence split around the main gate.
	_add_rect(Vector2(width - thick * 0.5, main_top * 0.5), Vector2(thick, main_top))
	_add_rect(Vector2(width - thick * 0.5, (main_bot + height) * 0.5), Vector2(thick, height - main_bot))


func _add_garden_fence_blocks() -> void:
	var g := GroundsLayout.GARDEN
	var x0 := float(g.position.x * TILE)
	var y0 := float(g.position.y * TILE)
	var x1 := float(g.end.x * TILE)
	var y1 := float(g.end.y * TILE)
	var t := 12.0
	_add_rect(Vector2((x0 + x1) * 0.5, y0 + t * 0.5), Vector2(x1 - x0, t))
	_add_rect(Vector2(x0 + t * 0.5, (y0 + y1) * 0.5), Vector2(t, y1 - y0))
	_add_rect(Vector2(x1 - t * 0.5, (y0 + y1) * 0.5 - 16.0), Vector2(t, y1 - y0 - 32.0))
	_add_rect(Vector2((x0 + x1) * 0.5 - 16.0, y1 - t * 0.5), Vector2(x1 - x0 - 32.0, t))


func _add_veg_garden_fence_blocks() -> void:
	var g := GroundsLayout.VEG_GARDEN
	var x0 := float(g.position.x * TILE)
	var y0 := float(g.position.y * TILE)
	var x1 := float(g.end.x * TILE)
	var y1 := float(g.end.y * TILE)
	var t := 12.0
	_add_rect(Vector2((x0 + x1) * 0.5, y0 + t * 0.5), Vector2(x1 - x0, t))
	_add_rect(Vector2((x0 + x1) * 0.5, y1 - t * 0.5), Vector2(x1 - x0, t))
	_add_rect(Vector2(x1 - t * 0.5, (y0 + y1) * 0.5), Vector2(t, y1 - y0))
	# West fence split around the gate onto the picnic spur (tiles 34–36).
	_add_rect(Vector2(x0 + t * 0.5, 1056.0), Vector2(t, 64.0))
	_add_rect(Vector2(x0 + t * 0.5, 1248.0), Vector2(t, 128.0))


func _add_parsonage_hedge_blocks() -> void:
	# Hedge ring with a path gap on the east toward the campus.
	_add_rect(Vector2(320, 34 * TILE + 8), Vector2(12 * TILE, 16))
	_add_rect(Vector2(4 * TILE + 8, 40 * TILE), Vector2(16, 10 * TILE))
	_add_rect(Vector2(320, 46 * TILE - 8), Vector2(12 * TILE, 16))
	_add_rect(Vector2(16 * TILE - 8, 36 * TILE), Vector2(16, 4 * TILE))
	_add_rect(Vector2(16 * TILE - 8, 44 * TILE), Vector2(16, 4 * TILE))


func _add_car_blocks() -> void:
	for path in ["Props/LotCarA", "Props/LotCarB"]:
		var car := get_node_or_null(path) as Node2D
		if car == null or not car.visible:
			continue
		_add_rect(car.position + Vector2(0, -4), Vector2(40, 14))


func _place_occluder() -> void:
	_occlude("Lighting/ChurchOccluder", "Props/Church")
	_occlude_node("Lighting/HallOccluder", get_node_or_null("Props/FellowshipHall") as Node2D)
	_occlude("Lighting/ParsonageOccluder", "Props/Parsonage")


func _occlude(occluder_path: String, sprite_path: String) -> void:
	_occlude_node(occluder_path, get_node_or_null(sprite_path) as Node2D)


func _occlude_node(occluder_path: String, body: Node2D) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or body == null:
		return
	var occluder := lighting.get_node_or_null(occluder_path.get_file()) as LightOccluder2D
	if occluder == null:
		occluder = LightOccluder2D.new()
		occluder.name = occluder_path.get_file()
		lighting.add_child(occluder)
	var size := Vector2(96, 64)
	if body is Sprite2D and (body as Sprite2D).texture != null:
		size = (body as Sprite2D).texture.get_size()
	elif body.get_node_or_null("Sprite") is Sprite2D:
		var inner := body.get_node_or_null("Sprite") as Sprite2D
		if inner != null and inner.texture != null:
			size = inner.texture.get_size()
	var top_left := body.position - Vector2(size.x * 0.5, size.y)
	var poly := OccluderPolygon2D.new()
	poly.polygon = PackedVector2Array([
		top_left,
		top_left + Vector2(size.x, 0.0),
		top_left + size,
		top_left + Vector2(0.0, size.y),
	])
	occluder.occluder = poly


func _add_wayfinding() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_sign(props)
	_add_ground_arrow(props, "ArrowEast1", Vector2(1600, 880))
	_add_ground_arrow(props, "ArrowEast2", Vector2(1760, 880))
	_add_ground_arrow(props, "ArrowEast3", Vector2(1920, 880))
	_add_solid_sprite(props, "Mailbox", PlaceholderArt.mailbox(), GroundsLayout.POS_MAILBOX, Vector2(12, 8))
	_add_happening(
		props,
		"ThursdayFlowers",
		"thursday_flowers",
		Vector2(1024, 720),
		PlaceholderArt.flowers(),
		Vector2i(48, 32),
		1,
		"Margaret",
		"Look at the flowers",
		"happening_thursday",
		"Margaret looks up from the watering can."
	)
	_add_happening(
		props,
		"LaterBench",
		"later_bench",
		Vector2(800, 720),
		PlaceholderArt.crate(),
		Vector2i(32, 32),
		1,
		"Note",
		"Look at the tin",
		"happening_later_bench",
		"Someone left a pie tin on the bench."
	)
	_add_happening(
		props,
		"LeanWalk",
		"lean_walk",
		Vector2(912, 960),
		PlaceholderArt.townsfolk(0),
		Vector2i(32, 48),
		2,
		"A neighbor",
		"Say hello",
		"happening_lean_walk",
		"Somebody left a bulletin on the walk."
	)
	_add_happening(
		props,
		"SeedPorch",
		"seed_porch",
		Vector2(256, 1264),
		PlaceholderArt.crate(),
		Vector2i(32, 32),
		1,
		"Note",
		"Look at the card",
		"happening_seed_porch",
		"A folded card on the parsonage step."
	)
	_add_happening(
		props,
		"WednesdayPotluck",
		"wednesday_potluck",
		Vector2(912, 1120),
		PlaceholderArt.crate(),
		Vector2i(32, 32),
		1,
		"Margaret",
		"Join the potluck",
		"happening_potluck",
		"Casseroles on the long table."
	)


func _add_campus_props() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_solid_sprite(props, "MonumentSign", PlaceholderArt.monument_sign(), GroundsLayout.POS_MONUMENT, Vector2(72, 14))
	_add_solid_sprite(props, "GatePillarN", PlaceholderArt.gate_pillar(), GroundsLayout.POS_GATE_N, Vector2(16, 10))
	_add_solid_sprite(props, "GatePillarS", PlaceholderArt.gate_pillar(), GroundsLayout.POS_GATE_S, Vector2(16, 10))
	_add_solid_sprite(props, "CourtyardCross", PlaceholderArt.courtyard_cross(), GroundsLayout.POS_CROSS, Vector2(10, 8))
	_add_solid_sprite(props, "ChurchBell", PlaceholderArt.church_bell(), GroundsLayout.POS_BELL, Vector2(10, 8))
	_add_solid_sprite(props, "MemorialWall", PlaceholderArt.memorial_wall(), Vector2(224, 240), Vector2(56, 10))
	_add_solid_sprite(props, "HeadstoneA", PlaceholderArt.headstone(), Vector2(176, 280), Vector2(16, 8))
	_add_solid_sprite(props, "HeadstoneB", PlaceholderArt.headstone(), Vector2(256, 288), Vector2(16, 8))
	_add_solid_sprite(props, "HeadstoneC", PlaceholderArt.headstone(), Vector2(208, 320), Vector2(16, 8))
	_add_solid_sprite(props, "GardenBench", PlaceholderArt.bench(), Vector2(288, 300), Vector2(36, 10))
	_add_solid_sprite(props, "UtilityShed", PlaceholderArt.garden_shed(0), Vector2(1856, 240), Vector2(36, 14))
	_add_solid_sprite(props, "TrashBinA", PlaceholderArt.trash_can(), Vector2(1792, 280), Vector2(12, 8))
	_add_solid_sprite(props, "TrashBinB", PlaceholderArt.trash_can(), Vector2(1824, 288), Vector2(12, 8))
	_add_solid_sprite(props, "PicnicTableA", PlaceholderArt.picnic_table(), Vector2(800, 1120), Vector2(40, 12))
	_add_solid_sprite(props, "PicnicTableB", PlaceholderArt.picnic_table(), Vector2(1024, 1120), Vector2(40, 12))
	_add_solid_sprite(props, "PicnicTableC", PlaceholderArt.picnic_table(), Vector2(912, 1200), Vector2(40, 12))
	_add_solid_sprite(props, "CourtyardBenchE", PlaceholderArt.bench(), Vector2(1024, 752), Vector2(36, 10))
	_add_solid_sprite(props, "LotCarA", PlaceholderArt.parked_car(0), Vector2(1408, 656), Vector2(40, 14))
	_add_solid_sprite(props, "LotCarB", PlaceholderArt.parked_car(1), Vector2(1536, 656), Vector2(40, 14))
	_add_walkway_posts(props)
	_add_rhythm_trees(props)
	_add_campus_lamps(props)
	_add_window("HallWindow", GroundsLayout.POS_HALL + Vector2(-20, -70))
	_add_window("ParsonageWindow", GroundsLayout.POS_PARSONAGE + Vector2(-20, -60))
	_add_speech_inspect(
		props,
		"GardenQuiet",
		Vector2(224, 260),
		PlaceholderArt.headstone(),
		Vector2i(24, 32),
		"Memorial",
		"Look around",
		"A quiet corner. The stones are old and the grass is kept."
	)


func _add_walkway_posts(props: Node) -> void:
	var xs: Array[int] = [420, 500, 580, 660]
	for i in xs.size():
		_add_solid_sprite(props, "WalkPost%d" % i, PlaceholderArt.walkway_post(), Vector2(xs[i], 688), Vector2(8, 8))


func _add_rhythm_trees(props: Node) -> void:
	var spots: Array[Vector2] = [
		Vector2(480, 200), Vector2(720, 200), Vector2(1120, 200), Vector2(1360, 200),
		Vector2(480, 1000), Vector2(1168, 992), Vector2(1720, 1008),
		Vector2(200, 880), Vector2(1680, 480), Vector2(400, 1280),
	]
	for i in spots.size():
		_add_solid_sprite(props, "CampusTree%d" % i, PlaceholderArt.tree(i % 3), spots[i], Vector2(14, 8))


func _add_campus_lamps(props: Node) -> void:
	_add_park_lamp(props, "LampDrive1", Vector2(1280, 832))
	_add_park_lamp(props, "LampDrive2", Vector2(1600, 832))
	_add_park_lamp(props, "LampDrive3", Vector2(1904, 832))
	_add_park_lamp(props, "LampAxis", Vector2(976, 960))
	_add_park_lamp(props, "LampPicnic", Vector2(848, 1120))
	_add_park_lamp(props, "LampParsonage", Vector2(400, 1232))
	_add_park_lamp(props, "LampHall", Vector2(560, 736))
	_add_park_lamp(props, "LampNorth", Vector2(912, 352))


func _add_expansion_plots() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	for row in GroundsPlots.all_plots():
		var plot_id := str(row.get("id", ""))
		if plot_id.is_empty() or props.get_node_or_null(plot_id) != null:
			continue
		var rect := GroundsPlots.plot_rect(row)
		var plot := ExpansionPlot.new()
		plot.name = plot_id
		plot.plot_id = plot_id
		plot.display_name = GroundsPlots.display_name(row)
		plot.inspect_line = GroundsPlots.inspect_line(row)
		plot.project_id = str(row.get("project_id", ""))
		plot.built_scene = str(row.get("built_scene", ""))
		plot.tile_rect = rect
		plot.position = GroundsLayout.tile_center(rect.position + rect.size / 2)
		props.add_child(plot)


func _add_sunday_gathering() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	var spots: Array[Vector2] = [Vector2(800, 736), Vector2(1024, 736), Vector2(880, 768)]
	for i in spots.size():
		_add_gathering(props, "SundayNeighbor%d" % i, spots[i], i)


func _add_gathering(props: Node, node_name: String, pos: Vector2, variant: int) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := SpeechProp.new()
	person.name = node_name
	person.position = pos
	person.sheet = PlaceholderArt.townsfolk(variant % 3)
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = "A neighbor"
	person.prompt_text = "Say hello"
	person.line = "We'll go in when the bell says."
	person.blocks_movement = false
	person.block_size = Vector2(12, 8)
	person.radius = 36.0
	person.add_to_group("sunday_courtyard")
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


func _add_sign(props: Node) -> void:
	if props.get_node_or_null("Signpost") != null:
		return
	var sign := SpeechProp.new()
	sign.name = "Signpost"
	sign.position = GroundsLayout.POS_SIGNPOST
	sign.sheet = PlaceholderArt.signpost()
	sign.frame_size = Vector2i(32, 48)
	sign.frame_count = 1
	sign.speaker_name = "Sign"
	sign.prompt_text = "Read the sign"
	sign.line = "Oak Street is east, past this lane. Hardware, the bay, and the cottages."
	sign.blocks_movement = true
	sign.block_size = Vector2(14, 8)
	sign.radius = 36.0
	sign.add_to_group("wayfinding")
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sign.add_child(sprite)
	props.add_child(sign)


func _add_ground_arrow(props: Node, node_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var arrow := Sprite2D.new()
	arrow.name = node_name
	arrow.texture = PlaceholderArt.arrow_east()
	arrow.position = pos
	arrow.centered = true
	arrow.z_index = -5
	arrow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(arrow)


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


func _add_park_lamp(props: Node, lamp_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(lamp_name) != null:
		return
	var lamp := SolidProp.new()
	lamp.name = lamp_name
	lamp.texture = PlaceholderArt.lamp_post()
	lamp.centered = true
	if lamp.texture != null:
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


func _add_speech_inspect(
	props: Node,
	node_name: String,
	pos: Vector2,
	sheet: Texture2D,
	frame: Vector2i,
	speaker: String,
	prompt: String,
	line: String
) -> void:
	if props.get_node_or_null(node_name) != null or sheet == null:
		return
	var spot := SpeechProp.new()
	spot.name = node_name
	spot.position = pos
	spot.sheet = sheet
	spot.frame_size = frame
	spot.frame_count = 1
	spot.speaker_name = speaker
	spot.prompt_text = prompt
	spot.line = line
	spot.blocks_movement = true
	spot.block_size = Vector2(16, 8)
	spot.radius = 36.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	spot.add_child(sprite)
	props.add_child(spot)


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
