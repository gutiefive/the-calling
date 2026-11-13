class_name RepairCatalog
extends RefCounted
## Data-driven worksites. RepairState reads this; scenes do not duplicate lists.

const DATA_PATH := "res://data/repairs/catalog.json"
const EXPECTED_IDS: PackedStringArray = [
	"church_fence",
	"picnic_weeds",
	"lot_litter",
	"picnic_bed",
]
const HAND_TOOLS := "hand_tools"

static var _loaded: bool = false
static var _action_minutes: int = 8
static var _sites: Dictionary = {}
static var _order: PackedStringArray = PackedStringArray()


static func ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_sites.clear()
	_order = PackedStringArray()
	var parsed: Variant = JsonFile.read(DATA_PATH)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	_action_minutes = maxi(0, int(data.get("action_minutes", 8)))
	var rows_v: Variant = data.get("sites", [])
	if not rows_v is Array:
		return
	for row_v in rows_v as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = (row_v as Dictionary).duplicate(true)
		var site_id := str(row.get("id", ""))
		if site_id.is_empty():
			continue
		_sites[site_id] = row
		_order.append(site_id)


static func action_minutes() -> int:
	ensure()
	return _action_minutes


static func ids() -> PackedStringArray:
	ensure()
	return _order.duplicate()


static func has_site(site_id: String) -> bool:
	ensure()
	return _sites.has(site_id)


static func site(site_id: String) -> Dictionary:
	ensure()
	if not _sites.has(site_id):
		return {}
	var row_v: Variant = _sites[site_id]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


static func title(site_id: String) -> String:
	return str(site(site_id).get("title", site_id))


static func kind(site_id: String) -> String:
	return str(site(site_id).get("kind", ""))


static func tool(site_id: String) -> String:
	var named := str(site(site_id).get("tool", HAND_TOOLS))
	if named.is_empty():
		return HAND_TOOLS
	return named


static func request_id(site_id: String) -> String:
	return str(site(site_id).get("request_id", ""))


static func complete_flag(site_id: String) -> String:
	return str(site(site_id).get("complete_flag", ""))


static func kindness_flag(site_id: String) -> String:
	return str(site(site_id).get("kindness_flag", ""))


static func hide_when_done(site_id: String) -> bool:
	return bool(site(site_id).get("hide_when_done", false))


static func prompt_done(site_id: String) -> String:
	var line := str(site(site_id).get("prompt_done", ""))
	if line.is_empty():
		return "Look around"
	return line


static func position(site_id: String) -> Vector2:
	var pos_v: Variant = site(site_id).get("position", [])
	if pos_v is Array and (pos_v as Array).size() >= 2:
		var pair: Array = pos_v
		return Vector2(float(pair[0]), float(pair[1]))
	return Vector2.ZERO


static func stages(site_id: String) -> Array:
	var stages_v: Variant = site(site_id).get("stages", [])
	if stages_v is Array:
		return (stages_v as Array).duplicate(true)
	return []


static func stage_count(site_id: String) -> int:
	return stages(site_id).size()


static func last_stage_index(site_id: String) -> int:
	return maxi(0, stage_count(site_id) - 1)


static func stage_at(site_id: String, index: int) -> Dictionary:
	var rows := stages(site_id)
	if index < 0 or index >= rows.size():
		return {}
	var row_v: Variant = rows[index]
	if row_v is Dictionary:
		return row_v
	return {}


static func stage_art(site_id: String, index: int) -> String:
	return str(stage_at(site_id, index).get("art", ""))


static func stage_prompt(site_id: String, index: int) -> String:
	return str(stage_at(site_id, index).get("prompt", "Repair"))


static func stage_line(site_id: String, index: int) -> String:
	return str(stage_at(site_id, index).get("line", ""))


static func stage_required(site_id: String, index: int) -> Dictionary:
	var req_v: Variant = stage_at(site_id, index).get("required", {})
	if req_v is Dictionary:
		return (req_v as Dictionary).duplicate(true)
	return {}


static func stage_yield(site_id: String, index: int) -> Dictionary:
	var yield_v: Variant = stage_at(site_id, index).get("yield", {})
	if yield_v is Dictionary:
		return (yield_v as Dictionary).duplicate(true)
	return {}


static func site_for_request(ask_id: String) -> String:
	if ask_id.is_empty():
		return ""
	for site_id in ids():
		if request_id(site_id) == ask_id:
			return site_id
	return ""
