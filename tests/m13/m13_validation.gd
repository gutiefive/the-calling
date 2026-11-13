extends Node
## Headless checks for Milestone 13 (sanctuary and Fellowship Hall interiors).
## Prints M13_OK or M13_FAIL.
## Run: godot --headless --path . res://tests/m13/m13_validation.tscn

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
	await _fellowship_rooms()
	await _interactables()
	await _ambients_clear_doors()
	await _sunday_and_ledger()
	await _flowers_and_potluck()
	await _m8_and_chapter()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _art_and_layout() -> void:
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")
	_check(InteriorArt.atlas() != null, "interior atlas draws")
	for frame_id in PackedStringArray(["pew", "altar", "pulpit", "stained_glass", "piano", "desk", "kneeler", "fridge", "chalkboard", "coffee"]):
		var image: Image = InteriorFrames.build(frame_id)
		_check(image != null and image.get_width() >= 16 and image.get_height() >= 16, "interior art %s is drawn" % frame_id)
	_check(InteriorLayout.sanctuary_rooms().size() >= 7, "sanctuary lists every room")
	_check(InteriorLayout.hall_rooms().size() >= 5, "fellowship hall lists every room")
	_check(InteriorLayout.SANCTUARY_AISLE_CELL == Vector2i(22, 18), "the aisle cell is in the worship runner")


func _sanctuary_rooms() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(3)
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null, "the sanctuary has a Ground layer")
	if ground != null:
		_check(ground.get_cell_atlas_coords(InteriorLayout.SANCTUARY_AISLE_CELL) == InteriorLayout.TILE_RUNNER, "the worship aisle is a carpet runner")
	var spawn := room.get_node_or_null("Spawns/from_exterior") as Node2D
	var door := room.get_node_or_null("Props/Door") as Door
	_check(spawn != null and door != null, "sanctuary spawn and door exist")
	if spawn != null:
		_check(_walkable(room, spawn.global_position), "the sanctuary spawn is not inside collision")
	if spawn != null and door != null:
		_check(spawn.global_position.distance_to(door.global_position) > door.radius + 2.0, "the sanctuary spawn sits outside the door")
		_check(str(door.destination_scene).ends_with("church_exterior.tscn"), "the sanctuary door returns to the grounds")
		_check(door.destination_spawn == &"from_sanctuary", "the sanctuary door uses the outdoor return spawn")
	var probes: Dictionary = InteriorLayout.sanctuary_probes()
	for room_id in probes.keys():
		var pos: Vector2 = probes[room_id]
		_check(_walkable(room, pos), "sanctuary %s probe is walkable" % str(room_id))
		if spawn != null:
			_check(_tile_reachable(room, spawn.global_position, pos), "sanctuary %s is reachable from the entrance" % str(room_id))
	_check(room.get_node_or_null("Props/Ledger") != null, "the ledger is in the sanctuary")
	_check(room.get_node_or_null("Props/KeyRing") != null, "the spare keys are still in the sanctuary")
	_check(room.get_node_or_null("SundayService") != null, "Sunday service is still in the sanctuary")
	_check(room.get_node_or_null("Lighting/SconceL") != null, "the sanctuary still has a sconce")
	var keys := room.get_node_or_null("Props/KeyRing") as Node2D
	if spawn != null and keys != null:
		_check(_tile_reachable(room, spawn.global_position, keys.global_position + Vector2(0, 26)), "the key ring is reachable")
	var ledger := room.get_node_or_null("Props/Ledger") as Node2D
	if spawn != null and ledger != null:
		_check(_tile_reachable(room, spawn.global_position, ledger.global_position + Vector2(0, 26)), "the office ledger is reachable")
	room.free()
	await _pump(1)


func _fellowship_rooms() -> void:
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
	var door := room.get_node_or_null("Props/Door") as Door
	_check(spawn != null and door != null, "hall spawn and door exist")
	if spawn != null:
		_check(_walkable(room, spawn.global_position), "the hall spawn is not inside collision")
	if spawn != null and door != null:
		_check(spawn.global_position.distance_to(door.global_position) > door.radius + 2.0, "the hall spawn sits outside the door")
		_check(str(door.destination_scene).ends_with("church_exterior.tscn"), "the hall door returns to the grounds")
	var probes: Dictionary = InteriorLayout.hall_probes()
	for room_id in probes.keys():
		var pos: Vector2 = probes[room_id]
		_check(_walkable(room, pos), "hall %s probe is walkable" % str(room_id))
		if spawn != null:
			_check(_tile_reachable(room, spawn.global_position, pos), "hall %s is reachable from the entrance" % str(room_id))
	_check(room.get_node_or_null("Props/TableA") != null, "potluck tables are in the hall")
	_check(room.get_node_or_null("Props/KitchenCounter") != null, "the kitchen has a counter")
	_check(room.get_node_or_null("Props/Chalkboard") != null, "the classroom has a chalkboard")
	room.free()
	await _pump(1)


func _interactables() -> void:
	DayClock.set_time(4, 14, 0)
	var sanct := _instance(SANCT)
	if sanct == null:
		return
	await _pump(2)
	for node_name in InteriorLayout.sanctuary_interactables():
		_check_flavor(sanct, node_name)
	sanct.free()
	await _pump(1)
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	var hall := _instance(HALL)
	if hall == null:
		return
	await _pump(2)
	for node_name in InteriorLayout.hall_interactables():
		_check_flavor(hall, node_name)
	hall.free()
	await _pump(1)


func _ambients_clear_doors() -> void:
	DayClock.set_time(5, 11, 0)
	var sanct := _instance(SANCT)
	if sanct == null:
		return
	await _pump(2)
	_check_ambient_clear(sanct, InteriorLayout.sanctuary_doorways(), "sanctuary")
	sanct.free()
	await _pump(1)
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(5, 11, 0)
	var hall := _instance(HALL)
	if hall == null:
		return
	await _pump(2)
	_check_ambient_clear(hall, InteriorLayout.hall_doorways(), "hall")
	_check(hall.get_node_or_null("Props/KitchenVolunteer") != null, "a kitchen volunteer exists")
	_check(hall.get_node_or_null("Props/ClassroomKid") != null, "a classroom kid exists")
	hall.free()
	await _pump(1)


func _sunday_and_ledger() -> void:
	NarrativeState.reset()
	DayClock.reset()
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
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("sermon_theme", "hope")
	NarrativeState.set_flag("margaret_sunday", true)
	DayClock.set_time(0, 11, 0)
	var after := _instance(SANCT)
	if after == null:
		return
	await _pump(3)
	var ledger := after.get_node_or_null("Props/Ledger") as Interactable
	_check(ledger != null and ledger.visible and ledger.enabled, "the ledger still appears after Margaret's follow-up")
	after.free()
	await _pump(1)


func _flowers_and_potluck() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	var bare := _instance(SANCT)
	if bare == null:
		return
	await _pump(2)
	var flowers := bare.get_node_or_null("Props/SanctuaryFlowers") as CanvasItem
	_check(flowers != null and not flowers.visible, "Margaret's flowers start hidden")
	bare.free()
	await _pump(1)
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	var bloom := _instance(SANCT)
	if bloom == null:
		return
	await _pump(2)
	flowers = bloom.get_node_or_null("Props/SanctuaryFlowers") as CanvasItem
	_check(flowers != null and flowers.visible, "Margaret's flowers still appear in the sanctuary")
	bloom.free()
	await _pump(1)
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(10, 12, 0)
	var empty := _instance(HALL)
	if empty == null:
		return
	await _pump(3)
	_check(_npc_visible(empty, "Margaret"), "Margaret appears with no prep")
	_check(_npc_visible(empty, "Harold"), "Harold appears with no prep")
	_check(_npc_visible(empty, "Sarah"), "Sarah appears with no prep")
	_check(not _npc_visible(empty, "Ostrow"), "Ostrow stays away with no invites")
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
	_check(_npc_visible(full, "Ostrow"), "an invited Ostrow appears")
	_check(_npc_visible(full, "Ruth"), "an invited Ruth appears")
	_check(_npc_visible(full, "Dale"), "an invited Dale appears")
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
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	var open_run := DialogueRunner.new()
	_check(open_run.start(DialogueRunner.load_conversation("sarah")), "Sarah's gathering talk starts")
	var guard := 0
	while open_run.is_open() and open_run.choice_count() == 0 and guard < 10:
		open_run.advance()
		guard += 1
	_check(open_run.choice_count() == 2, "Sarah still offers two framings")
	if open_run.choice_count() >= 1:
		open_run.choose(0)
	_check(str(_events().call("framing")) == "open", "Sarah's open framing still stores")


func _m8_and_chapter() -> void:
	_check(HappeningSchedule.is_active("wednesday_potluck", "Wednesday", 12, 0), "the M8 potluck happening remains")
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("ledger_revealed", true)
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("chapter_one_complete", true)
	_check(not NarrativeState.flag_is_true("week_continues"), "Chapter 1 still has not continued")
	var ending_data := DialogueRunner.load_conversation("hall_celebration")
	_check(_conversation_has(ending_data, "potluck"), "Harold still names a potluck after the hall is repaired")
	DayClock.set_time(0, 15, 0)
	var room := _instance(SANCT)
	if room == null:
		return
	await _pump(4)
	var ending := room.get_node_or_null("ChapterEnd")
	_check(ending != null, "the chapter ending node is still in the sanctuary")
	room.free()
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
	NarrativeState.reset()
	DayClock.set_time(5, 9, 0)
	_check(SaveGame.apply_state(saved), "the sanctuary save applies")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "load restores Thursday afternoon")
	var inf := get_node_or_null("/root/InfluenceState")
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == 0, "new interiors do not raise Pull")
	_check(int(_funds().get("balance")) >= 0, "ChurchFunds stay untouched by the interiors")
	var reloaded := _instance(SANCT)
	if reloaded != null:
		await _pump(2)
		var spawn := reloaded.get_node_or_null("Spawns/default") as Node2D
		_check(spawn != null and _walkable(reloaded, spawn.global_position), "a loaded sanctuary still has a clear spawn")
		reloaded.free()
		await _pump(1)


func _check_flavor(room: Node, node_name: String) -> void:
	var prop := room.get_node_or_null("Props/%s" % node_name) as SpeechProp
	_check(prop != null, "%s exists" % node_name)
	if prop == null:
		return
	var line := str(prop.line)
	_check(not line.is_empty(), "%s has a line" % node_name)
	_check(not line.contains("$"), "%s has no dollar amounts" % node_name)
	_check(not line.to_lower().contains("cult"), "%s does not say cult" % node_name)
	prop.interact(room.get_node_or_null("Props/Player"))
	var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
	_check(label != null and label.text.contains(line.substr(0, mini(12, line.length()))), "%s shows its line" % node_name)


func _check_ambient_clear(room: Node, doors: Array[Vector2i], place: String) -> void:
	for node in get_tree().get_nodes_in_group("ambient_townsfolk"):
		if not (node is Node2D) or not room.is_ancestor_of(node):
			continue
		var body := node as Node2D
		if not body.visible:
			continue
		var cell := Vector2i(int(body.position.x / 32.0), int(body.position.y / 32.0))
		_check(not InteriorLayout.is_listed(cell, doors), "%s ambient %s is not in a doorway" % [place, body.name])
		_check(body.position.distance_to(_door_pos(room)) > 48.0, "%s ambient %s is not on the exit" % [place, body.name])


func _door_pos(room: Node) -> Vector2:
	var door := room.get_node_or_null("Props/Door") as Node2D
	if door == null:
		return Vector2.ZERO
	return door.global_position


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


func _npc_visible(room: Node, node_name: String) -> bool:
	var node := room.get_node_or_null("Props/%s" % node_name) as CanvasItem
	return node != null and node.visible


func _node_visible(room: Node, node_name: String) -> bool:
	var node := room.get_node_or_null("Props/%s" % node_name) as CanvasItem
	return node != null and node.visible


func _conversation_has(data: Dictionary, bit: String) -> bool:
	return str(data).to_lower().contains(bit)


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


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


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
	print("M13_OK" if not _failed else "M13_FAIL")
	tree.quit(0 if not _failed else 1)
