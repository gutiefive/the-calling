extends WorldRoom
## Modest Fellowship Hall. Wednesday 11–16 holds the potluck.

const MAP_SIZE := Vector2i(22, 16)
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


func _on_time_changed() -> void:
	super._on_time_changed()
	_refresh_gathering()


func _refresh_living() -> void:
	super._refresh_living()
	_refresh_gathering()


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := PlaceholderArt.grounds_atlas()
	if layer == null or tex == null:
		push_error("Fellowship Hall ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 10 or x == 11)
			var tile := Vector2i(4, 0)
			if x > 2 and x < 19 and y > 2 and y < 13:
				tile = Vector2i(5, 0)
			if border and not door_gap:
				tile = Vector2i(6, 0)
			layer.set_cell(Vector2i(x, y), 0, tile)


func _add_walls() -> void:
	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var border := x == 0 or y == 0 or x == MAP_SIZE.x - 1 or y == MAP_SIZE.y - 1
			var door_gap := y == MAP_SIZE.y - 1 and (x == 10 or x == 11)
			if border and not door_gap:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))
	_add_rect(Vector2(352, MAP_SIZE.y * 32 - 6), Vector2(64, 12))


func _place_room() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	if props is Node2D:
		(props as Node2D).y_sort_enabled = true
	_add_door(props)
	_place_marker("default", Vector2(352, 360), &"up")
	_place_marker("from_grounds", Vector2(352, 360), &"up")
	_add_lamp(Vector2(140, 140))
	_add_lamp(Vector2(560, 140))
	_add_solid(props, "Sideboard", PlaceholderArt.counter(), Vector2(180, 150), Vector2(64, 14))
	_add_guest(props, "Margaret", "margaret", "margaret", Catalog.post("margaret"))
	_add_guest(props, "Harold", "harold", "harold", Catalog.post("harold"))
	_add_guest(props, "Sarah", "sarah", "sarah", Catalog.post("sarah"))
	_add_guest(props, "Ostrow", "ostrow", "ostrow", Catalog.post("ostrow"))
	_add_guest(props, "Ruth", "ruth", "ruth", Catalog.post("ruth"))
	_add_guest(props, "Dale", "dale", "dale", Catalog.post("dale"))
	_ensure_gathering(props)
	_refresh_gathering()


func _ensure_gathering(props: Node) -> void:
	_sprite_prop(props, "TableA", "table_modest", Vector2(260, 240), Vector2(72, 14))
	_sprite_prop(props, "TableB", "table_modest", Vector2(440, 240), Vector2(72, 14))
	_sprite_prop(props, "ChairA", "chair", Vector2(230, 270), Vector2(12, 8))
	_sprite_prop(props, "ChairB", "chair", Vector2(290, 270), Vector2(12, 8))
	_sprite_prop(props, "ChairC", "chair", Vector2(410, 270), Vector2(12, 8))
	_sprite_prop(props, "ChairD", "chair", Vector2(470, 270), Vector2(12, 8))
	_sprite_prop(props, "CenterA", "centerpiece", Vector2(260, 228), Vector2(10, 8))
	_sprite_prop(props, "CenterB", "centerpiece", Vector2(440, 228), Vector2(10, 8))
	_sprite_prop(props, "DishesA", "dishes_simple", Vector2(300, 232), Vector2(20, 8))
	_sprite_prop(props, "DishesB", "dishes_simple", Vector2(400, 232), Vector2(20, 8))
	_sprite_prop(props, "Lights", "string_lights", Vector2(352, 110), Vector2(80, 8))
	_sprite_prop(props, "Banner", "banner", Vector2(352, 96), Vector2(36, 8))
	_sprite_prop(props, "ExtraChairs", "chairs_extra", Vector2(352, 320), Vector2(24, 8))


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
	var frame_id := "table_full" if full else "table_modest"
	sprite.texture = PotluckArt.texture(frame_id)
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
		return
	var door := Door.new()
	door.name = "Door"
	door.position = Vector2(352, 478)
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
	props.add_child(sprite)


func _add_lamp(pos: Vector2) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null:
		return
	var lamp_name := "Lamp%d" % lighting.get_child_count()
	if lighting.get_node_or_null(lamp_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = lamp_name
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


func _set_inside(inside: bool) -> void:
	var events := _events()
	if events != null and events.has_method("set_inside"):
		events.call("set_inside", inside)


func _events() -> Node:
	return get_node_or_null("/root/EventState")
