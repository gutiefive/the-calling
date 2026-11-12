class_name AmbientBarks
extends RefCounted
## One-line lines for unnamed people on Oak Street. The first matching day and phase wins.

const PATH := "res://data/ambient/barks.json"

static var _people: Dictionary = {}
static var _loaded: bool = false
static var _ok: bool = false


static func line(person_id: String, day_name: String, phase_name: String) -> String:
	if not _ensure():
		return ""
	var rows: Variant = _people.get(person_id, [])
	if not rows is Array:
		return ""
	var fallback := ""
	for row_v in rows as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var text := str(row.get("text", ""))
		if text.is_empty():
			continue
		if fallback.is_empty():
			fallback = text
		if not _listed(row.get("days", null), day_name):
			continue
		if not _listed(row.get("phases", null), phase_name):
			continue
		return text
	return fallback


static func _ensure() -> bool:
	if _loaded:
		return _ok
	_loaded = true
	var parsed: Variant = JsonFile.read(PATH)
	if not parsed is Dictionary:
		push_error("Bark file is not an object")
		return false
	var people: Variant = (parsed as Dictionary).get("people", [])
	if not people is Array:
		push_error("Bark file has no people list")
		return false
	for row_v in people as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var person_id := str(row.get("id", ""))
		if person_id.is_empty():
			continue
		var lines: Variant = row.get("lines", [])
		_people[person_id] = lines if lines is Array else []
	_ok = true
	return true


static func _listed(filter_v: Variant, value: String) -> bool:
	if filter_v == null:
		return true
	if not filter_v is Array:
		return true
	var items: Array = filter_v
	if items.is_empty():
		return true
	for item in items:
		if str(item) == value:
			return true
	return false
