extends Node
## Windowed shots of the denser sanctuary and Fellowship Hall.
## Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/m13b/shots"
const SANCT := "res://scenes/world/sanctuary.tscn"
const HALL := "res://scenes/world/fellowship_hall.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	await _sanct_shot("worship", InteriorLayout.sanctuary_probes()["worship"], "sanctuary_worship")
	await _sanct_shot("narthex", InteriorLayout.sanctuary_probes()["narthex"], "sanctuary_narthex")
	await _sanct_shot("office", InteriorLayout.sanctuary_probes()["office"], "sanctuary_office")
	await _sanct_shot("prayer", InteriorLayout.sanctuary_probes()["prayer"], "sanctuary_prayer")
	await _sanct_shot("choir", InteriorLayout.sanctuary_probes()["choir"], "sanctuary_choir")
	await _sanct_shot("storage", InteriorLayout.sanctuary_probes()["storage"], "sanctuary_storage")
	await _overview(SANCT, "sanctuary_overview", Vector2(736, 640), 0.28)
	await _hall_shot(false, InteriorLayout.hall_probes()["main"], "fellowship_main")
	await _hall_shot(true, InteriorLayout.hall_probes()["main"], "fellowship_potluck")
	await _hall_shot(false, InteriorLayout.hall_probes()["kitchen"], "fellowship_kitchen")
	await _hall_shot(false, InteriorLayout.hall_probes()["classroom"], "fellowship_classroom")
	await _overview(HALL, "fellowship_overview", Vector2(672, 500), 0.34)
	print("CAPTURE_OK")
	get_tree().quit(0)


func _sanct_shot(_room_id: String, pos: Vector2, shot_name: String) -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	SceneRouter.next_spawn = &"from_exterior"
	var room := (load(SANCT) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_place_camera(room, pos, Vector2.ONE)
	await _shot(shot_name)
	room.free()
	await get_tree().process_frame


func _hall_shot(full: bool, pos: Vector2, shot_name: String) -> void:
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
	else:
		DayClock.set_time(8, 14, 0)
	SceneRouter.next_spawn = &"from_grounds"
	var room := (load(HALL) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_place_camera(room, pos, Vector2.ONE)
	await _shot(shot_name)
	room.free()
	await get_tree().process_frame


func _overview(path: String, shot_name: String, pos: Vector2, zoom: float) -> void:
	NarrativeState.reset()
	if path.ends_with("fellowship_hall.tscn"):
		NarrativeState.set_flag("week_continues", true)
		NarrativeState.set_flag("hall_repaired", true)
		NarrativeState.set_flag("hall_celebrated", true)
		DayClock.set_time(8, 14, 0)
	else:
		DayClock.set_time(4, 14, 0)
		NarrativeState.set_flag("sanctuary_flowers_set", true)
	SceneRouter.next_spawn = &"default"
	var room := (load(path) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_place_camera(room, pos, Vector2(zoom, zoom))
	await _shot(shot_name)
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
