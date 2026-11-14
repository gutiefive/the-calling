extends Node
## Windowed shots of the M14 opening. Skips itself when headless. Quits on its own.

const SHOT_DIR := "res://tests/m14/shots"
const INTRO := "res://scenes/intro/intro_cutscene.tscn"
const GROUNDS := "res://scenes/world/church_exterior.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED")
		get_tree().quit(0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	SceneRouter.suppress_change = true
	await _intro_shot("letter_call", "letter")
	await _intro_shot("drive_road", "drive")
	await _intro_shot("church_reveal", "church_reveal")
	await _intro_shot("vignette_margaret", "town_vignette")
	await _intro_shot("closing_hope", "closing")
	await _handoff_shot("goals", "goals_handoff")
	await _handoff_shot("primer", "controls_primer")
	SceneRouter.suppress_change = false
	print("CAPTURE_OK")
	get_tree().quit(0)


func _intro_shot(beat_id: String, shot_name: String) -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.held = true
	SaveGame.pending_opening_handoff = false
	SaveGame.intro_replay = false
	var intro := (load(INTRO) as PackedScene).instantiate()
	add_child(intro)
	await get_tree().process_frame
	await get_tree().process_frame
	if intro.has_method("jump_to_beat"):
		intro.call("jump_to_beat", beat_id)
	await _shot(shot_name)
	intro.free()
	await get_tree().process_frame


func _handoff_shot(phase: String, shot_name: String) -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	SaveGame.pending_opening_handoff = true
	NarrativeState.set_flag("primer_seen", false)
	SceneRouter.next_spawn = &"default"
	var room := (load(GROUNDS) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var handoff := room.get_node_or_null("HUD/OpeningHandoff")
	if handoff != null and phase == "primer" and handoff.has_method("show_primer"):
		handoff.call("show_primer")
		await get_tree().process_frame
	await _shot(shot_name)
	room.free()
	SaveGame.pending_opening_handoff = false
	await get_tree().process_frame


func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, shot_name]
	var err := image.save_png(path)
	print("SHOT %s err=%s %dx%d" % [shot_name, err, image.get_width(), image.get_height()])
