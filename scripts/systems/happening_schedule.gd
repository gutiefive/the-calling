class_name HappeningSchedule
extends RefCounted
## Optional daytime moments. They are not quests and they are not required for the chapter.

const PATH := "res://data/happenings/week.json"

static var _rows: Array = []
static var _loaded: bool = false
static var _ok: bool = false


static func is_active(happening_id: String, day_name: String, hour: int, minute: int) -> bool:
	if not _ensure():
		return false
	var now := hour * 60 + minute
	for row_v in _rows:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		if str(row.get("id", "")) != happening_id:
			continue
		if not _day_matches(row.get("days", []), day_name):
			return false
		var start := _minutes(str(row.get("from", "00:00")))
		var until := _minutes(str(row.get("until", "24:00")))
		return now >= start and now < until
	return false


static func scene_for(happening_id: String) -> String:
	if not _ensure():
		return ""
	for row_v in _rows:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		if str(row.get("id", "")) == happening_id:
			return str(row.get("scene", ""))
	return ""


static func _ensure() -> bool:
	if _loaded:
		return _ok
	_loaded = true
	var parsed: Variant = JsonFile.read(PATH)
	if not parsed is Dictionary:
		push_error("Happening file is not an object")
		return false
	var rows: Variant = (parsed as Dictionary).get("happenings", [])
	if not rows is Array:
		push_error("Happening file has no happenings list")
		return false
	_rows = rows as Array
	_ok = true
	return true


static func _day_matches(days_v: Variant, day_name: String) -> bool:
	if not days_v is Array:
		return false
	for day_v in days_v as Array:
		if str(day_v) == day_name:
			return true
	return false


static func _minutes(text: String) -> int:
	var parts := text.split(":")
	if parts.size() < 2:
		return 0
	return int(parts[0]) * 60 + int(parts[1])
