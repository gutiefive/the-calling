extends Node
## Saves windowed screenshots of the polished garden and journal.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpc2/shots"
const GROUNDS := "res://scenes/world/church_exterior.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	DayClock.set_time(8, 14, 0)
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("grant_starter", "seeds")
		if pack.has_method("equip"):
			pack.call("equip", "hoe")
	var asks := get_node_or_null("/root/RequestState")
	if asks != null and asks.has_method("reset"):
		asks.call("reset")
		asks.call("accept", "fresh_for_the_table")
	_stage_tiles()
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	if player != null:
		player.global_position = GroundsLayout.tile_center(Vector2i(43, 37)) + Vector2(16, 24)
	var hud := room.get_node_or_null("HUD")
	if hud != null:
		hud.set("visible", false)
	await _shot("garden_patch")
	if hud != null:
		hud.set("visible", true)
		var journal := hud.get_node_or_null("Journal")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", true)
		await _shot("journal_open")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", false)
	print("CAPTURE_OK")
	get_tree().quit(0)


func _stage_tiles() -> void:
	var garden := get_node_or_null("/root/GardenState")
	if garden == null or not garden.has_method("from_dictionary"):
		return
	garden.call("from_dictionary", {
		"last_processed_day": 8,
		"tiles": {
			"42,35": _tile("42,35", "tilled", "", false, 0, "tilled", false),
			"43,35": _tile("43,35", "tilled", "", true, 0, "tilled", false),
			"44,35": _tile("44,35", "tilled", "lettuce", true, 0, "seeded", false),
			"42,36": _tile("42,36", "tilled", "lettuce", false, 1, "sprout", false),
			"43,36": _tile("43,36", "tilled", "lettuce", true, 2, "growing", false),
			"44,36": _tile("44,36", "tilled", "lettuce", false, 2, "mature", true),
			"42,37": _tile("42,37", "tilled", "carrots", true, 1, "sprout", false),
			"43,37": _tile("43,37", "tilled", "carrots", true, 2, "growing", false),
			"44,37": _tile("44,37", "tilled", "carrots", false, 3, "mature", true),
			"42,38": _tile("42,38", "tilled", "tomatoes", false, 1, "sprout", false),
			"43,38": _tile("43,38", "tilled", "tomatoes", true, 2, "growing", false),
			"44,38": _tile("44,38", "tilled", "tomatoes", true, 4, "mature", true),
			"45,35": _tile("45,35", "tilled", "flowers", true, 1, "sprout", false),
			"45,36": _tile("45,36", "tilled", "flowers", false, 2, "growing", false),
			"45,37": _tile("45,37", "tilled", "flowers", true, 3, "mature", true),
			"45,38": _tile("45,38", "harvested", "", false, 0, "harvested", false),
		},
	})


func _tile(
		plot_id: String,
		soil: String,
		crop: String,
		watered: bool,
		growth: int,
		stage: String,
		ready: bool
) -> Dictionary:
	return {
		"id": plot_id,
		"soil": soil,
		"crop": crop,
		"planted": not crop.is_empty(),
		"watered": watered,
		"growth": growth,
		"stage": stage,
		"ready": ready,
	}


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
