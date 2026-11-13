extends Node
## Windowed shots of fence stages and worksite before/after. Quits on its own.
## Skips itself when headless.

const SHOT_DIR := "res://tests/gpd2/shots"
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
		if pack.has_method("equip"):
			pack.call("equip", "hand_tools")
	_stage_all(0, false, false, false)
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	var hud := room.get_node_or_null("HUD")
	if hud != null:
		hud.set("visible", false)
	if player != null:
		player.global_position = GroundsLayout.REPAIR_FENCE + Vector2(-48, -24)
		if player.has_method("set_facing"):
			player.call("set_facing", &"right")
	await _shot("fence_damaged")
	_stage_all(1, false, false, false)
	_refresh_sites(room)
	await _shot("fence_cleared")
	_stage_all(2, false, false, false)
	_refresh_sites(room)
	await _shot("fence_new_wood")
	_stage_all(3, false, false, false)
	_refresh_sites(room)
	await _shot("fence_finished")
	_stage_all(0, false, false, false)
	_refresh_sites(room)
	if player != null:
		player.global_position = GroundsLayout.REPAIR_WEEDS + Vector2(16, 28)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	await _shot("weeds_before")
	_stage_all(0, true, false, false)
	_refresh_sites(room)
	await _shot("weeds_after")
	_stage_all(0, false, false, false)
	_refresh_sites(room)
	if player != null:
		player.global_position = GroundsLayout.REPAIR_LITTER + Vector2(8, 36)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	await _shot("litter_before")
	_stage_all(0, false, true, false)
	_refresh_sites(room)
	await _shot("litter_after")
	_stage_all(0, false, false, false)
	_refresh_sites(room)
	if player != null:
		player.global_position = GroundsLayout.REPAIR_BED + Vector2(0, 36)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	await _shot("bed_before")
	_stage_all(0, false, false, true)
	_refresh_sites(room)
	await _shot("bed_after")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _stage_all(fence_stage: int, weeds_done: bool, litter_done: bool, bed_done: bool) -> void:
	var repairs := get_node_or_null("/root/RepairState")
	if repairs == null or not repairs.has_method("from_dictionary"):
		return
	var fence_done := fence_stage >= 3
	NarrativeState.set_flag("lot_litter_cleared", litter_done)
	NarrativeState.set_flag("picnic_weeds_cleared", weeds_done)
	NarrativeState.set_flag("picnic_bed_restored", bed_done)
	if fence_done:
		NarrativeState.set_flag("church_fence_mended", true)
	else:
		NarrativeState.set_flag("church_fence_mended", false)
	repairs.call("from_dictionary", {
		"sites": {
			"church_fence": {"id": "church_fence", "stage": fence_stage, "done": fence_done},
			"picnic_weeds": {"id": "picnic_weeds", "stage": 1 if weeds_done else 0, "done": weeds_done},
			"lot_litter": {"id": "lot_litter", "stage": 1 if litter_done else 0, "done": litter_done},
			"picnic_bed": {"id": "picnic_bed", "stage": 2 if bed_done else 0, "done": bed_done},
		},
	})


func _refresh_sites(room: Node) -> void:
	if room == null:
		return
	if room.has_method("_apply_grounds_look"):
		room.call("_apply_grounds_look")
	for node in room.get_tree().get_nodes_in_group("repair_site"):
		if node != null and node.has_method("_refresh"):
			node.call("_refresh")


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
