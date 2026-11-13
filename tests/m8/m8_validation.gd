extends Node
## Headless checks for Milestone 8 (weekly loop, funds, Fellowship Hall).
## Prints M8_OK or M8_FAIL.
## Run: godot --headless --path . res://tests/m8/m8_validation.tscn

const DATA_ROOTS: PackedStringArray = [
	"res://data/dialogue",
	"res://data/ambient",
	"res://data/interactions",
	"res://data/quests",
]
const DOLLAR_WORDS := ["dollars", "dollar", "bucks"]

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
	_economy_and_attendance()
	_expenses_and_contributions()
	_project_completion()
	_no_money_in_dialogue()
	_chapter_one_unchanged()
	await _ledger_and_display()
	await _hall_visual()
	_save_roundtrip()
	_restore_user_save()
	_finish()


func _economy_and_attendance() -> void:
	var funds := _funds()
	_check(funds != null, "ChurchFunds autoload exists")
	_check(FileAccess.file_exists("res://data/economy/economy.json"), "economy.json exists")
	_check(InputMap.has_action("ledger"), "ledger input action exists")
	_check(DayClock.week_number() == 1, "Thursday of Chapter 1 is week 1")
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(8, 6, 0)
	_check(DayClock.week_number() == 2 and DayClock.weekday_name() == "Monday", "weekday 8 is Monday of week 2")
	DayClock.set_time(14, 10, 0)
	_check(DayClock.week_number() == 2 and DayClock.weekday_name() == "Sunday", "weekday 14 is Sunday of week 2")
	NarrativeState.reset()
	NarrativeState.set_flag("frank_listened", true)
	NarrativeState.set_flag("sarah_heard", true)
	NarrativeState.set_flag("grounds_tidy", true)
	NarrativeState.set_flag("garden_planted", true)
	DayClock.set_time(14, 10, 0)
	var first: Dictionary = funds.call("preview_week", 2, "hope")
	var again: Dictionary = funds.call("preview_week", 2, "hope")
	_check(int(first.get("attendance", 0)) == int(again.get("attendance", 0)), "attendance is deterministic for a seed and week")
	_check(int(first.get("offering", 0)) == int(again.get("offering", 0)), "offering is deterministic for a seed and week")
	_check(int(first.get("attendance", 0)) >= 8, "attendance stays at least the floor (%d)" % int(first.get("attendance", 0)))
	_check(int(first.get("offering", 0)) > 0, "offering is a positive dollar amount")
	var fit: Dictionary = funds.call("preview_week", 2, "hope")
	var other: Dictionary = funds.call("preview_week", 2, "forgiveness")
	_check(int(fit.get("offering", 0)) >= int(other.get("offering", 0)), "a fitting sermon does not shrink the plate")
	NarrativeState.reset()
	DayClock.set_time(14, 10, 0)
	var low: Dictionary = funds.call("preview_week", 2, "hope")
	_check(int(low.get("attendance", 99)) <= int(first.get("attendance", 0)), "trust and invites raise turnout")
	DayClock.reset()


func _expenses_and_contributions() -> void:
	var funds := _funds()
	NarrativeState.reset()
	DayClock.set_time(14, 11, 0)
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("hall_proposed", true)
	funds.call("reset")
	funds.set("project_state", "active")
	var settled: Dictionary = funds.call("settle_sunday", "service")
	_check(int(settled.get("expenses", 0)) == int(funds.call("expense_total")), "weekly expenses match economy.json")
	_check(int(funds.call("expense_total")) == 110, "utilities and upkeep total 110")
	_check(bool(funds.call("has_pending")), "settle_sunday leaves a pending surplus")
	var surplus := int(settled.get("surplus", 0))
	_check(surplus >= 0, "surplus is never negative")
	var start_balance := int(funds.get("balance"))
	var none_amt := int(funds.call("apply_contribution", "none"))
	_check(none_amt == 0, "none sends nothing to the project")
	_check(int(funds.get("balance")) == start_balance, "none keeps the surplus in the account")
	_check(int(funds.get("project_progress")) == 0, "none does not fund the hall")
	funds.call("reset")
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("hall_proposed", true)
	funds.set("project_state", "active")
	DayClock.set_time(14, 11, 0)
	funds.call("settle_sunday", "service")
	var half_surplus := int(funds.call("pending_surplus"))
	var half_amt := int(funds.call("apply_contribution", "half"))
	_check(half_amt == half_surplus / 2, "half sends half the surplus (%d vs %d)" % [half_amt, half_surplus / 2])
	funds.call("reset")
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("hall_proposed", true)
	funds.set("project_state", "active")
	DayClock.set_time(14, 11, 0)
	funds.call("settle_sunday", "service")
	var all_surplus := int(funds.call("pending_surplus"))
	var all_amt := int(funds.call("apply_contribution", "all"))
	_check(all_amt == all_surplus, "all sends the week's surplus")
	_check(int(funds.get("project_progress")) == all_amt, "all raises hall progress by the surplus")
	DayClock.reset()


func _project_completion() -> void:
	var funds := _funds()
	NarrativeState.reset()
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_proposed", true)
	DayClock.set_time(14, 11, 0)
	funds.call("reset")
	funds.set("project_state", "active")
	funds.set("project_progress", int(funds.call("project_cost")) - 20)
	funds.set("balance", 200)
	funds.call("settle_sunday", "service")
	funds.call("apply_contribution", "all")
	_check(str(funds.get("project_state")) == "repairing", "filling the cost starts Harold's repair week")
	_check(NarrativeState.flag_is_true("hall_repairing"), "repairing sets the hall_repairing flag")
	DayClock.set_time(15, 6, 0)
	_check(str(funds.get("project_state")) == "repairing", "the next morning is still a work week")
	DayClock.set_time(22, 6, 0)
	_check(str(funds.get("project_state")) == "repaired", "the hall flips after the work week (%s week %d)" % [str(funds.get("project_state")), DayClock.week_number()])
	_check(NarrativeState.flag_is_true("hall_repaired"), "repaired sets the hall_repaired flag")
	var runner := DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("weekly_service")), "weekly service loads")
	var weekly := DialogueRunner.load_conversation("weekly_service")
	_check(_conversation_has(weekly, "Fellowship Hall has been boarded"), "Margaret proposes the hall without naming money")
	_check(not _conversation_has_money(weekly), "the hall proposal has no dollar amounts")
	DayClock.reset()


func _no_money_in_dialogue() -> void:
	var hits: PackedStringArray = PackedStringArray()
	hits.append_array(_scan_dir("res://data/dialogue"))
	_check(hits.is_empty(), "no dialogue line contains $ or a dollar amount%s" % ("" if hits.is_empty() else " (%s)" % " | ".join(hits)))
	var cult_hits: PackedStringArray = PackedStringArray()
	for root in DATA_ROOTS:
		cult_hits.append_array(_scan_cult(root, false))
	_check(cult_hits.is_empty(), "no member line contains cult")


func _chapter_one_unchanged() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var service := DialogueRunner.load_conversation("sunday_service")
	_check(not service.is_empty(), "the first Sunday service still loads")
	var runner := DialogueRunner.new()
	runner.start(service)
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	_check(runner.choice_count() == 3, "the first Sunday still offers hope, forgiveness, and service")
	NarrativeState.reset()
	runner = DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("sunday_ledger")), "the Chapter 1 ledger still loads")
	guard = 0
	while runner.is_open() and guard < 8:
		runner.advance()
		guard += 1
	_check(NarrativeState.flag_is_true("ledger_revealed") and NarrativeState.flag_is_true("chapter_one_complete"), "Chapter 1 still completes from the ledger")
	_check(not NarrativeState.flag_is_true("weekly_loop"), "the Chapter 1 ledger does not start the weekly loop")
	DayClock.set_time(7, 15, 0)
	DayClock.sleep_until_morning()
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 15, "before Continue, Sunday sleep still does not add a Monday")
	DayClock.reset()


func _ledger_and_display() -> void:
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("chapter_one_complete", true)
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(8, 6, 0)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(4)
	var card := room.get_node_or_null("HUD/DayCard") as DayCard
	_check(DayClock.week_number() == 2, "the clock counts week 2 on the first Monday after Chapter 1")
	if card != null:
		card.call("_show_card")
		_check(card.card_text().contains("Week 2"), "the day card shows Week N (%s)" % _snippet(card.card_text()))
		card.call("_close_card")
	var ledger := room.get_node_or_null("HUD/LedgerScreen")
	_check(ledger != null, "the HUD has a ledger screen")
	await _tap("ledger")
	_check(ledger != null and ledger.has_method("is_open") and bool(ledger.call("is_open")), "L opens the ledger")
	_check(NarrativeState.ledger_open and NarrativeState.movement_locked(), "the ledger holds the player")
	var body := ""
	if ledger.has_method("_body_text"):
		body = str(ledger.call("_body_text"))
	_check(body.contains("$") and body.contains("Balance"), "the ledger shows dollar amounts")
	_check(body.contains("Margaret still notes a deposit"), "the ledger reuses the unrecognized-deposit seed")
	var journal := room.get_node_or_null("HUD/Journal")
	var blob := " ".join(NarrativeState.growth_lines())
	if journal != null and journal.has_method("_body_text"):
		blob += " " + str(journal.call("_body_text"))
	var phase := room.get_node_or_null("HUD/PhaseLabel") as Label
	var clock := room.get_node_or_null("HUD/ClockLabel") as Label
	if phase != null:
		blob += " " + phase.text
	if clock != null:
		blob += " " + clock.text
	blob += " " + body
	var lower := blob.to_lower()
	_check(not lower.contains("pull") and not lower.contains("storefront") and not lower.contains("dependent"), "Pull is not displayed")
	_check(not _contains_trust_number(blob), "trust and relationship numbers are not rendered")
	await _tap("pause")
	_check(ledger != null and not bool(ledger.call("is_open")), "Esc closes the ledger")
	room.free()
	await get_tree().process_frame


func _hall_visual() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var worn_room := _instance("res://scenes/world/church_exterior.tscn")
	if worn_room == null:
		return
	await _pump(3)
	var hall := worn_room.get_node_or_null("Props/FellowshipHall")
	_check(hall != null, "the Fellowship Hall stands on the church grounds")
	_check(hall != null and not NarrativeState.flag_is_true("hall_repaired"), "the hall starts boarded")
	if hall != null and hall.has_method("is_repaired_look"):
		_check(not bool(hall.call("is_repaired_look")), "the worn hall uses the boarded look")
	worn_room.free()
	await get_tree().process_frame
	NarrativeState.set_flag("hall_repaired", true)
	var fixed_room := _instance("res://scenes/world/church_exterior.tscn")
	if fixed_room == null:
		return
	await _pump(3)
	hall = fixed_room.get_node_or_null("Props/FellowshipHall")
	if hall != null and hall.has_method("apply_clock"):
		hall.call("apply_clock")
	_check(hall != null and hall.has_method("is_repaired_look") and bool(hall.call("is_repaired_look")), "the repaired hall uses the open look")
	var runner := DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("hall_celebration")), "the celebratory hall conversation loads")
	_check(_conversation_has(DialogueRunner.load_conversation("hall_celebration"), "potluck"), "Harold names a potluck")
	_check(HappeningSchedule.is_active("wednesday_potluck", "Wednesday", 12, 0) == true, "the potluck happening is active after the hall is repaired")
	fixed_room.free()
	await get_tree().process_frame


func _save_roundtrip() -> void:
	var funds := _funds()
	var inf := get_node_or_null("/root/InfluenceState")
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 9, 0)
	NarrativeState.set_flag("weekly_loop", true)
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_proposed", true)
	if inf != null and inf.has_method("set_chapter"):
		inf.call("set_chapter", "2")
	funds.call("reset")
	funds.set("project_state", "active")
	funds.set("project_progress", 400)
	funds.set("balance", 220)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	if player == null:
		_check(false, "save round-trip needs the player")
		room.free()
		return
	player.global_position = Vector2(420, 510)
	var saved := SaveGame.save_to_disk(get_tree())
	_check(saved, "a current-version save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary, "the save file is an object")
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == SaveGame.SAVE_VERSION, "the save file is the current version")
	_check(row.has("funds"), "the save stores funds")
	var funds_row: Dictionary = row.get("funds", {}) if row.get("funds", {}) is Dictionary else {}
	_check(int(funds_row.get("balance", -1)) == 220 and int(funds_row.get("project_progress", -1)) == 400, "the save round-trips funds")
	NarrativeState.reset()
	_check(int(funds.get("balance")) == 55, "reset restores the Chapter 1 starting balance")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == SaveGame.SAVE_VERSION, "read_file keeps the current version")
	SaveGame.apply_state(loaded)
	_check(int(funds.get("balance")) == 220 and int(funds.get("project_progress")) == 400, "load restores funds")
	_check(NarrativeState.flag_is_true("weekly_loop"), "load restores the weekly loop")
	_check(str(inf.call("chapter")) == "2" if inf != null else true, "load restores chapter 2")
	var from_v4 := SaveGame.migrate({
		"version": 4,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 8, "hour": 9, "minute": 0},
		"chapter": "",
		"influence": {"seats": 0, "storefronts": 0, "dependents": 0, "total": 0, "stage": 1, "chapter": ""},
		"narrative": {
			"flags": {"week_continues": true, "frank_listened": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v4.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 4 file migrates to the current save")
	var migrated_funds_v: Variant = from_v4.get("funds", {})
	var migrated_funds: Dictionary = migrated_funds_v if migrated_funds_v is Dictionary else {}
	_check(int(migrated_funds.get("balance", -1)) == 55 and str(migrated_funds.get("project_state", "")) == "none", "v4 migration adds starting funds")
	var flags: Dictionary = {}
	var narrative_v: Variant = from_v4.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	_check(bool(flags.get("weekly_loop", false)), "v4 week_continues gains the weekly loop")
	_check(str(from_v4.get("chapter", "")) == "2", "v4 continued weeks migrate to chapter 2")
	_check(bool(flags.get("frank_listened", false)), "v4 migration keeps the old story")
	var from_v3 := SaveGame.migrate({
		"version": 3,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"frank_listened": true}, "quests": {}, "relationships": {}},
	})
	_check(int(from_v3.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 3 file migrates to the current save")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	room.free()


func _conversation_has(data: Dictionary, needle: String) -> bool:
	var nodes_v: Variant = data.get("nodes", {})
	if not nodes_v is Dictionary:
		return false
	for node_id in (nodes_v as Dictionary).keys():
		var node_v: Variant = (nodes_v as Dictionary)[node_id]
		if not node_v is Dictionary:
			continue
		var node: Dictionary = node_v
		if str(node.get("text", "")).contains(needle):
			return true
		var choices_v: Variant = node.get("choices", [])
		if not choices_v is Array:
			continue
		for choice_v in choices_v as Array:
			if choice_v is Dictionary and str((choice_v as Dictionary).get("text", "")).contains(needle):
				return true
	return false


func _conversation_has_money(data: Dictionary) -> bool:
	return not _scan_value(data, "weekly_service").is_empty()


func _scan_dir(path: String) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	var dir := DirAccess.open(path)
	if dir == null:
		return hits
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var child := path.path_join(name)
		if dir.current_is_dir():
			hits.append_array(_scan_dir(child))
		elif name.ends_with(".json"):
			var parsed: Variant = JsonFile.read(child)
			hits.append_array(_scan_value(parsed, child))
		name = dir.get_next()
	dir.list_dir_end()
	return hits


func _scan_value(value: Variant, path: String) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	if value is Dictionary:
		var row: Dictionary = value
		for key in row.keys():
			hits.append_array(_scan_value(row[key], path))
		return hits
	if value is Array:
		for item in value as Array:
			hits.append_array(_scan_value(item, path))
		return hits
	if value is String:
		var text := str(value)
		if text.contains("$"):
			hits.append("%s: %s" % [path, text])
			return hits
		var lower := text.to_lower()
		for word in DOLLAR_WORDS:
			if lower.contains(word):
				hits.append("%s: %s" % [path, text])
				return hits
	return hits


func _scan_cult(path: String, outsider: bool) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	var dir := DirAccess.open(path)
	if dir == null:
		return hits
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var child := path.path_join(name)
		if dir.current_is_dir():
			hits.append_array(_scan_cult(child, outsider))
		elif name.ends_with(".json"):
			hits.append_array(_scan_cult_value(JsonFile.read(child), outsider, child))
		name = dir.get_next()
	dir.list_dir_end()
	return hits


func _scan_cult_value(value: Variant, outsider: bool, path: String) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	if value is Dictionary:
		var row: Dictionary = value
		var tagged := outsider or bool(row.get("outsider", false)) or str(row.get("tag", "")) == "outsider"
		for key in row.keys():
			hits.append_array(_scan_cult_value(row[key], tagged, path))
		return hits
	if value is Array:
		for item in value as Array:
			hits.append_array(_scan_cult_value(item, outsider, path))
		return hits
	if value is String:
		var text := str(value)
		if text.to_lower().contains("cult") and not outsider:
			hits.append("%s: %s" % [path, text])
	return hits


func _contains_trust_number(blob: String) -> bool:
	var lower := blob.to_lower()
	if lower.contains("trust: 0") or lower.contains("trust: 1") or lower.contains("trust: 2"):
		return true
	if lower.contains("relationship") and (lower.contains("+1") or lower.contains("-1")):
		return true
	return false


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


func _instance(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	_check(room != null, "instantiate " + path)
	if room == null:
		return null
	add_child(room)
	return room


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
		"journal", "ledger", "advance_dialogue", "dialogue_up", "dialogue_down",
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
	print("M8_OK" if not _failed else "M8_FAIL")
	tree.quit(0 if not _failed else 1)
