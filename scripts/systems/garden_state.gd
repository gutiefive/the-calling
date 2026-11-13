extends Node
## Sparse church-garden tiles. Growth ticks once per morning if watered. Never touches Pull or ChurchFunds.

const Crops := preload("res://scripts/systems/crop_catalog.gd")
const Catalog := preload("res://scripts/systems/item_catalog.gd")

signal crop_watered(plot_id: String)
signal crop_harvested(plot_id: String, item_id: String, quantity: int)
signal plots_changed
signal garden_action(kind: String)

const SOIL_UNTOUCHED := "untouched"
const SOIL_TILLED := "tilled"
const SOIL_HARVESTED := "harvested"
const REVERT_DAYS := 3


var _plots: Dictionary = {}
var _last_processed_day: int = 4


func _ready() -> void:
	reset()
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_signal("time_changed"):
		if not clock.time_changed.is_connected(_on_time_changed):
			clock.time_changed.connect(_on_time_changed)


func reset() -> void:
	_plots.clear()
	_last_processed_day = _clock_day()
	plots_changed.emit()


func plot_id_at(index: int) -> String:
	return GroundsLayout.legacy_bed_id(index)


func plot_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	var keys: Array = _plots.keys()
	keys.sort()
	for key in keys:
		ids.append(str(key))
	return ids


func has_plot(plot_id: String) -> bool:
	var key := resolve_id(plot_id)
	if _plots.has(key):
		return true
	return GroundsLayout.is_veg_tillable(GroundsLayout.parse_cell_id(key))


func is_tillable(cell: Vector2i) -> bool:
	return GroundsLayout.is_veg_tillable(cell)


func is_farmable(cell: Vector2i) -> bool:
	if GroundsLayout.is_veg_tillable(cell):
		return true
	return _plots.has(GroundsLayout.cell_id(cell))


func resolve_id(plot_id: String) -> String:
	if plot_id.begins_with("church_"):
		var index := int(plot_id.substr(7))
		if index >= 0 and index < 9:
			return GroundsLayout.legacy_bed_id(index)
	return plot_id


func neighbor_mask(cell: Vector2i) -> int:
	var mask := 0
	if _is_soil_cell(Vector2i(cell.x, cell.y - 1)):
		mask |= 1
	if _is_soil_cell(Vector2i(cell.x + 1, cell.y)):
		mask |= 2
	if _is_soil_cell(Vector2i(cell.x, cell.y + 1)):
		mask |= 4
	if _is_soil_cell(Vector2i(cell.x - 1, cell.y)):
		mask |= 8
	return mask


func plot_of(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	if _plots.has(key):
		var row_v: Variant = _plots[key]
		if row_v is Dictionary:
			return (row_v as Dictionary).duplicate(true)
		return {}
	if GroundsLayout.is_veg_tillable(GroundsLayout.parse_cell_id(key)):
		return _empty_plot(key)
	return {}


func last_processed_day() -> int:
	return _last_processed_day


func looks_tended() -> bool:
	for plot_id in plot_ids():
		var row := plot_of(plot_id)
		if bool(row.get("planted", false)) or bool(row.get("ready", false)):
			return true
		var soil := str(row.get("soil", ""))
		if soil == SOIL_HARVESTED or soil == SOIL_TILLED:
			return true
	return false


func looks_cared_for() -> bool:
	var watered := 0
	var mature := 0
	for plot_id in plot_ids():
		var row := plot_of(plot_id)
		if bool(row.get("ready", false)):
			mature += 1
		if bool(row.get("watered", false)):
			watered += 1
	return mature > 0 or watered >= 3


func prompt_for(plot_id: String) -> String:
	var key := resolve_id(plot_id)
	var cell := GroundsLayout.parse_cell_id(key)
	if not is_farmable(cell):
		return ""
	var row := plot_of(key)
	if row.is_empty():
		return "Till"
	if bool(row.get("ready", false)):
		return "Harvest"
	if bool(row.get("planted", false)):
		if bool(row.get("watered", false)):
			return "Watered"
		return "Water"
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	if soil == SOIL_UNTOUCHED:
		return "Till"
	return "Plant"


func interact_plot(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	var cell := GroundsLayout.parse_cell_id(key)
	if not is_farmable(cell):
		return _result(false, "noop", "Leave the path and the gate clear.")
	var row := plot_of(key)
	if row.is_empty():
		return _result(false, "noop", "Leave the path and the gate clear.")
	var pack := _pack()
	var tool := ""
	var seed := ""
	if pack != null:
		if pack.has_method("equipped_tool"):
			tool = str(pack.call("equipped_tool"))
		if pack.has_method("equipped_seed"):
			seed = str(pack.call("equipped_seed"))
	if bool(row.get("ready", false)):
		return harvest(key)
	if bool(row.get("planted", false)):
		if bool(row.get("watered", false)):
			return _result(false, "noop", _growing_line(row))
		if tool == "watering_can":
			return water(key)
		if tool == "hoe":
			return _result(false, "noop", "It's planted. A watering can would help.")
		return _result(false, "noop", "A watering can would help.")
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	if soil == SOIL_UNTOUCHED:
		if tool == "hoe":
			return till(key)
		return _result(false, "noop", "A Hoe would turn this soil.")
	if Catalog.item_is_seed(seed) and pack != null and pack.has_method("has") and bool(pack.call("has", seed, 1)):
		return plant(key, seed)
	if tool == "hoe":
		return _result(false, "noop", "The soil is ready for seed.")
	if tool == "watering_can":
		return _result(false, "noop", "Plant something first.")
	if _has_any_seed(pack):
		return _result(false, "noop", "Equip a seed packet in the pack, then plant.")
	return _result(false, "noop", "Need a seed packet.")


func till(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	var cell := GroundsLayout.parse_cell_id(key)
	if not GroundsLayout.is_veg_tillable(cell):
		return _result(false, "noop", "Leave the path and the gate clear.")
	var row := _mutable(key)
	if row.is_empty():
		row = _empty_plot(key)
	if bool(row.get("planted", false)) or bool(row.get("ready", false)):
		return _result(false, "noop", "Leave the plants. Harvest when they are ready.")
	if str(row.get("soil", "")) != SOIL_UNTOUCHED:
		return _result(false, "noop", "The soil is ready for seed.")
	row["soil"] = SOIL_TILLED
	row["stage"] = "tilled"
	row["watered"] = false
	row["idle_days"] = 0
	_store(row)
	_spend_time()
	garden_action.emit("till")
	plots_changed.emit()
	return _result(true, "till", "Tilled the soil.")


func plant(plot_id: String, seed_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	var row := _mutable(key)
	if row.is_empty():
		return _result(false, "noop", "A Hoe would turn this soil.")
	if bool(row.get("planted", false)) or bool(row.get("ready", false)):
		return _result(false, "noop", "This ground is already planted.")
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	if soil == SOIL_UNTOUCHED:
		return _result(false, "noop", "A Hoe would turn this soil.")
	var crop_id := Crops.crop_for_seed(seed_id)
	if crop_id.is_empty():
		return _result(false, "noop", "Those are not garden seeds.")
	var pack := _pack()
	if pack == null or not pack.has_method("has") or not bool(pack.call("has", seed_id, 1)):
		return _result(false, "noop", "Need a seed packet.")
	if int(pack.call("remove", seed_id, 1)) < 1:
		return _result(false, "noop", "Need a seed packet.")
	row["crop"] = crop_id
	row["planted"] = true
	row["watered"] = false
	row["growth"] = 0
	row["ready"] = false
	row["stage"] = "seeded"
	row["idle_days"] = 0
	_store(row)
	_spend_time()
	garden_action.emit("plant")
	plots_changed.emit()
	return _result(true, "plant", "Planted %s." % Catalog.display_name(seed_id))


func water(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	var row := _mutable(key)
	if row.is_empty():
		return _result(false, "noop", "Plant something first.")
	if not bool(row.get("planted", false)):
		return _result(false, "noop", "Plant something first.")
	if bool(row.get("ready", false)):
		return _result(false, "noop", "It's ready to pick.")
	if bool(row.get("watered", false)):
		return _result(false, "noop", "Already watered.")
	row["watered"] = true
	_refresh_stage(row)
	_store(row)
	_spend_time()
	crop_watered.emit(key)
	garden_action.emit("water")
	plots_changed.emit()
	return _result(true, "water", "Watered the soil.")


func harvest(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	var row := _mutable(key)
	if row.is_empty():
		return _result(false, "noop", "Not ready yet.")
	if not bool(row.get("ready", false)):
		return _result(false, "noop", "Not ready yet.")
	var crop_id := str(row.get("crop", ""))
	var item_id := Crops.item_id(crop_id)
	var amount := Crops.yield_count(crop_id)
	var pack := _pack()
	if pack == null or not pack.has_method("can_add") or not bool(pack.call("can_add", item_id, amount)):
		return _result(false, "noop", "No room in the pack.")
	var added := int(pack.call("add", item_id, amount))
	if added < amount:
		if added > 0:
			pack.call("remove", item_id, added)
		return _result(false, "noop", "No room in the pack.")
	row["soil"] = SOIL_HARVESTED
	row["crop"] = ""
	row["planted"] = false
	row["watered"] = false
	row["growth"] = 0
	row["ready"] = false
	row["stage"] = "harvested"
	row["idle_days"] = 0
	_store(row)
	_spend_time()
	crop_harvested.emit(key, item_id, amount)
	garden_action.emit("harvest")
	plots_changed.emit()
	var noun := Catalog.display_name(item_id)
	var line := "Harvested %s." % noun
	if amount > 1:
		line = "Harvested %d %s." % [amount, noun]
	return _result(true, "harvest", line)


func process_growth() -> int:
	var day := _clock_day()
	var hour := _clock_hour()
	if _last_processed_day > day:
		_last_processed_day = day
		return 0
	if hour < 6:
		return 0
	var ticks := 0
	while _last_processed_day < day:
		_last_processed_day += 1
		_grow_one_morning()
		ticks += 1
	if ticks > 0:
		plots_changed.emit()
	return ticks


func to_dictionary() -> Dictionary:
	var rows: Array = []
	for plot_id in plot_ids():
		rows.append(plot_of(plot_id))
	return {
		"last_processed_day": _last_processed_day,
		"tiles": _tiles_blob(),
		"plots": rows,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	_ingest_tiles(data)
	if data.has("last_processed_day"):
		_last_processed_day = int(data.get("last_processed_day", _clock_day()))
	else:
		_last_processed_day = _clock_day()
	plots_changed.emit()


func ingest_legacy_plots(plots_v: Variant) -> void:
	if not plots_v is Array:
		return
	for row_v in plots_v as Array:
		if not row_v is Dictionary:
			continue
		var incoming: Dictionary = row_v
		var plot_id := str(incoming.get("id", ""))
		var key := resolve_id(plot_id)
		if key.is_empty() or key.find(",") < 0:
			continue
		if not GroundsLayout.is_veg_tillable(GroundsLayout.parse_cell_id(key)):
			continue
		if not _row_has_work(incoming) and str(incoming.get("soil", SOIL_UNTOUCHED)) == SOIL_UNTOUCHED:
			continue
		var row := _empty_plot(key)
		_apply_row(row, incoming)
		row["id"] = key
		_plots[key] = row


func _on_time_changed() -> void:
	process_growth()


func _grow_one_morning() -> void:
	var keys: Array = _plots.keys()
	for key_v in keys:
		var key := str(key_v)
		var row := _mutable(key)
		if row.is_empty():
			continue
		if bool(row.get("planted", false)) and not bool(row.get("ready", false)):
			if bool(row.get("watered", false)):
				var crop_id := str(row.get("crop", ""))
				var needed := Crops.watered_days(crop_id)
				row["growth"] = int(row.get("growth", 0)) + 1
				row["watered"] = false
				if int(row.get("growth", 0)) >= needed:
					row["ready"] = true
				_refresh_stage(row)
				row["idle_days"] = 0
				_store(row)
			continue
		if bool(row.get("planted", false)) or bool(row.get("ready", false)):
			row["watered"] = false
			_store(row)
			continue
		var soil := str(row.get("soil", SOIL_UNTOUCHED))
		if soil != SOIL_TILLED and soil != SOIL_HARVESTED:
			continue
		row["watered"] = false
		row["idle_days"] = int(row.get("idle_days", 0)) + 1
		if int(row.get("idle_days", 0)) >= REVERT_DAYS:
			_plots.erase(key)
		else:
			_store(row)


func _refresh_stage(row: Dictionary) -> void:
	if bool(row.get("ready", false)):
		row["stage"] = "mature"
		return
	if bool(row.get("planted", false)):
		var growth := int(row.get("growth", 0))
		var needed := Crops.watered_days(str(row.get("crop", "")))
		if growth <= 0:
			row["stage"] = "seeded"
		elif growth == 1:
			row["stage"] = "sprout"
		elif growth >= needed:
			row["stage"] = "mature"
		else:
			row["stage"] = "growing"
		return
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	if soil == SOIL_HARVESTED:
		row["stage"] = "harvested"
	elif soil == SOIL_TILLED:
		row["stage"] = "tilled"
	else:
		row["stage"] = "untouched"


func _growing_line(row: Dictionary) -> String:
	var crop_id := str(row.get("crop", ""))
	var name := Crops.display_name(crop_id)
	var stage := str(row.get("stage", "seeded"))
	if stage == "seeded":
		return "Watered. Come back after it grows."
	if stage == "sprout":
		return "%s is up. Come back after it grows." % name
	return "%s is growing. Come back after it grows." % name


func _empty_plot(plot_id: String) -> Dictionary:
	return {
		"id": plot_id,
		"soil": SOIL_UNTOUCHED,
		"crop": "",
		"planted": false,
		"watered": false,
		"growth": 0,
		"stage": "untouched",
		"ready": false,
		"idle_days": 0,
	}


func _apply_row(row: Dictionary, incoming: Dictionary) -> void:
	row["soil"] = str(incoming.get("soil", SOIL_UNTOUCHED))
	row["crop"] = str(incoming.get("crop", ""))
	row["planted"] = bool(incoming.get("planted", false))
	row["watered"] = bool(incoming.get("watered", false))
	row["growth"] = maxi(0, int(incoming.get("growth", 0)))
	row["ready"] = bool(incoming.get("ready", false))
	row["idle_days"] = maxi(0, int(incoming.get("idle_days", 0)))
	var stage := str(incoming.get("stage", ""))
	if stage.is_empty():
		_refresh_stage(row)
	else:
		row["stage"] = stage


func _mutable(plot_id: String) -> Dictionary:
	var key := resolve_id(plot_id)
	if not _plots.has(key):
		if GroundsLayout.is_veg_tillable(GroundsLayout.parse_cell_id(key)):
			return _empty_plot(key)
		return {}
	var row_v: Variant = _plots[key]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


func _store(row: Dictionary) -> void:
	var plot_id := str(row.get("id", ""))
	if plot_id.is_empty():
		return
	_plots[plot_id] = row


func _result(ok: bool, kind: String, message: String) -> Dictionary:
	return {"ok": ok, "kind": kind, "message": message}


func _spend_time() -> void:
	var minutes := Crops.action_minutes()
	if minutes <= 0:
		return
	var clock := get_node_or_null("/root/DayClock")
	if clock == null or not clock.has_method("advance_minutes"):
		return
	if clock.has_method("at_cap") and bool(clock.call("at_cap")):
		return
	clock.call("advance_minutes", minutes)


func _has_any_seed(pack: Node) -> bool:
	if pack == null or not pack.has_method("quantity"):
		return false
	for crop_id in Crops.ids():
		var seed_id := Crops.seed_id(crop_id)
		if int(pack.call("quantity", seed_id)) > 0:
			return true
	return false


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _clock_day() -> int:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return 4
	return int(clock.get("weekday"))


func _clock_hour() -> int:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return 14
	return int(clock.get("hour"))


func _is_soil_cell(cell: Vector2i) -> bool:
	var key := GroundsLayout.cell_id(cell)
	if not _plots.has(key):
		return false
	var row_v: Variant = _plots[key]
	if not row_v is Dictionary:
		return false
	var soil := str((row_v as Dictionary).get("soil", SOIL_UNTOUCHED))
	return soil == SOIL_TILLED or soil == SOIL_HARVESTED or bool((row_v as Dictionary).get("planted", false))


func _tiles_blob() -> Dictionary:
	var blob: Dictionary = {}
	for plot_id in plot_ids():
		blob[plot_id] = plot_of(plot_id)
	return blob


func _ingest_tiles(data: Dictionary) -> void:
	var tiles_v: Variant = data.get("tiles", null)
	if tiles_v is Dictionary:
		var tiles: Dictionary = tiles_v
		for key_v in tiles.keys():
			var incoming_v: Variant = tiles[key_v]
			if not incoming_v is Dictionary:
				continue
			var incoming: Dictionary = incoming_v
			var key := resolve_id(str(key_v))
			if str(incoming.get("id", "")).is_empty():
				incoming["id"] = key
			else:
				key = resolve_id(str(incoming.get("id", key)))
			if not GroundsLayout.is_veg_tillable(GroundsLayout.parse_cell_id(key)) and not _row_has_work(incoming):
				continue
			if not _row_has_work(incoming) and str(incoming.get("soil", SOIL_UNTOUCHED)) == SOIL_UNTOUCHED:
				continue
			var row := _empty_plot(key)
			_apply_row(row, incoming)
			row["id"] = key
			_plots[key] = row
		return
	ingest_legacy_plots(data.get("plots", []))


func _row_has_work(row: Dictionary) -> bool:
	if bool(row.get("planted", false)) or bool(row.get("ready", false)):
		return true
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	return soil == SOIL_TILLED or soil == SOIL_HARVESTED
