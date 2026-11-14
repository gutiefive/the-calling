extends Node
## Headless checks for Milestone 14 (opening intro).
## Prints M14_OK or M14_FAIL.
## Run: godot --headless --path . res://tests/m14/m14_validation.tscn
##
## Old-test hook: SaveGame.bypass_intro = true makes New Game land on the church
## grounds, the way it did before M14. tests/m4/m4_validation.gd is the only
## existing suite that starts New Game and expects that landing.

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const GROUNDS := "res://scenes/world/church_exterior.tscn"
const INTRO := "res://scenes/intro/intro_cutscene.tscn"
const TITLE := "res://scenes/main.tscn"

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	_reset_story()
	_data_and_art()
	await _clock_holds_during_intro()
	await _skip_lands_on_thursday()
	_bypass_hook()
	await _continue_bypasses_intro()
	await _primer_once()
	_save_and_migration()
	await _title_lists_watch_intro()
	_journal_wording()
	_restore_user_save()
	_finish()


func _data_and_art() -> void:
	_check(FileAccess.file_exists("res://data/intro.json"), "intro data file exists")
	_check(FileAccess.file_exists(INTRO), "intro scene exists")
	var data := IntroData.load_data()
	_check(not data.is_empty(), "intro data loads")
	var rows := IntroData.beats(data)
	_check(rows.size() >= IntroData.MIN_BOXES and rows.size() <= IntroData.MAX_BOXES, "text box count %d is within %d-%d" % [rows.size(), IntroData.MIN_BOXES, IntroData.MAX_BOXES])
	for beat_v in rows:
		_check(beat_v is Dictionary, "each beat is an object")
		if not beat_v is Dictionary:
			continue
		var beat: Dictionary = beat_v
		var panel := IntroData.beat_panel(beat)
		_check(IntroFrames.has_panel(panel), "beat %s references a valid panel (%s)" % [IntroData.beat_id(beat), panel])
		var image := IntroFrames.build(panel)
		_check(image != null and image.get_width() >= 64 and image.get_height() >= 64, "panel %s is drawn" % panel)
	var issues := IntroData.issues(data)
	_check(issues.is_empty(), "intro text stays inside the length, panel, and wording rules")
	for issue in issues:
		_check(false, issue)
	var goals := IntroData.goals(data)
	var primer := IntroData.primer(data)
	_check(not str(goals.get("title", "")).is_empty(), "goals have a title")
	_check(not str(primer.get("title", "")).is_empty(), "the primer has a title")
	_check(SaveGame.SAVE_VERSION == 11, "save version stays 11")


func _clock_holds_during_intro() -> void:
	_reset_story()
	DayClock.held = false
	SceneRouter.suppress_change = true
	var intro := _instance(INTRO)
	if intro == null:
		SceneRouter.suppress_change = false
		return
	var before_day := DayClock.weekday
	var before_hour := DayClock.hour
	var before_minute := DayClock.minute
	await _pump(8)
	_check(DayClock.held, "the intro holds DayClock")
	_check(DayClock.weekday == before_day and DayClock.hour == before_hour and DayClock.minute == before_minute, "DayClock does not advance during the intro")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "the intro still sits on Thursday 2:00 p.m.")
	if intro.has_method("advance"):
		intro.call("advance")
		intro.call("advance")
		_check(int(intro.call("beat_index")) >= 1, "E advances an intro beat")
	intro.free()
	SceneRouter.suppress_change = false
	await _pump(1)


func _skip_lands_on_thursday() -> void:
	_reset_story()
	SaveGame.bypass_intro = false
	SaveGame.intro_replay = false
	SceneRouter.suppress_change = true
	SaveGame.begin_new_game(get_tree())
	_check(SceneRouter.last_path.ends_with("intro_cutscene.tscn"), "New Game opens the intro")
	var intro := _instance(INTRO)
	if intro == null:
		SceneRouter.suppress_change = false
		return
	intro.call("skip_to_end")
	_check(SceneRouter.last_path.ends_with("church_exterior.tscn"), "skip lands on the church grounds")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14 and DayClock.minute == 0, "skip keeps Thursday 2:00 p.m.")
	_check(NarrativeState.flag_is_true("intro_seen"), "skip records that the intro was seen")
	_check(not NarrativeState.flag_is_true("service_complete"), "skip does not set story flags")
	_check(NarrativeState.relationship("frank") == 0, "skip leaves relationships at zero")
	_check(NarrativeState.active_quests().is_empty(), "skip leaves quests empty")
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		_check(int(pack.call("occupied_slots")) == 0, "skip leaves the pack empty")
		_check(int(pack.call("cash")) == Catalog.starting_cash(), "starting wallet is unchanged")
	_check(SaveGame.pending_opening_handoff, "skip still hands off the goals primer")
	intro.free()
	SceneRouter.suppress_change = false
	SaveGame.pending_opening_handoff = false
	await _pump(1)


func _bypass_hook() -> void:
	_reset_story()
	SceneRouter.suppress_change = true
	SaveGame.bypass_intro = true
	SaveGame.begin_new_game(get_tree())
	SaveGame.bypass_intro = false
	_check(SceneRouter.last_path.ends_with("church_exterior.tscn"), "the test hook lands New Game on the grounds")
	_check(not NarrativeState.flag_is_true("intro_seen"), "the test hook does not mark the intro seen")
	_check(not SaveGame.pending_opening_handoff, "the test hook does not open the primer")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "the test hook still starts Thursday at 2 p.m.")
	SceneRouter.suppress_change = false


func _continue_bypasses_intro() -> void:
	_reset_story()
	NarrativeState.set_flag("service_complete", true)
	DayClock.set_time(6, 18, 0)
	_write_save({
		"version": 11,
		"scene": GROUNDS,
		"position": [420, 510],
		"facing": "up",
		"clock": {"weekday": 6, "hour": 18, "minute": 0},
		"narrative": {
			"version": 1,
			"flags": {"service_complete": true, "primer_seen": true},
			"quests": {},
			"relationships": {"frank": 1},
		},
	})
	SceneRouter.suppress_change = true
	var loaded := SaveGame.load_from_disk(get_tree())
	await _pump(3)
	_check(loaded, "Continue reads the save")
	_check(not SaveGame.pending_opening_handoff, "Continue does not queue the intro primer")
	_check(SceneRouter.last_path.ends_with("church_exterior.tscn"), "Continue loads the saved room, not the intro")
	_check(NarrativeState.flag_is_true("service_complete"), "Continue keeps story flags")
	_check(NarrativeState.flag_is_true("primer_seen"), "Continue keeps primer_seen")
	SceneRouter.suppress_change = false


func _primer_once() -> void:
	_reset_story()
	SaveGame.pending_opening_handoff = true
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	await _pump(4)
	var handoff := hud.get_node_or_null("OpeningHandoff")
	_check(handoff != null, "the HUD has the opening handoff")
	if handoff == null:
		hud.free()
		return
	_check(bool(handoff.call("is_open")) and str(handoff.call("current_phase")) == "goals", "the goals panel shows after the intro")
	var goals_text := str(handoff.call("body_text"))
	_check(goals_text.contains("Get into the church"), "the goals panel names getting into the church")
	_check(goals_text.contains("first Sunday"), "the goals panel names the first Sunday")
	_check(goals_text.contains("Oakridge"), "the goals panel names Oakridge")
	_check(goals_text.find("$") < 0, "the goals panel has no dollar sign")
	handoff.call("dismiss")
	_check(str(handoff.call("current_phase")) == "primer", "dismissing goals shows the controls primer")
	var primer_text := str(handoff.call("body_text"))
	_check(primer_text.contains("WASD") and primer_text.contains("journal") and primer_text.contains("pack"), "the primer lists walk, journal, and pack")
	_check(primer_text.contains("pause") and primer_text.contains("skip the clock"), "the primer lists pause and the clock skip")
	handoff.call("dismiss")
	_check(not bool(handoff.call("is_open")), "dismissing the primer closes it")
	_check(NarrativeState.flag_is_true("primer_seen"), "the primer records that it was seen")
	_check(not SaveGame.pending_opening_handoff, "the primer clears the pending handoff")
	_check(not NarrativeState.primer_open, "the primer releases movement")
	hud.free()
	await _pump(1)
	SaveGame.pending_opening_handoff = true
	var again := _instance("res://scenes/ui/hud.tscn")
	if again == null:
		return
	await _pump(4)
	var handoff2 := again.get_node_or_null("OpeningHandoff")
	_check(handoff2 != null and not bool(handoff2.call("is_open")), "the primer does not show again after it was seen")
	again.free()
	await _pump(1)
	NarrativeState.reset()
	SaveGame.pending_opening_handoff = false
	var loaded := _instance("res://scenes/ui/hud.tscn")
	if loaded == null:
		return
	await _pump(4)
	var handoff3 := loaded.get_node_or_null("OpeningHandoff")
	_check(handoff3 != null and not bool(handoff3.call("is_open")), "load without a pending handoff does not show the primer")
	loaded.free()
	await _pump(1)


func _save_and_migration() -> void:
	var from_v10 := SaveGame.migrate({
		"version": 10,
		"scene": GROUNDS,
		"narrative": {"flags": {"week_continues": true}},
	})
	_check(int(from_v10.get("version", 0)) == 11, "a version 10 file still migrates to version 11")
	var flags: Dictionary = {}
	var narrative_v: Variant = from_v10.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	_check(not bool(flags.get("intro_seen", false)), "an old save does not invent intro_seen")
	NarrativeState.from_dictionary({"flags": {"intro_seen": true, "primer_seen": true}})
	var captured := NarrativeState.to_dictionary()
	var out_flags: Dictionary = {}
	var out_v: Variant = captured.get("flags", {})
	if out_v is Dictionary:
		out_flags = out_v
	_check(bool(out_flags.get("intro_seen", false)) and bool(out_flags.get("primer_seen", false)), "intro_seen and primer_seen round-trip in the narrative blob")
	_check(SaveGame.migrate({"version": 12, "scene": GROUNDS}).is_empty(), "a newer save is still rejected")


func _title_lists_watch_intro() -> void:
	var title := _instance(TITLE)
	if title == null:
		return
	title.call("refresh")
	var listed: PackedStringArray = title.call("choices")
	_check(listed.has("New Game") and listed.has("Watch Intro") and listed.has("Quit"), "the title lists New Game, Watch Intro, and Quit")
	SceneRouter.suppress_change = true
	SaveGame.begin_intro_replay(get_tree())
	_check(SceneRouter.last_path.ends_with("intro_cutscene.tscn"), "Watch Intro opens the intro")
	_check(SaveGame.intro_replay, "Watch Intro is a replay")
	var intro := _instance(INTRO)
	if intro != null:
		intro.call("skip_to_end")
		_check(SceneRouter.last_path.ends_with("main.tscn"), "replay skip returns to the title")
		_check(not SaveGame.pending_opening_handoff, "replay does not start Thursday")
		intro.free()
	SceneRouter.suppress_change = false
	title.free()
	await _pump(1)


func _journal_wording() -> void:
	NarrativeState.reset()
	var notes := NarrativeState.journal_notes()
	_check(notes.size() == 1, "the first journal note is still the Oak Street hint")
	_check(notes[0].find("Oak Street") >= 0, "the Oak Street hint still names the street")
	_check(notes[0].find("meet the town") >= 0, "the Oak Street hint names meeting the town")


func _reset_story() -> void:
	NarrativeState.reset()
	DayClock.reset()
	SaveGame.bypass_intro = false
	SaveGame.pending_opening_handoff = false
	SaveGame.intro_replay = false
	var pack := get_node_or_null("/root/Inventory")
	if pack != null and pack.has_method("reset"):
		pack.call("reset")


func _write_save(data: Dictionary) -> void:
	var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_check(false, "could not write a save fixture")
		return
	file.store_string(JSON.stringify(data))
	file.close()


func _instance(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var node := packed.instantiate()
	if node == null:
		return null
	add_child(node)
	return node


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _restore_user_save() -> void:
	SaveGame.bypass_intro = false
	SaveGame.pending_opening_handoff = false
	SaveGame.intro_replay = false
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
	SaveGame.bypass_intro = false
	SaveGame.pending_opening_handoff = false
	SaveGame.intro_replay = false
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("M14_OK" if not _failed else "M14_FAIL")
	tree.quit(0 if not _failed else 1)
