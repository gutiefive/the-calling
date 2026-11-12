extends Node
## Headless checks for Milestone 4. Prints M4_OK or M4_FAIL.
## Run: godot --headless --path . res://tests/m4/m4_validation.tscn

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
	_static_checks()
	_clock_checks()
	_followup_lines()
	await _no_service_on_thursday()
	await _service_themes()
	await _title_and_save()
	_restore_user_save()
	_finish()


func _static_checks() -> void:
	for path in [
		"res://scenes/main.tscn",
		"res://data/dialogue/sunday_service.json",
		"res://data/dialogue/sunday_ledger.json",
		"res://data/dialogue/margaret_sunday.json",
		"res://scripts/services/sunday_service.gd",
		"res://scripts/ui/title_screen.gd",
		"res://scripts/ui/chapter_end.gd",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	var main := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	_check(main.ends_with("main.tscn"), "the title screen is the main scene")
	_check(InputMap.has_action("interact") and InputMap.has_action("advance_dialogue"), "service advance still uses the existing keys")
	var book := PlaceholderArt.ledger()
	var person := PlaceholderArt.congregant(0)
	var seated := PlaceholderArt.seated("margaret")
	_check(book != null and book.get_width() == 32 and book.get_height() == 32, "ledger art is 32x32")
	_check(person != null and person.get_width() == 32 and person.get_height() == 32, "congregant art is 32x32")
	_check(seated != null and seated.get_width() == 32, "seated portrait stays on the tile grid")
	var data := DialogueRunner.load_conversation("sunday_service")
	_check(not data.is_empty(), "the Sunday service file loads")


func _clock_checks() -> void:
	DayClock.set_time(6, 23, 50)
	DayClock.advance_minutes(80)
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 1 and DayClock.minute == 10, "the clock reaches Sunday morning (%s %d:%02d)" % [DayClock.weekday_name(), DayClock.hour, DayClock.minute])
	DayClock.set_time(6, 20, 0)
	DayClock.skip_ahead()
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 6, "T from Saturday night lands on Sunday morning")
	DayClock.skip_ahead()
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 10 and DayClock.minute == 0, "T from Sunday morning lands on the service")
	_check(not DayClock.at_cap(), "Sunday morning is not the end of the week")
	DayClock.set_time(0, 10, 0)
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 10, "set_time Sunday 10:00 stays on Sunday")
	DayClock.reset()


func _followup_lines() -> void:
	for theme in ["hope", "forgiveness", "service"]:
		NarrativeState.reset()
		_choose_theme(_theme_index(theme))
		_check(str(NarrativeState.get_flag("sermon_theme", "")) == theme, "the %s theme sets its flag" % theme)
		_check(NarrativeState.flag_is_true("service_complete"), "the %s service completes" % theme)
	NarrativeState.reset()
	_choose_theme(0)
	_check(NarrativeState.relationship("sarah") == 1 and NarrativeState.relationship("frank") == 0, "hope moves Sarah, not Frank")
	NarrativeState.reset()
	_choose_theme(1)
	_check(NarrativeState.relationship("frank") == 1 and NarrativeState.relationship("harold") == 0, "forgiveness moves Frank, not Harold")
	NarrativeState.reset()
	_choose_theme(2)
	_check(NarrativeState.relationship("harold") == 1 and NarrativeState.relationship("thomas") == 1 and NarrativeState.relationship("sarah") == 0, "service moves Harold and Thomas")
	var hope_m := _line_for("margaret_sunday", {"sermon_theme": "hope"})
	var forgive_m := _line_for("margaret_sunday", {"sermon_theme": "forgiveness"})
	var service_m := _line_for("margaret_sunday", {"sermon_theme": "service"})
	_check(hope_m.contains("repeat to the kids") and hope_m != forgive_m and forgive_m != service_m, "Margaret's follow-up changes with the theme")
	var hope_h := _line_for("harold_sunday", {"sermon_theme": "hope"})
	var forgive_h := _line_for("harold_sunday", {"sermon_theme": "forgiveness"})
	_check(hope_h.contains("east window") and forgive_h.contains("heard the name") and hope_h != forgive_h, "Harold's follow-up changes with the theme")
	var frank_heard := _line_for("frank_sunday", {"sermon_theme": "forgiveness", "frank_listened": true})
	var frank_other := _line_for("frank_sunday", {"sermon_theme": "hope", "frank_listened": true})
	var frank_invited := _line_for("frank_sunday", {"sermon_theme": "forgiveness", "frank_invited": true})
	_check(frank_heard.contains("did not say his name") and frank_other.contains("not because of the sermon") and frank_heard != frank_other, "Frank's line remembers Thursday and the sermon")
	_check(frank_invited.contains("Not both") and frank_invited != frank_heard, "inviting Frank changes his Sunday line")
	var sarah_hope := _line_for("sarah_sunday", {"sermon_theme": "hope", "sarah_heard": true})
	var sarah_work := _line_for("sarah_sunday", {"sermon_theme": "service", "sarah_heard": true})
	var sarah_invited := _line_for("sarah_sunday", {"sermon_theme": "hope"})
	_check(sarah_hope.contains("pickup line") and sarah_work.contains("side door") and sarah_hope != sarah_work, "Sarah's follow-up changes with the theme")
	_check(sarah_invited.contains("not joining") and sarah_invited != sarah_hope, "Sarah's Friday answer changes her Sunday line")
	NarrativeState.reset()
	DayClock.reset()


func _no_service_on_thursday() -> void:
	# Let _ready finish. Adding a node from inside the first setup frame is refused.
	await get_tree().process_frame
	_become_observer()
	DayClock.set_time(4, 14, 0)
	var room := await _travel_to("res://scenes/world/sanctuary.tscn")
	if room == null:
		return
	await _pump(6)
	var box := room.get_node("HUD/Banner") as DialogueBox
	_check(box != null and not box.is_conversation_open(), "Thursday does not start the service")
	_check(not NarrativeState.flag_is_true("service_complete"), "Thursday does not complete the service")


func _service_themes() -> void:
	await _run_theme(1, "forgiveness", "did not clap", "heard the name", "frank", 1)
	await _run_theme(2, "service", "permission to fix", "own screwdriver", "harold", 1)
	await _run_theme(0, "hope", "repeat to the kids", "east window", "sarah", 1)
	var room := get_tree().current_scene
	if room == null or String(room.name) != "Sanctuary":
		_check(false, "the hope service did not stay in the sanctuary")
		return
	var ledger := room.get_node("Props/Ledger") as Interactable
	var box := room.get_node("HUD/Banner") as DialogueBox
	var player := room.get_node("Props/Player") as Player
	var ending := room.get_node("ChapterEnd")
	if ledger == null or box == null or player == null or ending == null:
		_check(false, "the sanctuary is missing the ledger or the ending")
		return
	_check(ledger.visible and ledger.enabled, "Margaret's follow-up reveals the ledger")
	await _stand_at(player, ledger)
	await _tap("interact")
	_check(box.is_conversation_open(), "the ledger conversation opens")
	await _drain(box, 12)
	_check(not box.is_conversation_open(), "the ledger conversation finishes")
	_check(NarrativeState.flag_is_true("ledger_revealed"), "the ledger sets the chapter flag")
	await _pump(4)
	_check(ending.has_method("is_showing") and bool(ending.call("is_showing")), "the ledger opens the chapter ending")
	var summary := str(ending.call("body_text"))
	_check(summary.contains("oil") and summary.contains("hope"), "the ending summarizes the sermon and the money (%s)" % _snippet(summary))
	_check(NarrativeState.movement_locked(), "the ending holds the player")
	await _tap("interact")
	room = await _wait_scene("ChurchExterior")
	_check(room != null, "restart returns to the church grounds")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "restart restores Thursday afternoon")
	_check(not NarrativeState.flag_is_true("service_complete"), "restart clears the service")
	_check(str(NarrativeState.get_flag("sermon_theme", "")) == "", "restart clears the sermon")
	_check(NarrativeState.relationship("sarah") == 0 and NarrativeState.relationship("frank") == 0, "restart clears relationships")
	_check(NarrativeState.quest_status("first_sunday") == "" and NarrativeState.quest_status("spare_keys") == "", "restart clears quests")
	_check(not NarrativeState.ending_open and not NarrativeState.dialogue_open, "restart clears the menus")
	_check(not FileAccess.file_exists(SaveGame.SAVE_PATH), "restart removes the save so Continue cannot restore the ending")


func _title_and_save() -> void:
	var migrated := _write_and_read({
		"version": 1,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 6, "hour": 18, "minute": 0},
		"narrative": {"version": 1, "flags": {"sunday_ready": true}, "quests": {}, "relationships": {"sarah": 2}},
	})
	var flags: Dictionary = {}
	var narrative_v: Variant = migrated.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	var clock_v: Variant = migrated.get("clock", {})
	var clock_day := -1
	if clock_v is Dictionary:
		clock_day = int((clock_v as Dictionary).get("weekday", -1))
	_check(int(migrated.get("version", 0)) == SaveGame.SAVE_VERSION and str(flags.get("sermon_theme", "missing")) == "" and bool(flags.get("sunday_ready", false)), "a version 1 file migrates to the current save")
	_check(clock_day == 6, "migration keeps a Saturday clock")
	_write_and_read({
		"version": 2,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "up",
		"clock": {"weekday": 7, "hour": 10, "minute": 30},
		"narrative": {
			"version": 1,
			"flags": {"sermon_theme": "hope", "service_complete": true},
			"quests": {},
			"relationships": {"frank": 1},
		},
	})
	var title := await _travel_to("res://scenes/main.tscn")
	if title == null or not title.has_method("choices"):
		_check(false, "the title screen did not load")
		return
	title.call("refresh")
	await _pump(2)
	var listed: PackedStringArray = title.call("choices")
	_check(listed.has("New Game") and listed.has("Continue") and listed.has("Quit"), "the title lists New Game, Continue, and Quit (%s)" % " ".join(listed))
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_relationship("frank", 4)
	DayClock.set_time(0, 15, 0)
	SceneRouter.suppress_change = true
	await _tap("interact")
	_check(SceneRouter.last_path.ends_with("church_exterior.tscn"), "New Game targets the church grounds")
	_check(not NarrativeState.flag_is_true("service_complete") and NarrativeState.relationship("frank") == 0, "New Game clears narrative state")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "New Game starts Thursday at 2 p.m.")
	SceneRouter.suppress_change = false
	DayClock.held = true
	title.call("refresh")
	await _tap("dialogue_down")
	_check(str(title.call("current_choice")) == "Continue", "Down selects Continue")
	await _tap("interact")
	var room := await _wait_scene("ChurchExterior")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	_check(player != null and player.global_position.distance_to(Vector2(420, 510)) < 2.0, "Continue restores the saved position")
	_check(player != null and player.get_facing() == &"up", "Continue restores facing")
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 10 and DayClock.minute == 30, "Continue restores Sunday")
	_check(str(NarrativeState.get_flag("sermon_theme", "")) == "hope" and NarrativeState.flag_is_true("service_complete"), "Continue restores the sermon")
	_check(NarrativeState.relationship("frank") == 1, "Continue restores relationships")
	var again: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(again is Dictionary and int((again as Dictionary).get("version", 0)) == 2, "the slot on disk is version 2")


func _run_theme(index: int, theme: String, margaret_bit: String, harold_bit: String, npc_id: String, rel: int) -> void:
	NarrativeState.reset()
	DayClock.set_time(0, 10, 0)
	var room := await _travel_to("res://scenes/world/sanctuary.tscn")
	if room == null:
		return
	await _pump(8)
	var box := room.get_node("HUD/Banner") as DialogueBox
	var label := room.get_node("HUD/Banner/Label") as RichTextLabel
	var player := room.get_node("Props/Player") as Player
	if box == null or label == null or player == null:
		_check(false, "the sanctuary HUD is missing")
		return
	_check(box.is_conversation_open(), "the service starts at Sunday 10:00 (%s)" % theme)
	if theme == "forgiveness":
		_check(_crowd_count(room) == 12, "twelve unnamed congregants are seated")
		_check(_named_present(room) == 5, "the five named people are in the room")
		_check(_crowd_count(room) + _named_present(room) == 17, "the Sunday room holds about seventeen people")
	var reached := false
	for _i in 16:
		if label.text.contains("One theme") and label.text.contains("screwdriver") and not box.is_revealing():
			reached = true
			break
		await _tap("advance_dialogue")
	_check(reached, "the service reaches the sermon choice (%s)" % theme)
	for _i in index:
		await _tap("dialogue_down")
	await _tap("advance_dialogue")
	await _drain(box, 12)
	_check(not box.is_conversation_open() and not NarrativeState.dialogue_open, "the %s service closes without a softlock" % theme)
	_check(str(NarrativeState.get_flag("sermon_theme", "")) == theme, "the played service records %s" % theme)
	_check(NarrativeState.relationship(npc_id) == rel, "%s relationship is %d after %s" % [npc_id, rel, theme])
	var margaret := room.get_node("Props/Margaret") as Node2D
	var harold := room.get_node("Props/Harold") as Node2D
	if margaret == null or harold == null:
		_check(false, "follow-up speakers are missing")
		return
	await _speak(player, margaret, box, label)
	_check(label.text.contains(margaret_bit), "Margaret's Sunday line matches %s (%s)" % [theme, _snippet(label.text)])
	await _drain(box, 4)
	await _speak(player, harold, box, label)
	_check(label.text.contains(harold_bit), "Harold's Sunday line matches %s (%s)" % [theme, _snippet(label.text)])
	await _drain(box, 4)
	_check(not NarrativeState.movement_locked(), "follow-ups release the player (%s)" % theme)


func _speak(player: Player, npc: Node2D, box: DialogueBox, label: RichTextLabel) -> void:
	await _stand_at(player, npc)
	await _tap("interact")
	if box.is_revealing():
		await _tap("advance_dialogue")
	if label.text.is_empty() and box.is_conversation_open():
		await _tap("advance_dialogue")


func _choose_theme(index: int) -> void:
	var data := DialogueRunner.load_conversation("sunday_service")
	var runner := DialogueRunner.new()
	if not runner.start(data):
		_check(false, "service runner did not start")
		return
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	runner.choose(index)
	while runner.is_open() and guard < 16:
		runner.advance()
		guard += 1


func _line_for(conversation_id: String, flags: Dictionary) -> String:
	NarrativeState.reset()
	for key in flags.keys():
		NarrativeState.set_flag(str(key), flags[key])
	var data := DialogueRunner.load_conversation(conversation_id)
	var runner := DialogueRunner.new()
	if not runner.start(data):
		return ""
	return runner.body()


func _theme_index(theme: String) -> int:
	if theme == "forgiveness":
		return 1
	if theme == "service":
		return 2
	return 0


func _crowd_count(room: Node) -> int:
	var found := 0
	for node in get_tree().get_nodes_in_group("congregant"):
		if room.is_ancestor_of(node) and node is CanvasItem and (node as CanvasItem).visible:
			found += 1
	return found


func _named_present(room: Node) -> int:
	var found := 0
	for node_name in ["Margaret", "Harold", "Thomas", "Frank", "Sarah"]:
		var node := room.get_node_or_null("Props/" + node_name)
		if node is CanvasItem and (node as CanvasItem).visible:
			found += 1
	return found


func _write_and_read(data: Dictionary) -> Dictionary:
	var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_check(false, "could not write a save fixture")
		return {}
	file.store_string(JSON.stringify(data))
	file.close()
	return SaveGame.read_file()


func _drain(box: DialogueBox, limit: int) -> void:
	var guard := 0
	while box != null and box.is_conversation_open() and guard < limit:
		guard += 1
		await _tap("advance_dialogue")


func _travel_to(path: String) -> Node:
	_release_all()
	await _pump(1)
	_become_observer()
	SceneRouter.suppress_change = false
	SceneRouter.travel(get_tree(), path, &"default")
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
	if path.ends_with("main.tscn"):
		return "Title"
	return "ChurchExterior"


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


func _become_observer() -> void:
	var tree := get_tree()
	if tree.current_scene != self:
		return
	var host := Node.new()
	host.name = "M4SceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


func _release_all() -> void:
	for action in [
		"move_up", "move_down", "move_left", "move_right",
		"interact", "pause", "cycle_time",
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
	print("M4_OK" if not _failed else "M4_FAIL")
	tree.quit(0 if not _failed else 1)
