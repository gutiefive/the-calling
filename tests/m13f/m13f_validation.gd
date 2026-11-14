extends Node
## Headless checks for Milestone 13F (interior rough-spot patch).
## Prints M13F_OK or M13F_FAIL.
## Run: godot --headless --path . res://tests/m13f/m13f_validation.tscn

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
	await _sanctuary_light()
	await _fellowship_kids_and_walls()
	await _walkways_and_reach()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _art_and_layout() -> void:
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")
	_check(InteriorLayout.SANCT_OFFICE.size.y >= InteriorLayout.SANCT_NORTH_MIN_H, "the office is at least seven tiles tall")
	_check(InteriorLayout.contains_cell(InteriorLayout.SANCT_WORSHIP, InteriorLayout.SANCTUARY_AISLE_CELL), "the aisle cell stays in the worship hall")
	var pool: Image = InteriorFrames.build("stain_pool_aisle")
	_check(pool != null and pool.get_width() >= 8 and pool.get_height() >= 8, "the aisle stain pool is drawn")
	var peak := _max_alpha(pool)
	_check(peak > 0.04, "the aisle stain pool is still visible (alpha %.3f)" % peak)
	_check(peak < InteriorLayout.AISLE_STAIN_MAX_ALPHA, "aisle stain pool alpha %.3f stays under the soft threshold %.2f" % [peak, InteriorLayout.AISLE_STAIN_MAX_ALPHA])
	_check(TimeOfDay.stained_aisle_energy() <= InteriorLayout.AISLE_STAIN_LIGHT_MAX_ENERGY, "daytime aisle lights stay under the soft energy cap")
	_check(TimeOfDay.stained_aisle_energy() < TimeOfDay.stained_energy(), "aisle stained light is gentler than the window lights")
	for frame_id in PackedStringArray(["kids_play_rug", "kids_wall_drawing", "alphabet_strip", "pew", "rug_aisle_runner"]):
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 8 and image.get_height() >= 8, "patch art %s is drawn" % frame_id)


func _sanctuary_light() -> void:
	DayClock.set_time(4, 14, 0)
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(3)
	var lighting := room.get_node_or_null("Lighting")
	_check(lighting != null, "the sanctuary has a lighting node")
	for node_name in PackedStringArray(["AisleStain1Light", "AisleStain2Light", "AisleStain3Light", "AisleStain4Light"]):
		var lamp := room.get_node_or_null("Lighting/%s" % node_name) as PointLight2D
		_check(lamp != null, "stained-glass light %s still reaches the aisle" % node_name)
		if lamp != null:
			_check(lamp.energy <= InteriorLayout.AISLE_STAIN_LIGHT_MAX_ENERGY + 0.001, "%s energy %.3f stays soft" % [node_name, lamp.energy])
			_check(lamp.is_in_group("tod_stained_aisle"), "%s uses the soft aisle light group" % node_name)
			_check(lamp.texture_scale >= InteriorLayout.AISLE_STAIN_LIGHT_SCALE - 0.05, "%s has a gentle falloff scale" % node_name)
	for node_name in PackedStringArray(["AisleStain1", "AisleStain2", "AisleStain3", "AisleStain4"]):
		_check(room.get_node_or_null("Props/%s" % node_name) != null, "aisle color pool %s is placed" % node_name)
	_check_wall_deco(room, InteriorLayout.sanct_wall_deco_names())
	var spawn := room.get_node_or_null("Spawns/from_exterior") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the sanctuary spawn is not inside furniture")
	for spot in InteriorLayout.sanctuary_clear_spots():
		_check(_walkable(room, spot), "sanctuary clear spot %s stays open" % str(spot))
	for rect in InteriorLayout.sanctuary_walkway_rects():
		_check(rect.size.x >= 2 or rect.size.y >= 2, "sanctuary walkway %s is at least two tiles wide" % str(rect))
		_check(_walkway_clear(room, rect), "sanctuary walkway %s stays clear" % str(rect))
	_check_cells_clear(room, InteriorLayout.sanctuary_doorways(), "sanctuary doorway")
	_check_cells_clear(room, InteriorLayout.sanctuary_aisle_cells(), "sanctuary aisle")
	var ledger := room.get_node_or_null("Props/Ledger") as Interactable
	_check(ledger != null, "the ledger is still in the office")
	room.free()
	await _pump(1)


func _fellowship_kids_and_walls() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(3)
	var entry := InteriorLayout.hall_entry_view()
	_check(entry.has_point(InteriorLayout.POS_HALL_KIDS), "the kids' corner sits in the starting close camera")
	var kids_rect := InteriorLayout.hall_kids_rect()
	_check(kids_rect.size.x >= 160.0 and kids_rect.size.y >= 80.0, "the kids' corner has a real footprint")
	_check(entry.intersects(kids_rect), "the kids' corner footprint meets the entry camera")
	var coffee := room.get_node_or_null("Props/CoffeeStation") as Node2D
	_check(coffee != null, "the coffee station exists")
	if coffee != null:
		_check(InteriorLayout.hall_close_view().has_point(coffee.global_position), "the coffee station stays in the close camera")
		_check(not kids_rect.has_point(coffee.global_position), "the kids' corner does not cover the coffee station")
	var door := room.get_node_or_null("Props/Door") as Node2D
	_check(door != null, "the Fellowship door exists")
	if door != null:
		_check(not kids_rect.has_point(door.global_position), "the kids' corner does not cover the door")
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
	for node_name in PackedStringArray([
		"KidsPlayRug", "KidsSmallTable", "KidsCornerChair", "KidsCornerBin",
		"KidsBookBin", "KidsWallArt", "KidsWallArt2", "KidsAlphabet",
	]):
		_check(room.get_node_or_null("Props/%s" % node_name) != null, "the kids' corner has %s" % node_name)
	var rug := room.get_node_or_null("Props/KidsPlayRug") as Node2D
	_check(rug != null and entry.has_point(rug.global_position), "the play rug is visible on entry")
	_check_wall_deco(room, InteriorLayout.hall_wall_deco_names())
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
	_check(spawn != null and _walkable(hall, spawn.global_position), "the hall spawn is not inside furniture")
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
		_check(not InteriorLayout.hall_kids_rect().has_point(post), "potluck post %s is not inside the kids' corner" % npc_id)
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


func _check_wall_deco(room: Node, names: PackedStringArray) -> void:
	var rects: Array[Rect2] = []
	var seen: PackedStringArray = PackedStringArray()
	for node_name in names:
		var node := room.get_node_or_null("Props/%s" % node_name) as Sprite2D
		_check(node != null, "wall deco %s exists" % node_name)
		if node == null:
			continue
		_check(node.z_index <= InteriorLayout.WALL_DECO_Z, "wall deco %s uses the wall layer" % node_name)
		_check(node.is_in_group("interior_wall_deco"), "wall deco %s is tagged" % node_name)
		var box := InteriorLayout.sprite_foot_rect(node)
		_check(box.size.x >= 4.0 and box.size.y >= 4.0, "wall deco %s has a drawable rect" % node_name)
		for i in rects.size():
			var hit := box.intersection(rects[i])
			var overlaps := hit.size.x > 1.0 and hit.size.y > 1.0
			_check(not overlaps, "wall deco %s does not overlap %s" % [node_name, seen[i]])
		rects.append(box)
		seen.append(node_name)


func _max_alpha(image: Image) -> float:
	if image == null:
		return 0.0
	var peak := 0.0
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			if alpha > peak:
				peak = alpha
	return peak


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
	print("M13F_OK" if not _failed else "M13F_FAIL")
	tree.quit(0 if not _failed else 1)
