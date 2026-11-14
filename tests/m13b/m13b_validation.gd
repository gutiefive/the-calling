extends Node
## Headless checks for Milestone 13B (furniture and clutter density).
## Prints M13B_OK or M13B_FAIL.
## Run: godot --headless --path . res://tests/m13b/m13b_validation.tscn

const SANCT := "res://scenes/world/sanctuary.tscn"
const HALL := "res://scenes/world/fellowship_hall.tscn"
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
	_art_and_layout()
	await _sanctuary_density()
	await _fellowship_density()
	await _clearance_and_seating()
	await _potluck_and_save()
	_restore_user_save()
	_finish()


func _art_and_layout() -> void:
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")
	_check(InteriorArt.atlas() != null, "interior atlas draws")
	for frame_id in PackedStringArray(["pew", "altar", "plant", "baptism_font", "sound_desk", "armchair", "prayer_board", "robe_rack", "vacuum", "stage", "island", "cubbies"]):
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 12 and image.get_height() >= 12, "clutter art %s is drawn" % frame_id)
	for frame_id in InteriorLayout.clutter_frame_ids():
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 8 and image.get_height() >= 8, "listed clutter %s is drawn" % frame_id)
	_check(InteriorLayout.pew_rows().size() >= 5, "worship has extra pew rows")
	_check(InteriorLayout.HALL_MAIN.size.y <= 16, "the fellowship main hall is right-sized")
	_check(InteriorLayout.contains_cell(InteriorLayout.SANCT_WORSHIP, InteriorLayout.SANCTUARY_AISLE_CELL), "the aisle cell is in the worship hall")


func _sanctuary_density() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(3)
	_check_density(room, InteriorLayout.sanctuary_rooms(), true)
	_check_reachable(room, InteriorLayout.sanctuary_probes(), "sanctuary")
	_check_cells_clear(room, InteriorLayout.sanctuary_doorways(), "sanctuary doorway")
	_check_cells_clear(room, InteriorLayout.sanctuary_aisle_cells(), "sanctuary aisle")
	var spawn := room.get_node_or_null("Spawns/from_exterior") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the sanctuary spawn is not inside collision")
	for spot in InteriorLayout.sanctuary_clear_spots():
		_check(_walkable(room, spot), "sanctuary clear spot %s stays open" % str(spot))
	for node_name in InteriorLayout.sanctuary_interactables():
		var prop := room.get_node_or_null("Props/%s" % node_name) as Node2D
		_check(prop != null, "sanctuary interactable %s exists" % node_name)
		if spawn != null and prop != null:
			_check(_tile_reachable(room, spawn.global_position, prop.global_position + Vector2(0, 24)), "sanctuary %s is reachable" % node_name)
	var ledger := room.get_node_or_null("Props/Ledger") as Node2D
	if spawn != null and ledger != null:
		_check(_tile_reachable(room, spawn.global_position, ledger.global_position + Vector2(0, 26)), "the office ledger is reachable")
	var keys := room.get_node_or_null("Props/KeyRing") as Node2D
	if spawn != null and keys != null:
		_check(_tile_reachable(room, spawn.global_position, keys.global_position + Vector2(0, 26)), "the key ring is reachable")
	_check(room.get_node_or_null("Lighting/AisleStain1Light") != null, "stained color reaches the aisle")
	_check(room.get_node_or_null("Lighting/WorshipSconceW1") != null, "worship sconces add warm pools")
	_check_ambients_clear(room, InteriorLayout.sanctuary_doorways(), "sanctuary")
	room.free()
	await _pump(1)


func _fellowship_density() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(3)
	_check_density(room, InteriorLayout.hall_rooms(), false)
	_check_reachable(room, InteriorLayout.hall_probes(), "hall")
	_check_cells_clear(room, InteriorLayout.hall_doorways(), "hall doorway")
	var spawn := room.get_node_or_null("Spawns/from_grounds") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the hall spawn is not inside collision")
	for spot in InteriorLayout.hall_clear_spots():
		_check(_walkable(room, spot), "hall clear spot %s stays open" % str(spot))
	for node_name in InteriorLayout.hall_interactables():
		var prop := room.get_node_or_null("Props/%s" % node_name) as Node2D
		_check(prop != null, "hall interactable %s exists" % node_name)
		if spawn != null and prop != null:
			_check(_tile_reachable(room, spawn.global_position, prop.global_position + Vector2(0, 24)), "hall %s is reachable" % node_name)
	_check(room.get_node_or_null("Props/TableA") != null, "potluck tables are in the hall")
	_check(room.get_node_or_null("Props/Stage") != null, "the main hall has a stage")
	_check(room.get_node_or_null("Props/KitchenIsland") != null, "the kitchen has an island")
	_check_ambients_clear(room, InteriorLayout.hall_doorways(), "hall")
	room.free()
	await _pump(1)


func _clearance_and_seating() -> void:
	var seats: Dictionary = InteriorLayout.sunday_seats()
	var pew_ys: Array[float] = InteriorLayout.sunday_pew_rows()
	_check(seats.size() == 5, "five named Sunday seats")
	_check(InteriorLayout.sunday_crowd().size() == 12, "twelve congregant seats")
	for npc_id in seats.keys():
		var pos: Vector2 = seats[npc_id]
		_check(_is_pew_row(pos.y, pew_ys), "Sunday seat %s sits on a pew row" % str(npc_id))
		_check(pos.x < 704.0 or pos.x > 768.0, "Sunday seat %s is not in the aisle" % str(npc_id))
	for pos in InteriorLayout.sunday_crowd():
		_check(_is_pew_row(pos.y, pew_ys), "a congregant seat sits on a pew row")
		_check(pos.x < 704.0 or pos.x > 768.0, "a congregant seat is not in the aisle")
	DayClock.set_time(0, 10, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(10)
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	_check(box != null and box.is_conversation_open(), "Sunday service still starts at 10:00")
	var crowd := 0
	for node in get_tree().get_nodes_in_group("congregant"):
		if room.is_ancestor_of(node) and node is CanvasItem and (node as CanvasItem).visible:
			crowd += 1
	_check(crowd == 12, "twelve unnamed congregants still sit (%d)" % crowd)
	room.free()
	await _pump(1)


func _potluck_and_save() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(10, 12, 0)
	var empty := _instance(HALL)
	if empty == null:
		return
	await _pump(3)
	var modest := empty.get_node_or_null("Props/TableA") as Sprite2D
	_check(modest != null and modest.visible, "a modest table is out with no prep")
	var modest_tex: Texture2D = modest.texture if modest != null else null
	_check(not _node_visible(empty, "CenterA"), "centerpieces stay off with no flowers")
	_check(not _node_visible(empty, "Lights"), "string lights stay off with no grounds work")
	_check(not _node_visible(empty, "ExtraChairs"), "extra chairs stay off with no repair")
	empty.free()
	await _pump(1)
	_full_prep()
	DayClock.set_time(10, 12, 0)
	var full := _instance(HALL)
	if full == null:
		return
	await _pump(3)
	_check(_node_visible(full, "CenterA"), "flower centerpieces appear")
	_check(_node_visible(full, "Lights"), "string lights appear when the grounds are tended")
	_check(_node_visible(full, "ExtraChairs"), "extra chairs appear after the picnic bed")
	var table := full.get_node_or_null("Props/TableA") as Sprite2D
	if modest_tex != null and table != null and table.texture != null:
		_check(modest_tex != table.texture, "full prep uses a different table than no prep")
	var dishes := full.get_node_or_null("Props/DishesA") as Sprite2D
	_check(dishes != null and dishes.visible, "varied dishes appear with vegetables")
	full.free()
	await _pump(1)
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(2)
	var player := room.get_node_or_null("Props/Player") as Node2D
	if player != null:
		player.global_position = InteriorLayout.POS_SANCT_SPAWN
	_check(SaveGame.save_to_disk(get_tree()), "the sanctuary can be saved")
	_check(SaveGame.SAVE_VERSION == 11, "the slot is still version 11")
	var saved := SaveGame.read_file()
	_check(int(saved.get("version", 0)) == 11, "the file on disk is version 11")
	room.free()
	await _pump(1)
	_check(SaveGame.apply_state(saved), "the sanctuary save applies")
	var inf := get_node_or_null("/root/InfluenceState")
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == 0, "density furniture does not raise Pull")


func _check_density(room: Node, rooms: Dictionary, sanctuary: bool) -> void:
	var mins: Dictionary = InteriorLayout.min_prop_counts()
	var max_bare: Dictionary = InteriorLayout.max_bare_ratios()
	var props := _props_in(room)
	for room_id in rooms.keys():
		var key := str(room_id)
		if not sanctuary and key == "storage":
			key = "hall_storage"
		if not sanctuary and key == "hallway":
			key = "hall_hallway"
		var rect: Rect2i = rooms[room_id]
		var count := _count_in_rect(props, rect)
		var need := int(mins.get(key, 8))
		_check(count >= need, "%s has %d decorative props (need %d)" % [key, count, need])
		var bare := _bare_ratio(room, rect, props)
		var limit := float(max_bare.get(key, 0.7))
		_check(bare <= limit, "%s bare-floor ratio %.2f (max %.2f)" % [key, bare, limit])


func _check_reachable(room: Node, probes: Dictionary, place: String) -> void:
	var spawn := room.get_node_or_null("Spawns/from_exterior") as Node2D
	if spawn == null:
		spawn = room.get_node_or_null("Spawns/from_grounds") as Node2D
	if spawn == null:
		spawn = room.get_node_or_null("Spawns/default") as Node2D
	for room_id in probes.keys():
		var pos: Vector2 = probes[room_id]
		_check(_walkable(room, pos), "%s %s probe is walkable" % [place, str(room_id)])
		if spawn != null:
			_check(_tile_reachable(room, spawn.global_position, pos), "%s %s is reachable from the entrance" % [place, str(room_id)])


func _check_cells_clear(room: Node, cells: Array[Vector2i], label: String) -> void:
	for cell in cells:
		var pos := InteriorLayout.tile_center(cell)
		_check(not _blocked_by_furniture(room, pos), "%s %s stays clear" % [label, str(cell)])


func _check_ambients_clear(room: Node, doors: Array[Vector2i], place: String) -> void:
	for node in get_tree().get_nodes_in_group("ambient_townsfolk"):
		if not (node is Node2D) or not room.is_ancestor_of(node):
			continue
		var body := node as Node2D
		if not body.visible:
			continue
		var cell := InteriorLayout.world_to_cell(body.position)
		_check(not InteriorLayout.is_listed(cell, doors), "%s ambient %s is not in a doorway" % [place, body.name])
		_check(_walkable(room, body.position), "%s ambient %s is not inside furniture" % [place, body.name])


func _props_in(room: Node) -> Array[Node2D]:
	var found: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("interior_prop"):
		if node is Node2D and room.is_ancestor_of(node):
			found.append(node as Node2D)
	if found.is_empty():
		var props := room.get_node_or_null("Props")
		if props != null:
			for child in props.get_children():
				if child is Sprite2D or child is SolidProp or child is SpeechProp:
					if str(child.name) == "Player":
						continue
					found.append(child as Node2D)
	return found


func _count_in_rect(props: Array[Node2D], rect: Rect2i) -> int:
	var count := 0
	for prop in props:
		if InteriorLayout.contains_cell(rect, InteriorLayout.world_to_cell(prop.position)):
			count += 1
	return count


func _bare_ratio(room: Node, rect: Rect2i, props: Array[Node2D]) -> float:
	var layer := room.get_node_or_null("Ground") as TileMapLayer
	var floor_n := 0
	var bare_n := 0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if layer != null and layer.get_cell_atlas_coords(Vector2i(x, y)) == InteriorLayout.TILE_WALL:
				continue
			floor_n += 1
			var atlas := Vector2i(-1, -1)
			if layer != null:
				atlas = layer.get_cell_atlas_coords(Vector2i(x, y))
			var furnished := atlas == InteriorLayout.TILE_RUNNER or atlas == InteriorLayout.TILE_CARPET or atlas == InteriorLayout.TILE_STAIN
			if not furnished and not _tile_covered(Vector2i(x, y), props):
				bare_n += 1
	if floor_n == 0:
		return 1.0
	return float(bare_n) / float(floor_n)


func _tile_covered(cell: Vector2i, props: Array[Node2D]) -> bool:
	var tile := Rect2(cell.x * 32.0, cell.y * 32.0, 32.0, 32.0)
	for prop in props:
		var size := Vector2(28, 24)
		if prop is Sprite2D:
			var sprite := prop as Sprite2D
			if sprite.texture != null:
				size = Vector2(float(sprite.texture.get_width()), float(sprite.texture.get_height()))
		var origin := prop.global_position
		var box := Rect2(origin - Vector2(size.x * 0.5, size.y), size)
		box = box.grow(4.0)
		if box.intersects(tile):
			return true
		if origin.distance_to(InteriorLayout.tile_center(cell)) <= InteriorLayout.PROP_COVER_PAD:
			return true
	return false


func _is_pew_row(y: float, rows: Array[float]) -> bool:
	for row in rows:
		if absf(y - row) < 2.0:
			return true
	return false


func _full_prep() -> void:
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	NarrativeState.set_flag("potluck_vegetables", true)
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	NarrativeState.set_flag("grounds_cared_for", true)
	NarrativeState.set_flag("picnic_bed_restored", true)
	var events := _events()
	if events != null:
		events.call("from_dictionary", {
			"framing": "open",
			"invited": ["ostrow", "ruth", "dale"],
			"vegetables": true,
		})


func _node_visible(room: Node, node_name: String) -> bool:
	var node := room.get_node_or_null("Props/%s" % node_name) as CanvasItem
	return node != null and node.visible


func _walkable(room: Node, pos: Vector2) -> bool:
	var world := room as WorldRoom
	if world != null:
		var pad := 10.0
		if pos.x < world.bounds.position.x + pad or pos.y < world.bounds.position.y + pad:
			return false
		if pos.x > world.bounds.end.x - pad or pos.y > world.bounds.end.y - pad:
			return false
	return not _inside_solid(room, pos)


func _blocked_by_furniture(room: Node, pos: Vector2) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	var feet := Rect2(pos + Vector2(-6.0, -8.0), Vector2(12.0, 8.0))
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		if rect.size.x < 16.0 and rect.size.y < 16.0:
			continue
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet):
			return true
	return false


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
		if rect.size.x < 24.0 and rect.size.y < 16.0:
			continue
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet):
			return true
	return false


func _tile_reachable(room: Node, from_pos: Vector2, to_pos: Vector2) -> bool:
	var step := 16
	var start := Vector2i(int(from_pos.x / step), int(from_pos.y / step))
	var goal := Vector2i(int(to_pos.x / step), int(to_pos.y / step))
	if start == goal:
		return true
	var seen: Dictionary = {}
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	var guard := 0
	while not queue.is_empty() and guard < 8000:
		guard += 1
		var cell: Vector2i = queue.pop_front()
		if cell.distance_to(goal) <= 1:
			return true
		for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + offset
			if seen.has(next):
				continue
			var world := Vector2(next.x * step + step * 0.5, next.y * step + step * 0.5)
			if not _walkable(room, world):
				continue
			seen[next] = true
			queue.append(next)
	return seen.has(goal)


func _events() -> Node:
	return get_node_or_null("/root/EventState")


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"default"
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	if room == null:
		return null
	add_child(room)
	return room


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("M13B_OK" if not _failed else "M13B_FAIL")
	tree.quit(0 if not _failed else 1)
