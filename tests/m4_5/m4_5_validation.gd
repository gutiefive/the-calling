extends Node
## Headless checks for Milestone 4.5. Prints M4_5_OK or M4_5_FAIL.
## Run: godot --headless --path . res://tests/m4_5/m4_5_validation.tscn

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	NpcSchedule.debug_blocks = []
	NarrativeState.reset()
	DayClock.reset()
	_static_checks()
	await _wayfinding()
	await _walking()
	await _town_life()
	await _chapter_without_happenings()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _static_checks() -> void:
	for path in [
		"res://scripts/systems/npc_route.gd",
		"res://scripts/actors/schedule_agent.gd",
		"res://scripts/ui/town_map.gd",
		"res://scripts/ui/location_banner.gd",
		"res://data/happenings/week.json",
		"res://data/ambient/barks.json",
		"res://data/dialogue/happening_thursday.json",
		"res://data/dialogue/happening_friday.json",
		"res://data/dialogue/happening_saturday.json",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	_check(InputMap.has_action("town_map"), "town_map is an input action")
	_check(_action_has_key("town_map", KEY_M), "town map is bound to M")
	var atlas := PlaceholderArt.grounds_atlas()
	_check(atlas != null and atlas.get_width() == 256 and atlas.get_height() == 32, "ground atlas keeps 32px tiles and adds water")
	var sign := PlaceholderArt.signpost()
	_check(sign != null and sign.get_width() == 32, "signpost is a 32px-wide prop")
	var folk := PlaceholderArt.townsfolk(0)
	_check(folk != null and folk.get_size() == Vector2(64, 48), "townsfolk sheet is 64x48")
	var blocked: Array[Rect2] = [Rect2(Vector2(680, 380), Vector2(80, 180))]
	var failed := NpcRoute.plan(Vector2(700, 360), Vector2(700, 520), blocked)
	_check(not bool(failed.get("ok", true)), "a blocked segment is not a route")
	var clear_blocks: Array[Rect2] = []
	var clear := NpcRoute.plan(Vector2(700, 360), Vector2(700, 520), clear_blocks)
	_check(bool(clear.get("ok", false)), "an open segment is a route")
	_check(not DialogueRunner.load_conversation("happening_thursday").is_empty(), "Thursday happening dialogue loads")
	_check(not DialogueRunner.load_conversation("happening_friday").is_empty(), "Friday happening dialogue loads")
	_check(not DialogueRunner.load_conversation("happening_saturday").is_empty(), "Saturday happening dialogue loads")
	var thursday := AmbientBarks.line("ada", "Thursday", "Day")
	var friday := AmbientBarks.line("ada", "Friday", "Day")
	var evening := AmbientBarks.line("ada", "Thursday", "Evening")
	_check(not thursday.is_empty() and thursday != friday, "a neighbor's bark changes with the day")
	_check(thursday != evening and not evening.is_empty(), "a neighbor's bark changes with the time of day")


func _wayfinding() -> void:
	DayClock.set_time(4, 14, 0)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var door := room.get_node_or_null("Props/StreetDoor") as Node2D
	var sign := room.get_node_or_null("Props/Signpost") as SpeechProp
	_check(door != null, "the Oak Street exit is still on the grounds")
	_check(sign != null and sign.line.contains("Oak Street"), "a signpost points to Oak Street")
	_check(sign != null and door != null and sign.position.x < door.position.x, "the sign stands west of the exit, on the way to it")
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	var path_cell := Vector2i(-1, -1)
	if ground != null:
		path_cell = ground.get_cell_atlas_coords(GroundsLayout.PATH_TO_STREET)
	_check(path_cell == Vector2i(2, 0), "path tiles lead to the east exit")
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	_check(camera != null and camera.limit_right == GroundsLayout.MAP_SIZE.x * GroundsLayout.TILE and camera.limit_bottom == GroundsLayout.MAP_SIZE.y * GroundsLayout.TILE, "the church lot camera stays inside the grounds")
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.visible and banner.text == "Church grounds", "the location banner names the church grounds")
	var flowers := room.get_node_or_null("Props/ThursdayFlowers") as CanvasItem
	_check(flowers != null and flowers.visible, "Thursday's flower moment is on the grounds in the afternoon")
	await _tap("journal")
	var body := room.get_node_or_null("HUD/Journal/Scroll/Body") as Label
	_check(body != null and body.text.contains("Oak Street"), "the journal hints at Oak Street early (%s)" % _snippet(body.text if body != null else ""))
	await _tap("journal")

	var map := room.get_node_or_null("HUD/TownMap") as TownMap
	var player := room.get_node_or_null("Props/Player") as Player
	if map == null or player == null:
		_check(false, "the church HUD is missing the map or the player")
		room.free()
		return
	await _tap("town_map")
	_check(map.is_open(), "M opens the town map")
	var names := map.place_names()
	_check(names.has("Church grounds") and names.has("Sanctuary") and names.has("Oak Street"), "the map lists the church, the sanctuary, and Oak Street")
	_check(map.marker_region() == "church", "the map marks the player on the church grounds")
	var before := map.marker_position()
	_check(map.region_rect("church").has_point(before), "the player marker sits inside the church grounds")
	player.global_position = Vector2(200, 700)
	await _pump(2)
	var after := map.marker_position()
	_check(after.distance_to(before) > 4.0, "the marker follows the player")
	await _tap("town_map")
	_check(not map.is_open(), "M closes the town map")

	var pause := room.get_node_or_null("HUD/Pause")
	if pause != null and pause.has_method("toggle_pause"):
		pause.call("toggle_pause")
		await _tap("dialogue_down")
		await _tap("dialogue_down")
		await _tap("dialogue_down")
		await _tap("interact")
		_check(map.is_open(), "the pause menu opens the map")
		map.close()
		if get_tree().paused:
			pause.call("toggle_pause")
	_check(not get_tree().paused, "the pause menu closes after the map")
	await _talk_happening(room, "Props/ThursdayFlowers", "margaret", "happening_thursday", "watering")
	room.free()
	await _pump(1)


func _walking() -> void:
	NpcSchedule.debug_blocks = []
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var margaret := room.get_node_or_null("Props/Margaret") as Node2D
	_check(margaret != null and margaret.position.distance_to(GroundsLayout.POS_MARGARET) < 1.0, "Margaret starts at her Thursday afternoon post")
	if margaret == null:
		room.free()
		return
	var start_y := margaret.position.y
	DayClock.set_time(4, 17, 0)
	await _pump(20)
	var walked := margaret.position.y > start_y + 3.0
	var not_there := margaret.position.distance_to(GroundsLayout.POS_MARGARET_EVENING) > 20.0
	_check(walked and not_there and not bool(margaret.get_meta("schedule_fallback", false)), "Margaret walks toward her evening post instead of popping (%s)" % margaret.position)
	room.free()
	await _pump(1)

	NpcSchedule.debug_blocks = [Rect2(Vector2(1000, 700), Vector2(80, 180))]
	DayClock.set_time(4, 14, 0)
	room = _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		NpcSchedule.debug_blocks = []
		return
	margaret = room.get_node_or_null("Props/Margaret") as Node2D
	DayClock.set_time(4, 17, 0)
	await _pump(2)
	var landed := margaret != null and margaret.position.distance_to(GroundsLayout.POS_MARGARET_EVENING) < 1.0
	var used_fallback := margaret != null and bool(margaret.get_meta("schedule_fallback", false))
	_check(landed and used_fallback, "a blocked path teleports Margaret to the scheduled point")
	NpcSchedule.debug_blocks = []
	room.free()
	await _pump(1)


func _town_life() -> void:
	NarrativeState.reset()
	DayClock.set_time(5, 10, 0)
	var room := _instance("res://scenes/world/hardware_street.tscn")
	if room == null:
		return
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.visible and banner.text == "Oak Street", "the location banner names Oak Street")
	var bounds := Rect2()
	if room is WorldRoom:
		bounds = (room as WorldRoom).bounds
	_check(bounds.size.x > 42.0 * 32.0 and bounds.size.y > 24.0 * 32.0, "Oak Street is wider than the old block")
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	var water := Vector2i(-1, -1)
	if ground != null:
		water = ground.get_cell_atlas_coords(Vector2i(72, 10))
	_check(water == Vector2i(7, 0), "the creek uses the water tile")
	var gate := room.get_node_or_null("Props/MapleGate") as SpeechProp
	_check(gate != null and gate.line.contains("bridge"), "Maple Lane is gated with a reason (%s)" % (gate.line if gate != null else ""))
	var window := room.get_node_or_null("Lighting/CottageWindow") as PointLight2D
	_check(window != null, "the cottage has a window light")
	var day_windows := window.energy if window != null else -1.0
	_check(_named_visible(room, ["NeighborA", "NeighborB", "NeighborC", "NeighborD", "NeighborE"]) == 5, "neighbors are out on Oak Street during the day")
	var neighbor := room.get_node_or_null("Props/NeighborA") as AmbientTownsfolk
	var player := room.get_node_or_null("Props/Player") as Player
	if neighbor != null and player != null:
		await _stand_at(player, neighbor)
		await _tap("interact")
		var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
		var spoken := label.text if label != null else ""
		_check(spoken.contains("hardware door") or spoken.contains(neighbor.bark_text()), "a neighbor answers with a bark (%s)" % _snippet(spoken))
	_check(_spot_visible(room, "FridayDelivery"), "Friday's delivery is outside the store")
	_check(not _spot_visible(room, "SaturdayPark"), "the park gathering is absent on Friday")

	DayClock.set_time(6, 10, 0)
	await _pump(2)
	_check(not _spot_visible(room, "FridayDelivery"), "Friday's delivery is gone on Saturday")
	_check(_spot_visible(room, "SaturdayPark"), "Saturday morning gathers at the park")
	var street_map := room.get_node_or_null("HUD/TownMap") as TownMap
	if street_map != null:
		street_map.open()
		_check(street_map.marker_region() == "street", "the map marks the player on Oak Street")
		street_map.close()
	await _talk_happening(room, "Props/SaturdayPark", "sarah", "happening_saturday", "park")

	DayClock.set_time(4, 14, 0)
	await _pump(2)
	_check(not _spot_visible(room, "FridayDelivery") and not _spot_visible(room, "SaturdayPark"), "Oak Street's day moments are absent on Thursday")
	DayClock.set_time(4, 18, 0)
	await _pump(2)
	_check(_named_visible(room, ["NeighborA", "NeighborB", "NeighborC", "NeighborD", "NeighborE"]) == 1, "evening leaves one neighbor out")
	if window != null:
		_check(window.energy > day_windows, "windows light up in the evening")
	DayClock.set_time(4, 20, 30)
	await _pump(2)
	_check(_named_visible(room, ["NeighborA", "NeighborB", "NeighborC", "NeighborD", "NeighborE"]) == 0, "night sends the neighbors inside")
	if window != null:
		_check(window.energy > day_windows, "windows stay lit at night")
	room.free()
	await _pump(1)

	DayClock.set_time(5, 10, 0)
	room = _instance("res://scenes/world/hardware_street.tscn")
	if room == null:
		return
	await _talk_happening(room, "Props/FridayDelivery", "frank", "happening_friday", "delivery")
	room.free()
	await _pump(1)


func _chapter_without_happenings() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 15, 0)
	_check(not NarrativeState.flag_is_true("happening_thursday"), "the chapter check starts without the flower moment")
	_check(not NarrativeState.flag_is_true("happening_friday"), "the chapter check starts without the delivery")
	_check(not NarrativeState.flag_is_true("happening_saturday"), "the chapter check starts without the park")
	_check(NarrativeState.journal_notes().size() == 1, "only the Oak Street hint is written down")
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("sermon_theme", "hope")
	NarrativeState.set_flag("margaret_sunday", true)
	var room := _instance("res://scenes/world/sanctuary.tscn")
	if room == null:
		return
	await _pump(3)
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.text == "Sanctuary", "the location banner names the sanctuary")
	var sanct_map := room.get_node_or_null("HUD/TownMap") as TownMap
	if sanct_map != null:
		sanct_map.open()
		_check(sanct_map.marker_region() == "sanctuary", "the map marks the player in the sanctuary")
		sanct_map.close()
	var ledger := room.get_node_or_null("Props/Ledger") as CanvasItem
	_check(ledger != null and ledger.visible, "the ledger is available without the optional moments")
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	var player := room.get_node_or_null("Props/Player") as Player
	if box == null or player == null:
		_check(false, "the sanctuary is missing the dialogue box")
		room.free()
		return
	_check(box.open_conversation("sunday_ledger", player), "the ledger conversation opens")
	var guard := 0
	while box.is_conversation_open() and guard < 12:
		await _tap("advance_dialogue")
		guard += 1
	_check(not box.is_conversation_open(), "the ledger conversation finishes")
	_check(NarrativeState.flag_is_true("ledger_revealed"), "the ledger still ends the chapter")
	await _pump(2)
	var ending := room.get_node_or_null("ChapterEnd")
	_check(ending != null and ending.has_method("is_showing") and bool(ending.call("is_showing")), "the chapter ending still appears")
	_check(not NarrativeState.flag_is_true("happening_thursday"), "the flower moment was not required")
	_check(not NarrativeState.flag_is_true("happening_friday"), "the delivery was not required")
	_check(not NarrativeState.flag_is_true("happening_saturday"), "the park gathering was not required")
	room.free()
	await _pump(1)


func _save_roundtrip() -> void:
	_become_observer()
	NarrativeState.reset()
	DayClock.set_time(4, 16, 5)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	NarrativeState.add_note("Margaret was watering the flowers by the east wall.")
	NarrativeState.set_flag("seen_oak_street", true)
	NarrativeState.set_relationship("thomas", 1)
	var player := room.get_node_or_null("Props/Player") as Player
	if player == null:
		_check(false, "save test is missing the player")
		room.free()
		return
	player.global_position = Vector2(420, 510)
	player.velocity = Vector2.ZERO
	player.set_facing(&"up")
	var pause := room.get_node("HUD/Pause")
	pause.toggle_pause()
	await _tap("dialogue_down")
	await _tap("interact")
	var hint := room.get_node("HUD/Pause/Center/Hint") as Label
	_check(hint != null and hint.text == "Saved.", "the pause menu still saves (%s)" % (hint.text if hint != null else ""))
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary and int((parsed as Dictionary).get("version", -1)) == SaveGame.SAVE_VERSION, "the save stays on the current version")
	pause.toggle_pause()
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	_check(NarrativeState.relationship("thomas") == 0, "state was cleared after the save")
	pause.toggle_pause()
	await _tap("dialogue_down")
	await _tap("dialogue_down")
	await _tap("interact")
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	_check(player != null and player.global_position.distance_to(Vector2(420, 510)) < 2.0, "load restores the player")
	_check(player != null and player.get_facing() == &"up", "load restores facing")
	_check(NarrativeState.flag_is_true("seen_oak_street"), "load restores the Oak Street flag")
	_check(NarrativeState.relationship("thomas") == 1, "load restores relationships")
	_check(DayClock.hour == 16 and DayClock.minute == 5, "load restores the clock")
	var restored := NarrativeState.journal_notes()
	_check(restored.has("Margaret was watering the flowers by the east wall."), "load restores the journal note")
	_check(not get_tree().paused, "load resumes the game")


func _talk_happening(room: Node, path: String, who: String, flag: String, label: String) -> void:
	NarrativeState.reset()
	var spot := room.get_node_or_null(path) as Node2D
	var player := room.get_node_or_null("Props/Player") as Player
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	if spot == null or player == null or not spot.visible:
		_check(false, "%s happening is not available to talk to" % label)
		return
	await _stand_at(player, spot)
	await _tap("interact")
	_check(NarrativeState.flag_is_true(flag), "%s conversation sets its flag" % label)
	_check(NarrativeState.relationship(who) == 1, "%s conversation raises %s" % [label, who])
	_check(NarrativeState.journal_notes().size() > 1, "%s conversation writes a journal note" % label)
	if box != null and box.is_conversation_open():
		box.close_conversation()
	NarrativeState.reset()


func _spot_visible(room: Node, node_name: String) -> bool:
	var spot := room.get_node_or_null("Props/" + node_name) as CanvasItem
	return spot != null and spot.visible


func _visible_count(room: Node, group_name: String) -> int:
	var count := 0
	var tree := get_tree()
	if tree == null:
		return 0
	for node in tree.get_nodes_in_group(group_name):
		if node is CanvasItem and room.is_ancestor_of(node) and (node as CanvasItem).visible:
			count += 1
	return count


func _named_visible(room: Node, names: Array) -> int:
	var count := 0
	for node_name in names:
		var node := room.get_node_or_null("Props/" + str(node_name)) as CanvasItem
		if node != null and node.visible:
			count += 1
	return count


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
	host.name = "M45SceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


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


func _action_has_key(action: String, key: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == key:
			return true
	return false


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
	var flat := text.replace("\n", " ")
	if flat.length() > 140:
		return flat.substr(0, 140)
	return flat


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	_release_all()
	NpcSchedule.debug_blocks = []
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("M4_5_OK" if not _failed else "M4_5_FAIL")
	tree.quit(0 if not _failed else 1)
