extends WorldRoom
## One-room sanctuary. The south wall has a door gap and a stopper so the player cannot walk out of the map.

const MAP_SIZE := Vector2i(30, 22)
const POS_DOOR := Vector2(480, 680)
const POS_SPAWN := Vector2(496, 500)
const POS_ALTAR := Vector2(480, 280)
const POS_CROSS := Vector2(480, 230)
const POS_WINDOW := Vector2(480, 168)
const POS_CHAIRS := Vector2(110, 230)
const POS_HAROLD := Vector2(220, 420)
const POS_KEYS := Vector2(168, 292)
const POS_LEDGER := Vector2(160, 400)
const POS_SCONCE_L := Vector2(200, 360)
const POS_SCONCE_R := Vector2(760, 360)
const POS_SCONCE_N := Vector2(480, 240)


func area_name() -> String:
	return "Sanctuary"


func _on_time_changed() -> void:
	super._on_time_changed()
	var service := get_node_or_null("SundayService")
	if service != null and service.has_method("on_clock"):
		service.call("on_clock")


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_assign_art()
	_place_props()
	_paint_ground()
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	# Stops the player in the doorway instead of letting them leave through the gap.
	_add_rect(Vector2(480, 698), Vector2(72, 12))


func rebuild_collision() -> void:
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	_add_rect(Vector2(480, 698), Vector2(72, 12))


func _assign_art() -> void:
	_set_sprite("Props/Window", PlaceholderArt.sanctuary_window())
	_set_sprite("Props/Cross", PlaceholderArt.cross())
	_set_sprite("Props/Altar", PlaceholderArt.altar())
	_set_sprite("Props/Chairs", PlaceholderArt.chairs())
	for i in 4:
		_set_sprite("Props/PewL%d" % (i + 1), PlaceholderArt.pew())
		_set_sprite("Props/PewR%d" % (i + 1), PlaceholderArt.pew())
	_set_light_texture("Lighting/SconceL")
	_set_light_texture("Lighting/SconceR")
	_set_light_texture("Lighting/SconceN")


func _place_props() -> void:
	_place("Props/Door", POS_DOOR)
	_place("Props/Altar", POS_ALTAR)
	_feet_offset("Props/Altar")
	_place("Props/Cross", POS_CROSS)
	_feet_offset("Props/Cross")
	_place("Props/Window", POS_WINDOW)
	_feet_offset("Props/Window")
	_place("Props/Chairs", POS_CHAIRS)
	_feet_offset("Props/Chairs")
	_place("Props/Harold", POS_HAROLD)
	_place("Props/KeyRing", POS_KEYS)
	_place("Props/Ledger", POS_LEDGER)
	_add_quiet_note()
	_add_sanctuary_flowers()
	_place("Props/Thomas", Vector2(560, 520))
	_place("Props/Frank", Vector2(400, 600))
	_place("Props/Sarah", Vector2(400, 500))
	var pew_ys: Array[float] = [360.0, 440.0, 520.0, 600.0]
	for i in pew_ys.size():
		var left := _place("Props/PewL%d" % (i + 1), Vector2(330, pew_ys[i]))
		var right := _place("Props/PewR%d" % (i + 1), Vector2(630, pew_ys[i]))
		if left is Sprite2D:
			_feet_offset("Props/PewL%d" % (i + 1))
		if right is Sprite2D:
			_feet_offset("Props/PewR%d" % (i + 1))
	_place("Spawns/default", POS_SPAWN)
	_place("Spawns/from_exterior", POS_SPAWN)
	var spawn := get_node_or_null("Spawns/default")
	var entered := get_node_or_null("Spawns/from_exterior")
	if spawn != null:
		spawn.set_meta("facing", &"up")
	if entered != null:
		entered.set_meta("facing", &"up")
	_place("Lighting/SconceL", POS_SCONCE_L)
	_place("Lighting/SconceR", POS_SCONCE_R)
	_place("Lighting/SconceN", POS_SCONCE_N)


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
	bouquet.position = Vector2(430, 300)
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
	note.position = Vector2(480, 400)
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


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("Sanctuary ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 14 or x == 15)
			var aisle := x == 14 or x == 15
			var tile := Vector2i(4, 0)
			if border and not door_gap:
				tile = Vector2i(6, 0)
			elif aisle and not door_gap:
				tile = Vector2i(5, 0)
			layer.set_cell(Vector2i(x, y), 0, tile)


func _add_walls() -> void:
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 14 or x == 15)
			if border and not door_gap:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))


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
