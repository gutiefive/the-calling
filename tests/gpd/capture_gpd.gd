extends Node
## Saves windowed screenshots of fence stages and grounds before/after repairs.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpd/shots"
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
	_stage_repairs(0, false)
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
		player.global_position = GroundsLayout.REPAIR_FENCE + Vector2(48, 24)
	await _shot("fence_damaged")
	_stage_repairs(1, false)
	_refresh_sites(room)
	await _shot("fence_cleared")
	_stage_repairs(2, false)
	_refresh_sites(room)
	await _shot("fence_new_wood")
	_stage_repairs(3, true)
	_refresh_sites(room)
	await _shot("fence_finished")
	_stage_repairs(0, false)
	_refresh_sites(room)
	if player != null:
		player.global_position = Vector2(960, 1240)
	await _shot("grounds_before")
	_finish_all()
	_refresh_sites(room)
	await _shot("grounds_after")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _stage_repairs(fence_stage: int, fence_done: bool) -> void:
	var repairs := get_node_or_null("/root/RepairState")
	if repairs == null or not repairs.has_method("from_dictionary"):
		return
	repairs.call("from_dictionary", {
		"sites": {
			"church_fence": {"id": "church_fence", "stage": fence_stage, "done": fence_done},
			"picnic_weeds": {"id": "picnic_weeds", "stage": 0, "done": false},
			"lot_litter": {"id": "lot_litter", "stage": 0, "done": false},
			"picnic_bed": {"id": "picnic_bed", "stage": 0, "done": false},
		},
	})


func _finish_all() -> void:
	var repairs := get_node_or_null("/root/RepairState")
	if repairs == null or not repairs.has_method("from_dictionary"):
		return
	repairs.call("from_dictionary", {
		"sites": {
			"church_fence": {"id": "church_fence", "stage": 3, "done": true},
			"picnic_weeds": {"id": "picnic_weeds", "stage": 1, "done": true},
			"lot_litter": {"id": "lot_litter", "stage": 1, "done": true},
			"picnic_bed": {"id": "picnic_bed", "stage": 2, "done": true},
		},
	})


func _refresh_sites(room: Node) -> void:
	if room == null:
		return
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
