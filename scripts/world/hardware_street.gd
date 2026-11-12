extends WorldRoom
## Oak Street block: hardware store, Frank's bay, and a cottage. The west edge returns to the church.

const MAP_SIZE := Vector2i(42, 24)
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


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_assign_art()
	_place_props()
	_paint_ground()
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
	_place_occluders()


func rebuild_collision() -> void:
	_clear_solids()
	_add_buildings()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)
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
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("Oak Street ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var alt := (x * 13 + y * 7) % 11 == 0
			layer.set_cell(Vector2i(x, y), 0, Vector2i(1 if alt else 0, 0))
	# The street runs east from the church gate.
	for y in range(13, 18):
		for x in range(1, MAP_SIZE.x - 1):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
	for y in range(18, 21):
		for x in range(8, 36):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))


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
