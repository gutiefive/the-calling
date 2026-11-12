class_name SaveGame
extends RefCounted
## One save slot. Versioned JSON in user://. The migration stub is where older files will step forward.

const SAVE_VERSION := 3
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
	return {
		"version": SAVE_VERSION,
		"narrative": NarrativeState.to_dictionary(),
		"clock": clock_data,
		"scene": scene,
		"position": [player.global_position.x, player.global_position.y],
		"facing": facing,
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
	var clock_v: Variant = data.get("clock", {})
	var tree := Engine.get_main_loop() as SceneTree
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
