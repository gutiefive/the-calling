extends Node
## Saves windowed screenshots of Oak Street and Maple Lane under tests/m11/shots.
## Skips itself when headless.

const SHOT_DIR := "res://tests/m11/shots"
const STREET := "res://scenes/world/hardware_street.tscn"
const LANE := "res://scenes/world/maple_lane.tscn"

var _prefix: String = ""


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	var raw := OS.get_environment("M11_SHOT_PREFIX")
	_prefix = raw
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
	var bounds := Rect2(0, 0, 2432, 1152)
	if street is WorldRoom:
		bounds = (street as WorldRoom).bounds
	_fit_camera(camera, bounds)
	if player != null:
		player.global_position = bounds.get_center()
	await _shot("oak_wide_day")
	if camera != null:
		camera.zoom = Vector2.ONE
	var south := street.get_node_or_null("Props/Pharmacy") as Node2D
	if south == null:
		south = street.get_node_or_null("Props/Bench") as Node2D
	if player != null and south != null:
		player.global_position = south.global_position + Vector2(0, 8)
	elif player != null:
		player.global_position = Vector2(720, 680)
	await _shot("oak_south_day")
	street.queue_free()
	await get_tree().process_frame

	SceneRouter.next_spawn = &"from_oak"
	var lane := (load(LANE) as PackedScene).instantiate()
	add_child(lane)
	await get_tree().process_frame
	await get_tree().process_frame
	_hide_hud(lane)
	player = lane.get_node_or_null("Props/Player") as Node2D
	camera = lane.get_node_or_null("Props/Player/Camera2D") as Camera2D
	bounds = Rect2(0, 0, 1280, 1024)
	if lane is WorldRoom:
		bounds = (lane as WorldRoom).bounds
	_fit_camera(camera, bounds)
	if player != null:
		player.global_position = bounds.get_center()
	await _shot("maple_wide_day")
	if camera != null:
		camera.zoom = Vector2.ONE
	var house := lane.get_node_or_null("Props/HouseDale") as Node2D
	if house == null:
		house = lane.get_node_or_null("Props/HouseWest") as Node2D
	if player != null and house != null:
		player.global_position = house.global_position + Vector2(48, 36)
	await _shot("maple_house_day")
	DayClock.set_time(4, 18, 0)
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	var lighting := lane.get_node_or_null("Lighting")
	if lighting != null and lighting.has_method("apply"):
		lighting.call("apply")
	if player != null:
		player.global_position = bounds.get_center()
	_fit_camera(camera, bounds)
	await _shot("maple_evening")
	print("CAPTURE_OK prefix=%s" % _prefix)
	get_tree().quit(0)


func _hide_hud(room: Node) -> void:
	var hud := room.get_node_or_null("HUD") as CanvasItem
	if hud != null:
		hud.visible = false


func _fit_camera(camera: Camera2D, bounds: Rect2) -> void:
	if camera == null:
		return
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	var zoom_x: float = 640.0 / maxf(bounds.size.x, 1.0)
	var zoom_y: float = 360.0 / maxf(bounds.size.y, 1.0)
	var zoom: float = minf(zoom_x, zoom_y) * 0.96
	camera.zoom = Vector2(zoom, zoom)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var file_name := shot_name if _prefix.is_empty() else "%s%s" % [_prefix, shot_name]
	var path := "%s/%s.png" % [SHOT_DIR, file_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [file_name, err, image.get_width(), image.get_height()])
