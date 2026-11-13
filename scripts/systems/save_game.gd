class_name SaveGame
extends RefCounted
## One save slot. Versioned JSON in user://. The migration stub is where older files will step forward.

const SAVE_VERSION := 6
const SAVE_PATH := "user://the_calling_save.json"


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
	NarrativeState.reset()
	DayClock.reset()
	if tree != null:
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
	DayClock.held = false
	if tree != null and tree.paused:
		tree.paused = false
	SceneRouter.travel(tree, "res://scenes/world/church_exterior.tscn", &"default")


static func delete_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove("the_calling_save.json")


static func _migrate_step(data: Dictionary, from_version: int) -> Dictionary:
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
