extends Node
## Windowed shots for Gameplay F. Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpf/shots"
const GROUNDS := "res://scenes/world/church_exterior.tscn"
const MAPLE := "res://scenes/world/maple_lane.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	await _garden_growth_toast()
	await _picnic_after()
	await _litter_after()
	await _fence_repaired()
	await _dale_and_ruth()
	await _loop_end()
	print("CAPTURE_OK")
	get_tree().quit(0)


func _garden_growth_toast() -> void:
	_reset_week()
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("grant_starter", "seeds")
		pack.call("equip", "hoe")
	var garden := get_node_or_null("/root/GardenState")
	if garden != null:
		garden.call("reset")
	var cell := GroundsLayout.legacy_bed_cell(4)
	var plot_id := GroundsLayout.cell_id(cell)
	if garden != null:
		garden.call("till", plot_id)
		garden.call("plant", plot_id, "lettuce_seeds")
		if pack != null:
			pack.call("equip", "watering_can")
		garden.call("water", plot_id)
	DayClock.sleep_until_morning()
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
		player.global_position = GroundsLayout.tile_center(cell) + Vector2(0, 48)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	var toast := room.get_node_or_null("HUD/ActionToast") as ActionToast
	if toast != null:
		toast.show_message("Watered the soil.")
	await _shot("garden_growth_toast")
	room.free()
	await get_tree().process_frame


func _picnic_after() -> void:
	_reset_week()
	_stage_repairs(false, true, false, true)
	var room := await _grounds_at(GroundsLayout.REPAIR_WEEDS.lerp(GroundsLayout.REPAIR_BED, 0.5) + Vector2(0, 40), &"up", false)
	if room == null:
		return
	await _shot("picnic_after")
	room.free()
	await get_tree().process_frame


func _litter_after() -> void:
	_reset_week()
	_stage_repairs(false, false, true, false)
	var room := await _grounds_at(GroundsLayout.REPAIR_LITTER + Vector2(8, 40), &"up", false)
	if room == null:
		return
	await _shot("litter_after")
	room.free()
	await get_tree().process_frame


func _fence_repaired() -> void:
	_reset_week()
	_stage_repairs(true, false, false, false)
	var room := await _grounds_at(GroundsLayout.REPAIR_FENCE + Vector2(-48, -24), &"right", false)
	if room == null:
		return
	await _shot("fence_repaired")
	room.free()
	await get_tree().process_frame


func _dale_and_ruth() -> void:
	_reset_week()
	DayClock.set_time(8, 14, 0)
	SceneRouter.next_spawn = &"default"
	var room := (load(MAPLE) as PackedScene).instantiate()
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
	var stand := Vector2(420, 520)
	if player != null:
		player.global_position = stand + Vector2(0, 36)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	var dale := room.get_node_or_null("Props/NeighborDale") as Node2D
	var ruth := room.get_node_or_null("Props/NeighborRuth") as Node2D
	if dale != null:
		dale.position = stand + Vector2(-28, 0)
	if ruth != null:
		ruth.position = stand + Vector2(28, 0)
	await _shot("dale_ruth")
	room.free()
	await get_tree().process_frame


func _loop_end() -> void:
	_reset_week()
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("grant_starter", "seeds")
	var garden := get_node_or_null("/root/GardenState")
	if garden != null:
		garden.call("reset")
		var plot_id := GroundsLayout.legacy_bed_id(4)
		garden.call("till", plot_id)
		garden.call("plant", plot_id, "tomato_seeds")
		garden.call("water", plot_id)
	DayClock.sleep_until_morning()
	DayClock.sleep_until_morning()
	_stage_repairs(true, true, true, true)
	NarrativeState.set_flag("potluck_vegetables", true)
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	var room := await _grounds_at(GroundsLayout.tile_center(GroundsLayout.legacy_bed_cell(4)) + Vector2(0, 64), &"up", false)
	if room == null:
		return
	await _shot("loop_end")
	room.free()
	await get_tree().process_frame


func _grounds_at(pos: Vector2, facing: StringName, show_hud: bool) -> Node:
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	if room.has_method("_apply_grounds_look"):
		room.call("_apply_grounds_look")
	for node in room.get_tree().get_nodes_in_group("repair_site"):
		if node != null and node.has_method("_refresh"):
			node.call("_refresh")
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	var hud := room.get_node_or_null("HUD")
	if hud != null and not show_hud:
		hud.set("visible", false)
	if player != null:
		player.global_position = pos
		if player.has_method("set_facing"):
			player.call("set_facing", facing)
	return room


func _stage_repairs(fence_done: bool, weeds_done: bool, litter_done: bool, bed_done: bool) -> void:
	var repairs := get_node_or_null("/root/RepairState")
	if repairs == null or not repairs.has_method("from_dictionary"):
		return
	NarrativeState.set_flag("church_fence_mended", fence_done)
	NarrativeState.set_flag("picnic_weeds_cleared", weeds_done)
	NarrativeState.set_flag("lot_litter_cleared", litter_done)
	NarrativeState.set_flag("picnic_bed_restored", bed_done)
	if weeds_done and (fence_done or bed_done or litter_done):
		NarrativeState.set_flag("grounds_cared_for", true)
	repairs.call("from_dictionary", {
		"sites": {
			"church_fence": {"id": "church_fence", "stage": 3 if fence_done else 0, "done": fence_done},
			"picnic_weeds": {"id": "picnic_weeds", "stage": 1 if weeds_done else 0, "done": weeds_done},
			"lot_litter": {"id": "lot_litter", "stage": 1 if litter_done else 0, "done": litter_done},
			"picnic_bed": {"id": "picnic_bed", "stage": 2 if bed_done else 0, "done": bed_done},
		},
	})


func _reset_week() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(8, 14, 0)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
