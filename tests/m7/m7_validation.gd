extends Node
## Headless checks for Milestone 7 (seeds and influence).
## Prints M7_OK or M7_FAIL.
## Run: godot --headless --path . res://tests/m7/m7_validation.tscn

const OSTROW_SHEET := "res://assets/characters/npc_ostrow_sheet.png"
const FACINGS: PackedStringArray = ["down", "up", "left", "right"]
const DATA_ROOTS: PackedStringArray = [
	"res://data/dialogue",
	"res://data/ambient",
	"res://data/interactions",
	"res://data/quests",
]

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
	_influence_and_conditions()
	_seed_lines()
	_reece_name()
	_pull_choices()
	_thoughts()
	_no_cult()
	await _ostrow_and_hud()
	_save_roundtrip()
	_chapter_one_still_completes()
	_restore_user_save()
	_finish()


func _influence_and_conditions() -> void:
	var inf := get_node_or_null("/root/InfluenceState")
	_check(inf != null, "InfluenceState autoload exists")
	if inf == null:
		return
	inf.call("reset")
	_check(int(inf.call("pull_total")) == 0, "Pull starts at 0")
	_check(int(inf.call("pull_part", "seats")) == 0 and int(inf.call("pull_part", "storefronts")) == 0 and int(inf.call("pull_part", "dependents")) == 0, "Pull parts start at 0")
	_check(int(inf.call("influence_stage")) == 1, "ladder stage starts at trust")
	_check(bool(inf.call("influence_stage_at_least", 1)) and not bool(inf.call("pull_at_least", 1)), "stage 1 holds and Pull is not yet 1")
	inf.call("add_pull", 2)
	_check(int(inf.call("pull_total")) == 2 and bool(inf.call("pull_at_least", 2)), "add_pull raises the general total")
	inf.call("add_pull", 1, "seats")
	_check(int(inf.call("pull_part", "seats")) == 1 and int(inf.call("pull_total")) == 3, "add_pull can target a part")
	var runner := DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("influence_check")), "influence_check loads")
	_check(runner.body() == "high pull", "pull_at_least routes when Pull is high")
	inf.call("reset")
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("influence_check"))
	_check(runner.body() == "trust stage", "influence_stage_at_least routes at trust")
	inf.call("reset")


func _seed_lines() -> void:
	var ledger := DialogueRunner.load_conversation("sunday_ledger")
	_check(_conversation_has(ledger, "account I don't recognize"), "the ledger names unrecognized deposits")
	_check(_conversation_has(ledger, "week before a council vote"), "the deposits land the week before a council vote")
	var keys := DialogueRunner.load_conversation("margaret")
	_check(_conversation_has(keys, "Pastor Reece kept that one on him"), "Margaret names Reece's spare key")
	_check(_conversation_has(keys, "fits nothing"), "the extra key fits nothing")
	NarrativeState.reset()
	NarrativeState.set_flag("keys_approach", "search")
	NarrativeState.start_quest("spare_keys")
	NarrativeState.set_step("spare_keys", "return")
	var runner := DialogueRunner.new()
	runner.start(keys)
	_check(NarrativeState.flag_is_true("has_reece_key"), "returning the ring stores Reece's key")
	var sunday := DialogueRunner.load_conversation("margaret_sunday")
	_check(_conversation_has(sunday, "Thank you, Shepherd"), "Margaret says Shepherd")
	_check(_conversation_has(sunday, "That's what we called him"), "she corrects Shepherd to Pastor")
	var ostrow := DialogueRunner.load_conversation("ostrow")
	_check(_conversation_has(ostrow, "Pastor Reece and I got a lot done together"), "Ostrow names the work with Reece")
	var garden := AmbientBarks.line("ruth", "Thursday", "Day")
	_check(garden.contains("how you learn who'll show up"), "Ruth's garden line names Reece's saying (%s)" % _snippet(garden))
	var frank_sun := DialogueRunner.load_conversation("frank_sunday")
	_check(_conversation_has(frank_sun, "Don't spend it"), "Frank's Don't spend it line is still there")
	var sat := NpcSchedule.placement("ostrow", "Saturday", 12, 0)
	var thu := NpcSchedule.placement("ostrow", "Thursday", 14, 0)
	_check(str(sat.get("scene", "")) == "church_exterior" and thu.is_empty(), "Ostrow is on the church walk Saturday daytime")


func _reece_name() -> void:
	var frank := DialogueRunner.load_conversation("frank")
	_check(_conversation_has(frank, "Pastor Reece"), "Frank names Pastor Reece")
	_check(not _conversation_has(frank, "The last pastor"), "Frank no longer says the last pastor")
	var service := DialogueRunner.load_conversation("sunday_service")
	_check(_conversation_has(service, "Alden Reece"), "the service names Alden Reece")


func _pull_choices() -> void:
	var inf := get_node_or_null("/root/InfluenceState")
	if inf == null:
		return
	NarrativeState.reset()
	NarrativeState.set_step("oak_street", "frank")
	var frank := DialogueRunner.load_conversation("frank")
	var runner := DialogueRunner.new()
	runner.start(frank)
	_check(runner.choice_count() == 2, "Frank's Thursday visit still offers listen or invite")
	runner.choose(1)
	_check(int(inf.call("pull_total")) == 1, "pressing Frank toward Sunday adds 1 Pull")
	NarrativeState.reset()
	NarrativeState.set_step("oak_street", "frank")
	runner = DialogueRunner.new()
	runner.start(frank)
	runner.choose(0)
	_check(int(inf.call("pull_total")) == -1, "listening to Frank subtracts 1 Pull")
	NarrativeState.reset()
	NarrativeState.set_step("oak_street", "friday")
	DayClock.set_time(5, 10, 0)
	var sarah := DialogueRunner.load_conversation("sarah")
	runner = DialogueRunner.new()
	runner.start(sarah)
	_check(runner.choice_count() == 2, "Sarah's Friday visit still offers hear or invite")
	runner.choose(1)
	_check(int(inf.call("pull_total")) == 1, "inviting Sarah instead of hearing her adds 1 Pull")
	NarrativeState.reset()
	NarrativeState.set_step("oak_street", "friday")
	DayClock.set_time(5, 10, 0)
	runner = DialogueRunner.new()
	runner.start(sarah)
	runner.choose(0)
	_check(int(inf.call("pull_total")) == -1, "hearing Sarah subtracts 1 Pull")
	_check(NarrativeState.flag_is_true("sarah_heard") and NarrativeState.relationship("sarah") == 1, "hearing Sarah still records the old outcome")
	DayClock.reset()


func _thoughts() -> void:
	GameSettings.inner_voice = true
	NarrativeState.reset()
	var service := DialogueRunner.load_conversation("sunday_service")
	var runner := DialogueRunner.new()
	runner.start(service)
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	_check(runner.choice_count() == 3, "the sermon still offers three themes")
	runner.choose(0)
	_check(runner.is_thought() and runner.body().contains("Maybe too good"), "a thought follows the sermon choice")
	GameSettings.inner_voice = false
	NarrativeState.reset()
	runner = DialogueRunner.new()
	runner.start(service)
	guard = 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		runner.advance()
		guard += 1
	runner.choose(0)
	_check(not runner.is_thought() and runner.body().contains("small church"), "the thought toggle skips the inner voice")
	GameSettings.inner_voice = true
	_check(str(NarrativeState.get_flag("sermon_theme", "")) == "hope", "the sermon outcome is unchanged when the thought is off")


func _no_cult() -> void:
	var hits: PackedStringArray = PackedStringArray()
	for root in DATA_ROOTS:
		hits.append_array(_scan_dir(root, false))
	_check(hits.is_empty(), "no member line contains cult%s" % ("" if hits.is_empty() else " (%s)" % " | ".join(hits)))


func _ostrow_and_hud() -> void:
	_check(FileAccess.file_exists(OSTROW_SHEET), "Ostrow sheet exists")
	var allowed := _palette_keys()
	_check(not allowed.is_empty(), "master palette loaded")
	if FileAccess.file_exists(OSTROW_SHEET):
		var bytes := FileAccess.get_file_as_bytes(OSTROW_SHEET)
		var image := Image.new()
		var loaded := image.load_png_from_buffer(bytes)
		_check(loaded == OK and image.get_width() == 192 and image.get_height() == 192, "Ostrow sheet is 192x192")
		if loaded == OK:
			var off := _first_off_palette(image, allowed)
			_check(off.is_empty(), "Ostrow uses only palette colors%s" % ("" if off.is_empty() else " (%s)" % off))
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(6, 12, 0)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(4)
	var ostrow := room.get_node_or_null("Props/Ostrow") as DialogueNpc
	_check(ostrow != null, "Ostrow is wired on the church grounds")
	if ostrow != null:
		_check(ostrow.npc_id == "ostrow" and ostrow.dialogue_id == "ostrow", "Ostrow uses his dialogue and schedule id")
		_check(ostrow.visible and ostrow.enabled, "Ostrow is on the walk Saturday daytime")
		_check_actor_frames(ostrow.get_node_or_null("Sprite") as AnimatedSprite2D)
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
	var lower := blob.to_lower()
	_check(not lower.contains("pull") and not lower.contains("storefront") and not lower.contains("dependent"), "Pull is not displayed in journal or HUD text")
	room.free()
	await get_tree().process_frame


func _save_roundtrip() -> void:
	var inf := get_node_or_null("/root/InfluenceState")
	if inf == null:
		return
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	inf.call("add_pull", 2)
	inf.call("add_pull", 1, "seats")
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
	_check(row.has("influence") and row.has("chapter"), "the save stores influence and chapter")
	_check(str(row.get("chapter", "missing")) == "", "chapter is empty in Chapter 1")
	var influence_v: Variant = row.get("influence", {})
	var influence: Dictionary = influence_v if influence_v is Dictionary else {}
	_check(int(influence.get("total", -1)) == 3 and int(influence.get("seats", -1)) == 1, "the save round-trips Pull")
	NarrativeState.reset()
	_check(int(inf.call("pull_total")) == 0, "reset clears Pull before load")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == SaveGame.SAVE_VERSION, "read_file keeps the current version")
	SaveGame.apply_state(loaded)
	_check(int(inf.call("pull_total")) == 3 and int(inf.call("pull_part", "seats")) == 1, "load restores Pull")
	_check(str(inf.call("chapter")) == "", "load restores the empty chapter")
	var from_v3 := SaveGame.migrate({
		"version": 3,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 4, "hour": 14, "minute": 0},
		"narrative": {
			"flags": {"frank_listened": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v3.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 3 file migrates to the current save")
	var migrated_inf_v: Variant = from_v3.get("influence", {})
	var migrated_inf: Dictionary = migrated_inf_v if migrated_inf_v is Dictionary else {}
	_check(int(migrated_inf.get("total", -1)) == 0 and int(migrated_inf.get("stage", 0)) == 1, "v3 migration adds empty Pull at trust")
	_check(str(from_v3.get("chapter", "missing")) == "", "v3 migration adds an empty chapter")
	var flags: Dictionary = {}
	var narrative_v: Variant = from_v3.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	_check(bool(flags.get("frank_listened", false)), "v3 migration keeps the old story")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	room.free()


func _chapter_one_still_completes() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var runner := DialogueRunner.new()
	_check(runner.start(DialogueRunner.load_conversation("sunday_ledger")), "the ledger still loads")
	var guard := 0
	while runner.is_open() and guard < 8:
		runner.advance()
		guard += 1
	_check(not runner.is_open(), "the ledger conversation still finishes")
	_check(NarrativeState.flag_is_true("ledger_revealed") and NarrativeState.flag_is_true("chapter_one_complete"), "Chapter 1 still completes from the ledger")
	_check(NarrativeState.quest_status("first_sunday") == "completed", "First Sunday still completes")
	_check(str(NarrativeState.get_flag("sermon_theme", "")) == "", "the ledger still does not invent a sermon")


func _check_actor_frames(sprite: AnimatedSprite2D) -> void:
	_check(sprite != null, "Ostrow has an AnimatedSprite2D")
	if sprite == null:
		return
	var frames := sprite.sprite_frames
	_check(frames != null, "Ostrow has SpriteFrames")
	if frames == null:
		return
	for facing in FACINGS:
		var idle_name := facing + "_idle"
		var walk_name := facing + "_walk"
		_check(frames.has_animation(idle_name), "Ostrow has %s" % idle_name)
		_check(frames.has_animation(walk_name), "Ostrow has %s" % walk_name)
		if frames.has_animation(idle_name):
			_check(frames.get_frame_count(idle_name) == 2, "Ostrow %s is 2 frames" % idle_name)
		if frames.has_animation(walk_name):
			_check(frames.get_frame_count(walk_name) == 4, "Ostrow %s is 4 frames" % walk_name)
			var speed := frames.get_animation_speed(walk_name)
			_check(speed >= 8.0 and speed <= 10.0, "Ostrow walk is 8-10 fps")
	if not frames.has_animation("down_idle") or frames.get_frame_count("down_idle") < 1:
		return
	var tex := frames.get_frame_texture("down_idle", 0)
	var atlas := tex as AtlasTexture
	_check(atlas != null and atlas.atlas != null, "Ostrow frames use an atlas")
	if atlas == null or atlas.atlas == null:
		return
	_check(atlas.region.size == Vector2(32, 48), "Ostrow cell is 32x48")
	var path := atlas.atlas.resource_path
	_check(path == OSTROW_SHEET or path.ends_with("npc_ostrow_sheet.png"), "Ostrow uses npc_ostrow_sheet.png")


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
		if str(node.get("thought", "")).contains(needle):
			return true
		var choices_v: Variant = node.get("choices", [])
		if not choices_v is Array:
			continue
		for choice_v in choices_v as Array:
			if choice_v is Dictionary and str((choice_v as Dictionary).get("text", "")).contains(needle):
				return true
	return false


func _scan_dir(path: String, outsider: bool) -> PackedStringArray:
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
			hits.append_array(_scan_dir(child, outsider))
		elif name.ends_with(".json"):
			var parsed: Variant = JsonFile.read(child)
			hits.append_array(_scan_value(parsed, outsider, child))
		name = dir.get_next()
	dir.list_dir_end()
	return hits


func _scan_value(value: Variant, outsider: bool, path: String) -> PackedStringArray:
	var hits: PackedStringArray = PackedStringArray()
	if value is Dictionary:
		var row: Dictionary = value
		var tagged := outsider or bool(row.get("outsider", false)) or str(row.get("tag", "")) == "outsider"
		for key in row.keys():
			hits.append_array(_scan_value(row[key], tagged, path))
		return hits
	if value is Array:
		for item in value as Array:
			hits.append_array(_scan_value(item, outsider, path))
		return hits
	if value is String:
		var text := str(value)
		if text.to_lower().contains("cult") and not outsider:
			hits.append("%s: %s" % [path, text])
	return hits


func _palette_keys() -> Dictionary:
	var allowed: Dictionary = {}
	var text := FileAccess.get_file_as_string("res://assets/source/palette/the_calling_master.gpl")
	for line in text.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.is_empty() or trimmed.begins_with("#") or trimmed.begins_with("GIMP") or trimmed.begins_with("Name:") or trimmed.begins_with("Columns:"):
			continue
		var parts := trimmed.split(" ", false)
		if parts.size() < 3:
			continue
		allowed["%s,%s,%s" % [parts[0], parts[1], parts[2]]] = true
	return allowed


func _first_off_palette(image: Image, allowed: Dictionary) -> String:
	for y in image.get_height():
		for x in image.get_width():
			var px: Color = image.get_pixel(x, y)
			if px.a <= 0.001:
				continue
			var key := "%d,%d,%d" % [roundi(px.r * 255.0), roundi(px.g * 255.0), roundi(px.b * 255.0)]
			if not allowed.has(key):
				return "%s at %d,%d" % [key, x, y]
	return ""


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
	NarrativeState.reset()
	DayClock.reset()
	GameSettings.inner_voice = true
	print("M7_OK" if not _failed else "M7_FAIL")
	get_tree().quit(0 if not _failed else 1)
