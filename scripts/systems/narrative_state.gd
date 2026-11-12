extends Node
## Flags and quests that must outlive a room change.
## M3 can write to_dictionary() to disk. This milestone keeps it in memory only.

const SAVE_VERSION := 1

var dialogue_open: bool = false
var journal_open: bool = false

var _flags: Dictionary = {}
var _quests: Dictionary = {}
var _catalog: Dictionary = {}


func _ready() -> void:
	_load_catalog("res://data/quests/chapter1.json")


func movement_locked() -> bool:
	return dialogue_open or journal_open


func set_dialogue_open(is_open: bool) -> void:
	dialogue_open = is_open


func set_journal_open(is_open: bool) -> void:
	journal_open = is_open


func reset() -> void:
	_flags.clear()
	_quests.clear()
	dialogue_open = false
	journal_open = false


func set_flag(key: String, value: Variant) -> void:
	_flags[key] = value


func get_flag(key: String, fallback: Variant = null) -> Variant:
	return _flags.get(key, fallback)


func flag_is_true(key: String) -> bool:
	if not _flags.has(key):
		return false
	var value: Variant = _flags[key]
	return value is bool and bool(value)


func flag_equals(key: String, expected: Variant) -> bool:
	return _flags.get(key, null) == expected


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
	}


func from_dictionary(data: Dictionary) -> void:
	var flags_v: Variant = data.get("flags", {})
	_flags = (flags_v as Dictionary).duplicate(true) if flags_v is Dictionary else {}
	_quests.clear()
	var quests_v: Variant = data.get("quests", {})
	if quests_v is Dictionary:
		for key in (quests_v as Dictionary).keys():
			var record_v: Variant = (quests_v as Dictionary)[key]
			if record_v is Dictionary:
				_quests[str(key)] = (record_v as Dictionary).duplicate(true)


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
