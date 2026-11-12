extends Node
## Flags, quests, and relationship values that outlive a room change.
## SaveGame writes to_dictionary() into the versioned user:// file.

const SAVE_VERSION := 1

const OAK_HINT := "The lane east of the church grounds leads to Oak Street."

var dialogue_open: bool = false
var journal_open: bool = false
var ending_open: bool = false
var map_open: bool = false

var _flags: Dictionary = {}
var _quests: Dictionary = {}
var _relationships: Dictionary = {}
var _notes: Array[String] = []
var _catalog: Dictionary = {}


func _ready() -> void:
	_load_catalog("res://data/quests/chapter1.json")


func movement_locked() -> bool:
	return dialogue_open or journal_open or ending_open or map_open


func set_dialogue_open(is_open: bool) -> void:
	dialogue_open = is_open


func set_journal_open(is_open: bool) -> void:
	journal_open = is_open


func set_map_open(is_open: bool) -> void:
	map_open = is_open


func reset() -> void:
	_flags.clear()
	_quests.clear()
	_relationships.clear()
	_notes.clear()
	dialogue_open = false
	journal_open = false
	ending_open = false
	map_open = false


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


func relationship(npc_id: String) -> int:
	return int(_relationships.get(npc_id, 0))


func set_relationship(npc_id: String, value: int) -> void:
	_relationships[npc_id] = value


func add_relationship(npc_id: String, delta: int) -> void:
	_relationships[npc_id] = relationship(npc_id) + delta


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
	}


func from_dictionary(data: Dictionary) -> void:
	# A load replaces the story. The menu and the dialogue box belong to the old scene.
	dialogue_open = false
	journal_open = false
	ending_open = false
	map_open = false
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
