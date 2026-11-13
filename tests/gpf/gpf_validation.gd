extends Node
## Headless checks for Gameplay F (integration, polish, DayClock budget, balance).
## Prints GPF_OK or GPF_FAIL.
## Run: godot --headless --path . res://tests/gpf/gpf_validation.tscn

const Frames := preload("res://scripts/art/repair_frames.gd")
const CharFrames := preload("res://scripts/art/character_frames.gd")
const Catalog := preload("res://scripts/systems/item_catalog.gd")
const Crops := preload("res://scripts/systems/crop_catalog.gd")

const PLAYER_SPEED := 100.0
const WAKING_MINUTES := 14 * 60
const PACKED_DAY_LIMIT := 10 * 60

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
	await _toast_does_not_overlap_prompt()
	_weeds_off_pavement()
	_repair_art_blend()
	_dale_and_ruth_art()
	_onboarding_card_is_short()
	_ruth_vs_church_garden()
	_dayclock_budget()
	_clock_triggers_still_hold()
	_balance_still_fits()
	await _full_loop_playthrough()
	_restore_user_save()
	_finish()


func _toast_does_not_overlap_prompt() -> void:
	_check(ActionToast.SLOT_RIGHT <= 170.0, "toast stays left of the prompt bar")
	_check(ActionToast.SLOT_BOTTOM <= -36.0, "toast sits above the prompt bar")
	_check(ActionToast.HOLD_SECONDS + ActionToast.FADE_SECONDS <= 1.5, "toast lifetime is still at most 1.5s")
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	var pack := _pack()
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("equip", "hoe")
	var toast := hud.get_node_or_null("ActionToast") as ActionToast
	var prompt := hud.get_node_or_null("Prompt") as Control
	var hotbar := hud.get_node_or_null("Hotbar") as Control
	_check(toast != null and prompt != null, "HUD has toast and prompt")
	if toast == null or prompt == null:
		hud.free()
		return
	toast.show_message("Tilled the soil.")
	prompt.visible = true
	var prompt_label := prompt.get_node_or_null("Label") as Label
	if prompt_label != null:
		prompt_label.text = "E  Till"
	if hotbar != null:
		hotbar.visible = true
	await _pump(2)
	_check(toast.is_showing(), "the toast is showing for the overlap check")
	_check(not toast.overlaps_control(prompt), "toast does not overlap the prompt bar")
	if hotbar != null and hotbar.visible:
		_check(not toast.overlaps_control(hotbar), "toast does not overlap the hotbar")
		_check(hotbar.offset_right <= 170.0, "hotbar stays left of the prompt bar")
	_check(toast.offset_right <= prompt.offset_left, "toast right edge is left of the prompt")
	hud.free()


func _weeds_off_pavement() -> void:
	var cell := GroundsLayout.world_to_cell(GroundsLayout.REPAIR_WEEDS)
	_check(cell.y < 38 or cell.y > 39, "the weed patch is not on the parsonage walk (tile %s)" % str(cell))
	var picnic := GroundsLayout.PICNIC
	_check(picnic.has_point(cell) or picnic.has_point(Vector2i(cell.x, cell.y - 1)), "the weed patch sits on the picnic lawn")
	_check(Frames.build("weeds_cleared").get_width() >= 64, "cleared weeds still span more than one tile")


func _repair_art_blend() -> void:
	var weeds_before := Frames.build("weeds_patch")
	var weeds_after := Frames.build("weeds_cleared")
	_check(weeds_before != null and weeds_after != null, "weed stages still build")
	_check(_opaque_count(weeds_after) < 800, "cleared weeds are not a solid light-green rectangle")
	_check(_count_color(weeds_before, PixelDraw.pal("leaf")) > _count_color(weeds_after, PixelDraw.pal("leaf")), "tall weeds are gone after clearing")
	var litter := Frames.build("litter_pile")
	_check(litter != null, "litter pile still builds")
	_check(_count_color(litter, PixelDraw.pal("grass")) < 40, "litter is not sitting on a grass mat")
	_check(_opaque_count(litter) > 80, "scattered litter is still visible")
	var bed_before := Frames.build("bed_overgrown")
	var bed_after := Frames.build("bed_restored")
	_check(_count_color(bed_after, PixelDraw.pal("flower")) >= 20, "the restored bed has readable blooms")
	_check(_count_color(bed_after, PixelDraw.pal("flower")) > _count_color(bed_before, PixelDraw.pal("flower")), "after blooms read more clearly than before")
	var damaged := Frames.build("fence_damaged")
	_check(damaged != null and _opaque_count(damaged) > 80, "the damaged fence still reads as a stretch")


func _dale_and_ruth_art() -> void:
	_check("dale" in CharFrames.NAMES and "ruth" in CharFrames.NAMES, "Dale and Ruth are named character sheets")
	_check(CharacterSheets.is_named("dale") and CharacterSheets.is_named("ruth"), "Dale and Ruth load as named sheets")
	_check(FileAccess.file_exists("res://assets/characters/npc_dale_sheet.png"), "Dale's sheet PNG exists")
	_check(FileAccess.file_exists("res://assets/characters/npc_ruth_sheet.png"), "Ruth's sheet PNG exists")
	var dale := CharFrames.build_sheet("dale")
	var ruth := CharFrames.build_sheet("ruth")
	var harold := CharFrames.build_sheet("harold")
	var margaret := CharFrames.build_sheet("margaret")
	_check(dale != null and dale.get_width() == 192, "Dale's sheet is 192x192")
	_check(ruth != null and ruth.get_width() == 192, "Ruth's sheet is 192x192")
	_check(_image_delta(dale, harold) >= 80, "Dale is distinct from Harold")
	_check(_image_delta(ruth, margaret) >= 80, "Ruth is distinct from Margaret")
	_check(_image_delta(dale, ruth) >= 80, "Dale and Ruth are distinct from each other")


func _onboarding_card_is_short() -> void:
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	var note := grounds.get_node_or_null("Props/GardenNote")
	_check(note != null, "Ruth's garden card is still there")
	if note != null:
		var line := str(note.get("line"))
		_check(line.length() <= 80, "the garden card is short (%d chars)" % line.length())
		_check(line.contains("Till") and line.contains("Plant") and line.contains("Water"), "the card still names till, plant, and water")
	grounds.free()


func _ruth_vs_church_garden() -> void:
	_fresh()
	NarrativeState.set_flag("week_continues", true)
	var asks := _asks()
	var garden := _garden()
	asks.call("accept", "garden_needs_hands")
	var cell := GroundsLayout.legacy_bed_id(0)
	if _pack() != null:
		_pack().call("grant_starter", "tools")
		_pack().call("grant_starter", "seeds")
		_pack().call("equip", "hoe")
	garden.call("till", cell)
	_pack().call("equip", "lettuce_seeds")
	garden.call("plant", cell, "lettuce_seeds")
	_check(not NarrativeState.flag_is_true("garden_planted"), "church planting does not set Maple Lane garden_planted")
	_check(not bool(asks.call("can_deliver", "garden_needs_hands")), "Ruth's ask does not complete from the church garden")
	NarrativeState.set_flag("garden_planted", true)
	_check(bool(asks.call("can_deliver", "garden_needs_hands")), "Ruth's ask completes from Maple Lane garden_planted")


func _dayclock_budget() -> void:
	_check(is_equal_approx(DayClock.MINUTES_PER_REAL_SECOND, 4.0), "clock rate stays 4 in-game minutes per real second")
	_check(is_equal_approx(60.0 / DayClock.MINUTES_PER_REAL_SECOND, 15.0), "one in-game hour is 15 real seconds of walking")
	var home := GroundsLayout.POS_FROM_PARSONAGE
	var garden := GroundsLayout.tile_center(Vector2i(43, 36))
	var street := GroundsLayout.POS_STREET_DOOR
	var oak_spawn := Vector2(120.0, 17.0 * 32.0)
	var hardware := Vector2(816.0, 13.0 * 32.0 + 24.0)
	var tend_walk := _walk_minutes(home, garden)
	var shop_walk := _walk_minutes(garden, street) + _walk_minutes(oak_spawn, hardware)
	var home_walk := _walk_minutes(street, home)
	var garden_actions := float(Crops.action_minutes() * 9)
	var packed := tend_walk + shop_walk + home_walk + garden_actions
	_check(tend_walk > 0.0 and shop_walk > 0.0, "walk times between the parsonage, garden, and shop are measured")
	_check(packed < float(PACKED_DAY_LIMIT), "tending, a shop visit, and getting home fit in a day (%.0f min of %d)" % [packed, PACKED_DAY_LIMIT])
	_check(packed < float(WAKING_MINUTES), "the packed loop is under a 6:00–20:00 waking day (%.0f / %d min)" % [packed, WAKING_MINUTES])
	print("DAYCLOCK parsonage->garden=%.1f min garden->shop=%.1f min shop->home=%.1f min actions=%.0f packed=%.1f" % [tend_walk, shop_walk, home_walk, garden_actions, packed])


func _clock_triggers_still_hold() -> void:
	_fresh()
	DayClock.set_time(7, 10, 0)
	_check(DayClock.is_opening_sunday() and DayClock.hour == 10, "Sunday service still lands at 10:00")
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	DayClock.set_time(10, 12, 0)
	_check(bool(_events().call("is_live")), "the potluck window is still Wednesday 11:00–16:00")
	_check(HappeningSchedule.is_active("wednesday_potluck", "Wednesday", 12, 0), "the M8 Wednesday happening still fires")
	DayClock.set_time(10, 10, 0)
	_check(not bool(_events().call("is_live")), "Wednesday before 11:00 is still quiet")
	DayClock.set_time(10, 16, 0)
	_check(not bool(_events().call("is_live")), "Wednesday after 16:00 has still ended")
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("ledger_revealed", true)
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("chapter_one_complete", true)
	_check(not NarrativeState.flag_is_true("week_continues"), "Chapter 1 still has not continued")
	var ending := DialogueRunner.load_conversation("hall_celebration")
	_check(_conversation_has(ending, "potluck"), "Harold still names a potluck after the hall is repaired")


func _balance_still_fits() -> void:
	_check(Catalog.starting_cash() == 20, "wallet still starts at $20")
	_check(Catalog.shop_price("wood") == 4 and Catalog.shop_price("nails") == 3, "fence stock is still $4 wood and $3 nails")
	var fence_cost := Catalog.shop_price("wood") * 3 + Catalog.shop_price("nails") * 2
	_check(fence_cost <= Catalog.starting_cash(), "starting cash covers one fence shop visit ($%d)" % fence_cost)
	_check(Crops.watered_days("lettuce") == 2 and Crops.yield_count("lettuce") == 1, "lettuce is still 2 mornings, yield 1")
	_check(Crops.watered_days("carrots") == 3 and Crops.yield_count("carrots") == 2, "carrots are still 3 mornings, yield 2")
	_check(GroundsLayout.REVERT_DAYS == 3, "empty tilled soil still reverts after 3 mornings")


func _full_loop_playthrough() -> void:
	_fresh()
	_unlock_week()
	var pull_before := _pull()
	var funds_before := int(_funds().get("balance"))
	var attendance_before := _attendance()
	var trust_before := _growth("community_trust")
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	var panel := hud.get_node_or_null("InventoryPanel")
	_check(panel != null and panel.has_method("open"), "the inventory panel is on the HUD")
	if panel != null and panel.has_method("open"):
		panel.call("open")
		_check(bool(panel.call("is_open")), "opening the inventory works")
		panel.call("close")
		_check(not bool(panel.call("is_open")), "closing the inventory works")
	hud.free()
	await _pump(1)
	var pack := _pack()
	_check(bool(pack.call("grant_starter", "tools")), "starter tools come from the parsonage kit")
	_check(bool(pack.call("grant_starter", "seeds")), "starter seeds come from the garden crate")
	_check(int(pack.call("quantity", "lettuce_seeds")) >= 2, "the crate has lettuce seed")
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	await _pump(2)
	_check(grounds.get_node_or_null("Props/GardenNote") != null, "the garden is enterable and has Ruth's card")
	_check(grounds.get_node_or_null("Props/FenceWork") != null, "the fence worksite is in the garden")
	var lettuce_a := GroundsLayout.legacy_bed_id(0)
	var lettuce_b := GroundsLayout.legacy_bed_id(1)
	var carrot_id := GroundsLayout.legacy_bed_id(2)
	var garden := _garden()
	pack.call("equip", "hoe")
	_check(_ok(garden.call("till", lettuce_a)), "till the first plot")
	_check(_ok(garden.call("till", lettuce_b)), "till the second plot")
	_check(_ok(garden.call("till", carrot_id)), "till the carrot plot")
	_check(_ok(garden.call("plant", lettuce_a, "lettuce_seeds")), "plant lettuce")
	_check(_ok(garden.call("plant", lettuce_b, "lettuce_seeds")), "plant a second lettuce")
	_check(_ok(garden.call("plant", carrot_id, "carrot_seeds")), "plant carrots")
	pack.call("equip", "watering_can")
	_check(_ok(garden.call("water", lettuce_a)), "water lettuce")
	_check(_ok(garden.call("water", lettuce_b)), "water the second lettuce")
	_check(_ok(garden.call("water", carrot_id)), "water carrots")
	DayClock.sleep_until_morning()
	_check(int(_plot(lettuce_a).get("growth", 0)) == 1, "lettuce grew after the first morning")
	_check(not bool(_plot(lettuce_a).get("ready", false)), "lettuce is not ready after one morning")
	_water_again(lettuce_a, lettuce_b, carrot_id)
	DayClock.sleep_until_morning()
	_check(bool(_plot(lettuce_a).get("ready", false)), "lettuce is ready after two mornings")
	_water_again("", "", carrot_id)
	DayClock.sleep_until_morning()
	_check(bool(_plot(carrot_id).get("ready", false)), "carrots are ready after three mornings")
	_check(_ok(garden.call("harvest", lettuce_a)), "harvest lettuce")
	_check(_ok(garden.call("harvest", lettuce_b)), "harvest the second lettuce")
	_check(_ok(garden.call("harvest", carrot_id)), "harvest carrots")
	_check(int(pack.call("quantity", "lettuce")) >= 2, "the pack holds harvested lettuce")
	_check(int(pack.call("quantity", "carrots")) >= 2, "the pack holds harvested carrots")
	var asks := _asks()
	_check(_ok(asks.call("accept", "fresh_for_the_table")), "Sarah's ask accepts")
	_check(_ok(asks.call("deliver", "fresh_for_the_table")), "Sarah's vegetables deliver")
	_check(not _ok(asks.call("deliver", "fresh_for_the_table")), "a second delivery grants nothing")
	_check(NarrativeState.flag_is_true("potluck_vegetables"), "Sarah's delivery preps the potluck")
	_check(bool(pack.call("buy", "wood", 3)), "buy 3 Wood")
	_check(bool(pack.call("buy", "nails", 2)), "buy 2 Nails")
	pack.call("equip", "hand_tools")
	var repairs := _repairs()
	_check(_ok(repairs.call("interact", "church_fence")), "clear the fence boards")
	_check(_ok(repairs.call("interact", "church_fence")), "set new wood")
	_check(_ok(repairs.call("interact", "church_fence")), "nail the fence")
	_check(bool(repairs.call("is_finished", "church_fence")), "the fence is finished")
	_check(_ok(repairs.call("interact", "picnic_weeds")), "clear picnic weeds")
	_check(_ok(repairs.call("interact", "picnic_bed")), "trim the picnic bed")
	_check(_ok(repairs.call("interact", "picnic_bed")), "restore the picnic bed")
	_check(NarrativeState.flag_is_true("picnic_bed_restored"), "the picnic bed preps the gathering")
	_check(NarrativeState.flag_is_true("grounds_cared_for"), "two finished sites mark the grounds as cared for")
	_events().call("invite", "dale")
	DayClock.set_time(10, 12, 0)
	_check(bool(_events().call("is_live")), "Wednesday noon is the gathering")
	_events().call("set_inside", true)
	_check(bool(_events().call("did_attend")), "walking in counts as attending")
	_check(not bool(_events().call("mark_attended")), "a second attendance this week grants nothing")
	_check(_pull() == pull_before, "the loop does not raise Pull")
	_check(int(_funds().get("balance")) == funds_before, "the loop does not touch ChurchFunds")
	_check(_attendance() == attendance_before, "the loop does not raise attendance")
	_check(_growth("community_trust") == trust_before, "the loop does not raise community trust")
	var player := grounds.get_node_or_null("Props/Player") as Player
	if player != null:
		player.global_position = Vector2(420, 510)
	var saved := SaveGame.save_to_disk(get_tree())
	_check(saved, "save writes after the loop")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == 11, "the save file stays version 11")
	grounds.free()
	await _pump(1)
	NarrativeState.reset()
	DayClock.reset()
	_check(not NarrativeState.flag_is_true("church_fence_mended"), "reset clears the loop")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == 11, "load keeps version 11")
	SaveGame.apply_state(loaded)
	_check(NarrativeState.flag_is_true("church_fence_mended"), "load restores the mended fence")
	_check(NarrativeState.flag_is_true("potluck_vegetables"), "load restores potluck vegetables")
	_check(bool(_events().call("did_attend", 2)), "load restores attendance")
	_check(int(_pack().call("quantity", "hoe")) == 1, "load restores the pack")
	_check(_pull() == pull_before, "load still has no extra Pull")
	NarrativeState.reset()


func _ok(raw: Variant) -> bool:
	if raw is Dictionary:
		return bool((raw as Dictionary).get("ok", false))
	return false


func _plot(plot_id: String) -> Dictionary:
	var garden := _garden()
	if garden == null or not garden.has_method("plot_of"):
		return {}
	var raw: Variant = garden.call("plot_of", plot_id)
	if raw is Dictionary:
		return raw
	return {}


func _water_again(a: String, b: String, c: String) -> void:
	var garden := _garden()
	var pack := _pack()
	if pack != null:
		pack.call("equip", "watering_can")
	if not a.is_empty():
		garden.call("water", a)
	if not b.is_empty():
		garden.call("water", b)
	if not c.is_empty():
		garden.call("water", c)


func _walk_minutes(from: Vector2, to: Vector2) -> float:
	return from.distance_to(to) / PLAYER_SPEED * DayClock.MINUTES_PER_REAL_SECOND


func _unlock_week() -> void:
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 10, 0)


func _opaque_count(image: Image) -> int:
	if image == null:
		return 0
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.5:
				count += 1
	return count


func _count_color(image: Image, color: Color) -> int:
	if image == null:
		return 0
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.5 and pixel.is_equal_approx(color):
				count += 1
	return count


func _image_delta(a: Image, b: Image) -> int:
	if a == null or b == null:
		return 0
	var w := mini(a.get_width(), b.get_width())
	var h := mini(a.get_height(), b.get_height())
	var delta := 0
	for y in h:
		for x in w:
			if not a.get_pixel(x, y).is_equal_approx(b.get_pixel(x, y)):
				delta += 1
	return delta


func _conversation_has(data: Dictionary, needle: String) -> bool:
	return JSON.stringify(data).to_lower().contains(needle.to_lower())


func _pull() -> int:
	var inf := _influence()
	if inf != null and inf.has_method("pull_total"):
		return int(inf.call("pull_total"))
	return 0


func _attendance() -> int:
	return NarrativeState.growth_value("attendance")


func _growth(key: String) -> int:
	return NarrativeState.growth_value(key)


func _fresh() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 10, 0)


func _events() -> Node:
	return get_node_or_null("/root/EventState")


func _asks() -> Node:
	return get_node_or_null("/root/RequestState")


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")


func _repairs() -> Node:
	return get_node_or_null("/root/RepairState")


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


func _influence() -> Node:
	return get_node_or_null("/root/InfluenceState")


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
	print("GPF_OK" if not _failed else "GPF_FAIL")
	tree.quit(0 if not _failed else 1)
