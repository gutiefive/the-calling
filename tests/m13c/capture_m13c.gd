extends Node
## Windowed shots of Fellowship Hall tables on a normal day and at the potluck.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/m13c/shots"
const HALL := "res://scenes/world/fellowship_hall.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	await _hall_shot(false, false, InteriorLayout.hall_probes()["main"], "fellowship_main")
	await _overview()
	await _hall_shot(true, false, InteriorLayout.hall_probes()["main"], "potluck_none")
	await _hall_shot(true, true, InteriorLayout.hall_probes()["main"], "potluck_full")
	print("CAPTURE_OK")
	get_tree().quit(0)


func _hall_shot(live: bool, full: bool, pos: Vector2, shot_name: String) -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	if live:
		DayClock.set_time(10, 12, 0)
	else:
		DayClock.set_time(8, 14, 0)
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
	SceneRouter.next_spawn = &"from_grounds"
	var room := (load(HALL) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_place_camera(room, pos, Vector2.ONE)
	await _shot(shot_name)
	room.free()
	await get_tree().process_frame


func _overview() -> void:
	NarrativeState.reset()
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(8, 14, 0)
	SceneRouter.next_spawn = &"default"
	var room := (load(HALL) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_place_camera(room, Vector2(672, 500), Vector2(0.34, 0.34))
	await _shot("fellowship_overview")
	room.free()
	await get_tree().process_frame


func _place_camera(room: Node, pos: Vector2, zoom: Vector2) -> void:
	var player := room.get_node_or_null("Props/Player") as Node2D
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	if player != null:
		player.global_position = pos
	if camera != null:
		camera.zoom = zoom


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
