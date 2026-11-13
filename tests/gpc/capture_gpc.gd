extends Node
## Saves windowed screenshots of the journal, a request, and the in-ground garden.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpc/shots"
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
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("grant_starter", "seeds")
		pack.call("add", "lettuce", 2)
		pack.call("add", "carrots", 1)
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
		player.global_position = GroundsLayout.tile_center(Vector2i(43, 36)) + Vector2(0, 48)
	var hud := room.get_node_or_null("HUD")
	if hud != null:
		hud.set("visible", false)
	await _shot("garden_day")
	if hud != null:
		hud.set("visible", true)
		var journal := hud.get_node_or_null("Journal")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", true)
		await _shot("journal_requests")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", false)
		if asks != null and asks.has_method("reset"):
			asks.call("reset")
		var banner := hud.get_node_or_null("Banner")
		if banner != null and banner.has_method("open_conversation"):
			banner.call("open_conversation", "sarah", player, true)
			if banner.has_method("_reveal_step"):
				for _i in 200:
					banner.call("_reveal_step")
			if banner.has_method("_on_advance"):
				banner.call("_on_advance")
			if banner.has_method("_reveal_step"):
				for _i in 200:
					banner.call("_reveal_step")
		await _shot("request_dialogue")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _stage_tiles() -> void:
	var garden := get_node_or_null("/root/GardenState")
	if garden == null or not garden.has_method("from_dictionary"):
		return
	garden.call("from_dictionary", {
		"last_processed_day": 8,
		"tiles": {
			"42,35": {"id": "42,35", "soil": "tilled", "crop": "", "planted": false, "watered": false, "growth": 0, "stage": "tilled", "ready": false},
			"43,35": {"id": "43,35", "soil": "tilled", "crop": "lettuce", "planted": true, "watered": true, "growth": 0, "stage": "seeded", "ready": false},
			"44,35": {"id": "44,35", "soil": "tilled", "crop": "carrots", "planted": true, "watered": false, "growth": 1, "stage": "sprout", "ready": false},
			"42,36": {"id": "42,36", "soil": "tilled", "crop": "tomatoes", "planted": true, "watered": true, "growth": 2, "stage": "growing", "ready": false},
			"43,36": {"id": "43,36", "soil": "tilled", "crop": "flowers", "planted": true, "watered": false, "growth": 3, "stage": "mature", "ready": true},
			"44,36": {"id": "44,36", "soil": "tilled", "crop": "lettuce", "planted": true, "watered": true, "growth": 1, "stage": "sprout", "ready": false},
			"45,37": {"id": "45,37", "soil": "harvested", "crop": "", "planted": false, "watered": false, "growth": 0, "stage": "harvested", "ready": false},
		},
	})


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
