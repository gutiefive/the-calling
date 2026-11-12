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


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_assign_art()
	_place_props()
	_paint_ground()
	_clear_solids()
	_add_church_collision()
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
	_set_sprite("Props/Flowers", PlaceholderArt.flowers())
	_set_sprite("Props/Lamp", PlaceholderArt.lamp_post())
	_set_light_texture("Props/Lamp/Glow")
	_set_light_texture("Lighting/WindowL")
	_set_light_texture("Lighting/WindowR")


func _place_props() -> void:
	_place("Props/Church", POS_CHURCH)
	_feet_offset("Props/Church")
	_place("Props/Door", POS_DOOR)
	_place("Props/Mat", POS_MAT)
	_feet_offset("Props/Mat")
	_place("Props/Margaret", POS_MARGARET)
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
	var default_spawn := get_node_or_null("Spawns/default")
	var returned := get_node_or_null("Spawns/from_sanctuary")
	if default_spawn != null:
		default_spawn.set_meta("facing", &"up")
	if returned != null:
		returned.set_meta("facing", &"down")
	_place("Lighting/WindowL", POS_WIN_L)
	_place("Lighting/WindowR", POS_WIN_R)


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
