extends Node
## Headless checks for Milestone 11B (shop signs, Maple yards, evening life).
## Prints M11B_OK or M11B_FAIL.
## Run: godot --headless --path . res://tests/m11b/m11b_validation.tscn

const STREET := "res://scenes/world/hardware_street.tscn"
const LANE := "res://scenes/world/maple_lane.tscn"
const TILE := 32
const MAX_GRASS_RECT := 96
const MIN_YARD_FILL := 280
const MAPLE_WAYPOINTS: Array[Vector2] = [
	Vector2(640, 360),
	Vector2(640, 520),
	Vector2(656, 520),
	Vector2(656, 360),
	Vector2(640, 736),
	Vector2(640, 900),
	Vector2(656, 900),
	Vector2(656, 736),
	Vector2(832, 720),
	Vector2(640, 500),
	Vector2(736, 40),
	Vector2(736, 120),
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
	await _one_sign_each()
	await _maple_yards()
	await _evening_life()
	_restore_user_save()
	_finish()


func _static_data() -> void:
	_check(FileAccess.file_exists("res://assets/environments/for_sale_sign.png"), "for-sale sign art exists")
	_check(FileAccess.file_exists("res://assets/environments/garden_shed.png"), "garden shed art exists")
	_check(FileAccess.file_exists("res://assets/environments/hedge_bush.png"), "hedge bush art exists")
	_check(FileAccess.file_exists("res://assets/environments/dog.png"), "dog art exists")
	var street_src := FileAccess.get_file_as_string("res://scripts/art/street_frames.gd")
	var hanging_at := street_src.find("static func build_hanging_sign")
	_check(hanging_at > 0, "storefront sign builder exists")
	if hanging_at > 0:
		var facades := street_src.substr(0, hanging_at)
		_check(not facades.contains("_stamp_text"), "south facades have no painted names")
	var env_src := FileAccess.get_file_as_string("res://scripts/art/environment_frames.gd")
	var parked_at := env_src.find("static func build_parked_car")
	var hardware_at := env_src.find("static func build_hardware_store")
	_check(hardware_at > 0 and parked_at > hardware_at, "north shop builders exist")
	if hardware_at > 0 and parked_at > hardware_at:
		var north := env_src.substr(hardware_at, parked_at - hardware_at)
		_check(not north.contains("_stamp_text"), "north facades have no painted names")
	for row in TownFacades.oak_storefronts():
		_check(_flavor_ok(str(row.get("flavor", ""))), "%s flavor has no dollar amount" % str(row.get("id", "?")))
	for row in TownFacades.maple_houses():
		_check(_flavor_ok(str(row.get("flavor", ""))), "%s flavor has no dollar amount" % str(row.get("id", "?")))
	var barks := FileAccess.get_file_as_string("res://data/ambient/barks.json")
	_check(_flavor_ok(barks), "ambient barks have no dollar amount")
	var houses := TownFacades.maple_houses()
	_check(houses.size() >= 5 and houses.size() <= 8, "Maple Lane still has 5-8 houses")


func _one_sign_each() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var named := 0
	for row in TownFacades.oak_storefronts():
		var sign_id := str(row.get("sign_id", ""))
		var node_name := str(row.get("node", ""))
		if sign_id.is_empty() or node_name.is_empty():
			continue
		named += 1
		var sign := room.get_node_or_null("Props/%sSign" % node_name) as Sprite2D
		_check(sign != null and sign.texture != null, "%s has one storefront sign" % node_name)
		var extras := 0
		var props := room.get_node_or_null("Props")
		if props != null:
			for child in props.get_children():
				if child.name.begins_with(node_name) and str(child.name).contains("Sign") and child != sign:
					extras += 1
		_check(extras == 0, "%s has no extra sign nodes" % node_name)
	_check(named >= 10, "both sides of Oak Street keep storefront signs (%d)" % named)
	var group_signs := 0
	var tree := get_tree()
	if tree != null:
		for node in tree.get_nodes_in_group("shop_sign"):
			if room.is_ancestor_of(node):
				group_signs += 1
	_check(group_signs == named, "shop_sign group matches storefronts with names (%d/%d)" % [group_signs, named])
	room.free()
	await get_tree().process_frame


func _maple_yards() -> void:
	DayClock.set_time(5, 14, 0)
	var room := _instance(LANE)
	if room == null:
		return
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null, "Maple Lane has a Ground layer")
	_check(room.get_node_or_null("Props/Garden") != null, "the community garden is still on the lane")
	_check(room.get_node_or_null("Props/ToOak") != null, "the Oak Street door is still on the lane")
	_check(room.get_node_or_null("Props/SaleSign") != null, "the vacant lot has a for-sale sign")
	_check(room.get_node_or_null("Props/HouseWhitaker") != null, "a seventh house stands on Maple Lane")
	if ground != null:
		var filled := _yard_fill_count(ground)
		var largest := _largest_grass_area(ground)
		_check(filled >= MIN_YARD_FILL, "Maple yard fill is at least %d cells (saw %d)" % [MIN_YARD_FILL, filled])
		_check(largest <= MAX_GRASS_RECT, "largest empty Maple grass rectangle is at most %d (saw %d)" % [MAX_GRASS_RECT, largest])
	for row in TownFacades.maple_houses():
		var node_name := str(row.get("node", ""))
		var door := room.get_node_or_null("Props/%sDoor" % node_name) as BuildingDoor
		_check(door != null, "%s still has a door" % node_name)
		if door != null:
			_check(_door_on_walk(room, door), "%s door still meets a front walk or sidewalk" % node_name)
	for point in MAPLE_WAYPOINTS:
		_check(_walkable(room, point), "Maple waypoint %s stays walkable" % point)
	var tree := get_tree()
	if tree != null:
		for node in tree.get_nodes_in_group("maple_yard_prop"):
			if not room.is_ancestor_of(node) or not (node is Node2D):
				continue
			var prop := node as Node2D
			_check(not _on_street(room, prop.position), "%s is off the sidewalk and road" % prop.name)
			_check(not _blocks_protected(room, prop), "%s does not cover a door, walk, or waypoint" % prop.name)
			_check(_has_collision(room, prop), "%s has a matching collision" % prop.name)
	room.free()
	await get_tree().process_frame


func _evening_life() -> void:
	for spec in [
		{"hour": 18, "phase": TimeOfDay.Phase.EVENING, "label": "evening"},
		{"hour": 21, "phase": TimeOfDay.Phase.NIGHT, "label": "night"},
	]:
		var hour := int(spec.get("hour", 18))
		var label := str(spec.get("label", "evening"))
		DayClock.set_time(4, hour, 0)
		var street := _instance(STREET)
		if street == null:
			return
		var lane := _instance(LANE)
		if lane == null:
			street.free()
			return
		var lighting := street.get_node_or_null("Lighting")
		if lighting != null and lighting.has_method("apply"):
			lighting.call("apply")
		lighting = lane.get_node_or_null("Lighting")
		if lighting != null and lighting.has_method("apply"):
			lighting.call("apply")
		var people: Array[Node2D] = []
		_collect_ambient(street, people)
		_collect_ambient(lane, people)
		_check(people.size() >= 2, "%s places at least 2 ambient NPCs across Oak and Maple (saw %d)" % [label, people.size()])
		for person in people:
			var host := street if street.is_ancestor_of(person) else lane
			_check(_walkable(host, person.position), "%s %s stands on walkable ground" % [label, person.name])
		var window := street.get_node_or_null("Lighting/DinerWindow") as PointLight2D
		if window == null:
			window = street.get_node_or_null("Lighting/PharmacyWindow") as PointLight2D
		_check(window != null and window.energy > 0.0, "%s lights a storefront window" % label)
		var house_window := lane.get_node_or_null("Lighting/HouseMargaretWindow") as PointLight2D
		_check(house_window != null and house_window.energy > 0.0, "%s lights a Maple house window" % label)
		street.free()
		lane.free()
		await get_tree().process_frame


func _collect_ambient(room: Node, people: Array[Node2D]) -> void:
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("ambient_townsfolk"):
		if node is Node2D and room.is_ancestor_of(node) and (node as CanvasItem).visible:
			people.append(node as Node2D)


func _yard_fill_count(layer: TileMapLayer) -> int:
	var filled := 0
	for y in 50:
		for x in 46:
			if x >= 19 and x <= 26:
				continue
			var atlas := layer.get_cell_atlas_coords(Vector2i(x, y))
			if atlas == TownTiles.GRASS_A or atlas == TownTiles.GRASS_B or atlas == TownTiles.GRASS_C:
				continue
			filled += 1
	return filled


func _largest_grass_area(layer: TileMapLayer) -> int:
	var heights: Array[int] = []
	heights.resize(46)
	var best := 0
	for y in 50:
		for x in 46:
			if x >= 19 and x <= 26:
				heights[x] = 0
				continue
			var atlas := layer.get_cell_atlas_coords(Vector2i(x, y))
			if atlas == TownTiles.GRASS_A or atlas == TownTiles.GRASS_B or atlas == TownTiles.GRASS_C:
				heights[x] += 1
			else:
				heights[x] = 0
		best = maxi(best, _histogram_area(heights))
	return best


func _histogram_area(heights: Array[int]) -> int:
	var stack: Array[int] = []
	var best := 0
	var i := 0
	while i <= heights.size():
		var current := 0 if i == heights.size() else heights[i]
		if stack.is_empty() or current >= heights[stack[stack.size() - 1]]:
			stack.append(i)
			i += 1
			continue
		var top: int = stack.pop_back()
		var width := i if stack.is_empty() else i - stack[stack.size() - 1] - 1
		best = maxi(best, heights[top] * width)
	return best


func _on_street(room: Node, pos: Vector2) -> bool:
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if ground == null:
		return true
	var cell := Vector2i(int(pos.x / TILE), int(pos.y / TILE))
	var atlas := ground.get_cell_atlas_coords(cell)
	return TownTiles.is_sidewalk(atlas) or TownTiles.is_road(atlas)


func _blocks_protected(room: Node, prop: Node2D) -> bool:
	var block := _prop_block(prop)
	for row in TownFacades.maple_houses():
		var door := room.get_node_or_null("Props/%sDoor" % str(row.get("node", ""))) as Node2D
		if door != null and block.grow(8.0).has_point(door.global_position):
			return true
	var oak := room.get_node_or_null("Props/ToOak") as Node2D
	if oak != null and block.grow(8.0).has_point(oak.global_position):
		return true
	for point in MAPLE_WAYPOINTS:
		if block.grow(12.0).has_point(point):
			return true
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if ground != null:
		var cell := Vector2i(int(prop.position.x / TILE), int(prop.position.y / TILE))
		var atlas := ground.get_cell_atlas_coords(cell)
		if atlas == TownTiles.PATH and cell.x >= 8 and cell.x <= 34:
			var on_front := false
			for row in TownFacades.maple_houses():
				var door_y := int(float(row.get("y", 0.0)) / float(TILE))
				if cell.y == door_y:
					on_front = true
			if on_front:
				return true
	return false


func _prop_block(prop: Node2D) -> Rect2:
	var size := Vector2(16, 10)
	var raw: Variant = prop.get("block_size")
	if raw is Vector2:
		size = raw
	var offset := Vector2(0, -4)
	var off_raw: Variant = prop.get("block_offset")
	if off_raw is Vector2:
		offset = off_raw
	return Rect2(prop.global_position + offset - size * 0.5, size)


func _has_collision(room: Node, prop: Node2D) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	var feet := _prop_block(prop)
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet.grow(2.0)):
			return true
	return false


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
	print("M11B_OK" if not _failed else "M11B_FAIL")
	get_tree().quit(0 if not _failed else 1)
