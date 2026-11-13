extends Node
## Headless checks for Gameplay Phase C (requests, in-ground garden, save v9).
## Prints GPC_OK or GPC_FAIL.
## Run: godot --headless --path . res://tests/gpc/gpc_validation.tscn

const Crops := preload("res://scripts/systems/crop_catalog.gd")
const Items := preload("res://scripts/systems/item_catalog.gd")
const Asks := preload("res://scripts/systems/request_catalog.gd")

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
	_catalog_and_tiles()
	_unlock_and_accept()
	_three_active_limit()
	_item_tracking_and_delivery()
	_missing_items_fail()
	_no_duplicate_rewards()
	_completion_history_and_expiry()
	_no_pull_or_funds()
	_ruth_maple_flags()
	_dialogue_accept()
	await _layout_and_scene()
	await _save_and_load()
	_old_save_migration()
	_restore_user_save()
	_finish()


func _catalog_and_tiles() -> void:
	_check(FileAccess.file_exists("res://data/requests/catalog.json"), "request catalog exists")
	_check(Asks.ids().size() == Asks.EXPECTED_IDS.size(), "request catalog has four asks")
	_check(Asks.has_request("fresh_for_the_table"), "Sarah's vegetable ask is in data")
	_check(Asks.has_request("sanctuary_flowers"), "Margaret's flower ask is in data")
	_check(Asks.has_request("broken_fence"), "Harold's fence ask is in data")
	_check(Asks.has_request("garden_needs_hands"), "Ruth's garden ask is in data")
	_check(int(Asks.required("fresh_for_the_table").get("lettuce", 0)) == 2, "Sarah asks for lettuce")
	_check(int(Asks.required("sanctuary_flowers").get("flowers", 0)) == 3, "Margaret asks for flowers")
	_check(int(Asks.required("broken_fence").get("wood", 0)) == 3, "Harold asks for wood")
	_check(Asks.required("garden_needs_hands").is_empty(), "Ruth's ask uses Maple Lane flags, not church crops")
	var garden := _garden()
	_check(garden != null, "GardenState autoload exists")
	_check(_asks() != null, "RequestState autoload exists")
	_check(bool(garden.call("is_tillable", GroundsLayout.legacy_bed_cell(0))), "a former bed cell is still tillable")
	_check(bool(garden.call("is_tillable", Vector2i(45, 37))), "an arbitrary interior tile is tillable")
	_check(not bool(garden.call("is_tillable", Vector2i(40, 35))), "the path by Ruth's card is not tillable")
	_check(not bool(garden.call("is_tillable", Vector2i(40, 36))), "the seed crate tile is not tillable")
	_check(not bool(garden.call("is_tillable", Vector2i(39, 34))), "the fence is not tillable")
	_check(not bool(garden.call("is_tillable", Vector2i(10, 10))), "tiles outside the garden are not tillable")
	_fresh_garden()
	_prep_tools()
	var pack := _pack()
	pack.call("equip", "hoe")
	var blocked := _result(garden.call("till", GroundsLayout.cell_id(Vector2i(40, 35))))
	_check(not bool(blocked.get("ok", true)), "tilling a reserved tile fails")
	var open_id := GroundsLayout.cell_id(Vector2i(44, 37))
	var tilled := _result(garden.call("till", open_id))
	_check(bool(tilled.get("ok", false)), "tilling an arbitrary grass tile succeeds")
	_check(str(_plot(open_id).get("soil", "")) == "tilled", "the arbitrary tile is tilled")


func _unlock_and_accept() -> void:
	for request_id in Asks.ids():
		_week_open()
		var asks := _asks()
		_check(bool(asks.call("is_unlocked", request_id)), "%s unlocks after the week continues" % request_id)
		_check(bool(asks.call("is_available", request_id)), "%s is available" % request_id)
		var accepted := _result(asks.call("accept", request_id))
		_check(bool(accepted.get("ok", false)), "%s accept succeeds" % request_id)
		_check(bool(asks.call("is_active", request_id)), "%s is active after accept" % request_id)
		_check(not bool(asks.call("is_available", request_id)), "%s is not offered twice while active" % request_id)


func _three_active_limit() -> void:
	_week_open()
	var asks := _asks()
	var ids := Asks.ids()
	for i in 3:
		_check(bool(_result(asks.call("accept", str(ids[i]))).get("ok", false)), "accept %d of 3 succeeds" % (i + 1))
	_check(bool(asks.call("slots_full")), "three active asks fill the list")
	var fourth := _result(asks.call("accept", str(ids[3])))
	_check(not bool(fourth.get("ok", true)), "a fourth accept is refused")
	_check(int(asks.call("active_count")) == 3, "active count stays at 3")
	_check(not bool(asks.call("is_active", str(ids[3]))), "the fourth ask stays inactive")


func _item_tracking_and_delivery() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	pack.call("reset")
	asks.call("accept", "fresh_for_the_table")
	pack.call("add", "lettuce", 2)
	pack.call("add", "carrots", 2)
	pack.call("add", "tomatoes", 3)
	_check(asks.call("progress_line", "fresh_for_the_table").contains("2/2"), "progress tracks full stacks")
	var delivered := _result(asks.call("deliver", "fresh_for_the_table"))
	_check(bool(delivered.get("ok", false)), "delivery succeeds with the right crops")
	_check(int(pack.call("quantity", "lettuce")) == 0, "delivery removes the lettuce")
	_check(int(pack.call("quantity", "carrots")) == 0, "delivery removes the carrots")
	_check(int(pack.call("quantity", "tomatoes")) == 3, "delivery leaves unrelated crops")
	_check(bool(asks.call("is_completed", "fresh_for_the_table")), "Sarah's ask is completed")
	_check(int(pack.call("cash")) == Items.starting_cash() + 4, "Sarah's thank-you is a small personal tip")


func _missing_items_fail() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	pack.call("reset")
	pack.call("add", "lettuce", 1)
	pack.call("add", "carrots", 2)
	asks.call("accept", "fresh_for_the_table")
	var failed := _result(asks.call("deliver", "fresh_for_the_table"))
	_check(not bool(failed.get("ok", true)), "delivery with missing items fails")
	_check(int(pack.call("quantity", "lettuce")) == 1, "a failed delivery keeps the lettuce")
	_check(int(pack.call("quantity", "carrots")) == 2, "a failed delivery keeps the carrots")
	_check(not bool(asks.call("is_completed", "fresh_for_the_table")), "a failed delivery does not complete the ask")
	_check(str(failed.get("message", "")).begins_with("Missing:"), "missing items name what is short")


func _no_duplicate_rewards() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	pack.call("reset")
	pack.call("add", "flowers", 6)
	asks.call("accept", "sanctuary_flowers")
	var first := _result(asks.call("deliver", "sanctuary_flowers"))
	_check(bool(first.get("ok", false)), "first flower delivery succeeds")
	var cash_after := int(pack.call("cash"))
	var seeds_after := int(pack.call("quantity", "flower_seeds"))
	var second := _result(asks.call("deliver", "sanctuary_flowers"))
	_check(not bool(second.get("ok", true)), "a second delivery is refused")
	_check(int(pack.call("cash")) == cash_after, "duplicate delivery does not pay again")
	_check(int(pack.call("quantity", "flower_seeds")) == seeds_after, "duplicate delivery does not grant seeds again")
	_check(int(pack.call("quantity", "flowers")) == 3, "duplicate delivery does not consume more flowers")


func _completion_history_and_expiry() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	pack.call("reset")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	asks.call("accept", "broken_fence")
	var early := _result(asks.call("deliver", "broken_fence"))
	_check(not bool(early.get("ok", true)), "Harold's ask does not complete before the fence is mended")
	_check(int(pack.call("quantity", "wood")) == 3, "delivering early keeps the wood")
	_prep_tools()
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	_mend_fence()
	_check(NarrativeState.flag_is_true("church_fence_mended"), "mending the fence sets church_fence_mended")
	asks.call("deliver", "broken_fence")
	_check(bool(asks.call("is_completed", "broken_fence")), "Harold's ask completes")
	var history_v: Variant = asks.call("history_rows")
	var found := false
	if history_v is Array:
		for row_v in history_v as Array:
			if row_v is Dictionary and str((row_v as Dictionary).get("id", "")) == "broken_fence":
				found = str((row_v as Dictionary).get("status", "")) == "done"
	_check(found, "completed asks appear in history")
	_check(NarrativeState.flag_is_true("church_fence_mended"), "Harold's ask leaves the fence mended")
	_week_open()
	pack.call("reset")
	asks.call("accept", "fresh_for_the_table")
	DayClock.set_time(20, 8, 0)
	_check(not bool(asks.call("is_active", "fresh_for_the_table")), "an overdue ask expires")
	_check(not bool(asks.call("is_completed", "fresh_for_the_table")), "expiry does not complete the ask")
	_check(bool(asks.call("is_available", "fresh_for_the_table")), "a repeatable expired ask can be accepted again")


func _no_pull_or_funds() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	var funds := _funds()
	var inf := get_node_or_null("/root/InfluenceState")
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
	pack.call("reset")
	pack.call("add", "lettuce", 2)
	pack.call("add", "carrots", 2)
	pack.call("add", "flowers", 3)
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	asks.call("accept", "fresh_for_the_table")
	asks.call("deliver", "fresh_for_the_table")
	asks.call("accept", "sanctuary_flowers")
	asks.call("deliver", "sanctuary_flowers")
	asks.call("accept", "broken_fence")
	_prep_tools()
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	_mend_fence()
	asks.call("deliver", "broken_fence")
	var pull_after := 0
	var dependents_after := 0
	if inf != null:
		pull_after = int(inf.call("pull_total"))
		dependents_after = int(inf.call("pull_part", "dependents"))
	_check(pull_before == pull_after, "completing asks does not change Pull")
	_check(dependents_before == dependents_after, "completing asks does not change dependents")
	_check(church_before == int(funds.get("balance")), "completing asks does not touch ChurchFunds")
	_check(attend_before == NarrativeState.growth_value("attendance"), "completing asks does not change attendance")


func _ruth_maple_flags() -> void:
	_week_open()
	NarrativeState.set_flag("garden_cleared", false)
	NarrativeState.set_flag("garden_planted", false)
	var asks := _asks()
	asks.call("accept", "garden_needs_hands")
	var early := _result(asks.call("deliver", "garden_needs_hands"))
	_check(not bool(early.get("ok", true)), "Ruth's ask does not complete without Maple Lane planting")
	_check(not NarrativeState.flag_is_true("garden_planted"), "accepting Ruth's ask does not plant Maple Lane")
	NarrativeState.set_flag("garden_cleared", true)
	NarrativeState.set_flag("garden_planted", true)
	var done := _result(asks.call("deliver", "garden_needs_hands"))
	_check(bool(done.get("ok", false)), "Ruth's ask completes from Maple Lane flags")
	_check(NarrativeState.flag_is_true("garden_planted"), "completing Ruth's ask leaves garden_planted")
	_check(NarrativeState.flag_is_true("garden_cleared"), "completing Ruth's ask leaves garden_cleared")
	_check(NarrativeState.flag_is_true("garden_hands_helped"), "Ruth remembers the help")


func _dialogue_accept() -> void:
	_week_open()
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	var data := DialogueRunner.load_conversation("sarah")
	_check(not data.is_empty(), "Sarah's dialogue still loads")
	var runner := DialogueRunner.new()
	_check(runner.start(data), "Sarah's continued-week conversation starts")
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 8:
		if runner.body().contains("lettuce") or runner.body().contains("carrots") or runner.body().contains("meal"):
			break
		runner.advance()
		guard += 1
	_check(runner.body().contains("lettuce") or runner.body().contains("carrots") or runner.body().contains("meal"), "Sarah offers the vegetable ask (%s)" % runner.body())
	_check(runner.choice_count() >= 1, "Sarah's ask can be accepted in dialogue")
	if runner.choice_count() > 0:
		runner.choose(0)
		runner.advance()
	_check(bool(_asks().call("is_active", "fresh_for_the_table")), "accepting in dialogue activates Sarah's ask")
	var harold := DialogueRunner.load_conversation("harold")
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.start_quest("spare_keys")
	NarrativeState.complete_quest("spare_keys")
	var h_run := DialogueRunner.new()
	h_run.start(harold)
	_check(h_run.body().contains("fence") or h_run.body().contains("boards"), "Harold offers the fence ask after the keys (%s)" % h_run.body())


func _layout_and_scene() -> void:
	NarrativeState.reset()
	DayClock.reset()
	var lane := _instance("res://scenes/world/maple_lane.tscn")
	if lane == null:
		return
	await _pump(2)
	var plot := lane.get_node_or_null("Props/Garden") as GardenPlot
	_check(plot != null, "the Chapter 1 Maple Lane plot is still there")
	_check(plot != null and plot.plot_id == "", "the Chapter 1 plot is not a church farm tile")
	lane.free()
	await _pump(1)
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	await _pump(2)
	_check(grounds.get_node_or_null("Props/FarmField") != null, "the church garden is an in-ground field")
	_check(grounds.get_node_or_null("Props/ChurchPlot0") == null, "the raised beds are gone")
	_check(grounds.get_node_or_null("Props/SeedCrate") != null, "the seed crate is still in the garden")
	_check(grounds.get_node_or_null("Props/GardenNote") != null, "Ruth's card is still in the garden")
	_check(grounds.get_node_or_null("FarmSoil") != null, "tilled soil draws on a ground overlay")
	grounds.free()
	await _pump(1)


func _save_and_load() -> void:
	_week_open()
	var asks := _asks()
	var pack := _pack()
	var garden := _garden()
	var funds := _funds()
	pack.call("reset")
	pack.call("add", "hoe", 1)
	pack.call("add", "lettuce", 2)
	pack.call("set_cash", 12)
	asks.call("accept", "fresh_for_the_table")
	pack.call("equip", "hoe")
	garden.call("till", GroundsLayout.legacy_bed_id(4))
	NarrativeState.set_flag("frank_listened", true)
	funds.set("balance", 80)
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
	_check(saved, "a current-version save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary, "the save file is an object")
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == SaveGame.SAVE_VERSION, "the save file is the current version")
	_check(row.has("requests"), "the save stores requests")
	_check(row.has("garden"), "the save stores garden tiles")
	room.free()
	await _pump(1)
	NarrativeState.reset()
	_check(not bool(_asks().call("is_active", "fresh_for_the_table")), "reset clears active asks")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == SaveGame.SAVE_VERSION, "read_file keeps the current version")
	SaveGame.apply_state(loaded)
	_check(bool(_asks().call("is_active", "fresh_for_the_table")), "load restores an active ask")
	_check(int(pack.call("quantity", "lettuce")) == 2, "load keeps the vegetables")
	_check(int(funds.get("balance")) == 80, "load keeps church funds")
	_check(NarrativeState.flag_is_true("frank_listened"), "load keeps story flags")
	_check(str(_plot(GroundsLayout.legacy_bed_id(4)).get("soil", "")) == "tilled", "load restores a tilled tile")
	NarrativeState.reset()


func _old_save_migration() -> void:
	var from_v8 := SaveGame.migrate({
		"version": 8,
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
			"slots": [{"id": "hoe", "qty": 1}, {"id": "carrot_seeds", "qty": 1}],
			"equipped": "hoe",
			"cash": 12,
		},
		"garden": {
			"last_processed_day": 4,
			"plots": [
				{"id": "church_5", "soil": "tilled", "crop": "carrots", "planted": true, "watered": true, "growth": 1, "stage": "sprout", "ready": false},
			],
		},
		"narrative": {
			"flags": {"frank_listened": true, "spare_keys_returned": true, "garden_planted": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v8.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 8 file migrates to the current save")
	var asks_v: Variant = from_v8.get("requests", {})
	var asks_row: Dictionary = asks_v if asks_v is Dictionary else {}
	var active_v: Variant = asks_row.get("active", null)
	_check(active_v is Dictionary and (active_v as Dictionary).is_empty(), "v8 migration starts with no active asks")
	var garden_v: Variant = from_v8.get("garden", {})
	var garden_row: Dictionary = garden_v if garden_v is Dictionary else {}
	var tiles_v: Variant = garden_row.get("tiles", {})
	_check(tiles_v is Dictionary, "v8 migration stores garden tiles")
	var mapped := false
	if tiles_v is Dictionary:
		var key := GroundsLayout.legacy_bed_id(5)
		mapped = (tiles_v as Dictionary).has(key)
		if mapped:
			var tile_v: Variant = (tiles_v as Dictionary)[key]
			if tile_v is Dictionary:
				_check(str((tile_v as Dictionary).get("crop", "")) == "carrots", "v8 bed church_5 maps onto a garden tile")
				_check(bool((tile_v as Dictionary).get("watered", false)), "v8 watered soil survives the tile move")
	_check(mapped, "v8 church_5 lands on the matching tile")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	NarrativeState.reset()
	SaveGame.apply_state(from_v8)
	_check(not bool(_asks().call("is_active", "fresh_for_the_table")), "applying a migrated v8 save has no active asks")
	_check(int(_pack().call("cash")) == 12, "applying a migrated v8 save keeps the wallet")
	_check(NarrativeState.flag_is_true("garden_planted"), "applying a migrated v8 save keeps Maple Lane flags")
	_check(str(_plot(GroundsLayout.legacy_bed_id(5)).get("crop", "")) == "carrots", "applying a migrated v8 save keeps the crop")
	NarrativeState.reset()


func _week_open() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 10, 0)
	NarrativeState.set_flag("week_continues", true)
	var asks := _asks()
	if asks != null and asks.has_method("reset"):
		asks.call("reset")
	var garden := _garden()
	if garden != null and garden.has_method("reset"):
		garden.call("reset")


func _fresh_garden() -> void:
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


func _mend_fence() -> void:
	var repairs := get_node_or_null("/root/RepairState")
	var pack := _pack()
	if pack != null and pack.has_method("equip"):
		pack.call("equip", "hand_tools")
	if repairs == null or not repairs.has_method("interact"):
		NarrativeState.set_flag("church_fence_mended", true)
		if repairs != null and repairs.has_method("reset"):
			repairs.call("from_dictionary", {"sites": {"church_fence": {"id": "church_fence", "stage": 3, "done": true}}})
		return
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")


func _asks() -> Node:
	return get_node_or_null("/root/RequestState")


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
	print("GPC_OK" if not _failed else "GPC_FAIL")
	tree.quit(0 if not _failed else 1)
