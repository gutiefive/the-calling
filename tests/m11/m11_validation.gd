extends Node
## Headless checks for Milestone 11 (Oak south side and Maple Lane rework).
## Prints M11_OK or M11_FAIL.
## Run: godot --headless --path . res://tests/m11/m11_validation.tscn

const STREET := "res://scenes/world/hardware_street.tscn"
const LANE := "res://scenes/world/maple_lane.tscn"
const TILE := 32
const MIN_SIGN := Vector2(72, 16)
const SOUTH_NODES: PackedStringArray = [
	"CreditUnion", "Pharmacy", "Thrift", "FeedStore", "TownHall", "Boarded",
]
const SOUTH_DOORS: PackedStringArray = [
	"CreditUnionDoor", "PharmacyDoor", "ThriftDoor", "FeedStoreDoor", "TownHallDoor", "BoardedDoor",
]
const OAK_DOORS: Array[Dictionary] = [
	{"node": "Props/StoreDoor", "dest": "hardware_interior.tscn", "spawn": &"from_street"},
	{"node": "Props/BayDoor", "dest": "bay_interior.tscn", "spawn": &"from_street"},
	{"node": "Props/ToChurch", "dest": "church_exterior.tscn", "spawn": &"from_street"},
	{"node": "Props/MapleDoor", "dest": "maple_lane.tscn", "spawn": &"from_oak"},
]

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	NarrativeState.reset()
	DayClock.reset()
	_static_data()
	await _oak_layout()
	await _maple_layout()
	await _garden_still_works()
	await _routes_and_collision()
	await _old_save_fallback()
	_restore_user_save()
	_finish()


func _static_data() -> void:
	_check(FileAccess.file_exists("res://data/world/oak_storefronts.json"), "oak storefront data exists")
	_check(FileAccess.file_exists("res://data/world/maple_houses.json"), "maple house data exists")
	_check(FileAccess.file_exists("res://assets/environments/credit_union.png"), "credit union art exists")
	_check(FileAccess.file_exists("res://assets/environments/pharmacy.png"), "pharmacy art exists")
	_check(FileAccess.file_exists("res://assets/environments/thrift_shop.png"), "thrift art exists")
	_check(FileAccess.file_exists("res://assets/environments/feed_store.png"), "feed store art exists")
	_check(FileAccess.file_exists("res://assets/environments/town_hall.png"), "town hall art exists")
	_check(FileAccess.file_exists("res://assets/environments/boarded_shop.png"), "boarded shop art exists")
	_check(FileAccess.file_exists("res://assets/environments/sign_hardware.png"), "hardware storefront sign exists")
	_check(FileAccess.file_exists("res://assets/environments/house_0_east.png"), "house art exists")
	var houses := TownFacades.maple_houses()
	_check(houses.size() >= 5 and houses.size() <= 8, "Maple Lane has 5-8 houses in data")
	for row in houses:
		_check(row.has("destination_scene"), "%s has an optional destination_scene" % str(row.get("id", "?")))
		_check(_flavor_ok(str(row.get("flavor", ""))), "%s flavor has no dollar amount" % str(row.get("id", "?")))
	for row in TownFacades.oak_storefronts():
		_check(_flavor_ok(str(row.get("flavor", ""))), "%s flavor has no dollar amount" % str(row.get("id", "?")))
		if str(row.get("side", "")) != "south":
			continue
		_check(row.has("destination_scene"), "%s has an optional destination_scene" % str(row.get("id", "?")))


func _oak_layout() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null, "Oak Street has a Ground layer")
	for node_name in SOUTH_NODES:
		_check(room.get_node_or_null("Props/" + node_name) != null, "%s is on the south side" % node_name)
		_check(not _building_on_road(room, "Props/" + node_name), "%s does not overlap the road" % node_name)
	for door_name in SOUTH_DOORS:
		_check(_door_on_sidewalk(room, "Props/" + door_name), "%s sits on the sidewalk" % door_name)
		var door := room.get_node_or_null("Props/" + door_name) as BuildingDoor
		_check(door != null, "%s is a BuildingDoor" % door_name)
		if door != null:
			_check(door.destination_scene.is_empty(), "%s is not enterable yet" % door_name)
			_check(not door.is_open(), "%s stays closed" % door_name)
	for row in TownFacades.oak_storefronts():
		var sign_id := str(row.get("sign_id", ""))
		if sign_id.is_empty():
			continue
		var sign := room.get_node_or_null("Props/%sSign" % str(row.get("node", ""))) as Sprite2D
		_check(sign != null and sign.texture != null, "%s has a storefront sign" % str(row.get("node", "")))
		if sign != null and sign.texture != null:
			var size := sign.texture.get_size()
			_check(size.x >= MIN_SIGN.x and size.y >= MIN_SIGN.y, "%s sign is readable (%sx%s)" % [str(row.get("node", "")), size.x, size.y])
	for spec in OAK_DOORS:
		var spawn: StringName = spec.get("spawn")
		_check(_door_routes(room, str(spec.get("node", "")), str(spec.get("dest", "")), spawn), "%s still routes" % str(spec.get("node", "")))
	_check(_spawn_outside_door(room, "from_store", "Props/StoreDoor"), "from_store sits outside the store trigger")
	_check(_spawn_outside_door(room, "from_bay", "Props/BayDoor"), "from_bay sits outside the bay trigger")
	_check(_spawn_outside_door(room, "from_church", "Props/ToChurch"), "from_church sits outside the church trigger")
	_check(_spawn_outside_door(room, "from_maple", "Props/MapleDoor"), "from_maple sits outside the Maple Lane trigger")
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	var world := room as WorldRoom
	if camera != null and world != null:
		_check(camera.limit_left == int(world.bounds.position.x) and camera.limit_top == int(world.bounds.position.y), "Oak camera left/top match the street bounds")
		_check(camera.limit_right == int(world.bounds.end.x) and camera.limit_bottom == int(world.bounds.end.y), "Oak camera right/bottom contain the street")
	var player := room.get_node_or_null("Props/Player") as Player
	var flavor_door := room.get_node_or_null("Props/PharmacyDoor") as Node2D
	if player != null and flavor_door != null:
		SceneRouter.suppress_change = true
		await _walk_into(player, flavor_door)
		_check(is_instance_valid(room), "a south shop door does not change scenes")
		var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
		var spoken := label.text if label != null else ""
		_check(spoken.contains("Closed") or spoken.contains("blinds") or spoken.contains("day"), "a south shop door shows a closed line (%s)" % _snippet(spoken))
		SceneRouter.suppress_change = false
	room.free()
	await get_tree().process_frame


func _maple_layout() -> void:
	DayClock.set_time(5, 14, 0)
	var room := _instance(LANE)
	if room == null:
		return
	var houses: Array[Node2D] = []
	for row in TownFacades.maple_houses():
		var node_name := str(row.get("node", ""))
		var house := room.get_node_or_null("Props/" + node_name) as Node2D
		_check(house != null, "%s stands on Maple Lane" % node_name)
		if house != null:
			houses.append(house)
		_check(not _building_on_road(room, "Props/" + node_name), "%s does not overlap the road" % node_name)
		var door := room.get_node_or_null("Props/%sDoor" % node_name) as BuildingDoor
		_check(door != null, "%s has a data-driven door" % node_name)
		if door != null:
			_check(_door_on_walk(room, door), "%s door meets a front walk or sidewalk" % node_name)
			_check(door.destination_scene.is_empty(), "%s is not enterable yet" % node_name)
			_check(door.has_method("is_open") and not door.is_open(), "%s stays closed until a target scene is set" % node_name)
	_check(houses.size() >= 5 and houses.size() <= 8, "Maple Lane has 5-8 houses")
	_check(_adjacent_facades_differ(room), "no two adjacent houses share a facade variant")
	_check(room.get_node_or_null("Props/Garden") != null, "the community garden is still on the lane")
	_check(room.get_node_or_null("Props/ToOak") != null, "the Oak Street door is still on the lane")
	_check(_door_routes(room, "Props/ToOak", "hardware_street.tscn", &"from_maple"), "Maple Lane still routes back to Oak Street")
	_check(_spawn_outside_door(room, "from_oak", "Props/ToOak"), "from_oak sits outside the Oak Street trigger")
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	var world := room as WorldRoom
	if camera != null and world != null:
		_check(camera.limit_left == int(world.bounds.position.x) and camera.limit_top == int(world.bounds.position.y), "Maple camera left/top match the lane bounds")
		_check(camera.limit_right == int(world.bounds.end.x) and camera.limit_bottom == int(world.bounds.end.y), "Maple camera right/bottom contain the lane")
	var player := room.get_node_or_null("Props/Player") as Player
	var house_door := room.get_node_or_null("Props/HouseMargaretDoor") as Node2D
	if player != null and house_door != null:
		SceneRouter.suppress_change = true
		player.clear_interact_lock()
		player.global_position = house_door.global_position + Vector2(50, 0)
		player.velocity = Vector2.ZERO
		await get_tree().process_frame
		await get_tree().physics_frame
		Input.action_press("move_left")
		for _i in 45:
			await get_tree().physics_frame
		Input.action_release("move_left")
		_check(is_instance_valid(room), "a house door does not change scenes")
		var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
		var spoken := label.text if label != null else ""
		_check(not spoken.is_empty(), "a house door shows a flavor line (%s)" % _snippet(spoken))
		_check(_flavor_ok(spoken), "house flavor has no dollar amount")
		SceneRouter.suppress_change = false
	room.free()
	await get_tree().process_frame


func _garden_still_works() -> void:
	NarrativeState.reset()
	DayClock.set_time(5, 14, 0)
	var room := _instance(LANE)
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var plot := room.get_node_or_null("Props/Garden") as GardenPlot
	var helper := room.get_node_or_null("Props/GardenNeighbor") as Node2D
	_check(plot != null and plot.shown_stage == 0, "the garden starts overgrown")
	if player != null and plot != null:
		await _stand_at(player, plot)
		await _tap("interact")
		await _tap("interact")
	_check(NarrativeState.flag_is_true("garden_cleared") and plot != null and plot.shown_stage == 1, "clearing the weeds still changes the plot")
	if player != null and helper != null:
		await _stand_at(player, helper)
		var guard := 0
		while not NarrativeState.flag_is_true("garden_planted") and guard < 6:
			await _tap("interact")
			guard += 1
	_check(NarrativeState.flag_is_true("garden_planted"), "a neighbor still helps plant the garden")
	room.free()
	await get_tree().process_frame


func _routes_and_collision() -> void:
	DayClock.set_time(5, 10, 0)
	var street := _instance(STREET)
	if street == null:
		return
	for node_name in ["NeighborA", "NeighborB", "NeighborC", "NeighborD", "NeighborE"]:
		var neighbor := street.get_node_or_null("Props/" + node_name) as AmbientTownsfolk
		_check(neighbor != null, "%s exists on Oak Street" % node_name)
		if neighbor == null:
			continue
		_check(_walkable(street, neighbor.position), "%s stands on walkable ground" % node_name)
	var sarah := street.get_node_or_null("Props/Sarah") as Node2D
	_check(sarah != null and _walkable(street, sarah.position), "Sarah still stands on walkable Oak Street ground")
	var player := street.get_node_or_null("Props/Player") as Player
	var pharmacy := street.get_node_or_null("Props/Pharmacy") as Node2D
	if player != null and pharmacy != null:
		var left := pharmacy.global_position.x - 130.0
		player.global_position = Vector2(left, pharmacy.global_position.y - 56.0)
		player.velocity = Vector2.ZERO
		Input.action_press("move_right")
		for _i in 50:
			await get_tree().physics_frame
		Input.action_release("move_right")
		_check(player.global_position.x < pharmacy.global_position.x - 20.0, "a south shop blocks the player")
	var car := street.get_node_or_null("Props/CarC") as Node2D
	if player != null and car != null:
		player.global_position = car.global_position + Vector2(0, 36)
		player.velocity = Vector2.ZERO
		Input.action_press("move_up")
		for _i in 40:
			await get_tree().physics_frame
		Input.action_release("move_up")
		_check(player.global_position.y > car.global_position.y, "a south-side parked car blocks the player")
	street.free()
	await get_tree().process_frame
	DayClock.set_time(5, 14, 0)
	var lane := _instance(LANE)
	if lane == null:
		return
	for node_name in ["NeighborDale", "NeighborRuth", "Sarah", "Thomas"]:
		var person := lane.get_node_or_null("Props/" + node_name) as Node2D
		_check(person != null and _walkable(lane, person.position), "%s stands on walkable Maple Lane ground" % node_name)
	player = lane.get_node_or_null("Props/Player") as Player
	var house := lane.get_node_or_null("Props/HouseDale") as Node2D
	if player != null and house != null:
		var right := house.global_position.x + 120.0
		player.global_position = Vector2(right, house.global_position.y - 40.0)
		player.velocity = Vector2.ZERO
		Input.action_press("move_left")
		for _i in 50:
			await get_tree().physics_frame
		Input.action_release("move_left")
		_check(player.global_position.x > house.global_position.x + 20.0, "a Maple Lane house blocks the player")
	lane.free()
	await get_tree().process_frame


func _old_save_fallback() -> void:
	DayClock.set_time(4, 14, 0)
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(816, 300)
	SceneRouter.exact_facing = &"down"
	var room := _instance_keeping_exact(STREET)
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and _walkable(room, player.global_position), "a blocked Oak Street save snaps onto walkable ground")
	if player != null:
		_check(player.global_position.distance_to(Vector2(816, 300)) > 40.0, "a save inside a shop does not keep the old coordinates")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(120, 544)
	SceneRouter.exact_facing = &"right"
	room = _instance_keeping_exact(STREET)
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and player.global_position.distance_to(Vector2(120, 544)) < 2.0, "a valid Oak Street save keeps its position")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(384, 300)
	SceneRouter.exact_facing = &"down"
	room = _instance_keeping_exact(LANE)
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and _walkable(room, player.global_position), "a blocked Maple Lane save snaps onto walkable ground")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(736, 200)
	SceneRouter.exact_facing = &"down"
	room = _instance_keeping_exact(LANE)
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and player.global_position.distance_to(Vector2(736, 200)) < 2.0, "a valid Maple Lane save keeps its position")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = false


func _adjacent_facades_differ(room: Node) -> bool:
	var west: Array[Dictionary] = []
	var east: Array[Dictionary] = []
	for row in TownFacades.maple_houses():
		var node_name := str(row.get("node", ""))
		var house := room.get_node_or_null("Props/" + node_name) as Node2D
		if house == null:
			return false
		var item := {"y": house.position.y, "variant": int(house.get_meta("facade_variant", row.get("variant", -1)))}
		if str(row.get("side", "")) == "west":
			west.append(item)
		else:
			east.append(item)
	return _sorted_variants_differ(west) and _sorted_variants_differ(east)


func _sorted_variants_differ(rows: Array[Dictionary]) -> bool:
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.get("y", 0.0)) < float(b.get("y", 0.0)))
	for i in range(1, rows.size()):
		if int(rows[i].get("variant", 0)) == int(rows[i - 1].get("variant", -1)):
			return false
	return true


func _door_on_sidewalk(room: Node, node_path: String) -> bool:
	var door := room.get_node_or_null(node_path) as Node2D
	return _door_on_walk(room, door)


func _door_on_walk(room: Node, door: Node2D) -> bool:
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if door == null or ground == null:
		return false
	var cell := Vector2i(int(door.position.x / TILE), int(door.position.y / TILE))
	for offset in [Vector2i.ZERO, Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var atlas := ground.get_cell_atlas_coords(cell + offset)
		if TownTiles.is_sidewalk(atlas) or atlas == TownTiles.PATH:
			return true
	return false


func _building_on_road(room: Node, node_path: String) -> bool:
	var sprite := room.get_node_or_null(node_path) as Sprite2D
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if sprite == null or sprite.texture == null or ground == null:
		return true
	var sample := sprite.position + Vector2(0.0, -40.0)
	var cell := Vector2i(int(sample.x / TILE), int(sample.y / TILE))
	return TownTiles.is_road(ground.get_cell_atlas_coords(cell))


func _door_routes(room: Node, node_path: String, dest: String, spawn: StringName) -> bool:
	var door := room.get_node_or_null(node_path)
	if door == null:
		return false
	var scene := str(door.get("destination_scene"))
	var dest_spawn: StringName = door.get("destination_spawn")
	return scene.ends_with(dest) and dest_spawn == spawn


func _spawn_outside_door(room: Node, spawn_id: String, door_path: String) -> bool:
	var marker := room.get_node_or_null("Spawns/" + spawn_id) as Node2D
	var door := room.get_node_or_null(door_path) as Node2D
	if marker == null or door == null:
		return false
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	return marker.global_position.distance_to(door.global_position) > radius + 2.0


func _walkable(room: Node, pos: Vector2) -> bool:
	var world := room as WorldRoom
	if world != null:
		var pad := 10.0
		if pos.x < world.bounds.position.x + pad or pos.y < world.bounds.position.y + pad:
			return false
		if pos.x > world.bounds.end.x - pad or pos.y > world.bounds.end.y - pad:
			return false
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if ground != null:
		var cell := Vector2i(int(pos.x / TILE), int(pos.y / TILE))
		if ground.get_cell_atlas_coords(cell) == TownTiles.WATER:
			return false
	return not _inside_large_solid(room, pos)


func _inside_large_solid(room: Node, pos: Vector2) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	var feet := Rect2(pos + Vector2(-6.0, -8.0), Vector2(12.0, 8.0))
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		if rect.size.x < 24.0 and rect.size.y < 16.0:
			continue
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet):
			return true
	return false


func _flavor_ok(text: String) -> bool:
	var lower := text.to_lower()
	if lower.contains("$") or lower.contains("dollar"):
		return false
	return true


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"from_church" if path.ends_with("hardware_street.tscn") else &"from_oak"
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	_check(room != null, "instantiate " + path)
	if room == null:
		return null
	add_child(room)
	return room


func _instance_keeping_exact(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load saved " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	if room == null:
		return null
	add_child(room)
	return room


func _walk_into(player: Player, door: Node2D) -> void:
	if player == null or door == null:
		return
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	player.clear_interact_lock()
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	var dest := door.global_position
	player.global_position = dest + Vector2(0, radius + 20.0)
	player.velocity = Vector2.ZERO
	await get_tree().process_frame
	await get_tree().process_frame
	Input.action_press("move_up")
	for _i in 40:
		await get_tree().physics_frame
	Input.action_release("move_up")


func _stand_at(player: Player, target: Node2D) -> void:
	player.velocity = Vector2.ZERO
	player.global_position = target.global_position + Vector2(0, 26)
	player.clear_interact_lock()
	await get_tree().process_frame
	await get_tree().process_frame


func _tap(action: String) -> void:
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("interact")
	await get_tree().process_frame
	await get_tree().physics_frame
	Input.action_press(action)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(action)
	await get_tree().process_frame
	await get_tree().process_frame


func _snippet(text: String) -> String:
	var clean := text.replace("\n", " ")
	if clean.length() > 48:
		return clean.substr(0, 48)
	return clean


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
	elif FileAccess.file_exists(SaveGame.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveGame.SAVE_PATH))


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	print("M11_OK" if not _failed else "M11_FAIL")
	get_tree().quit(0 if not _failed else 1)
