extends Node
## Church-grounds worksites. Completing a repair never raises Pull, attendance, or ChurchFunds.

const Catalog := preload("res://scripts/systems/repair_catalog.gd")
const Items := preload("res://scripts/systems/item_catalog.gd")

signal repair_finished(site_id: String)
signal sites_changed

const TOOL_HINT := "Basic Hand Tools would help."


var _sites: Dictionary = {}


func _ready() -> void:
	reset()


func reset() -> void:
	_sites.clear()
	for site_id in Catalog.ids():
		_sites[site_id] = _empty_row(site_id)
	_sync_from_flags()
	sites_changed.emit()


func site_ids() -> PackedStringArray:
	return Catalog.ids()


func stage_of(site_id: String) -> int:
	var row := _row(site_id)
	return int(row.get("stage", 0))


func is_finished(site_id: String) -> bool:
	if not Catalog.has_site(site_id):
		return false
	return stage_of(site_id) >= Catalog.last_stage_index(site_id)


func is_hidden(site_id: String) -> bool:
	return Catalog.hide_when_done(site_id) and is_finished(site_id)


func art_id(site_id: String) -> String:
	return Catalog.stage_art(site_id, stage_of(site_id))


func prompt_for(site_id: String) -> String:
	if is_finished(site_id):
		return Catalog.prompt_done(site_id)
	return Catalog.stage_prompt(site_id, stage_of(site_id))


func missing_line(site_id: String) -> String:
	if not Catalog.has_site(site_id) or is_finished(site_id):
		return ""
	var needed := Catalog.stage_required(site_id, stage_of(site_id))
	if needed.is_empty():
		return ""
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


func progress_line(site_id: String) -> String:
	if not Catalog.has_site(site_id):
		return ""
	if is_finished(site_id):
		return Catalog.stage_line(site_id, Catalog.last_stage_index(site_id))
	var prompt := Catalog.stage_prompt(site_id, stage_of(site_id))
	var missing := missing_line(site_id)
	if missing.is_empty():
		return prompt
	return "%s. %s" % [prompt, missing]


func progress_for_request(request_id: String) -> String:
	var site_id := Catalog.site_for_request(request_id)
	if site_id.is_empty():
		return ""
	return progress_line(site_id)


func looks_cared_for() -> bool:
	var done := 0
	for site_id in Catalog.ids():
		if is_finished(site_id):
			done += 1
	return done >= 2


func interact(site_id: String) -> Dictionary:
	if not Catalog.has_site(site_id):
		return _result(false, "noop", "Nothing to do here.")
	if is_finished(site_id):
		return _result(false, "noop", Catalog.stage_line(site_id, Catalog.last_stage_index(site_id)))
	var tool := Catalog.tool(site_id)
	var equipped := _equipped_tool()
	if equipped != tool:
		return _result(false, "noop", TOOL_HINT)
	var missing := missing_line(site_id)
	if not missing.is_empty():
		return _result(false, "noop", missing)
	if not _consume_stage(site_id):
		return _result(false, "noop", missing_line(site_id))
	_grant_yield(site_id)
	var line := Catalog.stage_line(site_id, stage_of(site_id))
	var next_stage := mini(stage_of(site_id) + 1, Catalog.last_stage_index(site_id))
	var row := _row(site_id)
	row["stage"] = next_stage
	row["done"] = next_stage >= Catalog.last_stage_index(site_id)
	_sites[site_id] = row
	_spend_time()
	if bool(row.get("done", false)):
		_apply_complete(site_id)
		repair_finished.emit(site_id)
	sites_changed.emit()
	return _result(true, "repair", line)


func to_dictionary() -> Dictionary:
	return {
		"sites": _sites.duplicate(true),
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	var sites_v: Variant = data.get("sites", {})
	if sites_v is Dictionary:
		for key in (sites_v as Dictionary).keys():
			var site_id := str(key)
			if not Catalog.has_site(site_id):
				continue
			var row_v: Variant = (sites_v as Dictionary)[key]
			if not row_v is Dictionary:
				continue
			var incoming: Dictionary = row_v
			var row := _empty_row(site_id)
			var stage := clampi(int(incoming.get("stage", 0)), 0, Catalog.last_stage_index(site_id))
			row["stage"] = stage
			row["done"] = stage >= Catalog.last_stage_index(site_id) or bool(incoming.get("done", false))
			if bool(row.get("done", false)):
				row["stage"] = Catalog.last_stage_index(site_id)
			_sites[site_id] = row
	_sync_from_flags()
	sites_changed.emit()


func _sync_from_flags() -> void:
	for site_id in Catalog.ids():
		var flag := Catalog.complete_flag(site_id)
		if flag.is_empty():
			continue
		if not NarrativeState.flag_is_true(flag):
			continue
		var row := _row(site_id)
		row["stage"] = Catalog.last_stage_index(site_id)
		row["done"] = true
		_sites[site_id] = row


func _apply_complete(site_id: String) -> void:
	var flag := Catalog.complete_flag(site_id)
	if not flag.is_empty():
		NarrativeState.set_flag(flag, true)
	var kindness := Catalog.kindness_flag(site_id)
	if not kindness.is_empty():
		NarrativeState.set_flag(kindness, true)
	if looks_cared_for() and not NarrativeState.flag_is_true("grounds_cared_for"):
		NarrativeState.set_flag("grounds_cared_for", true)
		NarrativeState.add_note("The church grounds look looked-after.")


func _consume_stage(site_id: String) -> bool:
	var needed := Catalog.stage_required(site_id, stage_of(site_id))
	if needed.is_empty():
		return true
	var pack := _pack()
	if pack == null or not pack.has_method("has") or not pack.has_method("remove"):
		return false
	for item_id in needed.keys():
		if not bool(pack.call("has", str(item_id), int(needed[item_id]))):
			return false
	for item_id in needed.keys():
		var want := int(needed[item_id])
		if int(pack.call("remove", str(item_id), want)) < want:
			return false
	return true


func _grant_yield(site_id: String) -> void:
	var granted := Catalog.stage_yield(site_id, stage_of(site_id))
	if granted.is_empty():
		return
	var pack := _pack()
	if pack == null or not pack.has_method("add"):
		return
	for item_id in granted.keys():
		pack.call("add", str(item_id), int(granted[item_id]))


func _empty_row(site_id: String) -> Dictionary:
	return {
		"id": site_id,
		"stage": 0,
		"done": false,
	}


func _row(site_id: String) -> Dictionary:
	if _sites.has(site_id):
		var row_v: Variant = _sites[site_id]
		if row_v is Dictionary:
			return (row_v as Dictionary).duplicate(true)
	return _empty_row(site_id)


func _equipped_tool() -> String:
	var pack := _pack()
	if pack == null or not pack.has_method("equipped_tool"):
		return ""
	return str(pack.call("equipped_tool"))


func _spend_time() -> void:
	var minutes := Catalog.action_minutes()
	if minutes <= 0:
		return
	var clock := get_node_or_null("/root/DayClock")
	if clock == null or not clock.has_method("advance_minutes"):
		return
	if clock.has_method("at_cap") and bool(clock.call("at_cap")):
		return
	clock.call("advance_minutes", minutes)


func _result(ok: bool, kind: String, message: String) -> Dictionary:
	return {"ok": ok, "kind": kind, "message": message}


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")
