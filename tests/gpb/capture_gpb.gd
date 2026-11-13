extends Node
## Saves windowed screenshots of the church garden and shop UI under tests/gpb/shots.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpb/shots"
const GROUNDS := "res://scenes/world/church_exterior.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	DayClock.set_time(4, 14, 0)
	NarrativeState.reset()
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("grant_starter", "seeds")
		pack.call("add", "wood", 3)
		pack.call("set_cash", 18)
		if pack.has_method("equip"):
			pack.call("equip", "hoe")
	_stage_plots()
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_hide_hud(room)
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	if player != null:
		player.global_position = GroundsLayout.tile_center(GroundsLayout.legacy_bed_cell(4)) + Vector2(0, 48)
	await _shot("garden_day")
	room.free()
	await get_tree().process_frame
	var hud := (load("res://scenes/ui/hud.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame
	var shop := hud.get_node_or_null("ShopPanel")
	if shop != null and shop.has_method("open"):
		shop.call("open")
	await _shot("shop_ui")
	var inventory := hud.get_node_or_null("InventoryPanel")
	if shop != null and shop.has_method("close"):
		shop.call("close")
	if inventory != null and inventory.has_method("open"):
		inventory.call("open")
	await _shot("inventory_ui")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _stage_plots() -> void:
	var garden := get_node_or_null("/root/GardenState")
	if garden == null or not garden.has_method("from_dictionary"):
		return
	garden.call("from_dictionary", {
		"last_processed_day": 4,
		"plots": [
			{"id": "church_0", "soil": "untouched", "crop": "", "planted": false, "watered": false, "growth": 0, "stage": "untouched", "ready": false},
			{"id": "church_1", "soil": "tilled", "crop": "", "planted": false, "watered": false, "growth": 0, "stage": "tilled", "ready": false},
			{"id": "church_2", "soil": "tilled", "crop": "lettuce", "planted": true, "watered": true, "growth": 0, "stage": "seeded", "ready": false},
			{"id": "church_3", "soil": "tilled", "crop": "carrots", "planted": true, "watered": false, "growth": 1, "stage": "sprout", "ready": false},
			{"id": "church_4", "soil": "tilled", "crop": "tomatoes", "planted": true, "watered": true, "growth": 2, "stage": "growing", "ready": false},
			{"id": "church_5", "soil": "tilled", "crop": "flowers", "planted": true, "watered": false, "growth": 3, "stage": "mature", "ready": true},
			{"id": "church_6", "soil": "tilled", "crop": "lettuce", "planted": true, "watered": false, "growth": 2, "stage": "mature", "ready": true},
			{"id": "church_7", "soil": "harvested", "crop": "", "planted": false, "watered": false, "growth": 0, "stage": "harvested", "ready": false},
			{"id": "church_8", "soil": "tilled", "crop": "carrots", "planted": true, "watered": true, "growth": 2, "stage": "growing", "ready": false},
		],
	})


func _hide_hud(room: Node) -> void:
	var hud := room.get_node_or_null("HUD")
	if hud == null:
		return
	hud.set("visible", false)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
