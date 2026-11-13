extends Node
## Windowed shots of the small till toast, both potluck rooms, and Sarah's choice.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/gpe/shots"
const GROUNDS := "res://scenes/world/church_exterior.tscn"
const HALL := "res://scenes/world/fellowship_hall.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	await _toast_shot()
	await _hall_shot(false, "potluck_none")
	await _hall_shot(true, "potluck_full")
	await _choice_shot()
	print("CAPTURE_OK")
	get_tree().quit(0)


func _toast_shot() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	DayClock.set_time(8, 14, 0)
	var pack := get_node_or_null("/root/Inventory")
	if pack != null:
		pack.call("reset")
		pack.call("grant_starter", "tools")
		pack.call("equip", "hoe")
	var garden := get_node_or_null("/root/GardenState")
	if garden != null:
		garden.call("reset")
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	var cell := GroundsLayout.legacy_bed_cell(4)
	if player != null:
		player.global_position = GroundsLayout.tile_center(cell) + Vector2(0, 48)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	if garden != null and garden.has_method("till"):
		garden.call("till", GroundsLayout.cell_id(cell))
	var toast := room.get_node_or_null("HUD/ActionToast") as ActionToast
	if toast != null:
		toast.show_message("Tilled the soil.")
	await _shot("toast_till")
	room.free()
	await get_tree().process_frame


func _hall_shot(full: bool, shot_name: String) -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(10, 12, 0)
	if full:
		NarrativeState.set_flag("potluck_vegetables", true)
		NarrativeState.set_flag("sanctuary_flowers_set", true)
		NarrativeState.set_flag("grounds_cared_for", true)
		NarrativeState.set_flag("picnic_bed_restored", true)
		var events := get_node_or_null("/root/EventState")
		if events != null:
			events.call("from_dictionary", {
				"framing": "open",
				"invited": ["ostrow", "ruth", "dale"],
				"vegetables": true,
			})
	SceneRouter.next_spawn = &"default"
	var room := (load(HALL) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	if player != null:
		player.global_position = Vector2(352, 300)
		if player.has_method("set_facing"):
			player.call("set_facing", &"up")
	await _shot(shot_name)
	room.free()
	await get_tree().process_frame


func _choice_shot() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	DayClock.set_time(8, 14, 0)
	var hud := (load("res://scenes/ui/hud.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame
	var box := hud.get_node_or_null("Banner")
	var source := Node2D.new()
	add_child(source)
	if box != null and box.has_method("open_conversation"):
		box.call("open_conversation", "sarah", source, true)
	await get_tree().process_frame
	if box != null:
		var runner: Variant = box.get("_runner")
		if runner is DialogueRunner:
			var talk: DialogueRunner = runner
			var guard := 0
			while talk.is_open() and talk.choice_count() == 0 and guard < 10:
				talk.advance()
				guard += 1
			box.set("_reveal", talk.body().length())
			if box.has_method("_refresh_text"):
				box.call("_refresh_text")
	await get_tree().process_frame
	await _shot("sarah_choice")
	hud.free()
	source.free()


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
