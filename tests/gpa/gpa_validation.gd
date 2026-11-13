extends Node
## Headless checks for Gameplay Phase A (inventory, wallet, shop, starters, save v7).
## Prints GPA_OK or GPA_FAIL.
## Run: godot --headless --path . res://tests/gpa/gpa_validation.tscn

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const Icons := preload("res://scripts/art/item_art.gd")

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false
var _added_id: String = ""
var _added_qty: int = 0
var _consumed_id: String = ""
var _consumed_qty: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	NarrativeState.reset()
	DayClock.reset()
	_catalog()
	_add_remove_and_stacks()
	_capacity_and_invalid()
	_wallet_vs_church()
	_shop_purchase()
	_signals()
	_starter_once()
	await _pickup_and_shop_nodes()
	await _ui_and_clock()
	_save_roundtrip()
	_old_save_migration()
	_restore_user_save()
	_finish()


func _catalog() -> void:
	_check(FileAccess.file_exists("res://data/items/catalog.json"), "item catalog exists")
	_check(InputMap.has_action("inventory"), "inventory input action exists")
	var ids := Catalog.ids()
	_check(ids.size() == Catalog.EXPECTED_IDS.size(), "catalog has exactly %d items (%d)" % [Catalog.EXPECTED_IDS.size(), ids.size()])
	for item_id in Catalog.EXPECTED_IDS:
		_check(Catalog.has_item(item_id), "catalog has %s" % item_id)
		_check(not Catalog.display_name(item_id).is_empty(), "%s has a name" % item_id)
		_check(not Catalog.description(item_id).is_empty(), "%s has a description" % item_id)
		_check(Catalog.max_stack(item_id) >= 1, "%s has a max stack" % item_id)
	var extras: PackedStringArray = PackedStringArray()
	for item_id in ids:
		if not Catalog.EXPECTED_IDS.has(item_id):
			extras.append(item_id)
	_check(extras.is_empty(), "catalog has no extra items%s" % ("" if extras.is_empty() else " (%s)" % ",".join(extras)))
	_check(Catalog.item_is_tool("hoe") and Catalog.item_is_tool("watering_can") and Catalog.item_is_tool("hand_tools"), "the three tools are tools")
	_check(Catalog.is_consumable("lettuce_seeds") and Catalog.is_consumable("wood"), "seeds and materials are consumable")
	_check(Catalog.shop_price("wood") == 4 and Catalog.shop_price("nails") == 3, "wood and nails have fixed prices")
	_check(Catalog.shop_price("lettuce_seeds") == 2 and Catalog.shop_price("scrap") == 0, "seeds sell; scrap does not")
	_check(Catalog.capacity() == 16 and Catalog.starting_cash() == 20, "capacity 16 and starting wallet 20")
	for item_id in Catalog.EXPECTED_IDS:
		var icon := Icons.icon(item_id)
		_check(icon != null, "icon exists for %s" % item_id)


func _add_remove_and_stacks() -> void:
	var pack := _pack()
	_check(pack != null, "Inventory autoload exists")
	pack.call("reset")
	_check(int(pack.call("add", "wood", 3)) == 3, "add 3 wood")
	_check(int(pack.call("quantity", "wood")) == 3, "quantity reports 3 wood")
	_check(bool(pack.call("has", "wood", 3)) and not bool(pack.call("has", "wood", 4)), "has() respects the requested count")
	_check(int(pack.call("remove", "wood", 1)) == 1, "remove 1 wood")
	_check(int(pack.call("quantity", "wood")) == 2, "2 wood remain")
	_check(int(pack.call("remove", "wood", 9)) == 2, "remove more than held takes what exists")
	_check(int(pack.call("quantity", "wood")) == 0, "wood pile is empty")
	_check(int(pack.call("occupied_slots")) == 0, "empty stacks leave the pack")
	pack.call("reset")
	_check(int(pack.call("add", "lettuce_seeds", 15)) == 15, "add 15 lettuce seeds")
	_check(int(pack.call("add", "lettuce_seeds", 10)) == 10, "add 10 more lettuce seeds")
	_check(int(pack.call("quantity", "lettuce_seeds")) == 25, "seeds total 25")
	_check(int(pack.call("occupied_slots")) == 2, "max stack 20 splits onto a second slot")
	var slots: Array = pack.call("slots")
	_check(slots.size() == 2, "two seed stacks")
	if slots.size() >= 2:
		_check(int((slots[0] as Dictionary).get("qty", 0)) == 20, "first stack is full at 20")
		_check(int((slots[1] as Dictionary).get("qty", 0)) == 5, "overflow sits on the next stack")
	_check(int(pack.call("add", "hoe", 1)) == 1, "add a hoe")
	_check(int(pack.call("add", "hoe", 1)) == 1, "a second hoe takes its own slot because tools do not stack past 1")
	_check(int(pack.call("quantity", "hoe")) == 2 and int(pack.call("occupied_slots")) == 4, "two hoe slots")


func _capacity_and_invalid() -> void:
	var pack := _pack()
	pack.call("reset")
	var filled := 0
	for _i in 16:
		filled += int(pack.call("add", "hoe", 1))
	_check(filled == 16 and int(pack.call("occupied_slots")) == 16, "16 hoe stacks fill the pack (tools do not stack)")
	_check(int(pack.call("add", "wood", 1)) == 0, "a full pack accepts nothing new")
	_check(not bool(pack.call("can_add", "wood", 1)), "can_add is false when full")
	_check(int(pack.call("add", "not_an_item", 1)) == 0, "invalid items add nothing")
	_check(int(pack.call("quantity", "not_an_item")) == 0, "invalid items have quantity 0")
	_check(int(pack.call("remove", "not_an_item", 1)) == 0, "invalid items remove nothing")
	_check(int(pack.call("add", "scrap", 0)) == 0 and int(pack.call("add", "scrap", -3)) == 0, "non-positive adds are ignored")


func _wallet_vs_church() -> void:
	var pack := _pack()
	var funds := _funds()
	_check(funds != null, "ChurchFunds autoload exists")
	pack.call("reset")
	funds.call("reset")
	var church_start := int(funds.get("balance"))
	var wallet_start := int(pack.call("cash"))
	_check(wallet_start == 20, "personal wallet starts at 20")
	_check(church_start == 55 and church_start != wallet_start, "church starting balance stays separate from the wallet")
	pack.call("gain_cash", 15)
	_check(int(pack.call("cash")) == 35, "gain_cash raises the wallet")
	_check(int(funds.get("balance")) == church_start, "gain_cash does not touch ChurchFunds")
	_check(bool(pack.call("spend_cash", 10)), "spend_cash succeeds")
	_check(int(pack.call("cash")) == 25, "wallet decreases")
	_check(int(funds.get("balance")) == church_start, "spend_cash does not touch ChurchFunds")
	_check(not bool(pack.call("spend_cash", 40)), "cannot spend more than the wallet")
	_check(int(pack.call("cash")) == 25, "failed spend keeps the wallet")
	_check(int(funds.get("balance")) == church_start, "failed spend still leaves ChurchFunds")
	funds.set("balance", church_start + 40)
	_check(int(pack.call("cash")) == 25, "changing ChurchFunds does not change the wallet")


func _shop_purchase() -> void:
	var pack := _pack()
	var funds := _funds()
	pack.call("reset")
	funds.call("reset")
	var church_start := int(funds.get("balance"))
	pack.call("set_cash", 10)
	_check(bool(pack.call("buy", "wood", 1)), "buying wood succeeds")
	_check(int(pack.call("cash")) == 6, "wallet drops by the wood price")
	_check(int(pack.call("quantity", "wood")) == 1, "wood is added")
	_check(int(funds.get("balance")) == church_start, "a shop purchase does not spend ChurchFunds")
	pack.call("set_cash", 2)
	_check(not bool(pack.call("buy", "wood", 1)), "cannot overspend on wood")
	_check(int(pack.call("cash")) == 2, "overspend keeps the wallet")
	_check(int(pack.call("quantity", "wood")) == 1, "overspend adds no extra wood")
	_check(not bool(pack.call("buy", "scrap", 1)), "scrap is not sold")
	_check(not bool(pack.call("buy", "hoe", 1)), "tools are not sold")
	_check(bool(pack.call("buy", "lettuce_seeds", 1)), "buying seeds succeeds")
	_check(int(pack.call("quantity", "lettuce_seeds")) == 1, "seeds are added")


func _signals() -> void:
	var pack := _pack()
	pack.call("reset")
	if not pack.item_added.is_connected(_on_added):
		pack.item_added.connect(_on_added)
	if not pack.item_consumed.is_connected(_on_consumed):
		pack.item_consumed.connect(_on_consumed)
	_added_id = ""
	_added_qty = 0
	_consumed_id = ""
	_consumed_qty = 0
	pack.call("add", "nails", 4)
	_check(_added_id == "nails" and _added_qty == 4, "item_added fires with id and quantity")
	pack.call("remove", "nails", 2)
	_check(_consumed_id == "nails" and _consumed_qty == 2, "item_consumed fires with id and quantity")
	if pack.item_added.is_connected(_on_added):
		pack.item_added.disconnect(_on_added)
	if pack.item_consumed.is_connected(_on_consumed):
		pack.item_consumed.disconnect(_on_consumed)


func _starter_once() -> void:
	var pack := _pack()
	NarrativeState.reset()
	_check(bool(pack.call("grant_starter", "tools")), "starter tools grant once")
	_check(int(pack.call("quantity", "watering_can")) == 1, "watering can granted")
	_check(int(pack.call("quantity", "hoe")) == 1, "hoe granted")
	_check(int(pack.call("quantity", "hand_tools")) == 1, "hand tools granted")
	_check(NarrativeState.flag_is_true("starter_tools_taken"), "starter_tools_taken is set")
	_check(not bool(pack.call("grant_starter", "tools")), "starter tools do not grant a second time")
	_check(int(pack.call("quantity", "hoe")) == 1, "a second grant does not duplicate the hoe")
	_check(bool(pack.call("grant_starter", "seeds")), "starter seeds grant once")
	_check(int(pack.call("quantity", "lettuce_seeds")) == 4, "lettuce seeds granted")
	_check(int(pack.call("quantity", "carrot_seeds")) == 4, "carrot seeds granted")
	_check(int(pack.call("quantity", "tomato_seeds")) == 3, "tomato seeds granted")
	_check(int(pack.call("quantity", "flower_seeds")) == 3, "flower seeds granted")
	_check(not bool(pack.call("grant_starter", "seeds")), "starter seeds do not grant a second time")
	_check(int(pack.call("quantity", "lettuce_seeds")) == 4, "a second seed grant does not duplicate packets")
	_check(str(pack.call("equipped_tool")) != "", "a tool is equipped after the starter grant")


func _pickup_and_shop_nodes() -> void:
	NarrativeState.reset()
	var home := _instance("res://scenes/world/parsonage.tscn")
	if home == null:
		return
	await _pump(2)
	var toolbox := home.get_node_or_null("Props/Toolbox") as ItemPickup
	_check(toolbox != null, "the parsonage has a toolbox")
	if toolbox != null:
		toolbox.interact(null)
		_check(NarrativeState.flag_is_true("starter_tools_taken"), "using the toolbox grants tools")
		_check(int(_pack().call("quantity", "hoe")) == 1, "toolbox grants a hoe")
		toolbox.interact(null)
		_check(int(_pack().call("quantity", "hoe")) == 1, "using the toolbox again does not duplicate tools")
	home.free()
	await _pump(1)
	NarrativeState.reset()
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	await _pump(2)
	var crate := grounds.get_node_or_null("Props/SeedCrate") as ItemPickup
	_check(crate != null, "the church garden has a seed crate")
	if crate != null:
		crate.interact(null)
		_check(NarrativeState.flag_is_true("starter_seeds_taken"), "using the crate grants seeds")
		_check(not NarrativeState.flag_is_true("garden_cleared"), "taking leftover seed does not clear the Maple Lane plot")
		crate.interact(null)
		_check(int(_pack().call("quantity", "lettuce_seeds")) == 4, "using the crate again does not duplicate seeds")
	grounds.free()
	await _pump(1)
	var lane := _instance("res://scenes/world/maple_lane.tscn")
	if lane == null:
		return
	await _pump(2)
	var plot := lane.get_node_or_null("Props/Garden") as GardenPlot
	_check(plot != null, "the Chapter 1 garden plot is still there")
	_check(lane.get_node_or_null("Props/SeedCrate") == null, "the seed crate is no longer on Maple Lane")
	lane.free()
	await _pump(1)
	var store := _instance("res://scenes/world/hardware_interior.tscn")
	if store == null:
		return
	await _pump(2)
	var shelves := store.get_node_or_null("Props/ShopShelves") as ShopCounter
	var thomas := store.get_node_or_null("Props/Thomas")
	_check(shelves != null, "the hardware store has shop shelves")
	_check(thomas != null, "Thomas is still behind the counter")
	store.free()
	await _pump(1)


func _ui_and_clock() -> void:
	NarrativeState.reset()
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	await _pump(2)
	var panel := hud.get_node_or_null("InventoryPanel")
	var shop := hud.get_node_or_null("ShopPanel")
	_check(panel != null, "HUD has an inventory panel")
	_check(shop != null, "HUD has a shop panel")
	if panel != null and panel.has_method("open"):
		panel.call("open")
		await _pump(2)
		_check(bool(panel.call("is_open")), "I-panel opens")
		_check(NarrativeState.inventory_open, "inventory_open locks movement")
		_check(NarrativeState.movement_locked(), "the clock holds while the pack is open")
		_check(not DayClock.is_exploring(), "DayClock is not exploring during inventory")
		if panel.has_method("close"):
			panel.call("close")
		await _pump(2)
		_check(not NarrativeState.inventory_open, "closing the pack unlocks movement")
	if shop != null and shop.has_method("open"):
		shop.call("open")
		await _pump(2)
		_check(bool(shop.call("is_open")), "shop UI opens")
		_check(NarrativeState.shop_open, "shop_open locks movement")
		_check(not DayClock.is_exploring(), "DayClock is not exploring during the shop")
		if shop.has_method("close"):
			shop.call("close")
		await _pump(2)
	hud.free()
	await _pump(1)


func _save_roundtrip() -> void:
	var pack := _pack()
	var funds := _funds()
	NarrativeState.reset()
	DayClock.reset()
	funds.call("reset")
	pack.call("reset")
	NarrativeState.set_flag("frank_listened", true)
	funds.set("balance", 80)
	pack.call("add", "wood", 3)
	pack.call("add", "hoe", 1)
	pack.call("equip", "hoe")
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
	_check(saved, "a current-version save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary, "the save file is an object")
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == SaveGame.SAVE_VERSION, "the save file is the current version")
	_check(row.has("inventory"), "the save stores inventory")
	var inv_row: Dictionary = row.get("inventory", {}) if row.get("inventory", {}) is Dictionary else {}
	_check(int(inv_row.get("cash", -1)) == 12, "the save stores wallet cash")
	NarrativeState.reset()
	_check(int(pack.call("cash")) == 20 and int(pack.call("quantity", "wood")) == 0, "reset restores empty pack and starting cash")
	_check(int(funds.get("balance")) == 55, "reset restores church starting balance")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == SaveGame.SAVE_VERSION, "read_file keeps the current version")
	SaveGame.apply_state(loaded)
	_check(int(pack.call("cash")) == 12, "load restores the wallet")
	_check(int(pack.call("quantity", "wood")) == 3, "load restores wood")
	_check(int(pack.call("quantity", "hoe")) == 1, "load restores the hoe")
	_check(str(pack.call("equipped_tool")) == "hoe", "load restores the equipped tool")
	_check(int(funds.get("balance")) == 80, "load restores church funds beside the wallet")
	_check(NarrativeState.flag_is_true("frank_listened"), "load keeps story flags")
	room.free()
	NarrativeState.reset()


func _old_save_migration() -> void:
	var from_v6 := SaveGame.migrate({
		"version": 6,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 4, "hour": 14, "minute": 0},
		"chapter": "",
		"funds": {"balance": 80, "project_state": "none", "project_progress": 0},
		"pastor_path": {"shepherd": 1, "builder": 0, "skeptic": 0, "history": [], "seed": 42},
		"threads": {"frank_grief": "open"},
		"run_seed": 42,
		"narrative": {
			"flags": {"frank_listened": true, "spare_keys_returned": true},
			"quests": {},
			"relationships": {"frank": 1},
			"growth": {"community_trust": 1, "attendance": 17},
		},
	})
	_check(int(from_v6.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 6 file migrates to the current save")
	var inv_v: Variant = from_v6.get("inventory", {})
	var inv: Dictionary = inv_v if inv_v is Dictionary else {}
	_check(int(inv.get("cash", -1)) == 20, "v6 migration adds starting wallet cash")
	var slots_v: Variant = inv.get("slots", null)
	_check(slots_v is Array and (slots_v as Array).is_empty(), "v6 migration adds an empty pack")
	_check(str(inv.get("equipped", "x")) == "", "v6 migration adds no equipped tool")
	var funds_v: Variant = from_v6.get("funds", {})
	var funds_row: Dictionary = funds_v if funds_v is Dictionary else {}
	_check(int(funds_row.get("balance", -1)) == 80, "v6 migration keeps church funds")
	var flags: Dictionary = {}
	var narrative_v: Variant = from_v6.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	_check(bool(flags.get("frank_listened", false)) and bool(flags.get("spare_keys_returned", false)), "v6 migration keeps story flags")
	_check(int(from_v6.get("run_seed", 0)) == 42, "v6 migration keeps the run seed")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	var pack := _pack()
	var funds := _funds()
	NarrativeState.reset()
	SaveGame.apply_state(from_v6)
	_check(int(pack.call("cash")) == 20 and int(pack.call("occupied_slots")) == 0, "applying a migrated v6 save uses default inventory")
	_check(int(funds.get("balance")) == 80, "applying a migrated v6 save keeps church funds")
	_check(NarrativeState.flag_is_true("frank_listened"), "applying a migrated v6 save keeps relationships' flags")
	NarrativeState.reset()


func _on_added(item_id: String, quantity: int) -> void:
	_added_id = item_id
	_added_qty = quantity


func _on_consumed(item_id: String, quantity: int) -> void:
	_consumed_id = item_id
	_consumed_qty = quantity


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
	print("GPA_OK" if not _failed else "GPA_FAIL")
	tree.quit(0 if not _failed else 1)
