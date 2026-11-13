class_name RequestCatalog
extends RefCounted
## Data-driven community requests. RequestState reads this; dialogue does not duplicate lists.

const DATA_PATH := "res://data/requests/catalog.json"
const EXPECTED_IDS: PackedStringArray = [
	"fresh_for_the_table",
	"sanctuary_flowers",
	"broken_fence",
	"garden_needs_hands",
]

static var _loaded: bool = false
static var _max_active: int = 3
static var _requests: Dictionary = {}
static var _order: PackedStringArray = PackedStringArray()


static func ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_requests.clear()
	_order = PackedStringArray()
	var parsed: Variant = JsonFile.read(DATA_PATH)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	_max_active = maxi(1, int(data.get("max_active", 3)))
	var rows_v: Variant = data.get("requests", [])
	if not rows_v is Array:
		return
	for row_v in rows_v as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = (row_v as Dictionary).duplicate(true)
		var request_id := str(row.get("id", ""))
		if request_id.is_empty():
			continue
		_requests[request_id] = row
		_order.append(request_id)


static func max_active() -> int:
	ensure()
	return _max_active


static func ids() -> PackedStringArray:
	ensure()
	return _order.duplicate()


static func has_request(request_id: String) -> bool:
	ensure()
	return _requests.has(request_id)


static func request(request_id: String) -> Dictionary:
	ensure()
	if not _requests.has(request_id):
		return {}
	var row_v: Variant = _requests[request_id]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


static func title(request_id: String) -> String:
	return str(request(request_id).get("title", request_id))


static func npc_id(request_id: String) -> String:
	return str(request(request_id).get("npc", ""))


static func npc_name(request_id: String) -> String:
	var row := request(request_id)
	var named := str(row.get("npc_name", ""))
	if named.is_empty():
		return npc_id(request_id).capitalize()
	return named


static func description(request_id: String) -> String:
	return str(request(request_id).get("description", ""))


static func return_where(request_id: String) -> String:
	return str(request(request_id).get("return_where", ""))


static func required(request_id: String) -> Dictionary:
	var row := request(request_id)
	var req_v: Variant = row.get("required", {})
	if req_v is Dictionary:
		return (req_v as Dictionary).duplicate(true)
	return {}


static func complete_if(request_id: String) -> Dictionary:
	var row := request(request_id)
	var cond_v: Variant = row.get("complete_if", {})
	if cond_v is Dictionary:
		return (cond_v as Dictionary).duplicate(true)
	return {}


static func available_if(request_id: String) -> Dictionary:
	var row := request(request_id)
	var cond_v: Variant = row.get("available_if", {})
	if cond_v is Dictionary:
		return (cond_v as Dictionary).duplicate(true)
	return {}


static func deadline_days(request_id: String) -> int:
	return int(request(request_id).get("deadline_days", 0))


static func is_repeatable(request_id: String) -> bool:
	return bool(request(request_id).get("repeatable", false))


static func cooldown_days(request_id: String) -> int:
	return maxi(0, int(request(request_id).get("cooldown_days", 0)))


static func rewards(request_id: String) -> Dictionary:
	var row := request(request_id)
	var reward_v: Variant = row.get("rewards", {})
	if reward_v is Dictionary:
		return (reward_v as Dictionary).duplicate(true)
	return {}
