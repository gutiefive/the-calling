extends Node
## Saves windowed screenshots under tests/m1/shots. Skips itself when headless.

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/m1/shots"))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	SceneRouter.next_spawn = &"default"
	var exterior := (load("res://scenes/world/church_exterior.tscn") as PackedScene).instantiate()
	add_child(exterior)
	await _shot("exterior_day")
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	exterior.get_node("Lighting").apply()
	await _shot("exterior_evening")
	TimeOfDay.set_phase(TimeOfDay.Phase.NIGHT)
	exterior.get_node("Lighting").apply()
	await _shot("exterior_night")
	var player := exterior.get_node("Props/Player") as Node2D
	var tree := exterior.get_node("Props/Tree1") as Node2D
	player.global_position = tree.global_position + Vector2(0, -28)
	await _shot("behind_tree")
	player.global_position = tree.global_position + Vector2(0, 36)
	await _shot("in_front_of_tree")
	exterior.free()
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	SceneRouter.next_spawn = &"from_exterior"
	var interior := (load("res://scenes/world/sanctuary.tscn") as PackedScene).instantiate()
	add_child(interior)
	await _shot("sanctuary_day")
	TimeOfDay.set_phase(TimeOfDay.Phase.NIGHT)
	interior.get_node("Lighting").apply()
	await _shot("sanctuary_night")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "res://tests/m1/shots/%s.png" % shot_name
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
