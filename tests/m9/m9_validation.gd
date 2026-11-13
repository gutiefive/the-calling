extends Node
## Headless checks for Milestone 9 (branching foundation).
## Prints M9_OK or M9_FAIL.
## Run: godot --headless --path . res://tests/m9/m9_validation.tscn

const DATA_ROOTS: PackedStringArray = [
	"res://data/dialogue",
	"res://data/ambient",
	"res://data/interactions",
	"res://data/quests",
	"res://data/story",
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
	GameSettings.inner_voice = true
	NarrativeState.reset()
	DayClock.reset()
	_nudge_and_dominant()
	_dialogue_conditions()
	_two_playthroughs()
	_threads_and_miss()
	await _journal_threads()
	_run_seed()
	_save_roundtrip()
	_no_cult_or_money()
	_default_chapter_one()
	_restore_user_save()
	_finish()


func _nudge_and_dominant() -> void:
	var path := _path()
	_check(path != null, "PastorPath autoload exists")
	if path == null:
		return
	path.call("reset")
	_check(str(path.call("dominant")) == "", "dominant is empty at the start")
	_check(not bool(path.call("lean_at_least", "shepherd", 1)), "lean_at_least is false at zero")
	path.call("nudge", "shepherd", 1, "t_shepherd")
	_check(bool(path.call("lean_at_least", "shepherd", 1)), "nudge raises shepherd")
	_check(str(path.call("dominant")) == "shepherd", "a unique lead is dominant")
	path.call("nudge", "shepherd", 1, "t_shepherd")
	_check(bool(path.call("has_reason", "t_shepherd")), "reason_ids are recorded")
	var stacked: Variant = path.call("to_dictionary")
	var stacked_n := -1
	if stacked is Dictionary:
		stacked_n = int((stacked as Dictionary).get("shepherd", -1))
	_check(stacked_n == 1, "the same reason_id does not stack")
	path.call("nudge", "builder", 1, "t_builder")
	_check(str(path.call("dominant")) == "", "a tie is not a dominant leaning")
	path.call("nudge", "builder", 1, "t_builder2")
	_check(str(path.call("dominant")) == "builder", "the higher unique leaning leads")
	path.call("nudge", "skeptic", 3, "t_skeptic")
	_check(str(path.call("dominant")) == "skeptic", "skeptic can lead")
	path.call("reset")
	_check(str(path.call("dominant")) == "" and int(path.call("run_seed")) == 8, "reset clears leanings and restores the default seed")


func _dialogue_conditions() -> void:
	var path := _path()
	var threads := _threads()
	NarrativeState.reset()
	var runner := DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("lean_check")), "lean_check loads")
	_check(runner.body() == "no lean", "no leaning routes to none")
	path.call("nudge", "shepherd", 1, "cond_shepherd")
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("lean_check"))
	_check(runner.body() == "shepherd lean", "lean_at_least routes when shepherd is 1")
	path.call("nudge", "builder", 2, "cond_builder")
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("lean_check"))
	_check(runner.body() == "builder lead", "dominant_is routes when builder leads")
	NarrativeState.reset()
	threads.call("open", "frank_grief")
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("lean_check"))
	_check(runner.body() == "grief open", "thread_is routes when frank_grief is open")
	NarrativeState.reset()
	runner = DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("lean_nudge")), "lean_nudge loads")
	_check(runner.choice_count() == 1, "lean_nudge offers a choice")
	runner.choose(0)
	_check(bool(path.call("has_reason", "lean_check")), "a nudge effect records its reason")
	_check(bool(path.call("lean_at_least", "shepherd", 1)), "a nudge effect raises shepherd")
	_check(bool(threads.call("is_state", "reece_mystery", "open")), "a thread effect can open a thread")
	NarrativeState.reset()


func _two_playthroughs() -> void:
	var shepherd := _scripted_run(true)
	var builder := _scripted_run(false)
	_check(str(shepherd.get("dominant", "")) == "shepherd", "a listening run leans shepherd (%s)" % str(shepherd.get("dominant", "")))
	_check(str(builder.get("dominant", "")) == "builder", "a pressing run leans builder (%s)" % str(builder.get("dominant", "")))
	_check(str(shepherd.get("frank_thread", "")) == "advanced", "listening opens frank_grief and later advances it")
	_check(str(builder.get("frank_thread", "")) == "missed", "pressing misses frank_grief")
	_check(str(shepherd.get("frank_later", "")).contains("porch light"), "listening later hears a memory of Frank's wife (%s)" % _snippet(str(shepherd.get("frank_later", ""))))
	_check(not str(builder.get("frank_later", "")).contains("porch light"), "pressing never hears that memory")
	_check(str(shepherd.get("sarah_thread", "")) == "open", "welcoming Sarah opens sarah_belonging")
	_check(str(builder.get("sarah_thread", "")) == "invited", "inviting Sarah sets a thinner belonging")
	_check(str(shepherd.get("sarah_later", "")).contains("nursery"), "Sarah's later line remembers being heard (%s)" % _snippet(str(shepherd.get("sarah_later", ""))))
	_check(str(builder.get("sarah_later", "")).contains("not making a new promise"), "inviting Sarah keeps the thinner later line")
	_check(str(shepherd.get("ostrow_thread", "")) == "cool", "the polite Ostrow choice is cool")
	_check(str(builder.get("ostrow_thread", "")) == "open", "the warm Ostrow choice opens an alliance")
	_check(str(builder.get("ostrow_week", "")).contains("people who like to see a church"), "warm Ostrow hints at later support without amounts (%s)" % _snippet(str(builder.get("ostrow_week", ""))))
	_check(str(shepherd.get("ostrow_week", "")).contains("not writing anything down"), "the polite Ostrow week line stays cool")
	_check(str(shepherd.get("thought", "")).contains("nobody needed more"), "the inner voice follows a shepherd lead (%s)" % _snippet(str(shepherd.get("thought", ""))))
	_check(str(builder.get("thought", "")).contains("could be a start"), "the inner voice follows a builder lead (%s)" % _snippet(str(builder.get("thought", ""))))
	_check(str(shepherd.get("lean_walk", "")).contains("Mrs. Hale"), "a weekly happening follows a shepherd lead (%s)" % _snippet(str(shepherd.get("lean_walk", ""))))
	_check(str(builder.get("lean_walk", "")).contains("means to grow"), "a weekly happening follows a builder lead")
	_check(str(shepherd.get("bark", "")).contains("Mrs. Hale"), "a weekday bark follows a shepherd lead")
	_check(str(builder.get("bark", "")).contains("means to keep it"), "a weekday bark follows a builder lead")
	_check(shepherd.get("frank_line", "") != builder.get("frank_line", ""), "the two Thursday Frank endings differ")
	NarrativeState.reset()
	DayClock.reset()


func _threads_and_miss() -> void:
	var threads := _threads()
	NarrativeState.reset()
	_check(threads.call("open", "frank_grief") == true, "a new thread can open")
	_check(bool(threads.call("is_state", "frank_grief", "open")), "open stores the open state")
	_check(threads.call("advance", "frank_grief") == true, "an open thread can advance")
	_check(bool(threads.call("is_state", "frank_grief", "advanced")), "advance stores the advanced state")
	_check(threads.call("miss", "frank_grief") == true, "an advanced thread can still be lost")
	_check(bool(threads.call("is_missed", "frank_grief")), "missed is remembered")
	_check(threads.call("open", "frank_grief") == false, "a missed thread never reopens")
	_check(bool(threads.call("is_missed", "frank_grief")), "open after miss keeps it missed")
	_check(threads.call("set_state", "frank_grief", "open") == false, "set_state cannot revive a missed thread")
	threads.call("open", "ostrow_alliance")
	threads.call("set_state", "ostrow_alliance", "guarded")
	_check(bool(threads.call("is_state", "ostrow_alliance", "guarded")), "named thread states can be set")
	NarrativeState.set_flag("has_reece_key", true)
	_check(threads.call("inspect_reece_key") == true, "inspecting Reece's key opens reece_mystery")
	_check(bool(threads.call("is_state", "reece_mystery", "open")), "reece_mystery is open after inspect")
	NarrativeState.set_flag("garden_planted", true)
	_check(bool(threads.call("is_state", "garden_growth", "open")), "planting the garden opens garden_growth")
	var shown := threads.call("journal_lines") as PackedStringArray
	var blob := " ".join(shown)
	_check(blob.contains("extra key"), "the journal names the extra key in words")
	_check(blob.contains("garden is in the ground"), "the journal names the garden in words")
	_check(not blob.contains("missed"), "missed threads do not list themselves")
	NarrativeState.reset()


func _journal_threads() -> void:
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("has_reece_key", true)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(3)
	var journal := room.get_node_or_null("HUD/Journal")
	_check(journal != null, "the HUD has a journal")
	if journal != null and journal.has_method("_set_open"):
		journal.call("_set_open", true)
	var body := ""
	if journal != null and journal.has_method("_body_text"):
		body = str(journal.call("_body_text"))
	_check(body.contains("Threads"), "the journal has a Threads section")
	_check(body.contains("extra key") or body.contains("Pastor Reece"), "inspecting the journal records Reece's key in words (%s)" % _snippet(body))
	_check(not _has_meter_number(body), "the Threads section does not show numbers")
	_check(not body.to_lower().contains("shepherd:") and not body.to_lower().contains("builder:"), "leanings are not printed")
	if journal != null and journal.has_method("_set_open"):
		journal.call("_set_open", false)
	room.free()
	await get_tree().process_frame
	NarrativeState.reset()


func _run_seed() -> void:
	var path := _path()
	var funds := _funds()
	NarrativeState.reset()
	path.call("set_seed", 8)
	DayClock.set_time(14, 10, 0)
	var first: Dictionary = funds.call("preview_week", 2, "hope")
	var again: Dictionary = funds.call("preview_week", 2, "hope")
	_check(int(first.get("attendance", 0)) == int(again.get("attendance", 0)), "the same seed repeats attendance")
	path.call("set_seed", 11)
	var other: Dictionary = funds.call("preview_week", 2, "hope")
	_check(int(first.get("attendance", 0)) != int(other.get("attendance", 0)), "a different seed can change attendance")
	NarrativeState.set_flag("week_continues", true)
	path.call("set_seed", 8)
	_check(HappeningSchedule.is_active("seed_porch", "Monday", 10, 0), "seed 8 shows the porch card")
	_check(not HappeningSchedule.is_active("seed_creek", "Monday", 10, 0), "seed 8 hides the creek boat")
	path.call("set_seed", 9)
	_check(not HappeningSchedule.is_active("seed_porch", "Monday", 10, 0), "seed 9 hides the porch card")
	_check(HappeningSchedule.is_active("seed_creek", "Monday", 10, 0), "seed 9 shows the creek boat")
	path.call("set_seed", 8)
	var shift_a := int(path.call("crowd_shift"))
	path.call("set_seed", 9)
	var shift_b := int(path.call("crowd_shift"))
	_check(shift_a != shift_b, "different seeds rotate which neighbor stays out")
	NarrativeState.reset()
	DayClock.reset()


func _save_roundtrip() -> void:
	var path := _path()
	var threads := _threads()
	var inf := get_node_or_null("/root/InfluenceState")
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 9, 0)
	path.call("nudge", "shepherd", 2, "save_shepherd")
	path.call("set_seed", 42)
	threads.call("open", "frank_grief")
	threads.call("advance", "frank_grief")
	NarrativeState.set_flag("weekly_loop", true)
	if inf != null and inf.has_method("set_chapter"):
		inf.call("set_chapter", "2")
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
	_check(saved, "a version 6 save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary, "the save file is an object")
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == 6, "the save file is version 6")
	_check(row.has("pastor_path") and row.has("threads") and row.has("run_seed"), "version 6 stores pastor_path, threads, and run_seed")
	_check(int(row.get("run_seed", 0)) == 42, "the save stores the run seed")
	NarrativeState.reset()
	_check(str(path.call("dominant")) == "" and int(path.call("run_seed")) == 8, "reset clears path before load")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == 6, "read_file keeps version 6")
	SaveGame.apply_state(loaded)
	_check(str(path.call("dominant")) == "shepherd", "load restores shepherd")
	_check(int(path.call("run_seed")) == 42, "load restores the run seed")
	_check(bool(threads.call("is_state", "frank_grief", "advanced")), "load restores threads")
	var from_v5 := SaveGame.migrate({
		"version": 5,
		"scene": "res://scenes/world/church_exterior.tscn",
		"funds": {"balance": 80, "project_state": "none", "project_progress": 0},
		"narrative": {"flags": {"frank_listened": true}, "quests": {}, "relationships": {}},
	})
	_check(int(from_v5.get("version", 0)) == 6, "a version 5 file migrates to version 6")
	_check(int(from_v5.get("run_seed", 0)) == 8, "v5 migration adds the default run seed")
	var migrated_path_v: Variant = from_v5.get("pastor_path", {})
	var migrated_path: Dictionary = migrated_path_v if migrated_path_v is Dictionary else {}
	_check(int(migrated_path.get("shepherd", -1)) == 0, "v5 migration adds empty leanings")
	var from_v4 := SaveGame.migrate({
		"version": 4,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"week_continues": true, "frank_listened": true}, "quests": {}, "relationships": {}},
	})
	_check(int(from_v4.get("version", 0)) == 6, "a version 4 file migrates to version 6")
	_check(from_v4.has("funds") and from_v4.has("pastor_path"), "v4 migration adds funds and branching")
	var from_v3 := SaveGame.migrate({
		"version": 3,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"frank_listened": true}, "quests": {}, "relationships": {}},
	})
	_check(int(from_v3.get("version", 0)) == 6, "a version 3 file migrates to version 6")
	_check(SaveGame.migrate({"version": 7, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	room.free()
	NarrativeState.reset()


func _no_cult_or_money() -> void:
	var money: PackedStringArray = PackedStringArray()
	money.append_array(_scan_money("res://data/dialogue"))
	_check(money.is_empty(), "no dialogue line contains $ or a dollar amount%s" % ("" if money.is_empty() else " (%s)" % " | ".join(money)))
	var cult_hits: PackedStringArray = PackedStringArray()
	for root in DATA_ROOTS:
		cult_hits.append_array(_scan_cult(root, false))
	_check(cult_hits.is_empty(), "no member line contains cult%s" % ("" if cult_hits.is_empty() else " (%s)" % " | ".join(cult_hits)))


func _default_chapter_one() -> void:
	NarrativeState.reset()
	DayClock.reset()
	GameSettings.inner_voice = true
	NarrativeState.set_step("oak_street", "frank")
	var runner := DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("frank"))
	_check(runner.choice_count() == 2, "Frank's Thursday visit still offers listen or invite")
	runner.choose(0)
	_check(runner.body().contains("unheard"), "the default Frank choice still listens")
	NarrativeState.reset()
	NarrativeState.set_step("oak_street", "friday")
	DayClock.set_time(5, 10, 0)
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("sarah"))
	_check(runner.choice_count() == 2, "Sarah's Friday visit still offers hear or invite")
	runner.choose(0)
	_check(runner.body().contains("nursery"), "the default Sarah choice still hears her")
	NarrativeState.reset()
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("ostrow"))
	_check(runner.body().contains("Pastor Reece and I got a lot done together"), "Ostrow's greeting is unchanged")
	_check(runner.choice_count() == 3, "Ostrow now offers three responses")
	runner.choose(0)
	_check(str(_threads().call("state_of", "ostrow_alliance")) == "cool", "the first Ostrow choice stays politely noncommittal")
	NarrativeState.reset()
	var service := DialogueRunner.load_conversation("sunday_service")
	runner = DialogueRunner.new()
	runner.start(service)
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	_check(runner.choice_count() == 3, "the first Sunday still offers hope, forgiveness, and service")
	runner.choose(0)
	_check(runner.is_thought() and runner.body().contains("Maybe too good"), "the default inner voice is unchanged")
	runner.advance()
	_check(runner.body().contains("small church"), "the default hope sermon is unchanged")
	NarrativeState.reset()
	runner = DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("sunday_ledger")), "the Chapter 1 ledger still loads")
	guard = 0
	while runner.is_open() and guard < 8:
		runner.advance()
		guard += 1
	_check(NarrativeState.flag_is_true("ledger_revealed") and NarrativeState.flag_is_true("chapter_one_complete"), "Chapter 1 still completes from the ledger")
	DayClock.reset()


func _scripted_run(listening: bool) -> Dictionary:
	var path := _path()
	var threads := _threads()
	NarrativeState.reset()
	DayClock.reset()
	GameSettings.inner_voice = true
	NarrativeState.set_step("oak_street", "frank")
	var runner := DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("frank"))
	runner.choose(0 if listening else 1)
	var frank_line := runner.body()
	NarrativeState.set_step("oak_street", "friday")
	DayClock.set_time(5, 10, 0)
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("sarah"))
	runner.choose(0 if listening else 1)
	NarrativeState.complete_quest("oak_street")
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("ostrow"))
	runner.choose(0 if listening else 1)
	var service := DialogueRunner.load_conversation("sunday_service")
	runner = DialogueRunner.new()
	runner.start(service)
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	runner.choose(0 if listening else 2)
	var thought := ""
	if runner.is_thought():
		thought = runner.body()
		runner.advance()
	while runner.is_open() and guard < 16:
		runner.advance()
		guard += 1
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(8, 10, 0)
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("frank"))
	var frank_later := runner.body()
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("sarah"))
	var sarah_later := runner.body()
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("ostrow"))
	var ostrow_week := runner.body()
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("happening_lean_walk"))
	var lean_walk := runner.body()
	var bark := AmbientBarks.line("ada", "Monday", "Day")
	return {
		"dominant": str(path.call("dominant")),
		"frank_thread": str(threads.call("state_of", "frank_grief")),
		"sarah_thread": str(threads.call("state_of", "sarah_belonging")),
		"ostrow_thread": str(threads.call("state_of", "ostrow_alliance")),
		"frank_line": frank_line,
		"frank_later": frank_later,
		"sarah_later": sarah_later,
		"ostrow_week": ostrow_week,
		"thought": thought,
		"lean_walk": lean_walk,
		"bark": bark,
	}


func _path() -> Node:
	return get_node_or_null("/root/PastorPath")


func _threads() -> Node:
	return get_node_or_null("/root/StoryThreads")


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


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _has_meter_number(body: String) -> bool:
	var lower := body.to_lower()
	if lower.contains("shepherd: 1") or lower.contains("builder: 1") or lower.contains("skeptic: 1"):
		return true
	if lower.contains("+1") or lower.contains("-1") or lower.contains("leaning"):
		return true
	return false


func _scan_money(path: String) -> PackedStringArray:
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
			hits.append_array(_scan_money(child))
		elif name.ends_with(".json"):
			hits.append_array(_scan_money_value(JsonFile.read(child), child))
		name = dir.get_next()
	dir.list_dir_end()
	return hits


func _scan_money_value(value: Variant, path: String) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	if value is Dictionary:
		var row: Dictionary = value
		for key in row.keys():
			hits.append_array(_scan_money_value(row[key], path))
		return hits
	if value is Array:
		for item in value as Array:
			hits.append_array(_scan_money_value(item, path))
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
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("M9_OK" if not _failed else "M9_FAIL")
	tree.quit(0 if not _failed else 1)
