extends Node
## Headless checks for Milestone 13C (Fellowship Hall tables and main-hall fill).
## Prints M13C_OK or M13C_FAIL.
## Run: godot --headless --path . res://tests/m13c/m13c_validation.tscn

const Draw := preload("res://scripts/art/pixel_draw.gd")
const Catalog := preload("res://scripts/systems/event_catalog.gd")
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
	await _normal_day_tables()
	await _walkways_and_reach()
	await _potluck_dishes()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _art_and_layout() -> void:
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")
	_check(InteriorLayout.hall_table_count() >= 8, "the main hall lists at least eight tables")
	var rug: Image = InteriorFrames.build("rug_hall")
	_check(rug != null, "the hall rug still draws")
	for frame_id in PackedStringArray(["round_table", "long_table", "craft_table", "puzzle_table", "table_shadow_round", "table_shadow_long", "hall_chair", "napkin_holder", "salt_pepper", "board_game"]):
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 8 and image.get_height() >= 8, "table art %s is drawn" % frame_id)
		if frame_id.ends_with("_table"):
			_check(not _same_image(image, rug), "table art %s is not the rug sprite" % frame_id)
			_check(_has_legs_or_shadow(image), "table art %s has a shadow or legs" % frame_id)
			_check(_carpet_fraction(image) < 0.2, "table art %s is not a red rug" % frame_id)
	for frame_id in PackedStringArray(["table_modest", "table_full"]):
		var image: Image = PotluckFrames.build(frame_id)
		_check(image != null and image.get_height() >= 40, "potluck %s is a raised table" % frame_id)
		_check(not _same_image(image, rug), "potluck %s is not the rug sprite" % frame_id)
		_check(_has_legs_or_shadow(image), "potluck %s has a shadow or legs" % frame_id)
	_check(_carpet_fraction(rug) < 0.15, "the hall rug is not a red carpet slab")


func _normal_day_tables() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(3)
	var tables: Array[Node2D] = _group_in(room, "hall_table")
	_check(tables.size() == InteriorLayout.hall_table_count(), "placed table count is %d" % InteriorLayout.hall_table_count())
	var rug_tex: Texture2D = InteriorArt.texture("rug_hall")
	for row_v in InteriorLayout.hall_tables():
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var table_id := str(row.get("id", ""))
		var kind := str(row.get("kind", "long"))
		var table := room.get_node_or_null("Props/%s" % table_id) as Sprite2D
		_check(table != null, "table %s exists" % table_id)
		if table == null:
			continue
		_check(table.texture != rug_tex, "table %s does not use the rug sprite" % table_id)
		_check(table.get_node_or_null("Shadow") != null, "table %s has a shadow layer" % table_id)
		_check(bool(table.get_meta("has_shadow_legs", false)), "table %s is marked with legs" % table_id)
		var chairs := _chairs_for(room, table_id)
		var need := InteriorLayout.hall_chair_count_for(kind)
		_check(chairs.size() >= need, "table %s has %d chairs (need %d)" % [table_id, chairs.size(), need])
	_check_rug_overlap(room, tables)
	room.free()
	await _pump(1)


func _walkways_and_reach() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(3)
	var spawn := room.get_node_or_null("Spawns/from_grounds") as Node2D
	_check(spawn != null and _walkable(room, spawn.global_position), "the hall spawn is not inside furniture")
	for rect in InteriorLayout.hall_walkway_rects():
		_check(rect.size.x >= 2 or rect.size.y >= 2, "walkway %s is at least two tiles wide" % str(rect))
		var blocked := 0
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				if not _walkable(room, InteriorLayout.tile_center(Vector2i(x, y))):
					blocked += 1
		_check(blocked == 0, "walkway %s stays clear (%d blocked)" % [str(rect), blocked])
	if spawn != null:
		_check(_tile_reachable(room, spawn.global_position, InteriorLayout.POS_HALL_STAGE + Vector2(-80, 48)), "the stage is reachable from the door")
		_check(_tile_reachable(room, spawn.global_position, InteriorLayout.POS_HALL_SERVING + Vector2(40, 36)), "the kitchen pass-through is reachable")
		_check(_tile_reachable(room, spawn.global_position, InteriorLayout.hall_probes()["hallway"]), "the hallway is reachable from the door")
		for node_name in InteriorLayout.hall_interactables():
			var prop := room.get_node_or_null("Props/%s" % node_name) as Node2D
			_check(prop != null, "interactable %s exists" % node_name)
			if prop != null:
				_check(_tile_reachable(room, spawn.global_position, prop.global_position + Vector2(0, 24)), "interactable %s is reachable" % node_name)
	for spot in InteriorLayout.hall_clear_spots():
		_check(_walkable(room, spot), "clear spot %s stays open" % str(spot))
	for npc_id in PackedStringArray(["margaret", "harold", "sarah", "ostrow", "ruth", "dale"]):
		var post := Catalog.post(npc_id)
		_check(_walkable(room, post), "NPC post %s is not inside furniture" % npc_id)
	_check_cells_clear(room, InteriorLayout.hall_doorways(), "hall doorway")
	room.free()
	await _pump(1)


func _potluck_dishes() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(10, 12, 0)
	var modest := _instance(HALL)
	if modest == null:
		return
	await _pump(3)
	_check_dishes_on_tables(modest, "no-prep")
	var modest_table := modest.get_node_or_null("Props/TableA") as Sprite2D
	_check(modest_table != null and modest_table.visible, "a modest table is out with no prep")
	var modest_tex: Texture2D = modest_table.texture if modest_table != null else null
	_check(not _node_visible(modest, "CenterA"), "centerpieces stay off with no flowers")
	_check(not _node_visible(modest, "ExtraChairs"), "extra chairs stay off with no repair")
	modest.free()
	await _pump(1)
	_full_prep()
	DayClock.set_time(10, 12, 0)
	var full := _instance(HALL)
	if full == null:
		return
	await _pump(3)
	_check_dishes_on_tables(full, "full-prep")
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


func _save_roundtrip() -> void:
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var room := _instance(HALL)
	if room == null:
		return
	await _pump(2)
	var player := room.get_node_or_null("Props/Player") as Node2D
	if player != null:
		player.global_position = InteriorLayout.POS_HALL_SPAWN
	_check(SaveGame.save_to_disk(get_tree()), "the hall can be saved")
	_check(SaveGame.SAVE_VERSION == 11, "the slot is still version 11")
	var saved := SaveGame.read_file()
	_check(int(saved.get("version", 0)) == 11, "the file on disk is version 11")
	room.free()
	await _pump(1)
	_check(SaveGame.apply_state(saved), "the hall save applies")
	var inf := get_node_or_null("/root/InfluenceState")
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == 0, "table furniture does not raise Pull")


func _check_dishes_on_tables(room: Node, label: String) -> void:
	for pair in [["TableA", "DishesA"], ["TableB", "DishesB"], ["TableA", "CenterA"], ["TableB", "CenterB"]]:
		var table := room.get_node_or_null("Props/%s" % pair[0]) as Sprite2D
		var item := room.get_node_or_null("Props/%s" % pair[1]) as Node2D
		_check(table != null and item != null, "%s %s and %s exist" % [label, pair[0], pair[1]])
		if table == null or item == null:
			continue
		_check(_on_table_top(table, item), "%s %s sits on %s" % [label, pair[1], pair[0]])


func _check_rug_overlap(room: Node, tables: Array[Node2D]) -> void:
	var rugs: Array[Sprite2D] = []
	for node in get_tree().get_nodes_in_group("hall_rug"):
		if node is Sprite2D and room.is_ancestor_of(node):
			rugs.append(node as Sprite2D)
	for table in tables:
		if not (table is Sprite2D):
			continue
		var sprite := table as Sprite2D
		var table_box := _sprite_box(sprite)
		if table_box.size.x <= 1.0:
			continue
		var overlapped := 0.0
		for rug in rugs:
			var hit := table_box.intersection(_sprite_box(rug))
			if hit.size.x > 0.0 and hit.size.y > 0.0:
				overlapped += hit.size.x * hit.size.y
		var fraction := overlapped / (table_box.size.x * table_box.size.y)
		_check(fraction <= InteriorLayout.HALL_RUG_OVERLAP_MAX, "rug overlap on %s is %.2f" % [sprite.name, fraction])


func _on_table_top(table: Sprite2D, item: Node2D) -> bool:
	return _sprite_box(table).grow(16.0).has_point(item.global_position)


func _sprite_box(sprite: Sprite2D) -> Rect2:
	var size := Vector2(32, 24)
	if sprite.texture != null:
		size = Vector2(float(sprite.texture.get_width()), float(sprite.texture.get_height()))
	var origin := sprite.global_position
	return Rect2(origin - Vector2(size.x * 0.5, size.y), size)


func _chairs_for(room: Node, table_id: String) -> Array[Node2D]:
	var found: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("hall_chair"):
		if not (node is Node2D) or not room.is_ancestor_of(node):
			continue
		if str(node.get_meta("table_id", "")) == table_id:
			found.append(node as Node2D)
	return found


func _group_in(room: Node, group_name: String) -> Array[Node2D]:
	var found: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group(group_name):
		if node is Node2D and room.is_ancestor_of(node):
			found.append(node as Node2D)
	return found


func _has_legs_or_shadow(image: Image) -> bool:
	if image == null:
		return false
	var h := image.get_height()
	var w := image.get_width()
	var y0 := int(float(h) * 0.58)
	var opaque := 0
	var gaps := 0
	for y in range(y0, h):
		for x in range(w):
			if image.get_pixel(x, y).a > 0.5:
				opaque += 1
			else:
				gaps += 1
	return opaque >= 20 and gaps >= 8


func _carpet_fraction(image: Image) -> float:
	if image == null:
		return 1.0
	var carpet: Array[Color] = [Draw.pal("carpet"), Draw.pal("carpet_d"), Draw.pal("carpet_l")]
	var hits := 0
	var total := 0
	for y in image.get_height():
		for x in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a < 0.5:
				continue
			total += 1
			for tone in carpet:
				if pixel.is_equal_approx(tone):
					hits += 1
					break
	if total == 0:
		return 1.0
	return float(hits) / float(total)


func _same_image(a: Image, b: Image) -> bool:
	if a == null or b == null:
		return false
	if a.get_width() != b.get_width() or a.get_height() != b.get_height():
		return false
	return a.get_data() == b.get_data()


func _check_cells_clear(room: Node, cells: Array[Vector2i], label: String) -> void:
	for cell in cells:
		var pos := InteriorLayout.tile_center(cell)
		_check(not _blocked_by_furniture(room, pos), "%s %s stays clear" % [label, str(cell)])


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
	print("M13C_OK" if not _failed else "M13C_FAIL")
	tree.quit(0 if not _failed else 1)
