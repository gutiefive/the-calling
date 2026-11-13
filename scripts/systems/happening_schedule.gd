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
		if not _flag_ok(row.get("requires_flag", "")):
			return false
		if not _week_ok(row):
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


static func _flag_ok(flag_name: Variant) -> bool:
	if flag_name == null:
		return true
	var key := str(flag_name)
	if key.is_empty() or key == "<null>":
		return true
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var story := tree.root.get_node_or_null("NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	return bool(story.call("flag_is_true", key))


static func _week_ok(row: Dictionary) -> bool:
	if not row.has("week_mod"):
		return true
	var modulus := int(row.get("week_mod", 0))
	if modulus <= 0:
		return true
	var want := int(row.get("week_index", 0))
	var week := 1
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		var clock := tree.root.get_node_or_null("DayClock")
		if clock != null and clock.has_method("week_number"):
			week = int(clock.call("week_number"))
	return (week % modulus) == want


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
