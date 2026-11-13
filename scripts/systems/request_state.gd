extends Node
## Optional community requests. Completing one never raises Pull, attendance, or ChurchFunds.

const Catalog := preload("res://scripts/systems/request_catalog.gd")
const Items := preload("res://scripts/systems/item_catalog.gd")

signal request_accepted(request_id: String)
signal request_completed(request_id: String)
signal request_expired(request_id: String)
signal requests_changed

const MAX_HISTORY := 12


var _active: Dictionary = {}
var _history: Array = []
var _completed: Dictionary = {}
var _last_completed_day: Dictionary = {}
var _rewarded: Dictionary = {}


func _ready() -> void:
	reset()
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_signal("time_changed"):
		if not clock.time_changed.is_connected(_on_time_changed):
			clock.time_changed.connect(_on_time_changed)


func reset() -> void:
	_active.clear()
	_history.clear()
	_completed.clear()
	_last_completed_day.clear()
	_rewarded.clear()
	requests_changed.emit()


func is_active(request_id: String) -> bool:
	_tick_expiry()
	return _active.has(request_id)


func is_completed(request_id: String) -> bool:
	return bool(_completed.get(request_id, false))


func is_available(request_id: String) -> bool:
	_tick_expiry()
	if not Catalog.has_request(request_id):
		return false
	if _active.has(request_id):
		return false
	if not _conditions_hold(Catalog.available_if(request_id)):
		return false
	if is_completed(request_id) and not Catalog.is_repeatable(request_id):
		return false
	if is_completed(request_id) and Catalog.is_repeatable(request_id):
		var last := int(_last_completed_day.get(request_id, -99))
		if _clock_day() - last < Catalog.cooldown_days(request_id):
			return false
	return true


func is_unlocked(request_id: String) -> bool:
	if not Catalog.has_request(request_id):
		return false
	return _conditions_hold(Catalog.available_if(request_id))


func slots_full() -> bool:
	_tick_expiry()
	return _active.size() >= Catalog.max_active()


func active_count() -> int:
	_tick_expiry()
	return _active.size()


func active_ids() -> PackedStringArray:
	_tick_expiry()
	var ids := PackedStringArray()
	for key in _active.keys():
		ids.append(str(key))
	return ids


func history_rows() -> Array:
	return _history.duplicate(true)


func accept(request_id: String) -> Dictionary:
	_tick_expiry()
	if not is_available(request_id):
		return _result(false, "That ask is not open.")
	if slots_full():
		return _result(false, "Three asks is enough for now.")
	_active[request_id] = {
		"id": request_id,
		"accepted_day": _clock_day(),
		"deadline_day": _deadline_day(request_id),
	}
	request_accepted.emit(request_id)
	requests_changed.emit()
	return _result(true, "I'll see to it.")


func can_deliver(request_id: String) -> bool:
	_tick_expiry()
	if not _active.has(request_id):
		return false
	if not Catalog.complete_if(request_id).is_empty():
		return _completion_flag_met(request_id)
	if _completion_flag_met(request_id):
		return true
	return _has_required(request_id)


func missing_line(request_id: String) -> String:
	var needed := Catalog.required(request_id)
	if needed.is_empty():
		if _completion_flag_met(request_id):
			return ""
		return "The Maple Lane garden still wants seed."
	var parts: PackedStringArray = PackedStringArray()
	var pack := _pack()
	for item_id in needed.keys():
		var want := int(needed[item_id])
		var have := 0
		if pack != null and pack.has_method("quantity"):
			have = int(pack.call("quantity", str(item_id)))
		if have < want:
			parts.append("%d %s" % [want - have, Items.display_name(str(item_id))])
	if parts.is_empty():
		return ""
	return "Missing: %s" % ", ".join(parts)


func deliver(request_id: String) -> Dictionary:
	_tick_expiry()
	if not _active.has(request_id):
		return _result(false, "That ask is not on the list.")
	if is_completed(request_id) and _rewarded.has(request_id) and not Catalog.is_repeatable(request_id):
		return _result(false, "That was already seen to.")
	if not can_deliver(request_id):
		var missing := missing_line(request_id)
		if missing.is_empty():
			if not Catalog.complete_if(request_id).is_empty():
				missing = "The garden fence still needs work."
			else:
				missing = "Not yet."
		return _result(false, missing)
	if _completion_flag_met(request_id):
		return _complete(request_id)
	if not _consume_required(request_id):
		return _result(false, missing_line(request_id))
	return _complete(request_id)


func progress_line(request_id: String) -> String:
	if _completion_flag_met(request_id):
		var done := str(Catalog.request(request_id).get("progress_done", ""))
		if not done.is_empty():
			return done
	var repairs := get_node_or_null("/root/RepairState")
	if repairs != null and repairs.has_method("progress_for_request"):
		var repair_line := str(repairs.call("progress_for_request", request_id))
		if not repair_line.is_empty():
			return repair_line
	var needed := Catalog.required(request_id)
	if needed.is_empty():
		if _completion_flag_met(request_id):
			return "The Maple Lane garden is in the ground."
		return "The Maple Lane garden still needs planting."
	var pack := _pack()
	var parts: PackedStringArray = PackedStringArray()
	for item_id in needed.keys():
		var want := int(needed[item_id])
		var have := 0
		if pack != null and pack.has_method("quantity"):
			have = int(pack.call("quantity", str(item_id)))
		have = mini(have, want)
		parts.append("%s %d/%d" % [Items.display_name(str(item_id)), have, want])
	return ", ".join(parts)


func journal_lines() -> PackedStringArray:
	_tick_expiry()
	var lines := PackedStringArray()
	if not _active.is_empty():
		for request_id in active_ids():
			lines.append(Catalog.title(request_id))
			var desc := Catalog.description(request_id)
			if not desc.is_empty():
				lines.append(desc)
			var progress := progress_line(request_id)
			if not progress.is_empty():
				lines.append(progress)
			var where := Catalog.return_where(request_id)
			if not where.is_empty():
				lines.append("Return to %s." % where)
			var row_v: Variant = _active.get(request_id, {})
			if row_v is Dictionary:
				var deadline := int((row_v as Dictionary).get("deadline_day", 0))
				if deadline > 0:
					var left := deadline - _clock_day()
					if left <= 1:
						lines.append("Soon.")
	if not _history.is_empty():
		lines.append("")
		lines.append("Seen to")
		var count := mini(_history.size(), 6)
		var start := _history.size() - count
		for i in range(start, _history.size()):
			var row_v: Variant = _history[i]
			if not row_v is Dictionary:
				continue
			var row: Dictionary = row_v
			var title := Catalog.title(str(row.get("id", "")))
			var status := str(row.get("status", "done"))
			if status == "expired":
				lines.append("%s — the week moved on." % title)
			else:
				var note := str(row.get("note", ""))
				if note.is_empty():
					lines.append(title)
				else:
					lines.append("%s — %s" % [title, note])
	return lines


func to_dictionary() -> Dictionary:
	return {
		"active": _active.duplicate(true),
		"history": _history.duplicate(true),
		"completed": _completed.duplicate(true),
		"last_completed_day": _last_completed_day.duplicate(true),
		"rewarded": _rewarded.duplicate(true),
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	var active_v: Variant = data.get("active", {})
	if active_v is Dictionary:
		for key in (active_v as Dictionary).keys():
			var row_v: Variant = (active_v as Dictionary)[key]
			if row_v is Dictionary:
				_active[str(key)] = (row_v as Dictionary).duplicate(true)
	var history_v: Variant = data.get("history", [])
	if history_v is Array:
		for row_v in history_v as Array:
			if row_v is Dictionary:
				_history.append((row_v as Dictionary).duplicate(true))
	var completed_v: Variant = data.get("completed", {})
	if completed_v is Dictionary:
		for key in (completed_v as Dictionary).keys():
			_completed[str(key)] = bool((completed_v as Dictionary)[key])
	var last_v: Variant = data.get("last_completed_day", {})
	if last_v is Dictionary:
		for key in (last_v as Dictionary).keys():
			_last_completed_day[str(key)] = int((last_v as Dictionary)[key])
	var rewarded_v: Variant = data.get("rewarded", {})
	if rewarded_v is Dictionary:
		for key in (rewarded_v as Dictionary).keys():
			_rewarded[str(key)] = bool((rewarded_v as Dictionary)[key])
	_tick_expiry()
	requests_changed.emit()


func _complete(request_id: String) -> Dictionary:
	var instance_key := _instance_key(request_id)
	if _rewarded.has(instance_key):
		return _result(false, "That was already seen to.")
	_apply_rewards(request_id)
	_rewarded[instance_key] = true
	_rewarded[request_id] = true
	_completed[request_id] = true
	_last_completed_day[request_id] = _clock_day()
	_active.erase(request_id)
	var note := str(Catalog.rewards(request_id).get("note", ""))
	_history.append({
		"id": request_id,
		"status": "done",
		"day": _clock_day(),
		"note": note,
	})
	if _history.size() > MAX_HISTORY:
		_history.pop_front()
	request_completed.emit(request_id)
	requests_changed.emit()
	if not note.is_empty():
		return _result(true, note)
	return _result(true, "That's done.")


func _apply_rewards(request_id: String) -> void:
	var rewards := Catalog.rewards(request_id)
	var cash := int(rewards.get("cash", 0))
	var pack := _pack()
	if cash > 0 and pack != null and pack.has_method("gain_cash"):
		pack.call("gain_cash", cash)
	var items_v: Variant = rewards.get("items", {})
	if items_v is Dictionary and pack != null and pack.has_method("add"):
		for item_id in (items_v as Dictionary).keys():
			pack.call("add", str(item_id), int((items_v as Dictionary)[item_id]))
	var flags_v: Variant = rewards.get("flags", {})
	if flags_v is Dictionary:
		for key in (flags_v as Dictionary).keys():
			NarrativeState.set_flag(str(key), (flags_v as Dictionary)[key])
	var rel_v: Variant = rewards.get("relationships", {})
	if rel_v is Dictionary:
		for key in (rel_v as Dictionary).keys():
			NarrativeState.add_relationship(str(key), int((rel_v as Dictionary)[key]))
	var note := str(rewards.get("note", ""))
	if not note.is_empty():
		NarrativeState.add_note(note)
	var thread_v: Variant = rewards.get("thread", null)
	if thread_v is Dictionary:
		var threads := get_node_or_null("/root/StoryThreads")
		var row: Dictionary = thread_v
		var thread_id := str(row.get("id", ""))
		if threads != null and not thread_id.is_empty() and threads.has_method("set_state"):
			threads.call("set_state", thread_id, str(row.get("state", "open")))


func _consume_required(request_id: String) -> bool:
	var needed := Catalog.required(request_id)
	if needed.is_empty():
		return true
	if not _has_required(request_id):
		return false
	var pack := _pack()
	if pack == null or not pack.has_method("remove"):
		return false
	for item_id in needed.keys():
		var want := int(needed[item_id])
		if int(pack.call("remove", str(item_id), want)) < want:
			return false
	return true


func _has_required(request_id: String) -> bool:
	var needed := Catalog.required(request_id)
	if needed.is_empty():
		return _completion_flag_met(request_id)
	var pack := _pack()
	if pack == null or not pack.has_method("has"):
		return false
	for item_id in needed.keys():
		if not bool(pack.call("has", str(item_id), int(needed[item_id]))):
			return false
	return true


func _completion_flag_met(request_id: String) -> bool:
	var cond := Catalog.complete_if(request_id)
	if cond.is_empty():
		return false
	return _conditions_hold(cond)


func _conditions_hold(condition: Dictionary) -> bool:
	if condition.is_empty():
		return true
	if condition.has("flag"):
		return NarrativeState.flag_is_true(str(condition.get("flag", "")))
	if condition.has("flag_equals"):
		var pair_v: Variant = condition.get("flag_equals", [])
		if pair_v is Array and (pair_v as Array).size() >= 2:
			var pair: Array = pair_v
			return NarrativeState.flag_equals(str(pair[0]), pair[1])
		return false
	if condition.has("quest_status"):
		var pair_v: Variant = condition.get("quest_status", [])
		if pair_v is Array and (pair_v as Array).size() >= 2:
			var pair: Array = pair_v
			return NarrativeState.quest_status(str(pair[0])) == str(pair[1])
		return false
	return true


func _tick_expiry() -> void:
	var day := _clock_day()
	var expired: Array = []
	for request_id in _active.keys():
		var row_v: Variant = _active[request_id]
		if not row_v is Dictionary:
			continue
		var deadline := int((row_v as Dictionary).get("deadline_day", 0))
		if deadline > 0 and day > deadline:
			expired.append(str(request_id))
	for request_id in expired:
		_active.erase(request_id)
		_history.append({
			"id": request_id,
			"status": "expired",
			"day": day,
			"note": "",
		})
		request_expired.emit(str(request_id))
	if not expired.is_empty():
		requests_changed.emit()


func _deadline_day(request_id: String) -> int:
	var days := Catalog.deadline_days(request_id)
	if days <= 0:
		return 0
	return _clock_day() + days


func _instance_key(request_id: String) -> String:
	var accepted := 0
	var row_v: Variant = _active.get(request_id, {})
	if row_v is Dictionary:
		accepted = int((row_v as Dictionary).get("accepted_day", _clock_day()))
	return "%s:%d" % [request_id, accepted]


func _on_time_changed() -> void:
	_tick_expiry()


func _result(ok: bool, message: String) -> Dictionary:
	return {"ok": ok, "message": message}


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _clock_day() -> int:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return 4
	return int(clock.get("weekday"))
