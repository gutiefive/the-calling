extends Node
## Headless checks for Milestone 9B (walk-in doors).
## Prints M9B_OK or M9B_FAIL.
## Run: godot --headless --path . res://tests/m9b/m9b_validation.tscn

const EXPECTED: Array[Dictionary] = [
	{"scene": "res://scenes/world/church_exterior.tscn", "node": "Props/Door", "dest": "sanctuary.tscn", "spawn": &"from_exterior", "place": "Sanctuary", "scheduled": false},
	{"scene": "res://scenes/world/church_exterior.tscn", "node": "Props/StreetDoor", "dest": "hardware_street.tscn", "spawn": &"from_church", "place": "Oak Street", "scheduled": false},
	{"scene": "res://scenes/world/church_exterior.tscn", "node": "Props/HomeDoor", "dest": "parsonage.tscn", "spawn": &"from_grounds", "place": "Parsonage", "scheduled": false},
	{"scene": "res://scenes/world/church_exterior.tscn", "node": "Props/HallDoor", "dest": "fellowship_hall.tscn", "spawn": &"from_grounds", "place": "Fellowship Hall", "scheduled": false},
	{"scene": "res://scenes/world/fellowship_hall.tscn", "node": "Props/Door", "dest": "church_exterior.tscn", "spawn": &"from_hall", "place": "Church grounds", "scheduled": false},
	{"scene": "res://scenes/world/sanctuary.tscn", "node": "Props/Door", "dest": "church_exterior.tscn", "spawn": &"from_sanctuary", "place": "Church grounds", "scheduled": false},
	{"scene": "res://scenes/world/hardware_street.tscn", "node": "Props/ToChurch", "dest": "church_exterior.tscn", "spawn": &"from_street", "place": "Church grounds", "scheduled": false},
	{"scene": "res://scenes/world/hardware_street.tscn", "node": "Props/StoreDoor", "dest": "hardware_interior.tscn", "spawn": &"from_street", "place": "Hardware Store", "scheduled": true},
	{"scene": "res://scenes/world/hardware_street.tscn", "node": "Props/BayDoor", "dest": "bay_interior.tscn", "spawn": &"from_street", "place": "Frank's bay", "scheduled": true},
	{"scene": "res://scenes/world/hardware_street.tscn", "node": "Props/MapleDoor", "dest": "maple_lane.tscn", "spawn": &"from_oak", "place": "Maple Lane", "scheduled": false},
	{"scene": "res://scenes/world/maple_lane.tscn", "node": "Props/ToOak", "dest": "hardware_street.tscn", "spawn": &"from_maple", "place": "Oak Street", "scheduled": false},
	{"scene": "res://scenes/world/parsonage.tscn", "node": "Props/Door", "dest": "church_exterior.tscn", "spawn": &"from_parsonage", "place": "Church grounds", "scheduled": false},
	{"scene": "res://scenes/world/hardware_interior.tscn", "node": "Props/Door", "dest": "hardware_street.tscn", "spawn": &"from_store", "place": "Oak Street", "scheduled": false},
	{"scene": "res://scenes/world/bay_interior.tscn", "node": "Props/Door", "dest": "hardware_street.tscn", "spawn": &"from_bay", "place": "Oak Street", "scheduled": false},
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
	await _enumerate_doors()
	await _walk_and_spawn()
	await _closed_and_locked()
	await _inert_during_ui()
	await _npc_talk_still_e()
	_restore_user_save()
	_finish()


func _enumerate_doors() -> void:
	SceneRouter.suppress_change = true
	var seen: Dictionary = {}
	for row in EXPECTED:
		var path := str(row.get("scene", ""))
		var room := _instance(path)
		if room == null:
			continue
		var node_path := str(row.get("node", ""))
		var door := room.get_node_or_null(node_path)
		var key := "%s:%s" % [path, node_path]
		seen[key] = true
		_check(door is Door, "%s is a Door" % key)
		if door is Door:
			var item := door as Door
			_check(item is Area2D, "%s is an Area2D walk-in trigger" % key)
			_check(not item.is_in_group("interactable"), "%s does not use E" % key)
			_check(item.is_in_group("scene_door"), "%s is in the scene_door group" % key)
			_check(item.destination_scene.ends_with(str(row.get("dest", ""))), "%s targets %s" % [key, row.get("dest", "")])
			_check(item.destination_spawn == row.get("spawn", &"default"), "%s spawn is %s" % [key, row.get("spawn", "")])
			_check(item.place_label() == str(row.get("place", "")), "%s hover is %s" % [key, row.get("place", "")])
			var want_scheduled: bool = bool(row.get("scheduled", false))
			_check((item is ScheduledDoor) == want_scheduled, "%s scheduled=%s" % [key, want_scheduled])
		var leftover := 0
		for node in get_tree().get_nodes_in_group("interactable"):
			if room.is_ancestor_of(node) and str(node.get_class()) == "Area2D" and node.is_in_group("scene_door"):
				leftover += 1
		_check(leftover == 0, "%s has no E-press doors left" % path.get_file())
		var found_in_room := 0
		for node in get_tree().get_nodes_in_group("scene_door"):
			if room.is_ancestor_of(node) and node is Door:
				var dest := str(node.get("destination_scene"))
				if dest.is_empty():
					continue
				found_in_room += 1
		var expected_in_room := 0
		for other in EXPECTED:
			if str(other.get("scene", "")) == path:
				expected_in_room += 1
		_check(found_in_room == expected_in_room, "%s lists every walk-in door (%d/%d)" % [path.get_file(), found_in_room, expected_in_room])
		room.free()
		await _pump(1)
	_check(seen.size() == EXPECTED.size(), "the catalog names every door in the game (%d)" % seen.size())
	SceneRouter.suppress_change = false
	_check(FileAccess.file_exists("res://scripts/interactions/door.gd"), "file res://scripts/interactions/door.gd")
	_check(FileAccess.file_exists("res://scripts/interactions/scheduled_door.gd"), "file res://scripts/interactions/scheduled_door.gd")


func _walk_and_spawn() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := await _enter("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var door := room.get_node_or_null("Props/Door") as Door
	if player == null or door == null:
		_check(false, "the grounds are missing the sanctuary door")
		return
	player.global_position = door.global_position + Vector2(0.0, door.radius + 8.0)
	player.velocity = Vector2.ZERO
	player.clear_interact_lock()
	await _pump(2)
	await get_tree().process_frame
	await get_tree().process_frame
	var prompt := room.get_node_or_null("HUD/Prompt/Label") as Label
	_check(player.get_focus() == null, "a door is not an E interactable")
	_check(prompt != null and prompt.visible and prompt.text == "Sanctuary", "the hover names the sanctuary (%s)" % (prompt.text if prompt != null else ""))
	_check(prompt != null and not prompt.text.begins_with("E"), "the door hover has no Press E")
	await _walk_into(player, door)
	room = await _wait_scene("Sanctuary")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	var arrived := room.get_node_or_null("Spawns/from_exterior") as Node2D
	_check(player != null and arrived != null and player.global_position.distance_to(arrived.global_position) < 2.0, "walking in reaches the sanctuary spawn")
	await _pump(40)
	_check(String(get_tree().current_scene.name) == "Sanctuary", "spawning in the sanctuary does not bounce back outside")
	player = room.get_node_or_null("Props/Player") as Player
	var out := room.get_node_or_null("Props/Door") as Door
	if player == null or out == null:
		_check(false, "the sanctuary is missing its door")
		return
	await _walk_into(player, out)
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	var home := room.get_node_or_null("Spawns/from_sanctuary") as Node2D
	_check(player != null and home != null and player.global_position.distance_to(home.global_position) < 2.0, "walking out reaches the grounds return spawn")
	await _pump(40)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "spawning on the grounds does not bounce back inside")
	player = room.get_node_or_null("Props/Player") as Player
	var street := room.get_node_or_null("Props/StreetDoor") as Door
	if player == null or street == null:
		_check(false, "the grounds are missing the Oak Street exit")
		return
	await _walk_into(player, street)
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	arrived = room.get_node_or_null("Spawns/from_church") as Node2D
	_check(player != null and arrived != null and player.global_position.distance_to(arrived.global_position) < 2.0, "walking east reaches the Oak Street spawn")
	await _pump(40)
	_check(String(get_tree().current_scene.name) == "HardwareStreet", "spawning on Oak Street does not bounce back to the grounds")
	player = room.get_node_or_null("Props/Player") as Player
	var back := room.get_node_or_null("Props/ToChurch") as Door
	if player == null or back == null:
		_check(false, "Oak Street is missing the return")
		return
	await _walk_into(player, back)
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	home = room.get_node_or_null("Spawns/from_street") as Node2D
	_check(player != null and home != null and player.global_position.distance_to(home.global_position) < 2.0, "walking west reaches the lot return spawn")
	await _pump(40)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "spawning from Oak Street does not bounce back to the street")
	player = room.get_node_or_null("Props/Player") as Player
	var home_door := room.get_node_or_null("Props/HomeDoor") as Door
	if player == null or home_door == null:
		_check(false, "the grounds are missing the parsonage door")
		return
	await _walk_into(player, home_door)
	room = await _wait_scene("Parsonage")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	arrived = room.get_node_or_null("Spawns/from_grounds") as Node2D
	_check(player != null and arrived != null and player.global_position.distance_to(arrived.global_position) < 2.0, "walking in reaches the parsonage spawn")
	await _pump(40)
	_check(String(get_tree().current_scene.name) == "Parsonage", "spawning in the parsonage does not bounce back outside")


func _closed_and_locked() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 21, 0)
	var room := await _enter("res://scenes/world/hardware_street.tscn", &"from_church")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var store := room.get_node_or_null("Props/StoreDoor") as Door
	if player == null or store == null:
		_check(false, "Oak Street is missing the store door")
		return
	_check(store is ScheduledDoor and not store.is_open(), "the store is shut at night")
	await _walk_into(player, store)
	_check(String(get_tree().current_scene.name) == "HardwareStreet", "a shut store does not change rooms")
	var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
	var shut := label.text if label != null else ""
	_check(shut.contains("Closed") and shut.contains("Back at"), "bumping a shut store shows the closed line once (%s)" % _snippet(shut))
	player = room.get_node_or_null("Props/Player") as Player
	if player != null:
		await _walk_into(player, store)
	var again := label.text if label != null else ""
	_check(String(get_tree().current_scene.name) == "HardwareStreet", "a second bump still stays on Oak Street")
	_check(again.contains("Closed"), "the closed line is still the short shop text")
	DayClock.set_time(5, 10, 0)
	await _pump(2)
	player = room.get_node_or_null("Props/Player") as Player
	store = room.get_node_or_null("Props/StoreDoor") as Door
	if player != null and store != null:
		await _walk_into(player, store)
	room = await _wait_scene("HardwareInterior")
	_check(room != null, "walking in during hours reaches the hardware store")


func _inert_during_ui() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := await _enter("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var margaret := room.get_node_or_null("Props/Margaret") as Node2D
	var door := room.get_node_or_null("Props/Door") as Door
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	if player == null or margaret == null or door == null or box == null:
		_check(false, "the grounds are missing Margaret or the sanctuary door")
		return
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(box.is_conversation_open() and NarrativeState.movement_locked(), "talking to Margaret opens dialogue")
	SceneRouter.last_path = ""
	player.global_position = door.global_position
	player.velocity = Vector2.ZERO
	await _pump(20)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "the sanctuary door is inert during dialogue")
	_check(SceneRouter.last_path == "" or not SceneRouter.last_path.ends_with("sanctuary.tscn"), "dialogue blocks the walk-in travel")
	box.close_conversation()
	await _pump(2)
	await _tap("journal")
	_check(NarrativeState.journal_open and NarrativeState.movement_locked(), "the journal holds the player")
	SceneRouter.last_path = ""
	player = room.get_node_or_null("Props/Player") as Player
	if player != null:
		player.global_position = door.global_position
		player.velocity = Vector2.ZERO
	await _pump(20)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "the sanctuary door is inert while the journal is open")
	await _tap("journal")
	var map := room.get_node_or_null("HUD/TownMap") as TownMap
	if map != null:
		map.open()
	_check(NarrativeState.map_open, "the map holds the player")
	SceneRouter.last_path = ""
	player = room.get_node_or_null("Props/Player") as Player
	if player != null:
		player.global_position = door.global_position
		player.velocity = Vector2.ZERO
	await _pump(12)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "the sanctuary door is inert while the map is open")
	if map != null:
		map.close()
	NarrativeState.day_card_open = true
	SceneRouter.last_path = ""
	player = room.get_node_or_null("Props/Player") as Player
	if player != null:
		player.global_position = door.global_position
		player.velocity = Vector2.ZERO
	await _pump(12)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "the sanctuary door is inert during the morning card")
	NarrativeState.day_card_open = false
	NarrativeState.ledger_open = true
	SceneRouter.last_path = ""
	player = room.get_node_or_null("Props/Player") as Player
	if player != null:
		player.global_position = door.global_position
		player.velocity = Vector2.ZERO
	await _pump(12)
	_check(String(get_tree().current_scene.name) == "ChurchExterior", "the sanctuary door is inert during the ledger")
	NarrativeState.ledger_open = false


func _npc_talk_still_e() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := await _enter("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var margaret := room.get_node_or_null("Props/Margaret") as SpeechProp
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	if player == null or margaret == null or box == null:
		_check(false, "NPC talk is missing Margaret")
		return
	await _stand_at(player, margaret)
	await _pump(4)
	_check(not box.is_conversation_open(), "walking up to Margaret does not start a conversation")
	_check(player.get_focus() == margaret, "E still focuses Margaret")
	var prompt := room.get_node_or_null("HUD/Prompt/Label") as Label
	_check(prompt != null and prompt.text.begins_with("E") and prompt.text.contains("Margaret"), "the prompt still uses E for people (%s)" % (prompt.text if prompt != null else ""))
	await _tap("interact")
	_check(box.is_conversation_open(), "E still talks to Margaret")
	box.close_conversation()
	await _pump(2)
	var notice := room.get_node_or_null("Props/Notice") as SpeechProp
	if player != null and notice != null:
		await _stand_at(player, notice)
		await _tap("interact")
		var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
		_check(label != null and label.text.contains("Sunday"), "E still inspects the notice board")


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"default"
	var packed := load(path) as PackedScene
	if packed == null:
		_check(false, "load " + path)
		return null
	var room := packed.instantiate()
	add_child(room)
	return room


func _become_observer() -> void:
	var tree := get_tree()
	if tree.current_scene != self:
		return
	var host := Node.new()
	host.name = "M9BSceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


func _enter(path: String, spawn: StringName) -> Node:
	_release_all()
	await _pump(1)
	_become_observer()
	SceneRouter.suppress_change = false
	SceneRouter.travel(get_tree(), path, spawn)
	return await _wait_scene(_scene_name(path))


func _wait_scene(want: String) -> Node:
	for _i in 40:
		await get_tree().process_frame
		var current := get_tree().current_scene
		if current != null and String(current.name) == want:
			await _pump(2)
			return current
	var seen := "none"
	if get_tree().current_scene != null:
		seen = String(get_tree().current_scene.name)
	_check(false, "scene change did not reach %s (saw %s)" % [want, seen])
	return null


func _scene_name(path: String) -> String:
	if path.ends_with("maple_lane.tscn"):
		return "MapleLane"
	if path.ends_with("hardware_interior.tscn"):
		return "HardwareInterior"
	if path.ends_with("bay_interior.tscn"):
		return "BayInterior"
	if path.ends_with("parsonage.tscn"):
		return "Parsonage"
	if path.ends_with("sanctuary.tscn"):
		return "Sanctuary"
	if path.ends_with("hardware_street.tscn"):
		return "HardwareStreet"
	return "ChurchExterior"


func _stand_at(player: Player, target: Node2D) -> void:
	_release_all()
	player.velocity = Vector2.ZERO
	player.global_position = target.global_position + Vector2(0, 26)
	player.clear_interact_lock()
	await _pump(2)


func _walk_into(player: Player, door: Node2D) -> void:
	if player == null or door == null:
		return
	_release_all()
	player.clear_interact_lock()
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	var dest := door.global_position
	var away := Vector2(0.0, 1.0)
	if player.global_position.distance_to(dest) > 1.0:
		away = (player.global_position - dest).normalized()
	player.global_position = dest + away * (radius + 20.0)
	player.velocity = Vector2.ZERO
	await _pump(3)
	if not is_instance_valid(player):
		return
	var delta := dest - player.global_position
	var action := "move_up"
	if absf(delta.x) > absf(delta.y):
		action = "move_right" if delta.x > 0.0 else "move_left"
	else:
		action = "move_down" if delta.y > 0.0 else "move_up"
	Input.action_press(action)
	var start := get_tree().current_scene
	var guard := 0
	while guard < 55:
		await get_tree().physics_frame
		guard += 1
		if get_tree().current_scene != start:
			break
		if not is_instance_valid(player):
			break
	Input.action_release(action)
	_release_all()
	await _pump(1)


func _tap(action: String) -> void:
	_release_all()
	await _pump(2)
	Input.action_press(action)
	await _pump(2)
	Input.action_release(action)
	await _pump(2)


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _release_all() -> void:
	for action in [
		"move_up", "move_down", "move_left", "move_right",
		"interact", "pause", "cycle_time",
		"journal", "advance_dialogue", "dialogue_up", "dialogue_down",
		"town_map",
	]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _snippet(text: String) -> String:
	var flat := text.replace("\n", " | ")
	if flat.length() > 180:
		return flat.substr(0, 180)
	return flat


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	_release_all()
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("M9B_OK" if not _failed else "M9B_FAIL")
	tree.quit(0 if not _failed else 1)
