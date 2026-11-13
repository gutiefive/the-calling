extends Node
## Headless checks for Milestone 5B. Prints M5B_OK or M5B_FAIL.
## Run: godot --headless --path . res://tests/m5b/m5b_validation.tscn

const ROOMS: PackedStringArray = [
	"res://scenes/world/church_exterior.tscn",
	"res://scenes/world/sanctuary.tscn",
	"res://scenes/world/hardware_street.tscn",
	"res://scenes/world/hardware_interior.tscn",
	"res://scenes/world/bay_interior.tscn",
	"res://scenes/world/maple_lane.tscn",
	"res://scenes/world/parsonage.tscn",
]
const SAMPLE_DAYS: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 14]
const SAMPLE_HOURS: Array[int] = [0, 8, 9, 10, 12, 14, 15, 17, 18, 21]

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
	await _one_place()
	await _continue_and_week()
	_restore_user_save()
	_finish()


func _one_place() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(4, 14, 0)
	var rooms: Array[Node] = []
	for path in ROOMS:
		var room := _instance(path)
		if room == null:
			return
		rooms.append(room)
	await _pump(4)
	var store := _find_room(rooms, "HardwareInterior")
	var lip := false
	if store != null:
		var solids := store.get_node_or_null("Solids")
		if solids != null:
			for child in solids.get_children():
				if child is CollisionShape2D and (child as CollisionShape2D).position.y > 490.0:
					lip = true
	_check(lip, "the shop doorway has a lip so the player cannot walk off the map")
	for day in SAMPLE_DAYS:
		for hour in SAMPLE_HOURS:
			DayClock.set_time(day, hour, 0)
			var day_name := DayClock.weekday_name()
			for npc_id in NpcSchedule.npc_ids():
				var hits := NpcSchedule.matches(npc_id, day_name, hour, 0)
				_check(hits.size() <= 1, "%s has one schedule window %s %02d:00 (saw %d)" % [npc_id, day_name, hour, hits.size()])
				var visible := _visible_named(npc_id)
				_check(visible <= 1, "%s is in at most one place %s %02d:00 (saw %d)" % [npc_id, day_name, hour, visible])
	DayClock.set_time(5, 10, 0)
	_check(_visible_named("thomas") == 1 and _visible_named("frank") == 1, "Friday morning keeps Thomas and Frank, each in one place")
	_check(not _node_visible(rooms, "HardwareStreet", "Props/Thomas"), "Thomas is not on the sidewalk while the store is open")
	_check(not _node_visible(rooms, "HardwareStreet", "Props/Frank"), "Frank is not on the sidewalk while the bay is open")
	var counter := _node(rooms, "HardwareInterior", "Props/Thomas") as Interactable
	_check(counter != null and counter.prompt_label().contains("Thomas"), "the counter prompt names Thomas")
	_check(_node_visible(rooms, "HardwareInterior", "Props/Thomas"), "Thomas is behind the counter Friday morning")
	_check(_node_visible(rooms, "BayInterior", "Props/Frank"), "Frank is in the bay Friday morning")
	DayClock.set_time(7, 10, 0)
	_check(_crowd(rooms, "Sanctuary") == 12, "the first Sunday still seats the congregants")
	_check(not _node_visible(rooms, "Sanctuary", "Props/QuietSunday"), "the first Sunday does not use the later-week note")
	DayClock.set_time(14, 10, 0)
	_check(_crowd(rooms, "Sanctuary") == 0, "a later Sunday does not fill the pews")
	var note := _node(rooms, "Sanctuary", "Props/QuietSunday") as SpeechProp
	_check(note != null and note.visible and note.line.contains("next chapter is still being written"), "a later Sunday morning leaves a quiet note")
	var box := _node(rooms, "Sanctuary", "HUD/Banner") as DialogueBox
	_check(box != null and not box.is_conversation_open(), "a later Sunday does not start the sermon")
	for room in rooms:
		room.free()
	NarrativeState.reset()
	DayClock.reset()


func _continue_and_week() -> void:
	NarrativeState.reset()
	DayClock.set_time(7, 15, 0)
	DayClock.sleep_until_morning()
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 15, "before Continue, Sunday sleep does not add a Monday")
	DayClock.set_time(7, 23, 50)
	DayClock.advance_minutes(30)
	_check(DayClock.hour == 23 and DayClock.minute == 59, "the first week still stops on Sunday night")
	NarrativeState.set_flag("ledger_revealed", true)
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("chapter_one_complete", true)
	DayClock.set_time(0, 15, 0)
	var room := await _enter("res://scenes/world/sanctuary.tscn", &"from_exterior")
	if room == null:
		return
	var ending := room.get_node_or_null("ChapterEnd")
	var guard := 0
	while ending != null and ending.has_method("is_showing") and not bool(ending.call("is_showing")) and guard < 30:
		await _pump(1)
		guard += 1
	_check(ending != null and bool(ending.call("is_showing")), "the ledger still opens the chapter ending")
	await _tap("interact")
	_check(NarrativeState.flag_is_true("week_continues"), "Continue stays in Oakridge")
	_check(ending != null and not bool(ending.call("is_showing")) and not NarrativeState.ending_open, "Continue closes the ending")
	_check(not NarrativeState.movement_locked(), "Continue gives the player the town back")
	_check(String(get_tree().current_scene.name) == "Sanctuary", "Continue does not restart the week")
	DayClock.set_time(7, 18, 0)
	DayClock.sleep_until_morning()
	_check(DayClock.weekday == 8 and DayClock.weekday_name() == "Monday" and DayClock.hour == 6, "sleep after Continue reaches Monday (%s %d)" % [DayClock.weekday_name(), DayClock.weekday])
	var next_names: PackedStringArray = ["Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Monday"]
	for i in 7:
		DayClock.set_time(8 + i, 15, 0)
		var from_name := DayClock.weekday_name()
		DayClock.sleep_until_morning()
		_check(DayClock.hour == 6 and DayClock.minute == 0 and DayClock.weekday == 9 + i, "sleep on %s reaches the next morning" % from_name)
		_check(DayClock.weekday_name() == next_names[i], "sleep on %s lands on %s" % [from_name, DayClock.weekday_name()])
	_check(DayClock.weekday == 15 and DayClock.weekday_name() == "Monday", "the week after the second Sunday is still a Monday")
	DayClock.set_time(14, 9, 0)
	await _pump(2)
	var quiet := room.get_node_or_null("Props/QuietSunday") as SpeechProp
	var banner := room.get_node_or_null("HUD/Banner") as DialogueBox
	_check(quiet != null and quiet.visible and quiet.line.contains("next chapter"), "the second Sunday morning is quiet in the sanctuary")
	_check(banner != null and not banner.is_conversation_open(), "the second Sunday does not replay the service")
	DayClock.set_time(12, 9, 20)
	var player := room.get_node_or_null("Props/Player") as Node2D
	if player != null:
		player.global_position = Vector2(496, 500)
	_check(SaveGame.save_to_disk(get_tree()), "week 2 can be saved")
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	_check(SaveGame.load_from_disk(get_tree()), "week 2 can be loaded")
	room = await _wait_scene("Sanctuary")
	_check(room != null, "the week 2 save returns to the sanctuary")
	_check(DayClock.weekday == 12 and DayClock.weekday_name() == "Friday" and DayClock.hour == 9 and DayClock.minute == 20, "load restores Friday of the second week (%s %d:%02d)" % [DayClock.weekday_name(), DayClock.hour, DayClock.minute])
	_check(NarrativeState.flag_is_true("week_continues"), "load keeps the continued week")
	NarrativeState.set_step("oak_street", "friday")
	DayClock.set_time(6, 11, 0)
	_check(NarrativeState.quest_step("oak_street") == "saturday", "a missed Friday errand leaves the journal")
	DayClock.set_time(7, 8, 0)
	_check(NarrativeState.quest_status("oak_street") == "completed", "a missed Saturday errand does not stay active on Sunday")
	room = await _enter("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	DayClock.set_time(4, 14, 0)
	await _pump(2)
	player = room.get_node_or_null("Props/Player") as Player
	var margaret := room.get_node_or_null("Props/Margaret") as Node2D
	if player != null and margaret != null:
		await _stand_at(player, margaret)
		await _pump(2)
	var prompt := room.get_node_or_null("HUD/Prompt/Label") as Label
	_check(prompt != null and prompt.visible and prompt.text.contains("Margaret"), "the prompt names Margaret (%s)" % (prompt.text if prompt != null else ""))
	var fade := get_node_or_null("/root/SceneFade")
	_check(fade != null and fade.has_method("is_fading"), "scene changes have a fade")
	if fade != null and fade.has_method("play"):
		fade.call("play")
		_check(bool(fade.call("is_fading")), "the fade covers the room change")
	var journal := room.get_node_or_null("HUD/Journal")
	await _tap("journal")
	_check(journal != null and journal.visible, "the journal opens")
	await _tap("pause")
	_check(journal != null and not journal.visible and not get_tree().paused, "Esc closes the journal without pausing")
	var map := room.get_node_or_null("HUD/TownMap") as TownMap
	await _tap("town_map")
	_check(map != null and map.is_open(), "the map opens")
	await _tap("pause")
	_check(map != null and not map.is_open() and not get_tree().paused, "Esc closes the map without pausing")
	NarrativeState.reset()
	DayClock.reset()


func _visible_named(npc_id: String) -> int:
	var count := 0
	var tree := get_tree()
	if tree == null:
		return 0
	for node in tree.get_nodes_in_group("scheduled_npc"):
		if str(node.get("npc_id")) != npc_id:
			continue
		if node is CanvasItem and (node as CanvasItem).visible:
			count += 1
	return count


func _crowd(rooms: Array[Node], room_name: String) -> int:
	var room := _find_room(rooms, room_name)
	if room == null:
		return -1
	var count := 0
	var tree := get_tree()
	if tree == null:
		return 0
	for node in tree.get_nodes_in_group("congregant"):
		if node is CanvasItem and room.is_ancestor_of(node) and (node as CanvasItem).visible:
			count += 1
	return count


func _node_visible(rooms: Array[Node], room_name: String, path: String) -> bool:
	var node := _node(rooms, room_name, path)
	return node is CanvasItem and (node as CanvasItem).visible


func _node(rooms: Array[Node], room_name: String, path: String) -> Node:
	var room := _find_room(rooms, room_name)
	if room == null:
		return null
	return room.get_node_or_null(path)


func _find_room(rooms: Array[Node], room_name: String) -> Node:
	for room in rooms:
		if String(room.name) == room_name:
			return room
	return null


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
	host.name = "M5BSceneHost"
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
	if path.ends_with("sanctuary.tscn"):
		return "Sanctuary"
	if path.ends_with("church_exterior.tscn"):
		return "ChurchExterior"
	return "Sanctuary"


func _stand_at(player: Player, target: Node2D) -> void:
	_release_all()
	player.velocity = Vector2.ZERO
	player.global_position = target.global_position + Vector2(0, 26)
	player.clear_interact_lock()
	await _pump(2)


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
		"interact", "pause", "cycle_time", "town_map",
		"journal", "advance_dialogue", "dialogue_up", "dialogue_down",
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
	print("M5B_OK" if not _failed else "M5B_FAIL")
	tree.quit(0 if not _failed else 1)
