extends Node
## Headless checks for Gameplay Phase D (interactive repairs, save v10).
## Prints GPD_OK or GPD_FAIL.
## Run: godot --headless --path . res://tests/gpd/gpd_validation.tscn

const Frames := preload("res://scripts/art/repair_frames.gd")
const Repairs := preload("res://scripts/systems/repair_catalog.gd")
const Asks := preload("res://scripts/systems/request_catalog.gd")
const Items := preload("res://scripts/systems/item_catalog.gd")

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
	_catalog_and_art()
	_each_repair_end_to_end()
	_fence_stages_and_materials()
	_missing_materials_message()
	_wrong_tool_is_harmless()
	_harold_no_double_reward()
	await _grounds_chore_and_chapter1()
	_no_pull_or_funds()
	await _layout_and_scene()
	await _persistence()
	_old_save_migration()
	_restore_user_save()
	_finish()


func _catalog_and_art() -> void:
	_check(FileAccess.file_exists("res://data/repairs/catalog.json"), "repair catalog exists")
	_check(Repairs.ids().size() == Repairs.EXPECTED_IDS.size(), "repair catalog has four worksites")
	_check(Repairs.has_site("church_fence"), "the garden fence is a worksite")
	_check(Repairs.has_site("picnic_weeds"), "clearing weeds is a worksite")
	_check(Repairs.has_site("lot_litter"), "picking up litter is a worksite")
	_check(Repairs.has_site("picnic_bed"), "restoring a flower bed is a worksite")
	_check(Repairs.kind("church_fence") == "fence", "the fence is tagged as a fence")
	_check(Repairs.stage_count("church_fence") == 4, "the fence has four visual stages")
	_check(int(Repairs.stage_required("church_fence", 1).get("wood", 0)) == 3, "setting boards uses 3 Wood")
	_check(int(Repairs.stage_required("church_fence", 2).get("nails", 0)) == 2, "nailing uses 2 Nails")
	_check(Repairs.complete_flag("church_fence") == "church_fence_mended", "the fence keeps church_fence_mended")
	_check(Repairs.request_id("church_fence") == "broken_fence", "the fence is Harold's ask")
	_check(_repairs() != null, "RepairState autoload exists")
	var damaged := Frames.build("fence_damaged")
	var cleared := Frames.build("fence_cleared")
	var framed := Frames.build("fence_new_wood")
	var finished := Frames.build("fence_finished")
	_check(damaged != null and cleared != null and framed != null and finished != null, "fence stage images build")
	_check(_images_differ(damaged, cleared), "damaged fence differs from boards-removed")
	_check(_images_differ(cleared, framed), "boards-removed differs from new wood")
	_check(_images_differ(framed, finished), "new wood differs from the finished fence")
	_check(_images_differ(damaged, finished), "damaged fence differs from finished")
	_check(_images_differ(Frames.build("weeds_patch"), Frames.build("weeds_cleared")), "cleared weeds look different")
	_check(_images_differ(Frames.build("bed_overgrown"), Frames.build("bed_restored")), "the restored bed looks different")
	_check(_images_differ(Frames.build("litter_pile"), Frames.build("litter_gone")), "picked-up litter looks different")
	_check(Asks.required("broken_fence").get("wood", 0) == 3, "Harold's ask still lists 3 Wood")
	_check(not Asks.complete_if("broken_fence").is_empty(), "Harold's ask completes when the fence is mended")


func _each_repair_end_to_end() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	_prep_tools()
	pack.call("equip", "hand_tools")
	var weeds := _result(repairs.call("interact", "picnic_weeds"))
	_check(bool(weeds.get("ok", false)), "clearing weeds succeeds with hand tools")
	_check(bool(repairs.call("is_finished", "picnic_weeds")), "weeds finish in one short step")
	_check(NarrativeState.flag_is_true("picnic_weeds_cleared"), "clearing weeds sets its flag")
	_check(int(pack.call("quantity", "scrap")) == 1, "clearing weeds yields a little scrap")
	var litter := _result(repairs.call("interact", "lot_litter"))
	_check(bool(litter.get("ok", false)), "picking up litter succeeds")
	_check(bool(repairs.call("is_finished", "lot_litter")), "litter finishes in one short step")
	_check(bool(repairs.call("is_hidden", "lot_litter")), "finished litter hides")
	_check(int(pack.call("quantity", "scrap")) == 2, "litter yields a little scrap")
	var trim := _result(repairs.call("interact", "picnic_bed"))
	_check(bool(trim.get("ok", false)), "trimming the bed succeeds")
	_check(not bool(repairs.call("is_finished", "picnic_bed")), "the bed needs a second step")
	var plant := _result(repairs.call("interact", "picnic_bed"))
	_check(bool(plant.get("ok", false)), "setting flowers succeeds")
	_check(bool(repairs.call("is_finished", "picnic_bed")), "the flower bed is restored")
	_check(NarrativeState.flag_is_true("picnic_bed_restored"), "restoring the bed sets its flag")
	_check(NarrativeState.flag_is_true("bed_kindness"), "restoring the bed is a hidden kindness")
	_check(str(repairs.call("art_id", "picnic_weeds")) == "weeds_cleared", "cleared weeds use the cleared art")
	_check(str(repairs.call("art_id", "picnic_bed")) == "bed_restored", "the restored bed uses the blooming art")


func _fence_stages_and_materials() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	_prep_tools()
	pack.call("equip", "hand_tools")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	_check(str(repairs.call("art_id", "church_fence")) == "fence_damaged", "the fence starts damaged")
	var clear := _result(repairs.call("interact", "church_fence"))
	_check(bool(clear.get("ok", false)), "clearing boards needs no materials")
	_check(int(pack.call("quantity", "wood")) == 3, "clearing boards does not consume wood")
	_check(int(pack.call("quantity", "nails")) == 2, "clearing boards does not consume nails")
	_check(str(repairs.call("art_id", "church_fence")) == "fence_cleared", "boards-removed is a distinct stage")
	_check(int(repairs.call("stage_of", "church_fence")) == 1, "the fence is at the cleared stage")
	var set_wood := _result(repairs.call("interact", "church_fence"))
	_check(bool(set_wood.get("ok", false)), "setting new wood succeeds with 3 Wood")
	_check(int(pack.call("quantity", "wood")) == 0, "setting boards consumes the wood once")
	_check(int(pack.call("quantity", "nails")) == 2, "setting boards leaves the nails")
	_check(str(repairs.call("art_id", "church_fence")) == "fence_new_wood", "new wood is a distinct stage")
	var nail := _result(repairs.call("interact", "church_fence"))
	_check(bool(nail.get("ok", false)), "nailing the boards succeeds with 2 Nails")
	_check(int(pack.call("quantity", "nails")) == 0, "nailing consumes the nails once")
	_check(bool(repairs.call("is_finished", "church_fence")), "the fence is finished")
	_check(str(repairs.call("art_id", "church_fence")) == "fence_finished", "the finished fence is a distinct stage")
	_check(NarrativeState.flag_is_true("church_fence_mended"), "finishing the fence sets church_fence_mended")
	_check(NarrativeState.flag_is_true("fence_kindness"), "finishing the fence is a hidden kindness")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	var again := _result(repairs.call("interact", "church_fence"))
	_check(not bool(again.get("ok", true)), "a finished fence does not take another action")
	_check(int(pack.call("quantity", "wood")) == 3, "a finished fence does not consume more wood")
	_check(int(pack.call("quantity", "nails")) == 2, "a finished fence does not consume more nails")


func _missing_materials_message() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	_prep_tools()
	pack.call("equip", "hand_tools")
	pack.call("add", "nails", 2)
	repairs.call("interact", "church_fence")
	var missing := str(repairs.call("missing_line", "church_fence"))
	_check(missing == "Missing: 3 Wood", "missing wood prints Missing: 3 Wood (%s)" % missing)
	var failed := _result(repairs.call("interact", "church_fence"))
	_check(not bool(failed.get("ok", true)), "the wood stage fails without wood")
	_check(str(failed.get("message", "")) == "Missing: 3 Wood", "the failed action names the missing wood")
	_check(int(pack.call("quantity", "nails")) == 2, "a missing-wood attempt keeps the nails")
	_check(int(repairs.call("stage_of", "church_fence")) == 1, "a missing-wood attempt stays on the cleared stage")
	pack.call("add", "wood", 3)
	repairs.call("interact", "church_fence")
	pack.call("remove", "nails", 2)
	var nails_msg := str(repairs.call("missing_line", "church_fence"))
	_check(nails_msg == "Missing: 2 Nails", "missing nails print Missing: 2 Nails (%s)" % nails_msg)


func _wrong_tool_is_harmless() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	_prep_tools()
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	pack.call("equip", "hoe")
	var hoe := _result(repairs.call("interact", "church_fence"))
	_check(not bool(hoe.get("ok", true)), "the hoe does not repair the fence")
	_check(str(hoe.get("message", "")).contains("Hand Tools"), "the wrong tool names Basic Hand Tools")
	_check(int(repairs.call("stage_of", "church_fence")) == 0, "the wrong tool leaves the fence damaged")
	_check(int(pack.call("quantity", "wood")) == 3, "the wrong tool does not consume wood")
	pack.call("equip", "")
	var none := _result(repairs.call("interact", "picnic_weeds"))
	_check(not bool(none.get("ok", true)), "no tool does not clear weeds")
	_check(not bool(repairs.call("is_finished", "picnic_weeds")), "no tool leaves the weeds")
	_check(int(pack.call("quantity", "scrap")) == 0, "no tool does not grant scrap")
	pack.call("equip", "watering_can")
	var can := _result(repairs.call("interact", "lot_litter"))
	_check(not bool(can.get("ok", true)), "the watering can does not pick up litter")
	_check(int(repairs.call("stage_of", "lot_litter")) == 0, "the wrong tool leaves the litter")


func _harold_no_double_reward() -> void:
	_fresh()
	NarrativeState.set_flag("week_continues", true)
	var asks := _asks()
	var pack := _pack()
	var repairs := _repairs()
	_prep_tools()
	pack.call("equip", "hand_tools")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	asks.call("accept", "broken_fence")
	var early := _result(asks.call("deliver", "broken_fence"))
	_check(not bool(early.get("ok", true)), "Harold does not take the materials before the repair")
	_check(int(pack.call("quantity", "wood")) == 3, "an early talk keeps the wood")
	_check(int(pack.call("quantity", "scrap")) == 0, "an early talk grants no scrap")
	_check(not bool(asks.call("is_completed", "broken_fence")), "Harold's ask stays open until the fence is set")
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	_check(NarrativeState.flag_is_true("church_fence_mended"), "the repair sets church_fence_mended")
	_check(int(pack.call("quantity", "scrap")) == 0, "the fence repair does not grant Harold's scrap")
	_check(int(pack.call("quantity", "wood")) == 0, "the repair consumed the wood")
	var thanks := _result(asks.call("deliver", "broken_fence"))
	_check(bool(thanks.get("ok", false)), "Harold thanks you after the fence is set")
	_check(bool(asks.call("is_completed", "broken_fence")), "Harold's ask completes after the repair")
	_check(int(pack.call("quantity", "scrap")) == 1, "Harold's thank-you is one bit of scrap")
	var again := _result(asks.call("deliver", "broken_fence"))
	_check(not bool(again.get("ok", true)), "Harold does not thank you twice")
	_check(int(pack.call("quantity", "scrap")) == 1, "duplicate thanks do not grant more scrap")


func _grounds_chore_and_chapter1() -> void:
	_fresh()
	var pack := _pack()
	pack.call("reset")
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(2)
	var player := room.get_node_or_null("Props/Player")
	_check(room.get_node_or_null("Props/LitterA") != null, "GroundsChore litter is still on the grounds")
	_check(room.get_node_or_null("Props/LitterB") != null, "the second GroundsChore litter is still there")
	_check(room.get_node_or_null("Props/FlowerBed") != null, "the Chapter 1 flower bed chore is still there")
	for chore_name in ["LitterA", "LitterB", "FlowerBed"]:
		var chore := room.get_node_or_null("Props/" + chore_name)
		_check(chore != null, "GroundsChore %s exists" % chore_name)
		if chore != null and chore.has_method("interact"):
			chore.call("interact", player)
	_check(NarrativeState.flag_is_true("grounds_litter_a"), "GroundsChore still sets grounds_litter_a")
	_check(NarrativeState.flag_is_true("grounds_litter_b"), "GroundsChore still sets grounds_litter_b")
	_check(NarrativeState.flag_is_true("grounds_bed"), "GroundsChore still sets grounds_bed")
	_check(NarrativeState.flag_is_true("grounds_tidy"), "the three chores still finish grounds_tidy")
	_check(room.get_node_or_null("Props/FenceWork") != null, "the interactive fence is on the grounds")
	_check(room.get_node_or_null("Props/PicnicWeeds") != null, "the weed worksite is on the grounds")
	_check(room.get_node_or_null("Props/LotLitter") != null, "the litter worksite is on the grounds")
	_check(room.get_node_or_null("Props/PicnicBed") != null, "the flower-bed worksite is on the grounds")
	room.free()
	await _pump(1)
	var lane := _instance("res://scenes/world/maple_lane.tscn")
	if lane == null:
		return
	await _pump(2)
	var plot := lane.get_node_or_null("Props/Garden") as GardenPlot
	_check(plot != null, "the Chapter 1 Maple Lane plot is still there")
	_check(plot != null and plot.plot_id == "", "the Maple Lane plot is not a church worksite")
	lane.free()
	await _pump(1)


func _no_pull_or_funds() -> void:
	_fresh()
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
	_prep_tools()
	pack.call("equip", "hand_tools")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	var repairs := _repairs()
	repairs.call("interact", "picnic_weeds")
	repairs.call("interact", "lot_litter")
	repairs.call("interact", "picnic_bed")
	repairs.call("interact", "picnic_bed")
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	var pull_after := 0
	var dependents_after := 0
	if inf != null:
		pull_after = int(inf.call("pull_total"))
		dependents_after = int(inf.call("pull_part", "dependents"))
	_check(pull_before == pull_after, "repairs do not change Pull")
	_check(dependents_before == dependents_after, "repairs do not change dependents")
	_check(church_before == int(funds.get("balance")), "repairs do not touch ChurchFunds")
	_check(attend_before == NarrativeState.growth_value("attendance"), "repairs do not change attendance")
	_check(int(pack.call("cash")) == Items.starting_cash(), "repairs do not spend the personal wallet")


func _layout_and_scene() -> void:
	_fresh()
	_check(_off_plots(GroundsLayout.REPAIR_FENCE), "the fence worksite is not on a Future Site lot")
	_check(_off_plots(GroundsLayout.REPAIR_WEEDS), "the weed worksite is not on a Future Site lot")
	_check(_off_plots(GroundsLayout.REPAIR_LITTER), "the litter worksite is not on a Future Site lot")
	_check(_off_plots(GroundsLayout.REPAIR_BED), "the flower-bed worksite is not on a Future Site lot")
	_check(GroundsLayout.REPAIR_FENCE == GroundsLayout.VEG_FENCE_MEND, "the fence sits on the garden fence line")
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(2)
	var fence := room.get_node_or_null("Props/FenceWork") as RepairSite
	_check(fence != null, "the fence worksite is instanced")
	if fence != null:
		_check(fence.current_art() == "fence_damaged", "the instanced fence shows the damaged stage")
		_check(fence.position.distance_to(GroundsLayout.REPAIR_FENCE) < 1.0, "the fence is at the layout point")
	var weeds := room.get_node_or_null("Props/PicnicWeeds") as RepairSite
	_check(weeds != null and weeds.visible, "weeds are visible before the repair")
	room.free()
	await _pump(1)


func _persistence() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	var funds := _funds()
	_prep_tools()
	pack.call("equip", "hand_tools")
	pack.call("add", "wood", 3)
	pack.call("add", "nails", 2)
	pack.call("set_cash", 12)
	repairs.call("interact", "church_fence")
	repairs.call("interact", "church_fence")
	_check(int(repairs.call("stage_of", "church_fence")) == 2, "the fence is mid-repair before the scene change")
	var first := _instance("res://scenes/world/church_exterior.tscn")
	if first == null:
		return
	await _pump(2)
	var fence := first.get_node_or_null("Props/FenceWork") as RepairSite
	_check(fence != null and fence.current_art() == "fence_new_wood", "scene change keeps the new-wood stage")
	first.free()
	await _pump(1)
	DayClock.set_time(9, 6, 0)
	_check(int(repairs.call("stage_of", "church_fence")) == 2, "sleep does not decay a repair")
	DayClock.set_time(20, 8, 0)
	_check(int(repairs.call("stage_of", "church_fence")) == 2, "weekly rollover does not decay a repair")
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
	_check(row.has("repairs"), "the save stores repairs")
	room.free()
	await _pump(1)
	NarrativeState.reset()
	_check(int(_repairs().call("stage_of", "church_fence")) == 0, "reset clears worksites")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == SaveGame.SAVE_VERSION, "read_file keeps the current version")
	SaveGame.apply_state(loaded)
	_check(int(_repairs().call("stage_of", "church_fence")) == 2, "load restores a mid-repair fence")
	_check(int(pack.call("quantity", "wood")) == 0, "load keeps the consumed wood gone")
	_check(int(funds.get("balance")) == 80, "load keeps church funds")
	_check(NarrativeState.flag_is_true("frank_listened"), "load keeps story flags")
	NarrativeState.reset()


func _old_save_migration() -> void:
	var from_v9 := SaveGame.migrate({
		"version": 9,
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
			"slots": [{"id": "hoe", "qty": 1}, {"id": "wood", "qty": 3}],
			"equipped": "hoe",
			"cash": 12,
		},
		"garden": {"last_processed_day": 4, "tiles": {}},
		"requests": {
			"active": {},
			"history": [{"id": "broken_fence", "status": "done", "day": 8, "note": "Harold mended the garden fence."}],
			"completed": {"broken_fence": true},
			"last_completed_day": {"broken_fence": 8},
			"rewarded": {"broken_fence": true},
		},
		"narrative": {
			"flags": {"frank_listened": true, "church_fence_mended": true, "week_continues": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v9.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 9 file migrates to the current save")
	var repair_v: Variant = from_v9.get("repairs", {})
	var repair_row: Dictionary = repair_v if repair_v is Dictionary else {}
	var sites_v: Variant = repair_row.get("sites", {})
	_check(sites_v is Dictionary, "v9 migration stores worksites")
	var fence_done := false
	if sites_v is Dictionary:
		var fence_v: Variant = (sites_v as Dictionary).get("church_fence", {})
		if fence_v is Dictionary:
			fence_done = bool((fence_v as Dictionary).get("done", false)) and int((fence_v as Dictionary).get("stage", 0)) == 3
	_check(fence_done, "v9 church_fence_mended becomes a finished fence")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	NarrativeState.reset()
	SaveGame.apply_state(from_v9)
	_check(bool(_repairs().call("is_finished", "church_fence")), "applying a migrated v9 save finishes the fence")
	_check(NarrativeState.flag_is_true("church_fence_mended"), "applying a migrated v9 save keeps church_fence_mended")
	_check(int(_pack().call("cash")) == 12, "applying a migrated v9 save keeps the wallet")
	_check(NarrativeState.flag_is_true("frank_listened"), "applying a migrated v9 save keeps story flags")
	var from_open := SaveGame.migrate({
		"version": 9,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"week_continues": true}},
	})
	var open_v: Variant = from_open.get("repairs", {})
	var open_row: Dictionary = open_v if open_v is Dictionary else {}
	var open_sites_v: Variant = open_row.get("sites", {})
	var open_fence := true
	if open_sites_v is Dictionary:
		open_fence = (open_sites_v as Dictionary).has("church_fence")
	_check(not open_fence, "a v9 file without the flag starts with an unfinished fence")
	NarrativeState.reset()


func _fresh() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 10, 0)
	NarrativeState.set_flag("week_continues", true)


func _prep_tools() -> void:
	var pack := _pack()
	pack.call("reset")
	pack.call("add", "hoe", 1)
	pack.call("add", "watering_can", 1)
	pack.call("add", "hand_tools", 1)
	pack.call("equip", "hand_tools")


func _off_plots(pos: Vector2) -> bool:
	var cell := GroundsLayout.world_to_cell(pos)
	for row in GroundsPlots.all_plots():
		if GroundsPlots.plot_rect(row).has_point(cell):
			return false
	return true


func _images_differ(a: Image, b: Image) -> bool:
	if a == null or b == null:
		return false
	if a.get_width() != b.get_width() or a.get_height() != b.get_height():
		return true
	for y in a.get_height():
		for x in a.get_width():
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				return true
	return false


func _result(raw: Variant) -> Dictionary:
	return raw if raw is Dictionary else {}


func _repairs() -> Node:
	return get_node_or_null("/root/RepairState")


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
	print("GPD_OK" if not _failed else "GPD_FAIL")
	tree.quit(0 if not _failed else 1)
