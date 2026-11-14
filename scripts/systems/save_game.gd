class_name SaveGame
extends RefCounted
## One save slot. Versioned JSON in user://. The migration stub is where older files will step forward.

const Catalog := preload("res://scripts/systems/item_catalog.gd")

const SAVE_VERSION := 11
const SAVE_PATH := "user://the_calling_save.json"
const INTRO_SCENE := "res://scenes/intro/intro_cutscene.tscn"
const GROUNDS_SCENE := "res://scenes/world/church_exterior.tscn"
const TITLE_SCENE := "res://scenes/main.tscn"
## Tests that still expect New Game to land on the church grounds set this true.
static var bypass_intro: bool = false
## Set after the opening cutscene so the grounds can show the goals/primer once.
static var pending_opening_handoff: bool = false
## Title "Watch Intro" returns to the title instead of starting Thursday.
static var intro_replay: bool = false


static func save_to_disk(tree: SceneTree) -> bool:
	var data := capture(tree)
	if data.is_empty():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


static func load_from_disk(tree: SceneTree) -> bool:
	if tree == null:
		return false
	pending_opening_handoff = false
	intro_replay = false
	var data := read_file()
	if data.is_empty():
		return false
	if not apply_state(data):
		return false
	if tree.paused:
		tree.paused = false
	var scene := str(data.get("scene", ""))
	var pos := _position(data.get("position", []))
	var facing := StringName(str(data.get("facing", "down")))
	# Next frame, so a pause-menu callback is not freed mid-physics-tick.
	tree.process_frame.connect(func() -> void:
		SceneRouter.travel_exact(tree, scene, pos, facing)
	, CONNECT_ONE_SHOT)
	return true


static func capture(tree: SceneTree) -> Dictionary:
	if tree == null:
		return {}
	var player := tree.get_first_node_in_group("player") as Node2D
	var room := _room_of(player)
	if player == null or room == null:
		push_error("Save needs a player in a room")
		return {}
	var scene := room.scene_file_path
	if scene.is_empty():
		push_error("Save needs a scene path")
		return {}
	var facing := "down"
	if player.has_method("get_facing"):
		facing = str(player.call("get_facing"))
	var clock_data: Dictionary = {}
	var clock := tree.root.get_node_or_null("DayClock")
	if clock != null and clock.has_method("to_dictionary"):
		var raw: Variant = clock.call("to_dictionary")
		if raw is Dictionary:
			clock_data = raw
	var influence_data: Dictionary = {}
	var chapter := ""
	var inf := tree.root.get_node_or_null("InfluenceState")
	if inf != null and inf.has_method("to_dictionary"):
		var inf_raw: Variant = inf.call("to_dictionary")
		if inf_raw is Dictionary:
			influence_data = inf_raw
		if inf.has_method("chapter"):
			chapter = str(inf.call("chapter"))
	var funds_data: Dictionary = {}
	var funds := tree.root.get_node_or_null("ChurchFunds")
	if funds != null and funds.has_method("to_dictionary"):
		var funds_raw: Variant = funds.call("to_dictionary")
		if funds_raw is Dictionary:
			funds_data = funds_raw
	var path_data: Dictionary = {}
	var run_seed := 8
	var pastor := tree.root.get_node_or_null("PastorPath")
	if pastor != null and pastor.has_method("to_dictionary"):
		var path_raw: Variant = pastor.call("to_dictionary")
		if path_raw is Dictionary:
			path_data = path_raw
		if pastor.has_method("run_seed"):
			run_seed = int(pastor.call("run_seed"))
	var thread_data: Dictionary = {}
	var threads := tree.root.get_node_or_null("StoryThreads")
	if threads != null and threads.has_method("to_dictionary"):
		var thread_raw: Variant = threads.call("to_dictionary")
		if thread_raw is Dictionary:
			thread_data = thread_raw
	var inventory_data: Dictionary = {}
	var pack := tree.root.get_node_or_null("Inventory")
	if pack != null and pack.has_method("to_dictionary"):
		var pack_raw: Variant = pack.call("to_dictionary")
		if pack_raw is Dictionary:
			inventory_data = pack_raw
	var garden_data: Dictionary = {}
	var garden := tree.root.get_node_or_null("GardenState")
	if garden != null and garden.has_method("to_dictionary"):
		var garden_raw: Variant = garden.call("to_dictionary")
		if garden_raw is Dictionary:
			garden_data = garden_raw
	var request_data: Dictionary = {}
	var asks := tree.root.get_node_or_null("RequestState")
	if asks != null and asks.has_method("to_dictionary"):
		var ask_raw: Variant = asks.call("to_dictionary")
		if ask_raw is Dictionary:
			request_data = ask_raw
	var repair_data: Dictionary = {}
	var repairs := tree.root.get_node_or_null("RepairState")
	if repairs != null and repairs.has_method("to_dictionary"):
		var repair_raw: Variant = repairs.call("to_dictionary")
		if repair_raw is Dictionary:
			repair_data = repair_raw
	var event_data: Dictionary = {}
	var events := tree.root.get_node_or_null("EventState")
	if events != null and events.has_method("to_dictionary"):
		var event_raw: Variant = events.call("to_dictionary")
		if event_raw is Dictionary:
			event_data = event_raw
	return {
		"version": SAVE_VERSION,
		"narrative": NarrativeState.to_dictionary(),
		"clock": clock_data,
		"scene": scene,
		"position": [player.global_position.x, player.global_position.y],
		"facing": facing,
		"influence": influence_data,
		"chapter": chapter,
		"funds": funds_data,
		"pastor_path": path_data,
		"threads": thread_data,
		"run_seed": run_seed,
		"inventory": inventory_data,
		"garden": garden_data,
		"requests": request_data,
		"repairs": repair_data,
		"event": event_data,
	}


static func read_file() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Save file is not an object")
		return {}
	return migrate(parsed)


static func apply_state(data: Dictionary) -> bool:
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		NarrativeState.from_dictionary(narrative_v)
	var tree := Engine.get_main_loop() as SceneTree
	var inf := tree.root.get_node_or_null("InfluenceState") if tree != null else null
	if inf != null and inf.has_method("from_dictionary"):
		var influence_v: Variant = data.get("influence", {})
		var influence_data: Dictionary = influence_v if influence_v is Dictionary else {}
		inf.call("from_dictionary", influence_data)
		if inf.has_method("set_chapter"):
			inf.call("set_chapter", str(data.get("chapter", influence_data.get("chapter", ""))))
	var funds := tree.root.get_node_or_null("ChurchFunds") if tree != null else null
	if funds != null and funds.has_method("from_dictionary"):
		var funds_v: Variant = data.get("funds", {})
		var funds_data: Dictionary = funds_v if funds_v is Dictionary else {}
		funds.call("from_dictionary", funds_data)
	var pastor := tree.root.get_node_or_null("PastorPath") if tree != null else null
	if pastor != null and pastor.has_method("from_dictionary"):
		var path_v: Variant = data.get("pastor_path", {})
		var path_data: Dictionary = path_v if path_v is Dictionary else {}
		pastor.call("from_dictionary", path_data)
		if pastor.has_method("set_seed"):
			var seed_value := int(data.get("run_seed", path_data.get("seed", 8)))
			pastor.call("set_seed", seed_value)
	var threads := tree.root.get_node_or_null("StoryThreads") if tree != null else null
	if threads != null and threads.has_method("from_dictionary"):
		var thread_v: Variant = data.get("threads", {})
		var thread_data: Dictionary = thread_v if thread_v is Dictionary else {}
		threads.call("from_dictionary", thread_data)
	var pack := tree.root.get_node_or_null("Inventory") if tree != null else null
	if pack != null and pack.has_method("from_dictionary"):
		var pack_v: Variant = data.get("inventory", {})
		var pack_data: Dictionary = pack_v if pack_v is Dictionary else {}
		pack.call("from_dictionary", pack_data)
	var garden := tree.root.get_node_or_null("GardenState") if tree != null else null
	if garden != null and garden.has_method("from_dictionary"):
		var garden_v: Variant = data.get("garden", {})
		var garden_data: Dictionary = garden_v if garden_v is Dictionary else {}
		garden.call("from_dictionary", garden_data)
	var asks := tree.root.get_node_or_null("RequestState") if tree != null else null
	if asks != null and asks.has_method("from_dictionary"):
		var ask_v: Variant = data.get("requests", {})
		var ask_data: Dictionary = ask_v if ask_v is Dictionary else {}
		asks.call("from_dictionary", ask_data)
	var repairs := tree.root.get_node_or_null("RepairState") if tree != null else null
	if repairs != null and repairs.has_method("from_dictionary"):
		var repair_v: Variant = data.get("repairs", {})
		var repair_data: Dictionary = repair_v if repair_v is Dictionary else {}
		repairs.call("from_dictionary", repair_data)
	var events := tree.root.get_node_or_null("EventState") if tree != null else null
	if events != null and events.has_method("from_dictionary"):
		var event_v: Variant = data.get("event", {})
		var event_data: Dictionary = event_v if event_v is Dictionary else {}
		events.call("from_dictionary", event_data)
	var clock_v: Variant = data.get("clock", {})
	if tree != null and clock_v is Dictionary:
		var clock := tree.root.get_node_or_null("DayClock")
		if clock != null and clock.has_method("from_dictionary"):
			clock.call("from_dictionary", clock_v)
	return data.has("scene") and not str(data.get("scene", "")).is_empty()


static func migrate(data: Dictionary) -> Dictionary:
	if not data.has("version"):
		push_error("Save is missing a version")
		return {}
	var version := int(data.get("version", 0))
	if version < 1 or version > SAVE_VERSION:
		push_error("Save version %s is not supported" % version)
		return {}
	var copy := data.duplicate(true)
	while version < SAVE_VERSION:
		copy = _migrate_step(copy, version)
		version += 1
		copy["version"] = version
	return copy


static func begin_new_game(tree: SceneTree) -> void:
	reset_run(tree)
	intro_replay = false
	if tree != null and tree.paused:
		tree.paused = false
	if bypass_intro:
		pending_opening_handoff = false
		DayClock.held = false
		SceneRouter.travel(tree, GROUNDS_SCENE, &"default")
		return
	pending_opening_handoff = true
	DayClock.held = true
	SceneRouter.travel(tree, INTRO_SCENE, &"default")


static func reset_run(tree: SceneTree) -> void:
	NarrativeState.reset()
	DayClock.reset()
	if tree == null:
		return
	var inf := tree.root.get_node_or_null("InfluenceState")
	if inf != null and inf.has_method("reset"):
		inf.call("reset")
	var funds := tree.root.get_node_or_null("ChurchFunds")
	if funds != null and funds.has_method("reset"):
		funds.call("reset")
	var pastor := tree.root.get_node_or_null("PastorPath")
	if pastor != null and pastor.has_method("reset"):
		pastor.call("reset")
	if pastor != null and pastor.has_method("roll_seed"):
		pastor.call("roll_seed")
	var threads := tree.root.get_node_or_null("StoryThreads")
	if threads != null and threads.has_method("reset"):
		threads.call("reset")
	var pack := tree.root.get_node_or_null("Inventory")
	if pack != null and pack.has_method("reset"):
		pack.call("reset")
	var garden := tree.root.get_node_or_null("GardenState")
	if garden != null and garden.has_method("reset"):
		garden.call("reset")
	var asks := tree.root.get_node_or_null("RequestState")
	if asks != null and asks.has_method("reset"):
		asks.call("reset")
	var repairs := tree.root.get_node_or_null("RepairState")
	if repairs != null and repairs.has_method("reset"):
		repairs.call("reset")
	var events := tree.root.get_node_or_null("EventState")
	if events != null and events.has_method("reset"):
		events.call("reset")


static func begin_intro_replay(tree: SceneTree) -> void:
	intro_replay = true
	pending_opening_handoff = false
	DayClock.held = true
	if tree != null and tree.paused:
		tree.paused = false
	SceneRouter.travel(tree, INTRO_SCENE, &"default")


static func finish_intro(tree: SceneTree) -> void:
	if intro_replay:
		intro_replay = false
		pending_opening_handoff = false
		DayClock.held = true
		SceneRouter.travel(tree, TITLE_SCENE, &"default")
		return
	NarrativeState.set_flag("intro_seen", true)
	pending_opening_handoff = true
	DayClock.set_time(DayClock.START_WEEKDAY, DayClock.START_HOUR, DayClock.START_MINUTE)
	DayClock.held = true
	SceneRouter.travel(tree, GROUNDS_SCENE, &"default")


static func delete_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove("the_calling_save.json")


static func _migrate_step(data: Dictionary, from_version: int) -> Dictionary:
	if from_version == 10:
		return _migrate_event(data)
	if from_version == 9:
		return _migrate_repairs(data)
	if from_version == 8:
		return _migrate_requests(data)
	if from_version == 7:
		return _migrate_garden(data)
	if from_version == 6:
		return _migrate_inventory(data)
	if from_version == 5:
		return _migrate_branching(data)
	if from_version == 4:
		return _migrate_funds(data)
	if from_version == 3:
		return _migrate_influence(data)
	if from_version == 2:
		return _migrate_growth(data)
	if from_version != 1:
		push_error("No migration step from version %s" % from_version)
		return data
	# Version 2 adds the sermon theme. Older files have not chosen one.
	var narrative: Dictionary = {}
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		narrative = (narrative_v as Dictionary).duplicate(true)
	var flags: Dictionary = {}
	var flags_v: Variant = narrative.get("flags", {})
	if flags_v is Dictionary:
		flags = (flags_v as Dictionary).duplicate(true)
	if not flags.has("sermon_theme"):
		flags["sermon_theme"] = ""
	narrative["flags"] = flags
	if not narrative.has("quests"):
		narrative["quests"] = {}
	if not narrative.has("relationships"):
		narrative["relationships"] = {}
	data["narrative"] = narrative
	return data


static func _migrate_growth(data: Dictionary) -> Dictionary:
	# Version 3 adds the soft church measures. Older files have not moved them.
	var narrative: Dictionary = {}
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		narrative = (narrative_v as Dictionary).duplicate(true)
	var growth := {
		"congregation_health": 0,
		"community_trust": 0,
		"community_impact": 0,
		"facility_condition": 0,
		"attendance": 17,
	}
	var growth_v: Variant = narrative.get("growth", {})
	if growth_v is Dictionary:
		for key in growth.keys():
			if (growth_v as Dictionary).has(key):
				growth[key] = int((growth_v as Dictionary)[key])
	narrative["growth"] = growth
	if not narrative.has("flags"):
		narrative["flags"] = {}
	if not narrative.has("quests"):
		narrative["quests"] = {}
	if not narrative.has("relationships"):
		narrative["relationships"] = {}
	if not narrative.has("notes"):
		narrative["notes"] = []
	data["narrative"] = narrative
	return data


static func _migrate_influence(data: Dictionary) -> Dictionary:
	# Version 4 adds hidden Pull and an empty chapter field. Older files have neither.
	var influence: Dictionary = {
		"seats": 0,
		"storefronts": 0,
		"dependents": 0,
		"total": 0,
		"stage": 1,
		"chapter": "",
	}
	var influence_v: Variant = data.get("influence", {})
	if influence_v is Dictionary:
		for key in influence.keys():
			if (influence_v as Dictionary).has(key):
				if key == "chapter":
					influence[key] = str((influence_v as Dictionary)[key])
				else:
					influence[key] = int((influence_v as Dictionary)[key])
	data["influence"] = influence
	if not data.has("chapter"):
		data["chapter"] = str(influence.get("chapter", ""))
	return data


static func _migrate_funds(data: Dictionary) -> Dictionary:
	# Version 5 adds church funds, the week project, and the weekly loop flag.
	var funds: Dictionary = {
		"balance": 55,
		"last_service_week": 0,
		"project_id": "fellowship_hall",
		"project_progress": 0,
		"project_state": "none",
		"repair_week": 0,
		"pending_week": 0,
		"pending_offering": 0,
		"pending_expenses": 0,
		"pending_attendance": 0,
		"pending_theme": "",
		"pending_choice": "",
		"history": [],
	}
	var funds_v: Variant = data.get("funds", {})
	if funds_v is Dictionary:
		for key in funds.keys():
			if (funds_v as Dictionary).has(key):
				funds[key] = (funds_v as Dictionary)[key]
	data["funds"] = funds
	var narrative: Dictionary = {}
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		narrative = (narrative_v as Dictionary).duplicate(true)
	var flags: Dictionary = {}
	var flags_v: Variant = narrative.get("flags", {})
	if flags_v is Dictionary:
		flags = (flags_v as Dictionary).duplicate(true)
	if bool(flags.get("week_continues", false)) and not bool(flags.get("weekly_loop", false)):
		flags["weekly_loop"] = true
	narrative["flags"] = flags
	data["narrative"] = narrative
	if bool(flags.get("weekly_loop", false)):
		if str(data.get("chapter", "")).is_empty():
			data["chapter"] = "2"
		var influence_v: Variant = data.get("influence", {})
		if influence_v is Dictionary:
			var influence: Dictionary = influence_v
			if str(influence.get("chapter", "")).is_empty():
				influence["chapter"] = "2"
			data["influence"] = influence
	return data


static func _migrate_branching(data: Dictionary) -> Dictionary:
	# Version 6 adds hidden leanings, story threads, and a per-save run seed.
	var path_data: Dictionary = {
		"shepherd": 0,
		"builder": 0,
		"skeptic": 0,
		"history": [],
		"seed": 8,
	}
	var path_v: Variant = data.get("pastor_path", {})
	if path_v is Dictionary:
		for key in path_data.keys():
			if (path_v as Dictionary).has(key):
				path_data[key] = (path_v as Dictionary)[key]
	var seed := int(path_data.get("seed", 8))
	if data.has("run_seed"):
		seed = int(data.get("run_seed", seed))
		path_data["seed"] = seed
	data["pastor_path"] = path_data
	data["run_seed"] = seed
	var threads: Dictionary = {}
	var thread_v: Variant = data.get("threads", {})
	if thread_v is Dictionary:
		for key in (thread_v as Dictionary).keys():
			threads[str(key)] = str((thread_v as Dictionary)[key])
	data["threads"] = threads
	return data


static func _migrate_inventory(data: Dictionary) -> Dictionary:
	# Version 7 adds the personal pack and wallet. Church funds stay as they were.
	var inventory: Dictionary = {
		"slots": [],
		"equipped": "",
		"cash": Catalog.starting_cash(),
	}
	var inv_v: Variant = data.get("inventory", {})
	if inv_v is Dictionary:
		var existing: Dictionary = inv_v
		if existing.has("slots"):
			inventory["slots"] = existing.get("slots", [])
		if existing.has("equipped"):
			inventory["equipped"] = str(existing.get("equipped", ""))
		if existing.has("cash"):
			inventory["cash"] = int(existing.get("cash", inventory["cash"]))
	data["inventory"] = inventory
	return data


static func _migrate_garden(data: Dictionary) -> Dictionary:
	# Version 8 adds the church garden plots. Older files get empty untilled beds.
	var garden: Dictionary = {
		"last_processed_day": 4,
		"plots": [],
	}
	var clock_v: Variant = data.get("clock", {})
	if clock_v is Dictionary:
		garden["last_processed_day"] = int((clock_v as Dictionary).get("weekday", 4))
	var garden_v: Variant = data.get("garden", {})
	if garden_v is Dictionary:
		var existing: Dictionary = garden_v
		if existing.has("last_processed_day"):
			garden["last_processed_day"] = int(existing.get("last_processed_day", garden["last_processed_day"]))
		if existing.has("plots"):
			garden["plots"] = existing.get("plots", [])
	data["garden"] = garden
	return data


static func _migrate_requests(data: Dictionary) -> Dictionary:
	# Version 9 adds community requests and maps old church beds onto garden tiles.
	var asks: Dictionary = {
		"active": {},
		"history": [],
		"completed": {},
		"last_completed_day": {},
		"rewarded": {},
	}
	var ask_v: Variant = data.get("requests", {})
	if ask_v is Dictionary:
		var existing: Dictionary = ask_v
		if existing.has("active"):
			asks["active"] = existing.get("active", {})
		if existing.has("history"):
			asks["history"] = existing.get("history", [])
		if existing.has("completed"):
			asks["completed"] = existing.get("completed", {})
		if existing.has("last_completed_day"):
			asks["last_completed_day"] = existing.get("last_completed_day", {})
		if existing.has("rewarded"):
			asks["rewarded"] = existing.get("rewarded", {})
	data["requests"] = asks
	var garden_v: Variant = data.get("garden", {})
	if garden_v is Dictionary:
		data["garden"] = _migrate_garden_tiles(garden_v)
	return data


static func _migrate_repairs(data: Dictionary) -> Dictionary:
	# Version 10 adds worksites. An already-mended fence starts finished.
	var sites: Dictionary = {}
	var repair_v: Variant = data.get("repairs", {})
	if repair_v is Dictionary:
		var existing: Dictionary = repair_v
		var sites_v: Variant = existing.get("sites", {})
		if sites_v is Dictionary:
			sites = (sites_v as Dictionary).duplicate(true)
	var flags: Dictionary = {}
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	if bool(flags.get("church_fence_mended", false)):
		sites["church_fence"] = {
			"id": "church_fence",
			"stage": 3,
			"done": true,
		}
	data["repairs"] = {"sites": sites}
	return data


static func _migrate_event(data: Dictionary) -> Dictionary:
	# Version 11 adds the weekly potluck. Prep flags already on the story stay.
	var event: Dictionary = {
		"framing": "",
		"invited": [],
		"last_window_week": 0,
		"last_window_day": 0,
		"last_reward_week": 0,
		"attended_weeks": [],
		"skipped_weeks": [],
		"vegetables": false,
		"last_seen_day": 0,
	}
	var event_v: Variant = data.get("event", {})
	if event_v is Dictionary:
		var existing: Dictionary = event_v
		for key in event.keys():
			if existing.has(key):
				event[key] = existing[key]
	var flags: Dictionary = {}
	var narrative_v: Variant = data.get("narrative", {})
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			flags = flags_v
	if bool(flags.get("potluck_vegetables", false)):
		event["vegetables"] = true
	if bool(flags.get("potluck_framing_open", false)):
		event["framing"] = "open"
	elif bool(flags.get("potluck_framing_church", false)):
		event["framing"] = "church"
	data["event"] = event
	return data


static func _migrate_garden_tiles(garden: Dictionary) -> Dictionary:
	if garden.has("tiles") and garden.get("tiles") is Dictionary:
		return garden
	var tiles: Dictionary = {}
	var plots_v: Variant = garden.get("plots", [])
	if plots_v is Array:
		for row_v in plots_v as Array:
			if not row_v is Dictionary:
				continue
			var row: Dictionary = (row_v as Dictionary).duplicate(true)
			var plot_id := str(row.get("id", ""))
			var key := plot_id
			if plot_id.begins_with("church_"):
				var index := int(plot_id.substr(7))
				if index >= 0 and index < 9:
					key = GroundsLayout.legacy_bed_id(index)
			if key.is_empty() or key.find(",") < 0:
				continue
			row["id"] = key
			tiles[key] = row
	garden["tiles"] = tiles
	return garden


static func _room_of(player: Node) -> Node:
	var node := player
	while node != null:
		var path := node.scene_file_path
		if path.begins_with("res://scenes/world/"):
			return node
		node = node.get_parent()
	return null


static func _position(value: Variant) -> Vector2:
	if value is Array and (value as Array).size() >= 2:
		var pair: Array = value
		return Vector2(float(pair[0]), float(pair[1]))
	return Vector2.ZERO
