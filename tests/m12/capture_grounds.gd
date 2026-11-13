extends Node
## Saves windowed screenshots of the church grounds under tests/m12/shots.
## Skips itself when headless.

const SHOT_DIR := "res://tests/m12/shots"
const GROUNDS := "res://scenes/world/church_exterior.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	DayClock.set_time(4, 14, 0)
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_hide_hud(room)
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	var bounds := Rect2(0, 0, 1152, 832)
	if room is WorldRoom:
		bounds = (room as WorldRoom).bounds
	if camera != null:
		camera.limit_left = int(bounds.position.x)
		camera.limit_top = int(bounds.position.y)
		camera.limit_right = int(bounds.end.x)
		camera.limit_bottom = int(bounds.end.y)
	if player != null:
		player.global_position = bounds.get_center()
	if camera != null:
		var zoom_x: float = 640.0 / maxf(bounds.size.x, 1.0)
		var zoom_y: float = 360.0 / maxf(bounds.size.y, 1.0)
		var zoom: float = minf(zoom_x, zoom_y) * 0.96
		camera.zoom = Vector2(zoom, zoom)
	await _shot("grounds_wide_day")
	if camera != null:
		camera.zoom = Vector2.ONE
	var street_door := room.get_node_or_null("Props/StreetDoor") as Node2D
	if player != null and street_door != null:
		player.global_position = street_door.global_position + Vector2(-80, 0)
	await _shot("grounds_entrance_day")
	var church := room.get_node_or_null("Props/Church") as Node2D
	if player != null and church != null:
		player.global_position = church.global_position + Vector2(0, 96)
	await _shot("grounds_courtyard_day")
	DayClock.set_time(4, 18, 0)
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	var lighting := room.get_node_or_null("Lighting")
	if lighting != null and lighting.has_method("apply"):
		lighting.call("apply")
	if player != null and church != null:
		player.global_position = church.global_position + Vector2(0, 96)
	if camera != null:
		camera.zoom = Vector2.ONE
	await _shot("grounds_evening")
	print("CAPTURE_OK")
	get_tree().quit(0)


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
