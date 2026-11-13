extends Node
## Saves windowed screenshots for Milestone 11C under tests/m11c/shots.
## Skips itself when headless.

const SHOT_DIR := "res://tests/m11c/shots"
const STREET := "res://scenes/world/hardware_street.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	DayClock.set_time(5, 10, 0)
	SceneRouter.next_spawn = &"from_church"
	var street := (load(STREET) as PackedScene).instantiate()
	add_child(street)
	await get_tree().process_frame
	await get_tree().process_frame
	_hide_hud(street)
	var player := street.get_node_or_null("Props/Player") as Node2D
	var camera := street.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera != null:
		camera.zoom = Vector2.ONE
	var diner := street.get_node_or_null("Props/Diner") as Node2D
	if player != null and diner != null:
		player.global_position = diner.global_position + Vector2(80, 44)
	await _shot("oak_north_day")
	var hardware := street.get_node_or_null("Props/Hardware") as Node2D
	if player != null and hardware != null:
		player.global_position = hardware.global_position + Vector2(0, 48)
	await _shot("oak_store_day")
	var south := street.get_node_or_null("Props/Pharmacy") as Node2D
	if player != null and south != null:
		player.global_position = south.global_position + Vector2(0, 8)
	await _shot("oak_south_day")
	DayClock.set_time(4, 18, 0)
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	var lighting := street.get_node_or_null("Lighting")
	if lighting != null and lighting.has_method("apply"):
		lighting.call("apply")
	if player != null and diner != null:
		player.global_position = diner.global_position + Vector2(80, 44)
	if camera != null:
		camera.zoom = Vector2.ONE
	await _shot("oak_evening")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _hide_hud(room: Node) -> void:
	var hud := room.get_node_or_null("HUD") as CanvasItem
	if hud != null:
		hud.visible = false


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
