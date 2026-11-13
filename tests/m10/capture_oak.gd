extends Node
## Saves windowed screenshots of Oak Street under tests/m10/shots. Skips itself when headless.

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/m10/shots"))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	SceneRouter.next_spawn = &"from_church"
	var street := (load("res://scenes/world/hardware_street.tscn") as PackedScene).instantiate()
	add_child(street)
	await get_tree().process_frame
	await get_tree().process_frame
	var hud := street.get_node_or_null("HUD") as CanvasItem
	if hud != null:
		hud.visible = false
	var player := street.get_node_or_null("Props/Player") as Node2D
	var camera := street.get_node_or_null("Props/Player/Camera2D") as Camera2D
	var bounds := Rect2(0, 0, 2048, 1280)
	if street is WorldRoom:
		bounds = (street as WorldRoom).bounds
	var hardware := street.get_node_or_null("Props/Hardware") as Node2D
	var garage := street.get_node_or_null("Props/Garage") as Node2D
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
	await _shot("oak_wide_day")
	if camera != null:
		camera.zoom = Vector2.ONE
	if player != null and hardware != null:
		player.global_position = hardware.global_position + Vector2(0, 48)
	await _shot("oak_store_day")
	if player != null and garage != null:
		player.global_position = garage.global_position + Vector2(0, 48)
	await _shot("oak_bay_day")
	DayClock.set_time(4, 18, 0)
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	var lighting := street.get_node_or_null("Lighting")
	if lighting != null and lighting.has_method("apply"):
		lighting.call("apply")
	if player != null:
		player.global_position = bounds.get_center()
	if camera != null:
		var zoom_x2: float = 640.0 / maxf(bounds.size.x, 1.0)
		var zoom_y2: float = 360.0 / maxf(bounds.size.y, 1.0)
		var zoom2: float = minf(zoom_x2, zoom_y2) * 0.96
		camera.zoom = Vector2(zoom2, zoom2)
	await _shot("oak_evening")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "res://tests/m10/shots/%s.png" % shot_name
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
