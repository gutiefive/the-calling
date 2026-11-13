class_name EventCatalog
extends RefCounted
## Data-driven weekly gathering. One file for Phase E.

const PATH := "res://data/events/potluck.json"

static var _row: Dictionary = {}
static var _loaded: bool = false
static var _ok: bool = false


static func id() -> String:
	_ensure()
	return str(_row.get("id", "wednesday_potluck"))


static func title() -> String:
	_ensure()
	return str(_row.get("title", "Wednesday table"))


static func happening_id() -> String:
	_ensure()
	return str(_row.get("happening_id", "wednesday_potluck"))


static func day_name() -> String:
	_ensure()
	return str(_row.get("day", "Wednesday"))


static func from_minutes() -> int:
	_ensure()
	return _minutes(str(_row.get("from", "11:00")))


static func until_minutes() -> int:
	_ensure()
	return _minutes(str(_row.get("until", "16:00")))


static func unlock_flags() -> PackedStringArray:
	_ensure()
	var out := PackedStringArray()
	var flags_v: Variant = _row.get("unlock_flags", [])
	if flags_v is Array:
		for item in flags_v as Array:
			out.append(str(item))
	return out


static func core_guests() -> PackedStringArray:
	return _string_list("core_guests")


static func invite_guests() -> PackedStringArray:
	return _string_list("invite_guests")


static func prep_rows() -> Array:
	_ensure()
	var rows_v: Variant = _row.get("prep", [])
	if rows_v is Array:
		return rows_v
	return []


static func prep_flag(category_id: String) -> String:
	for row_v in prep_rows():
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		if str(row.get("id", "")) == category_id:
			return str(row.get("flag", ""))
	return ""


static func prep_journal(category_id: String) -> String:
	for row_v in prep_rows():
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		if str(row.get("id", "")) == category_id:
			return str(row.get("journal", ""))
	return ""


static func post(npc_id: String) -> Vector2:
	_ensure()
	var posts_v: Variant = _row.get("posts", {})
	if not posts_v is Dictionary:
		return Vector2(320, 240)
	var pair_v: Variant = (posts_v as Dictionary).get(npc_id, [])
	if pair_v is Array and (pair_v as Array).size() >= 2:
		var pair: Array = pair_v
		return Vector2(float(pair[0]), float(pair[1]))
	return Vector2(320, 240)


static func _string_list(key: String) -> PackedStringArray:
	_ensure()
	var out := PackedStringArray()
	var rows_v: Variant = _row.get(key, [])
	if rows_v is Array:
		for item in rows_v as Array:
			out.append(str(item))
	return out


static func _minutes(text: String) -> int:
	var parts := text.split(":")
	if parts.size() < 2:
		return 0
	return int(parts[0]) * 60 + int(parts[1])


static func _ensure() -> bool:
	if _loaded:
		return _ok
	_loaded = true
	var parsed: Variant = JsonFile.read(PATH)
	if not parsed is Dictionary:
		push_error("Event file is not an object")
		return false
	_row = parsed
	_ok = true
	return true
