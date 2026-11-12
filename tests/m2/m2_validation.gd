extends Node
## Headless checks for Milestone 2. Prints M2_OK or M2_FAIL.
## Run: godot --headless --path . res://tests/m2/m2_validation.tscn

var _failed: bool = false
var _search_line: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	NarrativeState.reset()
	_static_checks()
	if not _failed:
		await _play_search_branch()
	if not _failed:
		await _play_harold_branch()
	_check_roundtrip()
	_finish()


func _static_checks() -> void:
	for path in [
		"res://data/dialogue/margaret.json",
		"res://data/dialogue/harold.json",
		"res://data/quests/chapter1.json",
		"res://data/interactions/spare_key_ring.json",
		"res://scripts/systems/narrative_state.gd",
		"res://scripts/dialogue/dialogue_runner.gd",
		"res://scripts/ui/dialogue_box.gd",
		"res://scripts/ui/journal_panel.gd",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	_check(get_node_or_null("/root/NarrativeState") != null, "NarrativeState autoload is present")
	for action in ["journal", "advance_dialogue", "dialogue_up", "dialogue_down"]:
		_check(InputMap.has_action(action), "input action " + action)
		if InputMap.has_action(action):
			_check(InputMap.action_get_events(action).size() > 0, action + " has a key")
	_check(_action_has_key("journal", KEY_J), "journal is bound to J")
	_check(_action_has_key("advance_dialogue", KEY_SPACE), "advance_dialogue is bound to Space")
	_check(_action_has_key("advance_dialogue", KEY_ENTER), "advance_dialogue is bound to Enter")
	_check(_action_has_key("dialogue_up", KEY_UP), "dialogue_up is bound to Up")
	_check(_action_has_key("dialogue_down", KEY_DOWN), "dialogue_down is bound to Down")
	for action in ["move_up", "move_down", "move_left", "move_right", "interact", "pause", "cycle_time"]:
		_check(InputMap.has_action(action), "M1 input action " + action)
	var harold_tex := PlaceholderArt.by_id("harold")
	var key_tex := PlaceholderArt.by_id("keys")
	_check(harold_tex != null and harold_tex.get_size() == Vector2(64, 48), "harold sheet is two frames")
	_check(key_tex != null and key_tex.get_size() == Vector2(32, 32), "key ring placeholder is 32x32")
	_check(NarrativeState.quest_title("spare_keys") == "The Spare Keys", "quest catalog loaded")
	_check(not NarrativeState.movement_locked(), "movement starts unlocked")
	var margaret := DialogueRunner.load_conversation("margaret")
	var harold := DialogueRunner.load_conversation("harold")
	_check(not margaret.is_empty() and not harold.is_empty(), "dialogue files load")
	var runner := DialogueRunner.new()
	_check(runner.start(harold), "harold conversation starts")
	_check(runner.speaker() == "Harold" and runner.body().contains("carpet"), "harold introduces himself before any quest")
	NarrativeState.reset()
	runner = DialogueRunner.new()
	_check(runner.start(margaret), "margaret conversation starts")
	_check(runner.body().contains("front step"), "margaret still opens on the step")
	runner.advance()
	_check(runner.choice_count() == 2, "margaret offers two choices")
	runner.choose(1)
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "search", "runner choice sets keys_approach")
	_check(NarrativeState.quest_status("spare_keys") == "active", "runner choice starts the quest")
	_check(NarrativeState.quest_step("spare_keys") == "search", "runner choice sets the search step")
	NarrativeState.reset()


func _play_search_branch() -> void:
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var margaret := room.get_node("Props/Margaret") as SpeechProp
	var notice := room.get_node("Props/Notice") as SpeechProp
	_check(margaret != null, "Margaret is still a speech prop")
	_check(notice != null and notice.line.contains("Sunday"), "the notice keeps its one line")
	var box := room.get_node("HUD/Banner") as DialogueBox
	var label := room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "exterior is missing player, Margaret, or the dialogue box")
		room.free()
		return

	await _stand_at(player, margaret)
	await _tap("interact")
	_check(box.is_conversation_open(), "dialogue opens")
	_check(label.text.contains("Margaret"), "the box names Margaret")
	_check(box.is_revealing(), "the line reveals over time")
	_check(not label.text.contains("front step"), "the first line is still revealing (%s)" % _snippet(label.text))
	_check(NarrativeState.movement_locked(), "dialogue locks movement")
	var origin := player.global_position
	Input.action_press("move_right")
	await _pump(18)
	var locked_dist := player.global_position.distance_to(origin)
	Input.action_release("move_right")
	await _pump(2)
	_check(locked_dist < 1.0, "holding D does not move the player during dialogue (%s)" % snappedf(locked_dist, 0.1))
	_check(box.is_conversation_open(), "dialogue stays open while movement is locked")

	await _tap("advance_dialogue")
	_check(not box.is_revealing(), "Space skips the reveal")
	_check(label.text.contains("front step"), "skip shows the rest of the line (%s)" % _snippet(label.text))
	_check(not label.text.contains("off its hook"), "skip does not advance yet")
	await _tap("interact")
	await _tap("advance_dialogue")
	_check(label.text.contains("off its hook"), "E then Space reaches the choice line (%s)" % _snippet(label.text))
	_check(label.text.contains("> I'll ask Harold."), "the first choice starts selected")
	await _tap("dialogue_down")
	_check(label.text.contains("> I'll look around first."), "Down moves the selection")
	await _tap("dialogue_up")
	_check(label.text.contains("> I'll ask Harold."), "Up moves the selection back")
	await _tap("dialogue_down")
	await _tap("interact")
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "search", "the choice sets the search flag")
	_check(NarrativeState.quest_status("spare_keys") == "active", "the quest is active")
	_check(NarrativeState.quest_step("spare_keys") == "search", "the quest step is search")
	await _tap("advance_dialogue")
	_check(label.text.contains("stacked chairs"), "Margaret points at the chairs (%s)" % _snippet(label.text))
	await _tap("interact")
	_check(not box.is_conversation_open(), "dialogue closes")
	_check(not NarrativeState.movement_locked(), "movement unlocks when dialogue closes")

	origin = player.global_position
	Input.action_press("move_right")
	await _pump(18)
	var moved := player.global_position.distance_to(origin)
	Input.action_release("move_right")
	await _pump(2)
	_check(moved > 8.0, "movement works after dialogue (%s px)" % snappedf(moved, 0.1))

	await _tap("journal")
	var journal := room.get_node("HUD/Journal")
	var body := room.get_node("HUD/Journal/Body") as Label
	_check(journal.visible, "journal opens")
	_check(body != null and body.text.contains("The Spare Keys"), "journal lists the quest")
	_check(body != null and body.text.contains("sanctuary"), "journal shows the current objective (%s)" % _snippet(body.text if body != null else ""))
	_check(NarrativeState.movement_locked(), "journal locks movement")
	await _tap("journal")
	_check(not journal.visible, "journal closes")
	_check(not NarrativeState.movement_locked(), "closing the journal unlocks movement")

	await _stand_at(player, notice)
	await _tap("interact")
	_check(not box.is_conversation_open(), "the notice is not a conversation")
	_check(label.text.contains("Sunday"), "the notice still uses the one-line banner")

	var approach := str(NarrativeState.get_flag("keys_approach", ""))
	room.free()
	_check(str(NarrativeState.get_flag("keys_approach", "")) == approach, "the flag survives leaving the room")
	room = await _travel_to("res://scenes/world/sanctuary.tscn", &"from_exterior")
	if room == null:
		return
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "search", "the flag survives the sanctuary transition")
	_check(NarrativeState.quest_step("spare_keys") == "search", "the quest step survives the sanctuary transition")
	player = room.get_node("Props/Player") as Player
	journal = room.get_node("HUD/Journal")
	body = room.get_node("HUD/Journal/Body") as Label
	await _tap("journal")
	_check(journal.visible and body != null and body.text.contains("The Spare Keys"), "journal in the new room reads the same quest")
	await _tap("journal")

	var keys := room.get_node("Props/KeyRing") as Node2D
	if player == null or keys == null:
		_check(false, "sanctuary is missing the player or the key ring")
		return
	await _stand_at(player, keys)
	await _tap("interact")
	_check(NarrativeState.flag_is_true("has_spare_keys"), "picking up the ring sets the flag")
	_check(NarrativeState.quest_step("spare_keys") == "return", "the pickup advances the quest")
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	_check(label != null and label.text.contains("spare key ring"), "the pickup line is shown")

	room = await _travel_to("res://scenes/world/church_exterior.tscn", &"from_sanctuary")
	if room == null:
		return
	_check(NarrativeState.flag_is_true("has_spare_keys"), "the key flag survives the return outside")
	player = room.get_node("Props/Player") as Player
	margaret = room.get_node("Props/Margaret") as SpeechProp
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "returned exterior is missing Margaret")
		return
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(box.is_conversation_open(), "Margaret's return line opens")
	_check(NarrativeState.quest_status("spare_keys") == "completed", "turning the keys in completes the quest")
	await _tap("advance_dialogue")
	_search_line = label.text
	_check(label.text.contains("committee"), "searching first changes Margaret's thanks (%s)" % _snippet(label.text))
	await _tap("interact")
	_check(not box.is_conversation_open(), "the return line closes")
	await _tap("journal")
	body = room.get_node("HUD/Journal/Body") as Label
	_check(body != null and body.text.contains("No active quests."), "the journal clears the active list")
	_check(body != null and body.text.contains("Completed") and body.text.contains("The Spare Keys"), "the journal lists the finished quest")
	await _tap("journal")
	NarrativeState.reset()
	_check(NarrativeState.quest_status("spare_keys") == "", "reset clears quest state for the other branch")


func _play_harold_branch() -> void:
	var room := get_tree().current_scene
	if room == null or String(room.name) != "ChurchExterior":
		room = await _travel_to("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var margaret := room.get_node("Props/Margaret") as Node2D
	var box := room.get_node("HUD/Banner") as DialogueBox
	var label := room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "harold branch is missing Margaret")
		return
	await _stand_at(player, margaret)
	await _tap("interact")
	await _tap("advance_dialogue")
	await _tap("interact")
	await _tap("advance_dialogue")
	_check(label.text.contains("> I'll ask Harold."), "the harold branch offers the same choices")
	await _tap("interact")
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "harold", "asking Harold sets the other flag")
	_check(NarrativeState.quest_step("spare_keys") == "talk_harold", "the quest step is to talk to Harold")
	await _tap("advance_dialogue")
	_check(label.text.contains("office lock"), "Margaret sends you to Harold (%s)" % _snippet(label.text))
	await _tap("interact")
	_check(not box.is_conversation_open(), "Margaret's send-off closes")

	room = await _travel_to("res://scenes/world/sanctuary.tscn", &"from_exterior")
	if room == null:
		return
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "harold", "the harold flag survives another transition")
	player = room.get_node("Props/Player") as Player
	var harold := room.get_node("Props/Harold") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or harold == null or box == null or label == null:
		_check(false, "sanctuary is missing Harold")
		return
	await _stand_at(player, harold)
	await _tap("interact")
	_check(box.is_conversation_open(), "Harold's dialogue opens")
	_check(NarrativeState.flag_is_true("harold_told"), "Harold's line sets a flag")
	_check(NarrativeState.quest_step("spare_keys") == "pickup", "Harold advances the quest to the pickup")
	await _tap("advance_dialogue")
	_check(label.text.contains("not hiding"), "Harold's voice is his own (%s)" % _snippet(label.text))
	_check(label.text.contains("Harold"), "the box names Harold")
	await _tap("interact")
	_check(not box.is_conversation_open(), "Harold's line closes")

	var keys := room.get_node("Props/KeyRing") as Node2D
	if keys == null:
		_check(false, "sanctuary is missing the key ring on the harold branch")
		return
	await _stand_at(player, keys)
	await _tap("interact")
	_check(NarrativeState.quest_step("spare_keys") == "return", "the ring still finishes the middle step")

	room = await _travel_to("res://scenes/world/church_exterior.tscn", &"from_sanctuary")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	margaret = room.get_node("Props/Margaret") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "final exterior is missing Margaret")
		return
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(NarrativeState.quest_status("spare_keys") == "completed", "the harold branch also completes")
	await _tap("advance_dialogue")
	_check(label.text.contains("He told you"), "asking Harold changes the thanks (%s)" % _snippet(label.text))
	_check(label.text != _search_line, "the two completion lines differ")
	await _tap("interact")


func _check_roundtrip() -> void:
	var snap := NarrativeState.to_dictionary()
	_check(int(snap.get("version", 0)) == 1, "the state payload has a version")
	var flags_v: Variant = snap.get("flags", {})
	var flags := flags_v as Dictionary if flags_v is Dictionary else {}
	_check(str(flags.get("keys_approach", "")) == "harold", "the payload keeps the flag")
	NarrativeState.reset()
	_check(NarrativeState.quest_status("spare_keys") == "", "reset clears a completed quest")
	NarrativeState.from_dictionary(snap)
	_check(str(NarrativeState.get_flag("keys_approach", "")) == "harold", "from_dictionary restores the flag")
	_check(NarrativeState.quest_status("spare_keys") == "completed", "from_dictionary restores the quest")


func _instance(path: String) -> Node:
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
	host.name = "M2SceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


func _travel_to(path: String, spawn: StringName) -> Node:
	_release_all()
	await _pump(1)
	_become_observer()
	SceneRouter.suppress_change = false
	SceneRouter.travel(get_tree(), path, spawn)
	var want := "Sanctuary" if path.ends_with("sanctuary.tscn") else "ChurchExterior"
	_check(SceneRouter.last_path.ends_with(path.trim_prefix("res://")), "router records %s" % path.get_file())
	for _i in 60:
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
		"interact", "pause", "cycle_time",
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


func _snippet(text: String) -> String:
	var flat := text.replace("\n", " | ")
	if flat.length() > 160:
		return flat.substr(0, 160)
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
	print("M2_OK" if not _failed else "M2_FAIL")
	tree.quit(0 if not _failed else 1)
