extends Node
## Named story threads. States are words. Missed threads never reopen. D45.

const CATALOG_PATH := "res://data/story/threads.json"
const STATE_OPEN := "open"
const STATE_ADVANCED := "advanced"
const STATE_CLOSED := "closed"
const STATE_MISSED := "missed"

var _states: Dictionary = {}
var _catalog: Dictionary = {}


func _ready() -> void:
	_load_catalog()


func reset() -> void:
	_states.clear()


func open(thread_id: String) -> bool:
	if thread_id.is_empty() or is_missed(thread_id) or is_closed(thread_id):
		return false
	if _state_of(thread_id).is_empty():
		_states[thread_id] = STATE_OPEN
	return true


func advance(thread_id: String) -> bool:
	if thread_id.is_empty() or is_missed(thread_id) or is_closed(thread_id):
		return false
	var current := _state_of(thread_id)
	if current.is_empty():
		return false
	if current == STATE_OPEN:
		_states[thread_id] = STATE_ADVANCED
		return true
	return current == STATE_ADVANCED


func close_thread(thread_id: String) -> bool:
	if thread_id.is_empty() or is_missed(thread_id):
		return false
	if _state_of(thread_id).is_empty():
		return false
	_states[thread_id] = STATE_CLOSED
	return true


func miss(thread_id: String) -> bool:
	if thread_id.is_empty():
		return false
	if is_closed(thread_id):
		return false
	_states[thread_id] = STATE_MISSED
	return true


func set_state(thread_id: String, state: String) -> bool:
	if thread_id.is_empty() or state.is_empty():
		return false
	if is_missed(thread_id):
		return false
	if is_closed(thread_id) and state != STATE_CLOSED:
		return false
	_states[thread_id] = state
	return true


func state_of(thread_id: String) -> String:
	return _state_of(thread_id)


func is_state(thread_id: String, state: String) -> bool:
	return _state_of(thread_id) == state


func is_open(thread_id: String) -> bool:
	var current := _state_of(thread_id)
	return current == STATE_OPEN or current == STATE_ADVANCED


func is_missed(thread_id: String) -> bool:
	return _state_of(thread_id) == STATE_MISSED


func is_closed(thread_id: String) -> bool:
	return _state_of(thread_id) == STATE_CLOSED


func inspect_reece_key() -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	if not bool(story.call("flag_is_true", "has_reece_key")):
		return false
	return open("reece_mystery")


func journal_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	var ids: Array = []
	for key in _catalog.keys():
		ids.append(str(key))
	ids.sort()
	for thread_id in ids:
		var state := _state_of(str(thread_id))
		if not _shows_in_journal(state):
			continue
		var summary := _summary(str(thread_id), state)
		if summary.is_empty():
			continue
		lines.append(summary)
	return lines


func to_dictionary() -> Dictionary:
	return _states.duplicate(true)


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	for key in data.keys():
		var thread_id := str(key)
		if thread_id.is_empty():
			continue
		_states[thread_id] = str(data[key])


func _state_of(thread_id: String) -> String:
	return str(_states.get(thread_id, ""))


func _shows_in_journal(state: String) -> bool:
	if state.is_empty() or state == STATE_MISSED or state == STATE_CLOSED:
		return false
	return true


func _summary(thread_id: String, state: String) -> String:
	var row_v: Variant = _catalog.get(thread_id, {})
	if not row_v is Dictionary:
		return ""
	var row: Dictionary = row_v
	var summaries_v: Variant = row.get("summaries", {})
	if summaries_v is Dictionary:
		var summaries: Dictionary = summaries_v
		if summaries.has(state):
			return str(summaries[state])
	return str(row.get("summary", ""))


func _load_catalog() -> void:
	_catalog.clear()
	var parsed: Variant = JsonFile.read(CATALOG_PATH)
	if not parsed is Dictionary:
		push_error("Thread catalog is not an object")
		return
	var rows: Variant = (parsed as Dictionary).get("threads", [])
	if not rows is Array:
		push_error("Thread catalog has no threads list")
		return
	for row_v in rows as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var thread_id := str(row.get("id", ""))
		if thread_id.is_empty():
			continue
		_catalog[thread_id] = row
