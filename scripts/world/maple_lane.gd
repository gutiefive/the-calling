extends WorldRoom
## Houses, a bus stop, and the community garden past the repaired bridge.

const MAP_SIZE := Vector2i(40, 32)


func area_name() -> String:
	return "Maple Lane"


func _build() -> void:
	bounds = Rect2(0, 0, MAP_SIZE.x * 32, MAP_SIZE.y * 32)
	_paint_ground()
	_place_lane()
	_clear_solids()
	_add_footprints()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)


func rebuild_collision() -> void:
	_clear_solids()
	_add_footprints()
	_add_prop_blocks()
	_add_map_border(MAP_SIZE)


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("Maple Lane ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var alt := (x * 5 + y * 9) % 11 == 0
			layer.set_cell(Vector2i(x, y), 0, Vector2i(1 if alt else 0, 0))
	for y in range(2, 30):
		for x in range(9, 13):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
	for x in range(13, 28):
		layer.set_cell(Vector2i(x, 16), 0, Vector2i(3, 0))
	for y in range(16, 26):
		layer.set_cell(Vector2i(26, y), 0, Vector2i(3, 0))


func _place_lane() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_solid_sprite(props, "HouseWest", PlaceholderArt.cottage(), Vector2(180, 360), Vector2(140, 48))
	_add_solid_sprite(props, "HouseEast", PlaceholderArt.parsonage(), Vector2(620, 340), Vector2(110, 40))
	_add_solid_sprite(props, "HouseFar", PlaceholderArt.cottage(), Vector2(980, 420), Vector2(140, 48))
	_add_solid_sprite(props, "Fence1", PlaceholderArt.fence(), Vector2(180, 480), Vector2(56, 10))
	_add_solid_sprite(props, "Fence2", PlaceholderArt.fence(), Vector2(620, 500), Vector2(56, 10))
	_add_solid_sprite(props, "BusStop", PlaceholderArt.bus_stop(), Vector2(500, 520), Vector2(12, 10))
	_add_solid_sprite(props, "Bench", PlaceholderArt.bench(), Vector2(560, 560), Vector2(36, 10))
	_add_garden(props)
	_add_helper(props)
	_add_person(props, "Sarah", "sarah", "sarah", Vector2(400, 560))
	_add_person(props, "Thomas", "thomas", "thomas", Vector2(400, 420))
	_add_neighbor(props, "NeighborDale", "dale", 0, 0, Vector2(420, 680))
	_add_neighbor(props, "NeighborRuth", "ruth", 1, 1, Vector2(520, 760))
	_add_door(props)
	_place_marker("default", Vector2(352, 200), &"down")
	_place_marker("from_oak", Vector2(352, 200), &"down")
	_add_lamp(Vector2(480, 640))


func _add_footprints() -> void:
	# The solid sprites already block through solid_prop. Houses use that path.
	pass


func _add_garden(props: Node) -> void:
	if props.get_node_or_null("Garden") != null:
		return
	var plot := GardenPlot.new()
	plot.name = "Garden"
	plot.position = Vector2(860, 760)
	plot.prompt_text = "Tend the garden"
	plot.radius = 44.0
	plot.blocks_movement = true
	plot.block_size = Vector2(40, 14)
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	plot.add_child(sprite)
	props.add_child(plot)


func _add_helper(props: Node) -> void:
	if props.get_node_or_null("GardenNeighbor") != null:
		return
	var person := DialogueNpc.new()
	person.name = "GardenNeighbor"
	person.position = Vector2(760, 680)
	person.dialogue_id = "garden_help"
	person.sheet = PlaceholderArt.townsfolk(2)
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = "A neighbor"
	person.prompt_text = "Talk"
	person.radius = 42.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


func _add_person(props: Node, node_name: String, npc_id: String, dialogue_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := DialogueNpc.new()
	person.name = node_name
	person.position = pos
	person.npc_id = npc_id
	person.dialogue_id = dialogue_id
	person.art_id = npc_id
	person.frame_size = Vector2i(32, 48)
	person.frame_count = 2
	person.speaker_name = node_name
	person.prompt_text = "Talk"
	person.radius = 40.0
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	person.add_child(sprite)
	props.add_child(person)


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
	var route: Array[Vector2] = [pos, pos + Vector2(80, 0), pos + Vector2(80, 28), pos + Vector2(0, 28)]
	person.set_route(route)
	props.add_child(person)


func _add_door(props: Node) -> void:
	if props.get_node_or_null("ToOak") != null:
		return
	var door := Door.new()
	door.name = "ToOak"
	door.position = Vector2(352, 96)
	door.prompt_text = "Walk to Oak Street"
	door.radius = 42.0
	door.destination_scene = "res://scenes/world/hardware_street.tscn"
	door.destination_spawn = &"from_maple"
	props.add_child(door)


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
	lamp.color = Color(1, 0.84, 0.58)
	lamp.energy = 0.0
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 3.0
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
