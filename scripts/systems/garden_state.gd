extends Node
## Nine church-grounds plots. Growth ticks once per morning if watered. Never touches Pull or ChurchFunds.

const Crops := preload("res://scripts/systems/crop_catalog.gd")
const Catalog := preload("res://scripts/systems/item_catalog.gd")

signal crop_watered(plot_id: String)
signal crop_harvested(plot_id: String, item_id: String, quantity: int)
signal plots_changed
signal garden_action(kind: String)

const PLOT_COUNT := 9
const SOIL_UNTOUCHED := "untouched"
const SOIL_TILLED := "tilled"
const SOIL_HARVESTED := "harvested"


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
	for i in PLOT_COUNT:
		var plot_id := plot_id_at(i)
		_plots[plot_id] = _empty_plot(plot_id)
	_last_processed_day = _clock_day()
	plots_changed.emit()


func plot_id_at(index: int) -> String:
	return "church_%d" % index


func plot_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for i in PLOT_COUNT:
		ids.append(plot_id_at(i))
	return ids


func has_plot(plot_id: String) -> bool:
	return _plots.has(plot_id)


func plot_of(plot_id: String) -> Dictionary:
	if not _plots.has(plot_id):
		return {}
	var row_v: Variant = _plots[plot_id]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


func last_processed_day() -> int:
	return _last_processed_day


func looks_tended() -> bool:
	for plot_id in plot_ids():
		var row := plot_of(plot_id)
		if bool(row.get("planted", false)) or bool(row.get("ready", false)):
			return true
		if str(row.get("soil", "")) == SOIL_HARVESTED or str(row.get("soil", "")) == SOIL_TILLED:
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
	var row := plot_of(plot_id)
	if row.is_empty():
		return "Tend the bed"
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
	var row := plot_of(plot_id)
	if row.is_empty():
		return _result(false, "noop", "That bed is not here.")
	var pack := _pack()
	var tool := ""
	var seed := ""
	if pack != null:
		if pack.has_method("equipped_tool"):
			tool = str(pack.call("equipped_tool"))
		if pack.has_method("equipped_seed"):
			seed = str(pack.call("equipped_seed"))
	if bool(row.get("ready", false)):
		return harvest(plot_id)
	if bool(row.get("planted", false)):
		if bool(row.get("watered", false)):
			return _result(false, "noop", _growing_line(row))
		if tool == "watering_can":
			return water(plot_id)
		if tool == "hoe":
			return _result(false, "noop", "It's planted. A watering can would help.")
		return _result(false, "noop", "A watering can would help.")
	var soil := str(row.get("soil", SOIL_UNTOUCHED))
	if soil == SOIL_UNTOUCHED:
		if tool == "hoe":
			return till(plot_id)
		return _result(false, "noop", "A Hoe would turn this soil.")
	if Catalog.item_is_seed(seed) and pack != null and pack.has_method("has") and bool(pack.call("has", seed, 1)):
		return plant(plot_id, seed)
	if tool == "hoe":
		return _result(false, "noop", "The soil is ready for seed.")
	if tool == "watering_can":
		return _result(false, "noop", "Plant something first.")
	if _has_any_seed(pack):
		return _result(false, "noop", "Equip a seed packet in the pack, then plant.")
	return _result(false, "noop", "Need a seed packet.")


func till(plot_id: String) -> Dictionary:
	var row := _mutable(plot_id)
	if row.is_empty():
		return _result(false, "noop", "That bed is not here.")
	if bool(row.get("planted", false)) or bool(row.get("ready", false)):
		return _result(false, "noop", "Leave the plants. Harvest when they are ready.")
	if str(row.get("soil", "")) != SOIL_UNTOUCHED:
		return _result(false, "noop", "The soil is ready for seed.")
	row["soil"] = SOIL_TILLED
	row["stage"] = "tilled"
	row["watered"] = false
	_store(row)
	_spend_time()
	garden_action.emit("till")
	plots_changed.emit()
	return _result(true, "till", "Tilled the soil.")


func plant(plot_id: String, seed_id: String) -> Dictionary:
	var row := _mutable(plot_id)
	if row.is_empty():
		return _result(false, "noop", "That bed is not here.")
	if bool(row.get("planted", false)) or bool(row.get("ready", false)):
		return _result(false, "noop", "This bed is already planted.")
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
	_store(row)
	_spend_time()
	garden_action.emit("plant")
	plots_changed.emit()
	return _result(true, "plant", "Planted %s." % Catalog.display_name(seed_id))


func water(plot_id: String) -> Dictionary:
	var row := _mutable(plot_id)
	if row.is_empty():
		return _result(false, "noop", "That bed is not here.")
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
	crop_watered.emit(plot_id)
	garden_action.emit("water")
	plots_changed.emit()
	return _result(true, "water", "Watered the bed.")


func harvest(plot_id: String) -> Dictionary:
	var row := _mutable(plot_id)
	if row.is_empty():
		return _result(false, "noop", "That bed is not here.")
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
	_store(row)
	_spend_time()
	crop_harvested.emit(plot_id, item_id, amount)
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
		"plots": rows,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	var rows_v: Variant = data.get("plots", [])
	if rows_v is Array:
		for row_v in rows_v as Array:
			if not row_v is Dictionary:
				continue
			var incoming: Dictionary = row_v
			var plot_id := str(incoming.get("id", ""))
			if not _plots.has(plot_id):
				continue
			var row := _empty_plot(plot_id)
			_apply_row(row, incoming)
			_plots[plot_id] = row
	if data.has("last_processed_day"):
		_last_processed_day = int(data.get("last_processed_day", _clock_day()))
	else:
		_last_processed_day = _clock_day()
	plots_changed.emit()


func _on_time_changed() -> void:
	process_growth()


func _grow_one_morning() -> void:
	for plot_id in plot_ids():
		var row := _mutable(plot_id)
		if row.is_empty():
			continue
		if not bool(row.get("planted", false)) or bool(row.get("ready", false)):
			continue
		if not bool(row.get("watered", false)):
			continue
		var crop_id := str(row.get("crop", ""))
		var needed := Crops.watered_days(crop_id)
		row["growth"] = int(row.get("growth", 0)) + 1
		row["watered"] = false
		if int(row.get("growth", 0)) >= needed:
			row["ready"] = true
		_refresh_stage(row)
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
	}


func _apply_row(row: Dictionary, incoming: Dictionary) -> void:
	row["soil"] = str(incoming.get("soil", SOIL_UNTOUCHED))
	row["crop"] = str(incoming.get("crop", ""))
	row["planted"] = bool(incoming.get("planted", false))
	row["watered"] = bool(incoming.get("watered", false))
	row["growth"] = maxi(0, int(incoming.get("growth", 0)))
	row["ready"] = bool(incoming.get("ready", false))
	var stage := str(incoming.get("stage", ""))
	if stage.is_empty():
		_refresh_stage(row)
	else:
		row["stage"] = stage


func _mutable(plot_id: String) -> Dictionary:
	if not _plots.has(plot_id):
		return {}
	var row_v: Variant = _plots[plot_id]
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
