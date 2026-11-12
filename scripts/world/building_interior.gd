extends WorldRoom
## Parsonage, hardware store, or Frank's bay. The node name picks which.

const MAP_SIZE := Vector2i(20, 16)


func area_name() -> String:
	var kind := _kind()
	if kind == "hardware":
		return "Hardware store"
	if kind == "bay":
		return "Frank's bay"
	return "Parsonage"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_paint_ground()
	_place_room()
	_clear_solids()
	_add_walls()
	_add_prop_blocks()


func rebuild_collision() -> void:
	_clear_solids()
	_add_walls()
	_add_prop_blocks()


func _kind() -> String:
	var node_name := String(name)
	if node_name == "HardwareInterior":
		return "hardware"
	if node_name == "BayInterior":
		return "bay"
	return "parsonage"


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("%s ground is missing" % name)
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 9 or x == 10)
			var tile := Vector2i(4, 0)
			if _kind() == "parsonage" and x > 3 and x < 16 and y > 2 and y < 12:
				tile = Vector2i(5, 0)
			if border and not door_gap:
				tile = Vector2i(6, 0)
			layer.set_cell(Vector2i(x, y), 0, tile)


func _add_walls() -> void:
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 9 or x == 10)
			if border and not door_gap:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))


func _place_room() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	var exit_scene := "res://scenes/world/church_exterior.tscn"
	var exit_spawn := &"from_parsonage"
	var exit_prompt := "Step outside"
	if _kind() == "hardware":
		exit_scene = "res://scenes/world/hardware_street.tscn"
		exit_spawn = &"from_store"
		exit_prompt = "Step outside"
	elif _kind() == "bay":
		exit_scene = "res://scenes/world/hardware_street.tscn"
		exit_spawn = &"from_bay"
		exit_prompt = "Step outside"
	_add_door(props, "Door", Vector2(320, 470), exit_prompt, exit_scene, exit_spawn)
	_place_marker("default", Vector2(320, 360), &"up")
	_place_marker("from_grounds", Vector2(320, 360), &"up")
	_place_marker("from_street", Vector2(320, 360), &"up")
	_add_lamp(Vector2(120, 140))
	if _kind() == "parsonage":
		_add_bed(props, Vector2(200, 180))
		_add_solid_sprite(props, "Table", PlaceholderArt.counter(), Vector2(430, 220), Vector2(64, 14))
		_add_flavor(props, "WindowNote", PlaceholderArt.notice_board(), Vector2(480, 150), Vector2i(32, 48), 1, "Note", "Read", "The spare key hangs on the kitchen nail. Margaret wrote that down.")
	elif _kind() == "hardware":
		_add_solid_sprite(props, "Counter", PlaceholderArt.counter(), Vector2(300, 200), Vector2(72, 16))
		_add_solid_sprite(props, "Shelf", PlaceholderArt.shelf(), Vector2(140, 160), Vector2(48, 16))
		_add_flavor(props, "Screws", PlaceholderArt.crate(), Vector2(460, 240), Vector2i(32, 32), 1, "Bin", "Look", "Number eights, same as the church step. Thomas keeps them in paper bags.")
		_add_flavor(props, "Paint", PlaceholderArt.shelf(), Vector2(480, 150), Vector2i(64, 48), 1, "Shelf", "Look", "The paint labels are sun-faded. He'll tell you which can is which.")
		_add_clerk(props, "Thomas", "thomas", "thomas", Vector2(300, 250))
	else:
		_add_solid_sprite(props, "Car", PlaceholderArt.car(), Vector2(180, 240), Vector2(80, 20))
		_add_solid_sprite(props, "Bench", PlaceholderArt.counter(), Vector2(430, 200), Vector2(64, 14))
		_add_flavor(props, "Tools", PlaceholderArt.tools(), Vector2(470, 250), Vector2i(32, 32), 1, "Tools", "Look", "A wrench, a lamp, and a rag. Nothing on this bench is for sale.")
		_add_flavor(props, "Clipboard", PlaceholderArt.ledger(), Vector2(400, 160), Vector2i(32, 32), 1, "Clipboard", "Read", "The sedan's brakes are apart. Frank's name is on the clipboard, not a customer's.")
		_add_clerk(props, "Frank", "frank", "frank", Vector2(360, 280))


func _add_door(props: Node, node_name: String, pos: Vector2, prompt: String, scene_path: String, spawn: StringName) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var door := Door.new()
	door.name = node_name
	door.position = pos
	door.prompt_text = prompt
	door.radius = 42.0
	door.destination_scene = scene_path
	door.destination_spawn = spawn
	props.add_child(door)


func _add_bed(props: Node, pos: Vector2) -> void:
	if props.get_node_or_null("Bed") != null:
		return
	var bed := Bed.new()
	bed.name = "Bed"
	bed.position = pos
	bed.prompt_text = "Sleep"
	bed.radius = 42.0
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = PlaceholderArt.bed()
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	bed.add_child(sprite)
	props.add_child(bed)


func _add_clerk(props: Node, node_name: String, hours_id: String, dialogue_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var clerk := ShopClerk.new()
	clerk.name = node_name
	clerk.position = pos
	clerk.hours_id = hours_id
	clerk.dialogue_id = dialogue_id
	clerk.art_id = hours_id
	clerk.frame_size = Vector2i(32, 48)
	clerk.frame_count = 2
	clerk.speaker_name = node_name
	clerk.prompt_text = "Talk"
	clerk.radius = 42.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	clerk.add_child(sprite)
	props.add_child(clerk)


func _add_flavor(props: Node, node_name: String, sheet: Texture2D, pos: Vector2, frame: Vector2i, frames: int, speaker: String, prompt: String, line: String) -> void:
	if props.get_node_or_null(node_name) != null or sheet == null:
		return
	var prop := SpeechProp.new()
	prop.name = node_name
	prop.position = pos
	prop.sheet = sheet
	prop.frame_size = frame
	prop.frame_count = frames
	prop.speaker_name = speaker
	prop.prompt_text = prompt
	prop.line = line
	prop.radius = 36.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	prop.add_child(sprite)
	props.add_child(prop)


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


func _add_lamp(pos: Vector2) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null("Lamp") != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = "Lamp"
	lamp.position = pos
	lamp.color = Color(1, 0.86, 0.62)
	lamp.energy = 0.9
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 3.2
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_lamp")
	lighting.add_child(lamp)


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
