extends Node
## Headless checks for Gameplay Phase B (church garden, growth, harvest, save v8).
## Prints GPB_OK or GPB_FAIL.
## Run: godot --headless --path . res://tests/gpb/gpb_validation.tscn

const Crops := preload("res://scripts/systems/crop_catalog.gd")
const Catalog := preload("res://scripts/systems/item_catalog.gd")

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	NarrativeState.reset()
	DayClock.reset()
	_crop_data()
	_full_cycle_every_crop()
	_wrong_tool_and_missing_seed()
	_unwatered_does_not_grow()
	_seed_use_and_yield()
	_no_pull_or_funds()
	await _chapter1_and_layout()
	await _save_and_scene()
	_old_save_migration()
	_restore_user_save()
	_finish()


func _crop_data() -> void:
	_check(FileAccess.file_exists("res://data/crops/catalog.json"), "crop catalog exists")
	_check(Crops.ids().size() == Crops.EXPECTED_IDS.size(), "crop catalog has four crops")
	_check(Crops.watered_days("lettuce") == 2 and Crops.yield_count("lettuce") == 1, "lettuce is 2 days / 1 yield")
	_check(Crops.watered_days("carrots") == 3 and Crops.yield_count("carrots") == 2, "carrots are 3 days / 2 yield")
	_check(Crops.watered_days("tomatoes") == 4 and Crops.yield_count("tomatoes") == 3, "tomatoes are 4 days / 3 yield")
	_check(Crops.watered_days("flowers") == 3 and Crops.yield_count("flowers") == 2, "flowers are 3 days / 2 yield")
	_check(Crops.crop_for_seed("lettuce_seeds") == "lettuce", "lettuce seeds plant lettuce")
	_check(Catalog.item_is_seed("carrot_seeds") and not Catalog.item_is_seed("hoe"), "seed packets are seeds")
	var garden := _garden()
	_check(garden != null, "GardenState autoload exists")
	_check(garden != null and garden.has_method("is_tillable") and bool(garden.call("is_tillable", GroundsLayout.legacy_bed_cell(0))), "the church garden still farms the old bed cells")


func _full_cycle_every_crop() -> void:
	var garden := _garden()
	var pack := _pack()
	for crop_id in Crops.ids():
		_fresh_day()
		_prep_tools()
		var plot_id := "church_0"
		pack.call("equip", "hoe")
		var tilled := _result(garden.call("till", plot_id))
		_check(bool(tilled.get("ok", false)), "%s till succeeds" % crop_id)
		_check(str(_plot(plot_id).get("stage", "")) == "tilled", "%s soil is tilled" % crop_id)
		var seed_id := Crops.seed_id(crop_id)
		pack.call("add", seed_id, 1)
		pack.call("equip_seed", seed_id)
		var planted := _result(garden.call("plant", plot_id, seed_id))
		_check(bool(planted.get("ok", false)), "%s plant succeeds" % crop_id)
		_check(int(pack.call("quantity", seed_id)) == 0, "%s consumed the seed packet" % crop_id)
		var days := Crops.watered_days(crop_id)
		for morning in days:
			pack.call("equip", "watering_can")
			var watered := _result(garden.call("water", plot_id))
			_check(bool(watered.get("ok", false)), "%s water on morning %d succeeds" % [crop_id, morning])
			DayClock.set_time(4 + morning + 1, 6, 0)
		var row := _plot(plot_id)
		_check(bool(row.get("ready", false)), "%s is ready after %d watered mornings" % [crop_id, days])
		_check(str(row.get("stage", "")) == "mature", "%s stage is mature" % crop_id)
		var harvested := _result(garden.call("harvest", plot_id))
		_check(bool(harvested.get("ok", false)), "%s harvest succeeds" % crop_id)
		_check(int(pack.call("quantity", Crops.item_id(crop_id))) == Crops.yield_count(crop_id), "%s yield matches" % crop_id)
		var after := _plot(plot_id)
		_check(not bool(after.get("planted", true)), "%s plot is free after harvest" % crop_id)
		_check(str(after.get("soil", "")) == "harvested", "%s soil is harvested and plantable" % crop_id)


func _wrong_tool_and_missing_seed() -> void:
	var garden := _garden()
	var pack := _pack()
	_fresh_day()
	_prep_tools()
	pack.call("equip", "watering_can")
	var wet := _result(garden.call("interact_plot", "church_1"))
	_check(not bool(wet.get("ok", true)), "watering untouched soil does nothing")
	_check(str(_plot("church_1").get("soil", "")) == "untouched", "wrong tool leaves the plot untouched")
	pack.call("equip", "hoe")
	garden.call("till", "church_1")
	pack.call("equip_seed", "")
	var empty := _result(garden.call("interact_plot", "church_1"))
	_check(not bool(empty.get("ok", true)), "planting without a seed does nothing")
	_check(not bool(_plot("church_1").get("planted", true)), "missing seed leaves the tilled plot")
	_check(int(pack.call("quantity", "lettuce_seeds")) == 0, "missing seed consumes nothing")
	pack.call("equip", "hoe")
	var again := _result(garden.call("interact_plot", "church_1"))
	_check(not bool(again.get("ok", true)), "hoeing a tilled plot does nothing")
	_check(str(_plot("church_1").get("soil", "")) == "tilled", "second hoe leaves tilled soil")


func _unwatered_does_not_grow() -> void:
	var garden := _garden()
	var pack := _pack()
	_fresh_day()
	_prep_tools()
	pack.call("equip", "hoe")
	garden.call("till", "church_2")
	pack.call("add", "lettuce_seeds", 1)
	pack.call("equip_seed", "lettuce_seeds")
	garden.call("plant", "church_2", "lettuce_seeds")
	DayClock.set_time(5, 6, 0)
	DayClock.set_time(6, 6, 0)
	var row := _plot("church_2")
	_check(int(row.get("growth", -1)) == 0, "an unwatered crop does not grow")
	_check(not bool(row.get("ready", true)), "an unwatered crop is not ready")
	_check(bool(row.get("planted", false)), "an unwatered crop never dies")
	pack.call("equip", "watering_can")
	garden.call("water", "church_2")
	DayClock.set_time(7, 6, 0)
	row = _plot("church_2")
	_check(int(row.get("growth", 0)) == 1, "growth resumes after watering")
	_check(not bool(row.get("watered", true)), "soil dries after a morning")


func _seed_use_and_yield() -> void:
	var garden := _garden()
	var pack := _pack()
	_fresh_day()
	_prep_tools()
	pack.call("add", "tomato_seeds", 2)
	pack.call("equip", "hoe")
	garden.call("till", "church_3")
	pack.call("equip_seed", "tomato_seeds")
	garden.call("plant", "church_3", "tomato_seeds")
	_check(int(pack.call("quantity", "tomato_seeds")) == 1, "planting consumes one packet and leaves the rest")
	for morning in Crops.watered_days("tomatoes"):
		pack.call("equip", "watering_can")
		garden.call("water", "church_3")
		DayClock.set_time(4 + morning + 1, 6, 0)
	garden.call("harvest", "church_3")
	_check(int(pack.call("quantity", "tomatoes")) == 3, "tomato harvest yields 3")


func _no_pull_or_funds() -> void:
	var garden := _garden()
	var pack := _pack()
	var funds := _funds()
	var inf := get_node_or_null("/root/InfluenceState")
	NarrativeState.reset()
	DayClock.reset()
	_fresh_day()
	_prep_tools()
	if inf != null and inf.has_method("reset"):
		inf.call("reset")
	if funds != null and funds.has_method("reset"):
		funds.call("reset")
	var pull_before := 0
	var dependents_before := 0
	if inf != null:
		pull_before = int(inf.call("pull_total"))
		dependents_before = int(inf.call("pull_part", "dependents"))
	var church_before := int(funds.get("balance")) if funds != null else 0
	var attend_before := NarrativeState.growth_value("attendance")
	pack.call("equip", "hoe")
	garden.call("till", "church_4")
	pack.call("add", "flower_seeds", 1)
	pack.call("equip_seed", "flower_seeds")
	garden.call("plant", "church_4", "flower_seeds")
	pack.call("equip", "watering_can")
	garden.call("water", "church_4")
	DayClock.set_time(5, 6, 0)
	pack.call("equip", "watering_can")
	garden.call("water", "church_4")
	DayClock.set_time(6, 6, 0)
	pack.call("equip", "watering_can")
	garden.call("water", "church_4")
	DayClock.set_time(7, 6, 0)
	garden.call("harvest", "church_4")
	var pull_after := 0
	var dependents_after := 0
	if inf != null:
		pull_after = int(inf.call("pull_total"))
		dependents_after = int(inf.call("pull_part", "dependents"))
	_check(pull_before == pull_after, "gardening does not change Pull")
	_check(dependents_before == dependents_after, "gardening does not change dependents")
	_check(church_before == int(funds.get("balance")), "gardening does not touch ChurchFunds")
	_check(attend_before == NarrativeState.growth_value("attendance"), "gardening does not change attendance")


func _chapter1_and_layout() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var lane := _instance("res://scenes/world/maple_lane.tscn")
	if lane == null:
		return
	await _pump(2)
	var plot := lane.get_node_or_null("Props/Garden") as GardenPlot
	_check(plot != null, "the Chapter 1 Maple Lane plot is still there")
	_check(lane.get_node_or_null("Props/SeedCrate") == null, "Maple Lane no longer has the seed crate")
	if plot != null:
		_check(plot.plot_id == "", "the Chapter 1 plot is not a church farm bed")
		plot.interact(null)
		_check(NarrativeState.flag_is_true("garden_cleared"), "clearing weeds still sets garden_cleared")
		_check(not NarrativeState.flag_is_true("garden_planted"), "clearing weeds does not plant the Chapter 1 plot")
		plot.interact(null)
		_check(not NarrativeState.flag_is_true("garden_planted"), "a second tend does not plant without the neighbor")
	lane.free()
	await _pump(1)
	NarrativeState.reset()
	DayClock.reset()
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	await _pump(2)
	var crate := grounds.get_node_or_null("Props/SeedCrate") as ItemPickup
	_check(crate != null, "the church garden has the seed crate")
	_check(grounds.get_node_or_null("Props/GardenNote") != null, "Ruth left a garden card")
	_check(grounds.get_node_or_null("Props/FarmField") != null, "the church garden is an in-ground field")
	_check(grounds.get_node_or_null("Props/ChurchPlot0") == null, "raised wooden beds are gone")
	_garden().call("till", "church_0")
	_check(not NarrativeState.flag_is_true("garden_cleared"), "tilling a church bed does not set garden_cleared")
	_check(not NarrativeState.flag_is_true("garden_planted"), "tilling a church bed does not set garden_planted")
	grounds.free()
	await _pump(1)


func _save_and_scene() -> void:
	var garden := _garden()
	var pack := _pack()
	var funds := _funds()
	NarrativeState.reset()
	DayClock.reset()
	_fresh_day()
	funds.call("reset")
	_prep_tools()
	pack.call("equip", "hoe")
	garden.call("till", "church_5")
	pack.call("add", "carrot_seeds", 2)
	pack.call("equip_seed", "carrot_seeds")
	garden.call("plant", "church_5", "carrot_seeds")
	pack.call("equip", "watering_can")
	garden.call("water", "church_5")
	NarrativeState.set_flag("frank_listened", true)
	funds.set("balance", 80)
	pack.call("set_cash", 12)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	if player == null:
		_check(false, "save round-trip needs the player")
		room.free()
		return
	player.global_position = Vector2(420, 510)
	var saved := SaveGame.save_to_disk(get_tree())
	_check(saved, "a version 9 save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary, "the save file is an object")
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == 9, "the save file is version 9")
	_check(row.has("garden"), "the save stores garden plots")
	room.free()
	await _pump(1)
	NarrativeState.reset()
	_check(str(_plot("church_5").get("stage", "")) == "untouched", "reset clears church plots")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == 9, "read_file keeps version 9")
	SaveGame.apply_state(loaded)
	var restored := _plot("church_5")
	_check(bool(restored.get("planted", false)), "load restores a planted plot")
	_check(bool(restored.get("watered", false)), "load restores watered soil")
	_check(str(restored.get("crop", "")) == "carrots", "load restores the crop")
	_check(int(pack.call("quantity", "carrot_seeds")) == 1, "load keeps the leftover seed")
	_check(int(funds.get("balance")) == 80, "load keeps church funds")
	_check(NarrativeState.flag_is_true("frank_listened"), "load keeps story flags")
	var again := _instance("res://scenes/world/church_exterior.tscn")
	if again == null:
		return
	await _pump(2)
	var field := again.get_node_or_null("Props/FarmField")
	_check(field != null, "re-entering the grounds finds the garden field")
	if field != null and field.has_method("rebuild"):
		field.call("rebuild")
	_check(str(_plot("church_5").get("crop", "")) == "carrots", "scene re-entry keeps plot state")
	again.free()
	NarrativeState.reset()
	await _pump(1)


func _old_save_migration() -> void:
	var from_v7 := SaveGame.migrate({
		"version": 7,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 4, "hour": 14, "minute": 0},
		"chapter": "",
		"funds": {"balance": 80, "project_state": "none", "project_progress": 0},
		"pastor_path": {"shepherd": 1, "builder": 0, "skeptic": 0, "history": [], "seed": 42},
		"threads": {"frank_grief": "open"},
		"run_seed": 42,
		"inventory": {
			"slots": [{"id": "hoe", "qty": 1}, {"id": "lettuce_seeds", "qty": 2}],
			"equipped": "hoe",
			"cash": 12,
		},
		"narrative": {
			"flags": {"frank_listened": true, "spare_keys_returned": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v7.get("version", 0)) == 9, "a version 7 file migrates to version 9")
	var garden_v: Variant = from_v7.get("garden", {})
	var garden_row: Dictionary = garden_v if garden_v is Dictionary else {}
	var plots_v: Variant = garden_row.get("plots", null)
	_check(plots_v is Array, "v7 migration adds a garden blob")
	if plots_v is Array:
		_check((plots_v as Array).is_empty() or _plots_are_empty(plots_v), "v7 migration leaves plots empty and untilled")
	var inv_v: Variant = from_v7.get("inventory", {})
	var inv: Dictionary = inv_v if inv_v is Dictionary else {}
	_check(int(inv.get("cash", -1)) == 12, "v7 migration keeps the wallet")
	_check(int(from_v7.get("run_seed", 0)) == 42, "v7 migration keeps the run seed")
	_check(SaveGame.migrate({"version": 10, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	var pack := _pack()
	var funds := _funds()
	var garden := _garden()
	NarrativeState.reset()
	SaveGame.apply_state(from_v7)
	_check(int(pack.call("cash")) == 12, "applying a migrated v7 save keeps the wallet")
	_check(int(pack.call("quantity", "hoe")) == 1, "applying a migrated v7 save keeps the pack")
	_check(int(funds.get("balance")) == 80, "applying a migrated v7 save keeps church funds")
	_check(NarrativeState.flag_is_true("frank_listened"), "applying a migrated v7 save keeps story flags")
	_check(str(_plot("church_0").get("soil", "")) == "untouched", "applying a migrated v7 save uses empty untilled plots")
	NarrativeState.reset()


func _plots_are_empty(plots_v: Variant) -> bool:
	if not plots_v is Array:
		return false
	for row_v in plots_v as Array:
		if not row_v is Dictionary:
			return false
		var row: Dictionary = row_v
		if bool(row.get("planted", false)) or str(row.get("soil", "untouched")) != "untouched":
			return false
	return true


func _fresh_day() -> void:
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(4, 14, 0)
	var garden := _garden()
	if garden != null and garden.has_method("reset"):
		garden.call("reset")


func _plot(plot_id: String) -> Dictionary:
	var garden := _garden()
	if garden == null or not garden.has_method("plot_of"):
		return {}
	var raw: Variant = garden.call("plot_of", plot_id)
	return raw if raw is Dictionary else {}


func _result(raw: Variant) -> Dictionary:
	return raw if raw is Dictionary else {}


func _prep_tools() -> void:
	var pack := _pack()
	pack.call("reset")
	pack.call("add", "hoe", 1)
	pack.call("add", "watering_can", 1)
	pack.call("add", "hand_tools", 1)
	pack.call("equip", "hoe")


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


func _instance(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	_check(room != null, "instantiate " + path)
	if room == null:
		return null
	add_child(room)
	return room


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("GPB_OK" if not _failed else "GPB_FAIL")
	tree.quit(0 if not _failed else 1)
