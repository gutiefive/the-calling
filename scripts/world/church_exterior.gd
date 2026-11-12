extends WorldRoom
## Church grounds blockout. Positions live here so the door, path, and collision stay aligned.

const MAP_SIZE := Vector2i(36, 26)
const POS_CHURCH := Vector2(576, 300)
const POS_DOOR := Vector2(576, 286)
const POS_MAT := Vector2(576, 316)
const POS_SPAWN := Vector2(560, 430)
const POS_RETURN := Vector2(560, 360)
const POS_MARGARET := Vector2(700, 360)
const POS_NOTICE := Vector2(430, 400)
const POS_BENCH := Vector2(340, 470)
const POS_LAMP := Vector2(500, 340)
const POS_FLOWERS := Vector2(860, 340)
const POS_WIN_L := Vector2(456, 256)
const POS_WIN_R := Vector2(696, 256)
const POS_STREET_DOOR := Vector2(1040, 640)
const POS_FROM_STREET := Vector2(920, 640)
const POS_HAROLD := Vector2(640, 420)


func area_name() -> String:
	return "Church grounds"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_assign_art()
	_place_props()
	_add_wayfinding()
	_add_home()
	_add_grounds_work()
	_paint_ground()
	_clear_solids()
	_add_church_collision()
	_add_parsonage_block()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_place_occluder()


func rebuild_collision() -> void:
	_clear_solids()
	_add_church_collision()
	_add_parsonage_block()
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
	_place("Props/Notice", POS_NOTICE)
	_place("Props/Bench", POS_BENCH)
	_feet_offset("Props/Bench")
	_place("Props/Lamp", POS_LAMP)
	_feet_offset("Props/Lamp")
	_place("Props/Flowers", POS_FLOWERS)
	_feet_offset("Props/Flowers")
	var trees: Array[Vector2] = [
		Vector2(260, 220), Vector2(1000, 200), Vector2(180, 680), Vector2(980, 700), Vector2(820, 560),
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
	for node in get_tree().get_nodes_in_group("day_world"):
		if is_ancestor_of(node) and node.has_method("apply_clock"):
			node.call("apply_clock")


func _add_home() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("Parsonage") != null:
		return
	var house := Sprite2D.new()
	house.name = "Parsonage"
	house.texture = PlaceholderArt.parsonage()
	house.centered = true
	house.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	house.position = Vector2(200, 430)
	if house.texture != null:
		house.offset = Vector2(0, -house.texture.get_height() * 0.5)
	props.add_child(house)
	var door := Door.new()
	door.name = "HomeDoor"
	door.position = Vector2(200, 500)
	door.prompt_text = "Go home"
	door.radius = 42.0
	door.destination_scene = "res://scenes/world/parsonage.tscn"
	door.destination_spawn = &"from_grounds"
	props.add_child(door)
	_place_marker("from_parsonage", Vector2(200, 580), &"down")


func _add_parsonage_block() -> void:
	var house := get_node_or_null("Props/Parsonage") as Sprite2D
	if house == null or house.texture == null:
		return
	var size := house.texture.get_size()
	var body_h := size.y - 20.0
	if body_h <= 0.0:
		return
	_add_rect(house.position + Vector2(0.0, -20.0 - body_h * 0.5), Vector2(size.x - 12.0, body_h))


func _add_grounds_work() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_chore(props, "LitterA", "litter_a", Vector2(760, 520), "Pick up the scrap", "A torn paper and a bottle cap. You pocket them.")
	_add_chore(props, "LitterB", "litter_b", Vector2(980, 600), "Pick up the scrap", "A cup and a bit of wire. The walk is clearer.")
	_add_chore(props, "FlowerBed", "bed", Vector2(900, 380), "Trim the bed", "You cut the weeds back. The flowers can breathe.")


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
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("Church exterior ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var alt := (x * 13 + y * 7) % 11 == 0
			layer.set_cell(Vector2i(x, y), 0, Vector2i(1 if alt else 0, 0))
	# Path from the south edge up to the church door (door sits on tile column 18).
	for y in range(9, 24):
		for x in range(16, 20):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
	for y in range(16, 24):
		for x in range(20, 33):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))
	# A lighter strip so the east lane reads as the way out to Oak Street.
	for y in range(19, 21):
		for x in range(20, 35):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))


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
	# Solid footprint with a doorway in the south edge. The door itself does not collide.
	_add_rect(POS_CHURCH + Vector2(0.0, -gap_h - body_h * 0.5), Vector2(size.x, body_h))
	_add_rect(POS_CHURCH + Vector2(-(gap_w + jamb_w) * 0.5, -gap_h * 0.5), Vector2(jamb_w, gap_h))
	_add_rect(POS_CHURCH + Vector2((gap_w + jamb_w) * 0.5, -gap_h * 0.5), Vector2(jamb_w, gap_h))


func _place_occluder() -> void:
	var church := get_node_or_null("Props/Church") as Sprite2D
	var occluder := get_node_or_null("Lighting/ChurchOccluder") as LightOccluder2D
	if church == null or church.texture == null or occluder == null:
		return
	var size := church.texture.get_size()
	var top_left := POS_CHURCH - Vector2(size.x * 0.5, size.y)
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
	_add_ground_arrow(props, "ArrowEast1", Vector2(736, 656))
	_add_ground_arrow(props, "ArrowEast2", Vector2(944, 656))
	_add_ground_arrow(props, "ArrowEast3", Vector2(1008, 656))
	_add_solid_sprite(props, "Mailbox", PlaceholderArt.mailbox(), Vector2(280, 560), Vector2(12, 8))
	_add_happening(
		props,
		"ThursdayFlowers",
		"thursday_flowers",
		Vector2(860, 430),
		PlaceholderArt.flowers(),
		Vector2i(48, 32),
		1,
		"Margaret",
		"Look at the flowers",
		"happening_thursday",
		"Margaret looks up from the watering can."
	)


func _add_sign(props: Node) -> void:
	if props.get_node_or_null("Signpost") != null:
		return
	var sign := SpeechProp.new()
	sign.name = "Signpost"
	sign.position = Vector2(860, 600)
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


func _make_tileset(tex: Texture2D) -> TileSet:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(32, 32)
	for i in 7:
		atlas.create_tile(Vector2i(i, 0))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_source(atlas, 0)
	return tileset
