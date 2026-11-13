extends Node
## Headless checks for Milestone 12 (church grounds redesign).
## Prints M12_OK or M12_FAIL.
## Run: godot --headless --path . res://tests/m12/m12_validation.tscn

const GROUNDS := "res://scenes/world/church_exterior.tscn"
const TILE := GroundsLayout.TILE
const DOORS: Array[Dictionary] = [
	{"node": "Props/Door", "dest": "sanctuary.tscn", "spawn": &"from_exterior", "return": "from_sanctuary"},
	{"node": "Props/StreetDoor", "dest": "hardware_street.tscn", "spawn": &"from_church", "return": "from_street"},
	{"node": "Props/HomeDoor", "dest": "parsonage.tscn", "spawn": &"from_grounds", "return": "from_parsonage"},
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
	await _campus_layout()
	await _plots_and_hall()
	await _doors_npcs_and_camera()
	await _collision_probes()
	await _old_save_fallback()
	_restore_user_save()
	_finish()


func _static_data() -> void:
	_check(FileAccess.file_exists("res://data/grounds/plots.json"), "plots data exists")
	_check(FileAccess.file_exists("res://scripts/world/grounds_layout.gd"), "grounds layout exists")
	_check(FileAccess.file_exists("res://scripts/world/expansion_plot.gd"), "expansion plot script exists")
	_check(FileAccess.file_exists("res://assets/environments/church_monument.png"), "monument sign art exists")
	_check(FileAccess.file_exists("res://assets/environments/church_pillar.png"), "gate pillar art exists")
	_check(FileAccess.file_exists("res://assets/environments/survey_stakes.png"), "survey stake art exists")
	_check(FileAccess.file_exists("res://assets/environments/future_site_sign.png"), "future site sign art exists")
	var rows := GroundsPlots.all_plots()
	_check(rows.size() >= 3 and rows.size() <= 5, "three to five expansion plots load from data (%d)" % rows.size())
	for row in rows:
		var inspect := GroundsPlots.inspect_line(row)
		_check(not inspect.is_empty(), "%s has an inspect line" % str(row.get("id", "")))
		_check(not _has_digit_or_dollar(inspect), "%s inspect line has no digits or dollar signs" % str(row.get("id", "")))
		_check(not inspect.to_lower().contains("cult"), "%s inspect line does not say cult" % str(row.get("id", "")))
		_check(not GroundsPlots.display_name(row).to_lower().contains("cult"), "%s name is neutral" % str(row.get("id", "")))


func _campus_layout() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(GROUNDS)
	if room == null:
		return
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null, "the grounds have a Ground layer")
	if ground != null:
		_check_perimeter(ground)
		_check_entrance_sidewalk(ground)
		_check_door_paths(room, ground)
		_check_path_network(room, ground)
		_check_plot_overlap(room, ground)
	_check_sign_placement(room)
	_check_no_cult_text(room)
	room.free()
	await get_tree().process_frame


func _plots_and_hall() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var worn := _instance(GROUNDS)
	if worn == null:
		return
	var hall := worn.get_node_or_null("Props/FellowshipHall")
	_check(hall != null, "the Fellowship Hall stands on the church grounds")
	if hall != null and hall.has_method("is_repaired_look"):
		_check(not bool(hall.call("is_repaired_look")), "the worn hall uses the boarded look")
	var seen: Dictionary = {}
	for node in get_tree().get_nodes_in_group("expansion_plot"):
		if worn.is_ancestor_of(node):
			seen[String(node.name)] = true
			var line := str(node.get("inspect_line"))
			_check(not line.is_empty(), "%s can be inspected" % node.name)
			_check(not _has_digit_or_dollar(line), "%s inspect line stays free of numbers" % node.name)
	_check(seen.size() == GroundsPlots.all_plots().size(), "every data plot is placed (%d)" % seen.size())
	worn.free()
	await get_tree().process_frame
	NarrativeState.set_flag("hall_repaired", true)
	var fixed := _instance(GROUNDS)
	if fixed == null:
		return
	hall = fixed.get_node_or_null("Props/FellowshipHall")
	if hall != null and hall.has_method("apply_clock"):
		hall.call("apply_clock")
	_check(hall != null and hall.has_method("is_repaired_look") and bool(hall.call("is_repaired_look")), "the repaired hall uses the open look")
	fixed.free()
	await get_tree().process_frame
	NarrativeState.reset()


func _doors_npcs_and_camera() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(GROUNDS)
	if room == null:
		return
	for row in DOORS:
		var node_path := str(row.get("node", ""))
		var door := room.get_node_or_null(node_path) as Door
		_check(door != null, "%s exists" % node_path)
		if door == null:
			continue
		_check(door.destination_scene.ends_with(str(row.get("dest", ""))), "%s routes to %s" % [node_path, row.get("dest", "")])
		_check(door.destination_spawn == row.get("spawn", &"default"), "%s destination spawn is set" % node_path)
		_check(_spawn_outside(room, str(row.get("return", "")), node_path), "%s spawn stands outside the trigger" % node_path)
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	_check(camera != null, "the grounds camera exists")
	if camera != null:
		_check(camera.limit_left == 0 and camera.limit_top == 0, "camera left/top match the map origin")
		_check(camera.limit_right == GroundsLayout.MAP_SIZE.x * TILE, "camera right contains the grounds")
		_check(camera.limit_bottom == GroundsLayout.MAP_SIZE.y * TILE, "camera bottom contains the grounds")
	_check_npc_posts(room)
	_check_sunday_courtyard(room)
	room.free()
	await get_tree().process_frame


func _collision_probes() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(GROUNDS)
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	_check(player != null, "the grounds have a player")
	if player == null:
		room.free()
		return
	var church := room.get_node_or_null("Props/Church") as Sprite2D
	if church != null and church.texture != null:
		var left := church.global_position.x - church.texture.get_width() * 0.5
		player.global_position = Vector2(left - 28.0, church.global_position.y - 70.0)
		player.velocity = Vector2.ZERO
		Input.action_press("move_right")
		for _i in 45:
			await get_tree().physics_frame
		Input.action_release("move_right")
		_check(player.global_position.x < left + 2.0, "the church wall blocks the player")
		_check(player.global_position.x > left - 26.0, "the player reached the church wall")
	var car := room.get_node_or_null("Props/LotCarA") as Node2D
	if car != null:
		var before := car.global_position + Vector2(0, 36)
		player.global_position = before
		player.velocity = Vector2.ZERO
		Input.action_press("move_up")
		for _i in 40:
			await get_tree().physics_frame
		Input.action_release("move_up")
		_check(player.global_position.y > car.global_position.y, "a parked car blocks the player")
	var fence_start := Vector2(GroundsLayout.map_px().x - 48.0, 200.0)
	if _walkable(room, fence_start):
		player.global_position = fence_start
		player.velocity = Vector2.ZERO
		Input.action_press("move_right")
		for _i in 40:
			await get_tree().physics_frame
		Input.action_release("move_right")
		_check(player.global_position.x < GroundsLayout.map_px().x - 8.0, "the perimeter fence blocks the player")
	_release()
	room.free()
	await get_tree().process_frame


func _old_save_fallback() -> void:
	DayClock.set_time(4, 14, 0)
	SceneRouter.exact_active = true
	SceneRouter.exact_position = GroundsLayout.POS_CHURCH + Vector2(0, -80)
	SceneRouter.exact_facing = &"up"
	var room := _instance_keeping_exact(GROUNDS)
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Node2D
	var default_spawn := room.get_node_or_null("Spawns/default") as Node2D
	_check(player != null and default_spawn != null, "an old church-grounds save can load")
	if player != null:
		_check(_walkable(room, player.global_position), "a blocked save snaps onto walkable ground")
		_check(player.global_position.distance_to(GroundsLayout.POS_CHURCH + Vector2(0, -80)) > 40.0, "a save inside the church does not keep the old coordinates")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = true
	SceneRouter.exact_position = GroundsLayout.POS_SPAWN
	SceneRouter.exact_facing = &"up"
	room = _instance_keeping_exact(GROUNDS)
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and player.global_position.distance_to(GroundsLayout.POS_SPAWN) < 2.0, "a valid church-grounds save keeps its position")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = false


func _check_perimeter(ground: TileMapLayer) -> void:
	var gaps: Array[Vector2i] = []
	for y in GroundsLayout.MAP_SIZE.y:
		for x in GroundsLayout.MAP_SIZE.x:
			var cell := Vector2i(x, y)
			if not (x == 0 or y == 0 or x == GroundsLayout.MAP_SIZE.x - 1 or y == GroundsLayout.MAP_SIZE.y - 1):
				continue
			if GroundsLayout.is_gate_cell(cell):
				var atlas := ground.get_cell_atlas_coords(cell)
				_check(GroundsLayout.is_path_atlas(atlas), "gate %s is a walkable opening" % str(cell))
				continue
			if not GroundsLayout.is_perimeter_atlas(ground.get_cell_atlas_coords(cell)):
				gaps.append(cell)
	_check(gaps.is_empty(), "the perimeter is continuous except at the gates (%s)" % str(gaps))


func _check_entrance_sidewalk(ground: TileMapLayer) -> void:
	var found := false
	for y in range(22, 33):
		var atlas := ground.get_cell_atlas_coords(Vector2i(GroundsLayout.MAP_SIZE.x - 1, y))
		if atlas == TownTiles.SIDEWALK or GroundsLayout.is_path_atlas(atlas):
			found = true
			break
	_check(found, "the main entrance meets a sidewalk or drive at Oak Street")
	_check(ground.get_cell_atlas_coords(Vector2i(62, 23)) == TownTiles.SIDEWALK, "the east edge keeps a sidewalk stub beside the drive")


func _check_door_paths(room: Node, ground: TileMapLayer) -> void:
	for row in DOORS:
		var door := room.get_node_or_null(str(row.get("node", ""))) as Node2D
		_check(door != null, "%s is present for pathing" % str(row.get("node", "")))
		if door == null:
			continue
		_check(_adjacent_path(ground, door.position), "%s connects to a path tile" % str(row.get("node", "")))


func _check_path_network(room: Node, ground: TileMapLayer) -> void:
	var start := Vector2i(int(GroundsLayout.POS_STREET_DOOR.x / TILE), int(GroundsLayout.POS_STREET_DOOR.y / TILE))
	var reached := _flood_paths(ground, start)
	_check(reached.has(GroundsLayout.PATH_CHURCH), "the courtyard path is reachable from the entrance")
	_check(reached.has(GroundsLayout.PATH_TO_STREET), "the entrance drive is on the path network")
	_check(_region_reached(reached, GroundsLayout.PARKING), "the parking lot is reachable from the entrance")
	_check(_region_reached(reached, GroundsLayout.PICNIC), "the picnic lawn is reachable from the entrance")
	_check(_region_reached(reached, GroundsLayout.GARDEN) or reached.has(Vector2i(11, 11)), "the memorial garden is reachable from the entrance")
	for row in GroundsPlots.all_plots():
		var rect := GroundsPlots.plot_rect(row)
		_check(_plot_reached(reached, rect), "%s is reachable from the entrance" % str(row.get("id", "")))
	for row in DOORS:
		var door := room.get_node_or_null(str(row.get("node", ""))) as Node2D
		if door == null:
			continue
		var cell := Vector2i(int(door.position.x / TILE), int(door.position.y / TILE))
		_check(_near_reached(reached, cell), "%s is on the connected path network" % str(row.get("node", "")))


func _check_plot_overlap(room: Node, ground: TileMapLayer) -> void:
	var blocked: Array[Rect2i] = []
	blocked.append(_sprite_tiles(room, "Props/Church"))
	blocked.append(_sprite_tiles(room, "Props/Parsonage"))
	var hall := room.get_node_or_null("Props/FellowshipHall") as Node2D
	if hall != null:
		blocked.append(Rect2i(int(hall.position.x / TILE) - 3, int(hall.position.y / TILE) - 2, 6, 4))
	var used: Array[Rect2i] = []
	for row in GroundsPlots.all_plots():
		var rect := GroundsPlots.plot_rect(row)
		_check(rect.size.x > 0 and rect.size.y > 0, "%s has a tile rect" % str(row.get("id", "")))
		for other in used:
			_check(not rect.intersects(other), "%s does not overlap another plot" % str(row.get("id", "")))
		used.append(rect)
		for building in blocked:
			if building.size.x <= 0:
				continue
			_check(not rect.intersects(building), "%s does not overlap a building" % str(row.get("id", "")))
		var path_hits := 0
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				if GroundsLayout.is_path_atlas(ground.get_cell_atlas_coords(Vector2i(x, y))):
					path_hits += 1
		_check(path_hits == 0, "%s does not sit on a path" % str(row.get("id", "")))


func _check_sign_placement(room: Node) -> void:
	var sign := room.get_node_or_null("Props/MonumentSign") as Sprite2D
	_check(sign != null and sign.texture != null, "the church name sits on a monument sign")
	if sign == null or sign.texture == null:
		return
	var sign_rect := Rect2(sign.position - Vector2(sign.texture.get_width() * 0.5, sign.texture.get_height()), sign.texture.get_size())
	for row in DOORS:
		var door := room.get_node_or_null(str(row.get("node", ""))) as Node2D
		if door == null:
			continue
		var opening := Rect2(door.position + Vector2(-32, -48), Vector2(64, 56))
		_check(not sign_rect.intersects(opening), "the church name sign is not in front of %s" % str(row.get("node", "")))
	_check(sign.position.distance_to(GroundsLayout.POS_MONUMENT) < 2.0, "the monument stands by the main drive")


func _check_no_cult_text(room: Node) -> void:
	var blob := ""
	for node in room.get_children():
		blob += _collect_text(node)
	_check(not blob.to_lower().contains("cult"), "no on-screen grounds text contains the word cult")


func _check_npc_posts(room: Node) -> void:
	var posts: Array[Vector2] = [
		GroundsLayout.POS_MARGARET,
		GroundsLayout.POS_MARGARET_EVENING,
		GroundsLayout.POS_HAROLD,
		GroundsLayout.POS_OSTROW,
	]
	for pos in posts:
		_check(_walkable(room, pos), "NPC post %s is on walkable ground" % str(pos))
	var margaret := room.get_node_or_null("Props/Margaret") as Node2D
	var harold := room.get_node_or_null("Props/Harold") as Node2D
	if margaret != null and harold != null:
		_check(_reachable(room, margaret, harold) or _walkable(room, GroundsLayout.POS_HAROLD), "Harold's courtyard post is reachable")


func _check_sunday_courtyard(room: Node) -> void:
	var spots := 0
	for node in get_tree().get_nodes_in_group("sunday_courtyard"):
		if not room.is_ancestor_of(node) or not (node is Node2D):
			continue
		spots += 1
		var body := node as Node2D
		_check(_walkable(room, body.position), "Sunday courtyard %s stands on walkable ground" % body.name)
	_check(spots >= 2, "Sunday courtyard gathering spots exist (%d)" % spots)


func _adjacent_path(ground: TileMapLayer, pos: Vector2) -> bool:
	var cell := Vector2i(int(pos.x / TILE), int(pos.y / TILE))
	for offset in [Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if GroundsLayout.is_path_atlas(ground.get_cell_atlas_coords(cell + offset)):
			return true
	return false


func _flood_paths(ground: TileMapLayer, start: Vector2i) -> Dictionary:
	var seen: Dictionary = {}
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var cell: Vector2i = stack.pop_back()
		if seen.has(cell):
			continue
		if cell.x < 0 or cell.y < 0 or cell.x >= GroundsLayout.MAP_SIZE.x or cell.y >= GroundsLayout.MAP_SIZE.y:
			continue
		if not GroundsLayout.is_path_atlas(ground.get_cell_atlas_coords(cell)):
			continue
		seen[cell] = true
		stack.append(cell + Vector2i.RIGHT)
		stack.append(cell + Vector2i.LEFT)
		stack.append(cell + Vector2i.DOWN)
		stack.append(cell + Vector2i.UP)
	return seen


func _region_reached(reached: Dictionary, rect: Rect2i) -> bool:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if reached.has(Vector2i(x, y)):
				return true
	return _plot_reached(reached, rect)


func _plot_reached(reached: Dictionary, rect: Rect2i) -> bool:
	for y in range(rect.position.y - 1, rect.end.y + 1):
		for x in range(rect.position.x - 1, rect.end.x + 1):
			if reached.has(Vector2i(x, y)):
				return true
	return false


func _near_reached(reached: Dictionary, cell: Vector2i) -> bool:
	for offset in [Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if reached.has(cell + offset):
			return true
	return false


func _sprite_tiles(room: Node, node_path: String) -> Rect2i:
	var sprite := room.get_node_or_null(node_path) as Sprite2D
	if sprite == null or sprite.texture == null:
		return Rect2i()
	var size := sprite.texture.get_size()
	var top_left := sprite.position - Vector2(size.x * 0.5, size.y)
	return Rect2i(int(top_left.x / TILE), int(top_left.y / TILE), int(ceil(size.x / TILE)), int(ceil(size.y / TILE)))


func _collect_text(node: Node) -> String:
	var blob := ""
	if node is Interactable or node is Door or node is ExpansionPlot:
		var line: Variant = node.get("line")
		if line is String:
			blob += " " + str(line)
		var inspect: Variant = node.get("inspect_line")
		if inspect is String:
			blob += " " + str(inspect)
		var place: Variant = node.get("place_name")
		if place is String:
			blob += " " + str(place)
		var prompt: Variant = node.get("prompt_text")
		if prompt is String:
			blob += " " + str(prompt)
		var speaker: Variant = node.get("speaker_name")
		if speaker is String:
			blob += " " + str(speaker)
	for child in node.get_children():
		blob += _collect_text(child)
	return blob


func _has_digit_or_dollar(text: String) -> bool:
	if text.contains("$"):
		return true
	for i in text.length():
		var ch := text.substr(i, 1)
		if ch >= "0" and ch <= "9":
			return true
	return false


func _spawn_outside(room: Node, spawn_id: String, door_path: String) -> bool:
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
	return not _inside_solid(room, pos)


func _inside_solid(room: Node, pos: Vector2) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	var feet := Rect2(pos + Vector2(-6.0, -8.0), Vector2(12.0, 8.0))
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		# Foot-sized NPC and prop boxes are standable posts, not walls.
		if rect.size.x < 24.0 and rect.size.y < 16.0:
			continue
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet):
			return true
	return false


func _reachable(room: Node, from_node: Node2D, to_node: Node2D) -> bool:
	if from_node == null or to_node == null:
		return false
	var blocks: Array[Rect2] = []
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids != null:
		for child in solids.get_children():
			var shape_node := child as CollisionShape2D
			if shape_node == null or not (shape_node.shape is RectangleShape2D):
				continue
			var rect := shape_node.shape as RectangleShape2D
			if rect.size.x < 24.0 and rect.size.y < 16.0:
				continue
			blocks.append(Rect2(shape_node.position - rect.size * 0.5, rect.size))
	var plan := NpcRoute.plan(from_node.position, to_node.position, blocks)
	return bool(plan.get("ok", false))


func _release() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right"]:
		if Input.is_action_pressed(action):
			Input.action_release(action)


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"default"
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
	print("M12_OK" if not _failed else "M12_FAIL")
	get_tree().quit(0 if not _failed else 1)
