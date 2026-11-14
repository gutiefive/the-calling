extends Node
## Headless checks for Milestone 13E (church interiors gameplay polish).
## Prints M13E_OK or M13E_FAIL.
## Run: godot --headless --path . res://tests/m13e/m13e_validation.tscn

const Catalog := preload("res://scripts/systems/event_catalog.gd")
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
	await _sanctuary_rooms()
	await _ledger_after_sunday()
	await _fellowship_fixes()
	await _walkways_and_reach()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _art_and_layout() -> void:
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")
	_check(InteriorLayout.SANCT_OFFICE.size.y >= InteriorLayout.SANCT_NORTH_MIN_H, "the office is at least seven tiles tall")
	_check(InteriorLayout.SANCT_PRAYER.size.y >= InteriorLayout.SANCT_NORTH_MIN_H, "the prayer room is at least seven tiles tall")
	_check(InteriorLayout.SANCT_CHOIR.size.y >= InteriorLayout.SANCT_NORTH_MIN_H, "the choir room is at least seven tiles tall")
	_check(InteriorLayout.SANCT_STORAGE.size.y >= InteriorLayout.SANCT_NORTH_MIN_H, "storage is at least seven tiles tall")
	_check(InteriorLayout.contains_cell(InteriorLayout.SANCT_WORSHIP, InteriorLayout.SANCTUARY_AISLE_CELL), "the aisle cell stays in the worship hall")
	for frame_id in PackedStringArray([
		"pew", "altar", "pulpit", "stained_glass", "offering_plates", "pendant_light",
		"church_flag", "prayer_box", "baptistry", "choir_riser", "kids_play_rug", "rug_aisle_runner",
	]):
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 8 and image.get_height() >= 8, "polish art %s is drawn" % frame_id)
	var runner: Image = InteriorFrames.build("rug_aisle_runner")
	_check(_runner_is_warm(runner), "the aisle runner is a muted warm color, not the old saturated blue")
	var pew: Image = InteriorFrames.build("pew")
	_check(pew != null and pew.get_width() >= 200 and pew.get_height() >= 32, "pews still read as long benches")
	var altar: Image = InteriorFrames.build("altar")
	_check(altar != null and altar.get_height() >= 40, "the altar has cloth and height")


func _sanctuary_rooms() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(3)
	_check_density(room, InteriorLayout.sanctuary_rooms(), true)
	for node_name in PackedStringArray(["PewL1", "Altar", "Pulpit", "Baptistry", "PendantA", "FlagW"]):
		_check(room.get_node_or_null("Props/%s" % node_name) != null, "worship has %s" % node_name)
	_check(room.get_node_or_null("Lighting/AisleStain1Light") != null, "stained-glass light still reaches the aisle")
	_check(room.get_node_or_null("Lighting/PendantGlowA") != null, "pendant lights add warm pools")
	var spawn := room.get_node_or_null("Spawns/from_exterior") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the sanctuary spawn is not inside furniture")
	for spot in InteriorLayout.sanctuary_clear_spots():
		_check(_walkable(room, spot), "sanctuary clear spot %s stays open" % str(spot))
	for node_name in InteriorLayout.sanctuary_interactables():
		var prop := room.get_node_or_null("Props/%s" % node_name) as Node2D
		_check(prop != null, "sanctuary interactable %s exists" % node_name)
		if spawn != null and prop != null:
			_check(_tile_reachable(room, spawn.global_position, prop.global_position + Vector2(0, 24)), "sanctuary %s is reachable" % node_name)
	var ledger := room.get_node_or_null("Props/Ledger") as Interactable
	_check(ledger != null, "the ledger is still in the office")
	if spawn != null and ledger != null:
		_check(_tile_reachable(room, spawn.global_position, ledger.global_position + Vector2(0, 26)), "the office ledger is reachable")
	_check_cells_clear(room, InteriorLayout.sanctuary_doorways(), "sanctuary doorway")
	_check_cells_clear(room, InteriorLayout.sanctuary_aisle_cells(), "sanctuary aisle")
	for rect in InteriorLayout.sanctuary_walkway_rects():
		_check(rect.size.x >= 2 or rect.size.y >= 2, "sanctuary walkway %s is at least two tiles wide" % str(rect))
		_check(_walkway_clear(room, rect), "sanctuary walkway %s stays clear" % str(rect))
	room.free()
	await _pump(1)


func _ledger_after_sunday() -> void:
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("sermon_theme", "hope")
	NarrativeState.set_flag("margaret_sunday", true)
	DayClock.set_time(0, 11, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(3)
	var ledger := room.get_node_or_null("Props/Ledger") as Interactable
	_check(ledger != null and ledger.visible and ledger.enabled, "the ledger is still interactable in the office after Sunday")
	room.free()
	await _pump(1)


func _fellowship_fixes() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(3)
	var coffee := room.get_node_or_null("Props/CoffeeStation") as Node2D
	var view := InteriorLayout.hall_close_view()
	_check(coffee != null, "the coffee station exists")
	if coffee != null:
		_check(view.has_point(coffee.global_position), "the coffee station sits in the starting close camera")
	var kids_rect := InteriorLayout.hall_kids_rect()
	_check(kids_rect.size.x >= 160.0 and kids_rect.size.y >= 80.0, "the kids' corner has a real footprint")
	var kids_found := 0
	var kids_v: Variant = InteriorLayout.hall_zone_prop_names().get("kids", PackedStringArray())
	var kids_names := PackedStringArray()
	if kids_v is PackedStringArray:
		kids_names = kids_v
	for node_name in kids_names:
		var node := room.get_node_or_null("Props/%s" % node_name) as Node2D
		if node != null and kids_rect.grow(24.0).has_point(node.global_position):
			kids_found += 1
	_check(kids_found >= 6, "the kids' corner has %d props in its footprint (need 6)" % kids_found)
	_check(room.get_node_or_null("Props/KidsPlayRug") != null, "the kids' corner has a play rug")
	_check(room.get_node_or_null("Props/KidsSmallTable") != null, "the kids' corner has a small table")
	var south_y := InteriorLayout.POS_HALL_PUZZLE.y
	_check(south_y <= view.position.y + view.size.y - 24.0, "the south tables sit inside the close camera")
	var spawn := room.get_node_or_null("Spawns/from_grounds") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the hall spawn is not inside furniture")
	room.free()
	await _pump(1)


func _walkways_and_reach() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var hall := _instance(HALL)
	if hall == null:
		return
	await _pump(3)
	var spawn := hall.get_node_or_null("Spawns/from_grounds") as Node2D
	for rect in InteriorLayout.hall_walkway_rects():
		_check(rect.size.x >= 2 or rect.size.y >= 2, "hall walkway %s is at least two tiles wide" % str(rect))
		_check(_walkway_clear(hall, rect), "hall walkway %s stays clear" % str(rect))
	if spawn != null:
		for node_name in InteriorLayout.hall_interactables():
			var prop := hall.get_node_or_null("Props/%s" % node_name) as Node2D
			_check(prop != null, "hall interactable %s exists" % node_name)
			if prop != null:
				_check(_tile_reachable(hall, spawn.global_position, prop.global_position + Vector2(0, 24)), "hall %s is reachable" % node_name)
	for spot in InteriorLayout.hall_clear_spots():
		_check(_walkable(hall, spot), "hall clear spot %s stays open" % str(spot))
	for npc_id in PackedStringArray(["margaret", "harold", "sarah", "ostrow", "ruth", "dale"]):
		var post := Catalog.post(npc_id)
		_check(_walkable(hall, post), "NPC post %s is not inside furniture" % npc_id)
	_check_cells_clear(hall, InteriorLayout.hall_doorways(), "hall doorway")
	hall.free()
	await _pump(1)


func _save_roundtrip() -> void:
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
	_check(str(saved.get("scene", "")).ends_with("sanctuary.tscn"), "the save remembers the sanctuary")
	room.free()
	await _pump(1)
	_check(SaveGame.apply_state(saved), "the sanctuary save applies")
	var inf := get_node_or_null("/root/InfluenceState")
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == 0, "interior polish does not raise Pull")


func _check_density(room: Node, rooms: Dictionary, sanctuary: bool) -> void:
	var mins: Dictionary = InteriorLayout.min_prop_counts()
	var props := _props_in(room)
	for room_id in rooms.keys():
		var key := str(room_id)
		if not sanctuary and key == "storage":
			key = "hall_storage"
		if not sanctuary and key == "hallway":
			key = "hall_hallway"
		var rect: Rect2i = rooms[room_id]
		var count := 0
		for prop in props:
			if InteriorLayout.contains_cell(rect, InteriorLayout.world_to_cell(prop.position)):
				count += 1
		var need := int(mins.get(key, 8))
		_check(count >= need, "%s has %d decorative props (need %d)" % [key, count, need])


func _props_in(room: Node) -> Array[Node2D]:
	var found: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("interior_prop"):
		if node is Node2D and room.is_ancestor_of(node):
			found.append(node as Node2D)
	return found


func _runner_is_warm(image: Image) -> bool:
	if image == null:
		return false
	var sample := image.get_pixel(clampi(image.get_width() / 2, 0, image.get_width() - 1), clampi(image.get_height() / 2, 0, image.get_height() - 1))
	return sample.r + 0.04 >= sample.b and sample.b < 0.52


func _walkway_clear(room: Node, rect: Rect2i) -> bool:
	var blocked := 0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if not _walkable(room, InteriorLayout.tile_center(Vector2i(x, y))):
				blocked += 1
	return blocked == 0


func _check_cells_clear(room: Node, cells: Array[Vector2i], label: String) -> void:
	for cell in cells:
		var pos := InteriorLayout.tile_center(cell)
		_check(not _blocked_by_furniture(room, pos), "%s %s stays clear" % [label, str(cell)])


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
	print("M13E_OK" if not _failed else "M13E_FAIL")
	tree.quit(0 if not _failed else 1)
