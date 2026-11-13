extends Node
## Flags, quests, and relationship values that outlive a room change.
## SaveGame writes to_dictionary() into the versioned user:// file.

signal story_changed

const SAVE_VERSION := 1

const OAK_HINT := "The lane east of the church grounds leads to Oak Street."

var dialogue_open: bool = false
var journal_open: bool = false
var ending_open: bool = false
var map_open: bool = false
var day_card_open: bool = false
var ledger_open: bool = false
var inventory_open: bool = false
var shop_open: bool = false

var _flags: Dictionary = {}
var _quests: Dictionary = {}
var _relationships: Dictionary = {}
var _notes: Array[String] = []
var _catalog: Dictionary = {}
## Soft church measures. Attendance is kept as a signal and is not a score.
var _growth: Dictionary = {
	"congregation_health": 0,
	"community_trust": 0,
	"community_impact": 0,
	"facility_condition": 0,
	"attendance": 17,
}


func _ready() -> void:
	_load_catalog("res://data/quests/chapter1.json")


func movement_locked() -> bool:
	return dialogue_open or journal_open or ending_open or map_open or day_card_open or ledger_open or inventory_open or shop_open


func set_dialogue_open(is_open: bool) -> void:
	dialogue_open = is_open


func set_journal_open(is_open: bool) -> void:
	journal_open = is_open


func set_map_open(is_open: bool) -> void:
	map_open = is_open


func set_inventory_open(is_open: bool) -> void:
	inventory_open = is_open


func set_shop_open(is_open: bool) -> void:
	shop_open = is_open


func reset() -> void:
	_flags.clear()
	_quests.clear()
	_relationships.clear()
	_notes.clear()
	_growth = _fresh_growth()
	dialogue_open = false
	journal_open = false
	ending_open = false
	map_open = false
	day_card_open = false
	ledger_open = false
	inventory_open = false
	shop_open = false
	var inf := get_node_or_null("/root/InfluenceState")
	if inf != null and inf.has_method("reset"):
		inf.call("reset")
	var funds := get_node_or_null("/root/ChurchFunds")
	if funds != null and funds.has_method("reset"):
		funds.call("reset")
	var path := get_node_or_null("/root/PastorPath")
	if path != null and path.has_method("reset"):
		path.call("reset")
	var threads := get_node_or_null("/root/StoryThreads")
	if threads != null and threads.has_method("reset"):
		threads.call("reset")
	var pack := get_node_or_null("/root/Inventory")
	if pack != null and pack.has_method("reset"):
		pack.call("reset")


func set_flag(key: String, value: Variant) -> void:
	_flags[key] = value
	if key == "garden_planted" and value is bool and bool(value):
		var threads := get_node_or_null("/root/StoryThreads")
		if threads != null and threads.has_method("open"):
			threads.call("open", "garden_growth")
	if key != "garden_planted" or not (value is bool) or not bool(value):
		return
	if _flags.has("garden_planted_on"):
		return
	var day := 4
	var clock := get_node_or_null("/root/DayClock")
	if clock != null:
		day = int(clock.get("weekday"))
	_flags["garden_planted_on"] = day
	if key.begins_with("garden_") or key.begins_with("grounds_"):
		story_changed.emit()


func get_flag(key: String, fallback: Variant = null) -> Variant:
	return _flags.get(key, fallback)


func flag_is_true(key: String) -> bool:
	if not _flags.has(key):
		return false
	var value: Variant = _flags[key]
	return value is bool and bool(value)


func flag_equals(key: String, expected: Variant) -> bool:
	return _flags.get(key, null) == expected


func relationship(npc_id: String) -> int:
	return int(_relationships.get(npc_id, 0))


func set_relationship(npc_id: String, value: int) -> void:
	_relationships[npc_id] = value


func add_relationship(npc_id: String, delta: int) -> void:
	_relationships[npc_id] = relationship(npc_id) + delta


func add_growth(key: String, delta: int) -> void:
	# Attendance stays a rough signal. Chores and choices do not pump it.
	if key == "attendance" or not _growth.has(key) or delta == 0:
		return
	_growth[key] = int(_growth[key]) + delta


func growth_value(key: String) -> int:
	return int(_growth.get(key, 0))


func growth_word(key: String) -> String:
	if key == "attendance":
		return "a small gathering"
	var value := growth_value(key)
	if value <= 0:
		return "Strained"
	if value == 1:
		return "Steady"
	return "Growing"


func growth_lines() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Congregation: %s" % growth_word("congregation_health"))
	lines.append("Trust: %s" % growth_word("community_trust"))
	lines.append("Impact: %s" % growth_word("community_impact"))
	lines.append("Building: %s" % growth_word("facility_condition"))
	lines.append("Pews: %s" % growth_word("attendance"))
	return lines


func garden_stage() -> int:
	if not flag_is_true("garden_planted"):
		if flag_is_true("garden_cleared"):
			return 1
		return 0
	var planted := int(get_flag("garden_planted_on", 0))
	var day := planted
	var clock := get_node_or_null("/root/DayClock")
	if clock != null:
		day = int(clock.get("weekday"))
	return mini(2 + maxi(0, day - planted), 4)


func reconcile_calendar() -> void:
	# A Friday errand should not still be the active journal line on Saturday, or a Saturday errand on Sunday.
	if quest_status("oak_street") != "active":
		return
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return
	var day := int(clock.get("weekday"))
	var step := quest_step("oak_street")
	if step == "friday" and day > 5:
		set_step("oak_street", "saturday")
		step = "saturday"
	if step == "saturday" and day >= 7:
		if not flag_is_true("sunday_ready"):
			set_flag("sunday_ready", true)
		complete_quest("oak_street")


func day_suggestions() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var clock := get_node_or_null("/root/DayClock")
	var day := 4
	var hour := 14
	var later_sunday := false
	if clock != null:
		day = int(clock.get("weekday"))
		hour = int(clock.get("hour"))
		if clock.has_method("is_later_sunday"):
			later_sunday = bool(clock.call("is_later_sunday"))
	if later_sunday and hour < 12:
		if flag_is_true("weekly_loop"):
			lines.append("Sunday is at ten, if you want the room.")
		else:
			lines.append("The sanctuary is quiet. The next chapter is still being written.")
	if flag_is_true("weekly_loop") and flag_is_true("hall_proposed") and not flag_is_true("hall_repaired"):
		if flag_is_true("hall_repairing"):
			lines.append("Harold is working on the Fellowship Hall this week.")
		else:
			lines.append("The Fellowship Hall is still boarded, if you want to keep at it.")
	if flag_is_true("hall_repaired") and not flag_is_true("hall_celebrated"):
		lines.append("The Fellowship Hall is open. Harold left the door unlatched.")
	if not flag_is_true("grounds_tidy"):
		lines.append("The church walk could use a few minutes, if you want them.")
	if not flag_is_true("garden_planted"):
		lines.append("The community garden on Maple Lane is still overgrown.")
	if lines.size() < 3 and not flag_is_true("frank_arc_heard"):
		if flag_is_true("frank_listened") or flag_is_true("frank_invited"):
			lines.append("Frank is at the bay during the day, if you feel like stopping.")
	if lines.size() < 3 and not flag_is_true("sunday_ready") and not flag_is_true("week_continues"):
		if day < 7:
			lines.append("Sunday is at ten, when the week gets there.")
	if lines.is_empty():
		lines.append("The town is quiet. Walk if you like.")
	var capped: PackedStringArray = PackedStringArray()
	var count := 0
	for line in lines:
		if count >= 3:
			break
		capped.append(line)
		count += 1
	return capped


func add_note(text: String) -> void:
	if text.is_empty() or _notes.has(text):
		return
	_notes.append(text)


func journal_notes() -> PackedStringArray:
	var lines := PackedStringArray()
	if not flag_is_true("seen_oak_street"):
		lines.append(OAK_HINT)
	for note in _notes:
		if not lines.has(note):
			lines.append(note)
	return lines


func quest_title(quest_id: String) -> String:
	var definition := _definition(quest_id)
	return str(definition.get("title", ""))


func quest_status(quest_id: String) -> String:
	if not _quests.has(quest_id):
		return ""
	return str((_quests[quest_id] as Dictionary).get("status", ""))


func quest_step(quest_id: String) -> String:
	if not _quests.has(quest_id):
		return ""
	return str((_quests[quest_id] as Dictionary).get("step", ""))


func start_quest(quest_id: String) -> void:
	if _quests.has(quest_id):
		return
	var definition := _definition(quest_id)
	if definition.is_empty():
		push_error("Unknown quest %s" % quest_id)
		return
	_quests[quest_id] = {
		"id": quest_id,
		"status": "active",
		"step": "",
		"title": str(definition.get("title", quest_id)),
		"objective": "",
	}


func set_step(quest_id: String, step: String) -> void:
	if not _quests.has(quest_id):
		start_quest(quest_id)
	if not _quests.has(quest_id):
		return
	var record: Dictionary = _quests[quest_id]
	if str(record.get("status", "")) == "completed":
		return
	record["status"] = "active"
	record["step"] = step
	record["objective"] = _objective(quest_id, step)
	_quests[quest_id] = record


func complete_quest(quest_id: String) -> void:
	if not _quests.has(quest_id):
		start_quest(quest_id)
	if not _quests.has(quest_id):
		return
	var record: Dictionary = _quests[quest_id]
	record["status"] = "completed"
	record["step"] = "done"
	record["objective"] = _objective(quest_id, "done")
	_quests[quest_id] = record


func active_quests() -> Array[Dictionary]:
	return _quests_with_status("active")


func completed_quests() -> Array[Dictionary]:
	return _quests_with_status("completed")


func to_dictionary() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"flags": _flags.duplicate(true),
		"quests": _quests.duplicate(true),
		"relationships": _relationships.duplicate(true),
		"notes": _notes.duplicate(),
		"growth": _growth.duplicate(true),
	}


func from_dictionary(data: Dictionary) -> void:
	# A load replaces the story. The menu and the dialogue box belong to the old scene.
	dialogue_open = false
	journal_open = false
	ending_open = false
	map_open = false
	day_card_open = false
	ledger_open = false
	inventory_open = false
	shop_open = false
	var flags_v: Variant = data.get("flags", {})
	_flags = (flags_v as Dictionary).duplicate(true) if flags_v is Dictionary else {}
	_quests.clear()
	var quests_v: Variant = data.get("quests", {})
	if quests_v is Dictionary:
		for key in (quests_v as Dictionary).keys():
			var record_v: Variant = (quests_v as Dictionary)[key]
			if record_v is Dictionary:
				_quests[str(key)] = (record_v as Dictionary).duplicate(true)
	_relationships.clear()
	var rel_v: Variant = data.get("relationships", {})
	if rel_v is Dictionary:
		for key in (rel_v as Dictionary).keys():
			_relationships[str(key)] = int((rel_v as Dictionary)[key])
	_notes.clear()
	var notes_v: Variant = data.get("notes", [])
	if notes_v is Array:
		for item in notes_v as Array:
			var text := str(item)
			if not text.is_empty() and not _notes.has(text):
				_notes.append(text)
	_growth = _fresh_growth()
	var growth_v: Variant = data.get("growth", {})
	if growth_v is Dictionary:
		for key in _growth.keys():
			if (growth_v as Dictionary).has(key):
				_growth[key] = int((growth_v as Dictionary)[key])


func _fresh_growth() -> Dictionary:
	return {
		"congregation_health": 0,
		"community_trust": 0,
		"community_impact": 0,
		"facility_condition": 0,
		"attendance": 17,
	}


func _load_catalog(path: String) -> void:
	var parsed: Variant = JsonFile.read(path)
	if not parsed is Dictionary:
		push_error("Quest catalog %s is not an object" % path)
		return
	var rows: Variant = (parsed as Dictionary).get("quests", [])
	if not rows is Array:
		push_error("Quest catalog %s has no quests list" % path)
		return
	for row_v in rows as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var quest_id := str(row.get("id", ""))
		if quest_id.is_empty():
			continue
		_catalog[quest_id] = row


func _definition(quest_id: String) -> Dictionary:
	var found: Variant = _catalog.get(quest_id, {})
	return found if found is Dictionary else {}


func _objective(quest_id: String, step: String) -> String:
	var steps: Variant = _definition(quest_id).get("steps", {})
	if steps is Dictionary:
		return str((steps as Dictionary).get(step, ""))
	return ""


func _quests_with_status(status: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for key in _quests.keys():
		var record: Dictionary = _quests[key]
		if str(record.get("status", "")) == status:
			found.append(record.duplicate(true))
	return found
