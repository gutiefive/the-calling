extends Node
## Weekly Fellowship Hall potluck. Prep is optional. Outcomes stay narrative.

signal event_prepared(category_id: String)
signal potluck_started
signal potluck_ended

const Catalog := preload("res://scripts/systems/event_catalog.gd")

const FRAMING_OPEN := "open"
const FRAMING_CHURCH := "church"
const SCENE_ID := "fellowship_hall"

var _framing: String = ""
var _invited: PackedStringArray = PackedStringArray()
var _last_window_week: int = 0
var _last_window_day: int = 0
var _last_reward_week: int = 0
var _attended_weeks: PackedInt32Array = PackedInt32Array()
var _skipped_weeks: PackedInt32Array = PackedInt32Array()
var _vegetables: bool = false
var _inside: bool = false
var _live_was: bool = false
var _last_seen_day: int = 0


func _ready() -> void:
	reset()
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_signal("time_changed"):
		if not clock.time_changed.is_connected(_on_time_changed):
			clock.time_changed.connect(_on_time_changed)
	var asks := get_node_or_null("/root/RequestState")
	if asks != null and asks.has_signal("request_completed"):
		if not asks.request_completed.is_connected(_on_request_completed):
			asks.request_completed.connect(_on_request_completed)


func reset() -> void:
	_framing = ""
	_invited = PackedStringArray()
	_last_window_week = 0
	_last_window_day = 0
	_last_reward_week = 0
	_attended_weeks = PackedInt32Array()
	_skipped_weeks = PackedInt32Array()
	_vegetables = false
	_inside = false
	_live_was = false
	_last_seen_day = 0


func is_unlocked() -> bool:
	for flag_name in Catalog.unlock_flags():
		if not NarrativeState.flag_is_true(flag_name):
			return false
	return true


func is_window_now() -> bool:
	if not is_unlocked():
		return false
	var clock := _clock()
	if clock == null:
		return false
	if str(clock.call("weekday_name")) != Catalog.day_name():
		return false
	var now := int(clock.get("hour")) * 60 + int(clock.get("minute"))
	return now >= Catalog.from_minutes() and now < Catalog.until_minutes()


func is_live() -> bool:
	return is_window_now()


func needs_framing() -> bool:
	return is_unlocked() and _framing.is_empty()


func framing() -> String:
	return _framing


func set_framing(choice: String) -> bool:
	if choice != FRAMING_OPEN and choice != FRAMING_CHURCH:
		return false
	if not _framing.is_empty():
		return false
	_framing = choice
	if choice == FRAMING_OPEN:
		NarrativeState.set_flag("potluck_framing_open", true)
		NarrativeState.set_flag("potluck_framing_church", false)
	else:
		NarrativeState.set_flag("potluck_framing_church", true)
		NarrativeState.set_flag("potluck_framing_open", false)
	event_prepared.emit("framing")
	return true


func can_invite(npc_id: String) -> bool:
	if npc_id.is_empty() or not is_unlocked():
		return false
	if _framing.is_empty():
		return false
	if is_invited(npc_id):
		return false
	return Catalog.invite_guests().has(npc_id)


func invite(npc_id: String) -> bool:
	if not can_invite(npc_id):
		return false
	_invited.append(npc_id)
	event_prepared.emit("invites")
	return true


func is_invited(npc_id: String) -> bool:
	return _invited.has(npc_id)


func invited_ids() -> PackedStringArray:
	return _invited.duplicate()


func invited_count() -> int:
	return _invited.size()


func has_prep(category_id: String) -> bool:
	match category_id:
		"vegetables":
			return _has_vegetables()
		"flowers":
			return NarrativeState.flag_is_true(Catalog.prep_flag("flowers"))
		"grounds":
			return NarrativeState.flag_is_true(Catalog.prep_flag("grounds"))
		"repair":
			return NarrativeState.flag_is_true(Catalog.prep_flag("repair"))
		"invites":
			return not _invited.is_empty()
		_:
			return false


func prep_count() -> int:
	var total := 0
	for row_v in Catalog.prep_rows():
		if not row_v is Dictionary:
			continue
		if has_prep(str((row_v as Dictionary).get("id", ""))):
			total += 1
	return total


func has_varied_dishes() -> bool:
	return has_prep("vegetables")


func has_centerpieces() -> bool:
	return has_prep("flowers")


func has_lights() -> bool:
	return has_prep("grounds")


func has_extra_chairs() -> bool:
	return has_prep("repair")


func extra_guest_count() -> int:
	return invited_count()


func is_present(npc_id: String) -> bool:
	if not is_live():
		return false
	if Catalog.core_guests().has(npc_id):
		return true
	return is_invited(npc_id)


func presence(npc_id: String) -> Dictionary:
	if not is_present(npc_id):
		return {}
	return {
		"scene": SCENE_ID,
		"position": Catalog.post(npc_id),
	}


func guest_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	if not is_live():
		return ids
	for npc_id in Catalog.core_guests():
		ids.append(npc_id)
	for npc_id in _invited:
		if not ids.has(npc_id):
			ids.append(npc_id)
	return ids


func mark_attended() -> bool:
	if not is_live():
		return false
	var week := _week()
	if _attended_weeks.has(week):
		return false
	_attended_weeks.append(week)
	_grant_attendance_reward(week)
	return true


func did_attend(week: int = -1) -> bool:
	var want := week if week >= 0 else _week()
	return _attended_weeks.has(want)


func did_skip(week: int = -1) -> bool:
	var want := week if week >= 0 else _week()
	return _skipped_weeks.has(want)


func last_reward_week() -> int:
	return _last_reward_week


func holds_clock() -> bool:
	return _inside and is_live()


func set_inside(inside: bool) -> void:
	_inside = inside
	if inside and is_live():
		mark_attended()
		if not _live_was:
			_live_was = true
			potluck_started.emit()


func is_inside() -> bool:
	return _inside


func journal_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	if not is_unlocked() and prep_count() == 0:
		return lines
	lines.append(Catalog.title())
	if is_unlocked():
		if is_live():
			lines.append("They're in the hall this afternoon.")
		elif needs_framing():
			lines.append("Sarah wants a word about who the table is for.")
		else:
			lines.append("Wednesday, late morning, in the hall. Come if you want a plate.")
	var any_prep := false
	for row_v in Catalog.prep_rows():
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var category_id := str(row.get("id", ""))
		if has_prep(category_id):
			any_prep = true
			var line := str(row.get("journal", ""))
			if not line.is_empty():
				lines.append(line)
	if is_unlocked() and not any_prep:
		lines.append("A modest table is enough.")
	if _framing == FRAMING_OPEN:
		lines.append("The gathering stays open. No one is owed a pew.")
	elif _framing == FRAMING_CHURCH:
		lines.append("The gathering leans toward Grace, without a sales pitch.")
	return lines


func to_dictionary() -> Dictionary:
	var invited: Array = []
	for npc_id in _invited:
		invited.append(npc_id)
	var attended: Array = []
	for week in _attended_weeks:
		attended.append(week)
	var skipped: Array = []
	for week in _skipped_weeks:
		skipped.append(week)
	return {
		"framing": _framing,
		"invited": invited,
		"last_window_week": _last_window_week,
		"last_window_day": _last_window_day,
		"last_reward_week": _last_reward_week,
		"attended_weeks": attended,
		"skipped_weeks": skipped,
		"vegetables": _vegetables,
		"last_seen_day": _last_seen_day,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	_framing = str(data.get("framing", ""))
	var invited_v: Variant = data.get("invited", [])
	if invited_v is Array:
		for item in invited_v as Array:
			var npc_id := str(item)
			if not npc_id.is_empty() and not _invited.has(npc_id):
				_invited.append(npc_id)
	_last_window_week = int(data.get("last_window_week", 0))
	_last_window_day = int(data.get("last_window_day", 0))
	_last_reward_week = int(data.get("last_reward_week", 0))
	_vegetables = bool(data.get("vegetables", false))
	_last_seen_day = int(data.get("last_seen_day", 0))
	if not _vegetables and NarrativeState.flag_is_true("potluck_vegetables"):
		_vegetables = true
	var attended_v: Variant = data.get("attended_weeks", [])
	if attended_v is Array:
		for item in attended_v as Array:
			var week := int(item)
			if not _attended_weeks.has(week):
				_attended_weeks.append(week)
	var skipped_v: Variant = data.get("skipped_weeks", [])
	if skipped_v is Array:
		for item in skipped_v as Array:
			var week := int(item)
			if not _skipped_weeks.has(week):
				_skipped_weeks.append(week)
	_sync_framing_flags()


func _on_time_changed() -> void:
	_resolve_windows()
	var live := is_live()
	if live and not _live_was:
		_live_was = true
		_last_window_week = _week()
		_last_window_day = _day()
		potluck_started.emit()
	elif not live and _live_was:
		_live_was = false
		_finish_window(_week())
		potluck_ended.emit()
	if _inside and live:
		mark_attended()


func _on_request_completed(request_id: String) -> void:
	if request_id == "fresh_for_the_table":
		_vegetables = true
		event_prepared.emit("vegetables")
	elif request_id == "sanctuary_flowers":
		event_prepared.emit("flowers")


func _has_vegetables() -> bool:
	return _vegetables or NarrativeState.flag_is_true("potluck_vegetables")


func _resolve_windows() -> void:
	var day := _day()
	if _last_seen_day <= 0:
		_last_seen_day = day
		return
	if not is_unlocked():
		_last_seen_day = day
		return
	var week := _week()
	if day < _last_seen_day:
		_last_seen_day = day
		return
	if day > _last_seen_day:
		var cursor := _last_seen_day
		while cursor < day:
			cursor += 1
			_consider_skip_for_day(cursor)
		_last_seen_day = day
	if is_window_now():
		if _last_window_week != week:
			_last_window_week = week
			_last_window_day = day
	else:
		_consider_skip_for_day(day)


func _consider_skip_for_day(day: int) -> void:
	if not is_unlocked():
		return
	var name_index: int = day % 7
	if name_index < 0:
		return
	# 0 Sunday, 3 Wednesday.
	if name_index != 3:
		return
	var week := int((maxi(day, 1) - 1) / 7) + 1
	if _attended_weeks.has(week) or _skipped_weeks.has(week):
		return
	var clock := _clock()
	var still_open := false
	if clock != null and int(clock.get("weekday")) == day:
		var now := int(clock.get("hour")) * 60 + int(clock.get("minute"))
		still_open = now < Catalog.until_minutes()
	if still_open:
		return
	_skipped_weeks.append(week)
	_clear_weekly_prep()


func _grant_attendance_reward(week: int) -> void:
	if _last_reward_week == week:
		return
	_last_reward_week = week
	if _skipped_weeks.has(week):
		var kept := PackedInt32Array()
		for item in _skipped_weeks:
			if item != week:
				kept.append(item)
		_skipped_weeks = kept
	NarrativeState.add_note("Wednesday had a table in the hall.")


func _finish_window(week: int) -> void:
	if not _attended_weeks.has(week) and not _skipped_weeks.has(week):
		_skipped_weeks.append(week)
	_clear_weekly_prep()


func _clear_weekly_prep() -> void:
	if is_window_now():
		return
	_vegetables = false
	if NarrativeState.flag_is_true("potluck_vegetables"):
		NarrativeState.set_flag("potluck_vegetables", false)
	_invited = PackedStringArray()


func _sync_framing_flags() -> void:
	if _framing == FRAMING_OPEN:
		NarrativeState.set_flag("potluck_framing_open", true)
		NarrativeState.set_flag("potluck_framing_church", false)
	elif _framing == FRAMING_CHURCH:
		NarrativeState.set_flag("potluck_framing_church", true)
		NarrativeState.set_flag("potluck_framing_open", false)


func _week() -> int:
	var clock := _clock()
	if clock != null and clock.has_method("week_number"):
		return int(clock.call("week_number"))
	return 1


func _day() -> int:
	var clock := _clock()
	if clock == null:
		return 0
	return int(clock.get("weekday"))


func _clock() -> Node:
	return get_node_or_null("/root/DayClock")
