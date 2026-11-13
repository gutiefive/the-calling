class_name CropCatalog
extends RefCounted
## Crop growth, yields, and seed links. GardenState reads this; it does not duplicate lists.

const DATA_PATH := "res://data/crops/catalog.json"
const EXPECTED_IDS: PackedStringArray = ["lettuce", "carrots", "tomatoes", "flowers"]

static var _loaded: bool = false
static var _action_minutes: int = 8
static var _crops: Dictionary = {}
static var _order: PackedStringArray = PackedStringArray()
static var _by_seed: Dictionary = {}


static func ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_crops.clear()
	_order = PackedStringArray()
	_by_seed.clear()
	var parsed: Variant = JsonFile.read(DATA_PATH)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	_action_minutes = maxi(0, int(data.get("action_minutes", 8)))
	var rows_v: Variant = data.get("crops", [])
	if not rows_v is Array:
		return
	for row_v in rows_v as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = (row_v as Dictionary).duplicate(true)
		var crop_id := str(row.get("id", ""))
		if crop_id.is_empty():
			continue
		_crops[crop_id] = row
		_order.append(crop_id)
		var seed_id := str(row.get("seed_id", ""))
		if not seed_id.is_empty():
			_by_seed[seed_id] = crop_id


static func action_minutes() -> int:
	ensure()
	return _action_minutes


static func ids() -> PackedStringArray:
	ensure()
	return _order.duplicate()


static func has_crop(crop_id: String) -> bool:
	ensure()
	return _crops.has(crop_id)


static func crop(crop_id: String) -> Dictionary:
	ensure()
	if not _crops.has(crop_id):
		return {}
	var row_v: Variant = _crops[crop_id]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


static func display_name(crop_id: String) -> String:
	var row := crop(crop_id)
	if row.is_empty():
		return crop_id
	return str(row.get("name", crop_id))


static func seed_id(crop_id: String) -> String:
	return str(crop(crop_id).get("seed_id", ""))


static func item_id(crop_id: String) -> String:
	return str(crop(crop_id).get("item_id", crop_id))


static func watered_days(crop_id: String) -> int:
	return maxi(1, int(crop(crop_id).get("watered_days", 2)))


static func yield_count(crop_id: String) -> int:
	return maxi(1, int(crop(crop_id).get("yield", 1)))


static func crop_for_seed(seed_id: String) -> String:
	ensure()
	return str(_by_seed.get(seed_id, ""))
