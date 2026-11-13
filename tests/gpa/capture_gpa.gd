extends Node
## Saves windowed screenshots of the inventory and shop UIs under tests/gpa/shots.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpa/shots"


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
		pack.call("add", "nails", 2)
		pack.call("set_cash", 18)
		if pack.has_method("equip"):
			pack.call("equip", "hoe")
	var hud := (load("res://scenes/ui/hud.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame
	var inventory := hud.get_node_or_null("InventoryPanel")
	if inventory != null and inventory.has_method("open"):
		inventory.call("open")
	await _shot("inventory_ui")
	if inventory != null and inventory.has_method("close"):
		inventory.call("close")
	var shop := hud.get_node_or_null("ShopPanel")
	if shop != null and shop.has_method("open"):
		shop.call("open")
	await _shot("shop_ui")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
