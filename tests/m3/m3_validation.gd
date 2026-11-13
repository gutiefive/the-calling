extends Node
## Headless checks for Milestone 3. Prints M3_OK or M3_FAIL.
## Run: godot --headless --path . res://tests/m3/m3_validation.tscn

var _failed: bool = false
var _save_backup: String = ""
var _had_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_had_save = FileAccess.file_exists(SaveGame.SAVE_PATH)
	if _had_save:
		_save_backup = FileAccess.get_file_as_string(SaveGame.SAVE_PATH)
	NarrativeState.reset()
	DayClock.reset()
	_static_checks()
	_relationship_lines()
	await _clock_and_light()
	await _schedules()
	await _town_trip()
	await _save_roundtrip()
	await _story_to_saturday()
	_restore_user_save()
	_finish()


func _static_checks() -> void:
	for path in [
		"res://scenes/world/hardware_street.tscn",
		"res://scripts/systems/day_clock.gd",
		"res://scripts/systems/npc_schedule.gd",
		"res://scripts/systems/save_game.gd",
		"res://data/schedules/week.json",
		"res://data/dialogue/frank.json",
		"res://data/dialogue/thomas.json",
		"res://data/dialogue/sarah.json",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	_check(get_node_or_null("/root/DayClock") != null, "DayClock autoload is present")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 640, "viewport width stays 640")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 360, "viewport height stays 360")
	_check(int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter")) == 0, "nearest filtering stays on")
	_check(InputMap.has_action("cycle_time"), "T is still the debug skip")
	var frank := PlaceholderArt.by_id("frank")
	var hardware := PlaceholderArt.hardware_store()
	_check(frank != null and frank.get_size() == Vector2(64, 48), "frank sheet is 64x48")
	_check(hardware != null and hardware.get_width() % 32 == 0, "hardware store art is on the 32 grid")
	var margaret_thu := NpcSchedule.placement("margaret", "Thursday", 14, 0)
	var sarah_thu := NpcSchedule.placement("sarah", "Thursday", 14, 0)
	_check(str(margaret_thu.get("scene", "")) == "church_exterior", "Margaret's Thursday post is the church grounds")
	_check(sarah_thu.is_empty(), "Sarah has no Thursday afternoon post")
	var kept := SaveGame.migrate({
		"version": 1,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"sunday_ready": true}, "quests": {}, "relationships": {"frank": 1}},
	})
	var migrated_flags: Dictionary = {}
	var narrative_v: Variant = kept.get("narrative", {})
	var rel_ok := false
	if narrative_v is Dictionary:
		var flags_v: Variant = (narrative_v as Dictionary).get("flags", {})
		if flags_v is Dictionary:
			migrated_flags = flags_v
		var rel_v: Variant = (narrative_v as Dictionary).get("relationships", {})
		if rel_v is Dictionary:
			rel_ok = int((rel_v as Dictionary).get("frank", 0)) == 1
	_check(
		int(kept.get("version", 0)) == SaveGame.SAVE_VERSION
		and str(migrated_flags.get("sermon_theme", "missing")) == ""
		and bool(migrated_flags.get("sunday_ready", false))
		and rel_ok,
		"version 1 migrates forward and keeps its story"
	)
	_check(SaveGame.migrate({}).is_empty(), "a save without a version is rejected")
	_check(DayClock.weekday_name() == "Thursday" and DayClock.hour == 14, "the week starts Thursday at 2 p.m.")
	_check(TimeOfDay.phase == TimeOfDay.Phase.DAY, "Thursday afternoon is still day")


func _relationship_lines() -> void:
	NarrativeState.reset()
	DayClock.set_time(6, 18, 0)
	NarrativeState.set_step("oak_street", "saturday")
	NarrativeState.set_relationship("frank", 1)
	var margaret := DialogueRunner.load_conversation("margaret")
	var runner := DialogueRunner.new()
	_check(runner.start(margaret), "Margaret's Saturday line loads")
	var listened := runner.body()
	_check(listened.contains("stayed and talked"), "listening to Frank changes Margaret's Saturday line (%s)" % _snippet(listened))
	NarrativeState.reset()
	DayClock.set_time(6, 18, 0)
	NarrativeState.set_step("oak_street", "saturday")
	runner = DialogueRunner.new()
	_check(runner.start(margaret), "Margaret's other Saturday line loads")
	var closed := runner.body()
	_check(closed.contains("half down"), "skipping Frank's story changes Margaret's Saturday line (%s)" % _snippet(closed))
	_check(listened != closed, "the two Saturday lines differ")
	NarrativeState.reset()
	NarrativeState.set_relationship("frank", 1)
	var frank := DialogueRunner.load_conversation("frank")
	runner = DialogueRunner.new()
	_check(runner.start(frank), "Frank's return line loads")
	var warm := runner.body()
	_check(warm.contains("without a flyer"), "Frank's relationship opens a different line (%s)" % _snippet(warm))
	NarrativeState.reset()
	NarrativeState.set_flag("frank_invited", true)
	runner = DialogueRunner.new()
	_check(runner.start(frank), "Frank's invited line loads")
	var pitched := runner.body()
	_check(pitched.contains("another Sunday pitch"), "inviting Frank changes his later line (%s)" % _snippet(pitched))
	_check(warm != pitched, "Frank's two later lines differ")
	NarrativeState.reset()
	DayClock.reset()


func _clock_and_light() -> void:
	DayClock.set_time(4, 14, 0)
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"default"
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var modulate := room.get_node("Lighting/CanvasModulate") as CanvasModulate
	var lamp := room.get_node("Props/Lamp/Glow") as PointLight2D
	var phase := room.get_node("HUD/PhaseLabel") as Label
	var clock_label := room.get_node("HUD/ClockLabel") as Label
	if modulate == null or lamp == null or phase == null or clock_label == null:
		_check(false, "exterior is missing the light or the clock label")
		room.free()
		return
	var day: Color = modulate.color
	var day_lamp := lamp.energy
	_check(phase.text == "Day", "the phase label still says Day at 2 p.m.")
	_check(clock_label.text.contains("Thursday") and clock_label.text.contains("2:00 PM"), "the HUD shows Thursday 2:00 PM (%s)" % clock_label.text)
	DayClock.set_time(4, 16, 57)
	DayClock.tick(1.0)
	_check(DayClock.hour == 17 and DayClock.minute == 1, "one real second advances four minutes (saw %d:%02d)" % [DayClock.hour, DayClock.minute])
	_check(TimeOfDay.phase == TimeOfDay.Phase.EVENING, "5:00 p.m. is evening")
	_check(modulate.color != day, "the grounds change color when the clock reaches evening")
	_check(phase.text == "Evening", "the phase label follows the clock")
	var evening: Color = modulate.color
	DayClock.skip_ahead()
	_check(DayClock.hour == 20 and TimeOfDay.phase == TimeOfDay.Phase.NIGHT, "skip-ahead from evening lands at night")
	_check(modulate.color != evening, "night looks different from evening")
	_check(lamp.energy > day_lamp, "the lamp brightens when the clock reaches night")
	_check(phase.text == "Night", "the phase label says Night")
	DayClock.skip_ahead()
	_check(DayClock.weekday_name() == "Friday" and DayClock.hour == 6, "night skip-ahead enters Friday morning, not Sunday")
	_check(TimeOfDay.phase == TimeOfDay.Phase.DAY and phase.text == "Day", "Friday morning is day again")
	DayClock.set_time(4, 14, 0)
	await _tap("cycle_time")
	_check(DayClock.hour == 17 and phase.text.contains("(T)"), "T still skips ahead (%s)" % phase.text)
	_check(clock_label.text.contains("5:00 PM"), "T updates the clock label (%s)" % clock_label.text)
	NarrativeState.set_dialogue_open(true)
	_check(not DayClock.is_exploring(), "dialogue holds the clock")
	NarrativeState.set_dialogue_open(false)
	_check(DayClock.is_exploring(), "the clock runs again once dialogue closes")
	get_tree().paused = true
	_check(not DayClock.is_exploring(), "pause holds the clock")
	get_tree().paused = false
	DayClock.set_time(6, 23, 50)
	DayClock.advance_minutes(80)
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 1 and DayClock.minute == 10, "Saturday night continues into Sunday morning")
	DayClock.set_time(0, 10, 0)
	_check(DayClock.weekday_name() == "Sunday" and DayClock.hour == 10 and DayClock.minute == 0, "a Sunday time stays on Sunday morning")
	DayClock.reset()
	room.free()


func _schedules() -> void:
	DayClock.set_time(4, 14, 0)
	var church := _instance("res://scenes/world/church_exterior.tscn")
	var sanctuary := _instance("res://scenes/world/sanctuary.tscn")
	if church == null or sanctuary == null:
		return
	var margaret: Node2D = church.get_node("Props/Margaret")
	var harold_out: Node2D = church.get_node("Props/Harold")
	var harold_in: Node2D = sanctuary.get_node("Props/Harold")
	var margaret_in: Node2D = sanctuary.get_node("Props/Margaret")
	_check(_present(margaret, "margaret", "Thursday", 14, 0), "Margaret is on the grounds Thursday afternoon")
	_check(not harold_out.visible, "Harold is absent from the grounds on Thursday")
	_check(_present(harold_in, "harold", "Thursday", 14, 0), "Harold is in the sanctuary Thursday afternoon")
	_check(not margaret_in.visible, "Margaret is absent from the sanctuary on Thursday afternoon")
	church.free()
	sanctuary.free()

	DayClock.set_time(5, 10, 0)
	var street := _instance("res://scenes/world/hardware_street.tscn")
	church = _instance("res://scenes/world/church_exterior.tscn")
	var store := _instance("res://scenes/world/hardware_interior.tscn")
	var bay := _instance("res://scenes/world/bay_interior.tscn")
	if street == null or church == null or store == null or bay == null:
		return
	var sarah: Node2D = street.get_node("Props/Sarah")
	var thomas_out: Node2D = street.get_node("Props/Thomas")
	var frank_out: Node2D = street.get_node("Props/Frank")
	_check(_present(sarah, "sarah", "Friday", 10, 0), "Sarah is on Oak Street Friday morning")
	_check(not thomas_out.visible and not frank_out.visible, "Thomas and Frank are not also on the sidewalk during shop hours")
	_check(_present(store.get_node("Props/Thomas"), "thomas", "Friday", 10, 0), "Thomas keeps Friday store hours behind the counter")
	_check(_present(bay.get_node("Props/Frank"), "frank", "Friday", 10, 0), "Frank is in the bay Friday morning")
	_check(_present(church.get_node("Props/Harold"), "harold", "Friday", 10, 0), "Harold is on the grounds Friday morning")
	street.free()
	church.free()
	store.free()
	bay.free()

	DayClock.set_time(5, 14, 0)
	sanctuary = _instance("res://scenes/world/sanctuary.tscn")
	church = _instance("res://scenes/world/church_exterior.tscn")
	street = _instance("res://scenes/world/hardware_street.tscn")
	if sanctuary == null or church == null or street == null:
		return
	_check(_present(sanctuary.get_node("Props/Margaret"), "margaret", "Friday", 14, 0), "Margaret moves to the sanctuary Friday afternoon")
	_check(not (church.get_node("Props/Margaret") as CanvasItem).visible, "Margaret leaves the grounds Friday afternoon")
	_check(not (street.get_node("Props/Sarah") as CanvasItem).visible, "Sarah is gone from Oak Street by Friday afternoon")
	sanctuary.free()
	church.free()
	street.free()

	DayClock.set_time(6, 18, 0)
	church = _instance("res://scenes/world/church_exterior.tscn")
	street = _instance("res://scenes/world/hardware_street.tscn")
	if church == null or street == null:
		return
	_check(_present(church.get_node("Props/Margaret"), "margaret", "Saturday", 18, 0), "Margaret is on the walk Saturday evening")
	_check(_present(church.get_node("Props/Harold"), "harold", "Saturday", 18, 0), "Harold is on the walk Saturday evening")
	_check(not (street.get_node("Props/Thomas") as CanvasItem).visible, "the hardware store is empty Saturday evening")
	_check(not (street.get_node("Props/Frank") as CanvasItem).visible, "Frank is absent Saturday evening")
	_check(not (street.get_node("Props/Sarah") as CanvasItem).visible, "Sarah is absent Saturday evening")
	var tiles := street.get_node("Ground") as TileMapLayer
	_check(tiles != null and tiles.tile_set != null and tiles.tile_set.tile_size == Vector2i(32, 32), "Oak Street uses 32x32 tiles")
	church.free()
	street.free()
	DayClock.reset()


func _town_trip() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := await _travel_to("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var door := room.get_node("Props/StreetDoor") as Door
	if player == null or door == null:
		_check(false, "the grounds are missing the Oak Street exit")
		return
	await _stand_at(player, door)
	await _tap("interact")
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var arrived := room.get_node("Spawns/from_church") as Node2D
	_check(player != null and arrived != null and player.global_position.distance_to(arrived.global_position) < 2.0, "Oak Street spawn is the church gate")
	_check(player != null and player.get_facing() == &"right", "arriving on Oak Street faces into the street")
	var back := room.get_node("Props/ToChurch") as Door
	if player == null or back == null:
		_check(false, "Oak Street is missing the return")
		return
	await _stand_at(player, back)
	await _tap("interact")
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var home := room.get_node("Spawns/from_street") as Node2D
	_check(player != null and home != null and player.global_position.distance_to(home.global_position) < 2.0, "the return spawn is on the church lot")
	_check(player != null and player.get_facing() == &"left", "returning from Oak Street faces back onto the grounds")


func _save_roundtrip() -> void:
	var room := get_tree().current_scene
	if room == null or String(room.name) != "ChurchExterior":
		room = await _travel_to("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	NarrativeState.reset()
	DayClock.set_time(5, 11, 15)
	NarrativeState.set_flag("frank_listened", true)
	NarrativeState.set_relationship("frank", 1)
	NarrativeState.set_relationship("sarah", 2)
	NarrativeState.set_step("oak_street", "friday")
	var player := room.get_node("Props/Player") as Player
	if player == null:
		_check(false, "save test is missing the player")
		return
	player.global_position = Vector2(420, 510)
	player.velocity = Vector2.ZERO
	player.set_facing(&"up")
	var pause := room.get_node("HUD/Pause")
	pause.toggle_pause()
	_check(get_tree().paused and pause.visible, "pause opens for save")
	await _tap("dialogue_down")
	await _tap("interact")
	var hint := room.get_node("HUD/Pause/Center/Hint") as Label
	_check(hint != null and hint.text == "Saved.", "the pause menu saves (%s)" % (hint.text if hint != null else ""))
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary and int((parsed as Dictionary).get("version", -1)) == SaveGame.SAVE_VERSION, "the save file is the current version")
	pause.toggle_pause()
	_check(not get_tree().paused, "pause closes after save")

	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	NarrativeState.set_flag("keys_approach", "search")
	room = await _travel_to("res://scenes/world/sanctuary.tscn", &"from_exterior")
	if room == null:
		return
	_check(NarrativeState.flag_equals("keys_approach", "search"), "state was changed after the save")
	_check(DayClock.weekday_name() == "Thursday", "the clock was changed after the save")
	pause = room.get_node("HUD/Pause")
	pause.toggle_pause()
	await _tap("dialogue_down")
	await _tap("dialogue_down")
	await _tap("interact")
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	_check(not get_tree().paused, "load resumes the game")
	player = room.get_node("Props/Player") as Player
	_check(player != null and player.global_position.distance_to(Vector2(420, 510)) < 2.0, "load restores the player position (%s)" % (player.global_position if player != null else Vector2.ZERO))
	_check(player != null and player.get_facing() == &"up", "load restores facing")
	_check(NarrativeState.flag_is_true("frank_listened"), "load restores the narrative flag")
	_check(not NarrativeState.flag_equals("keys_approach", "search"), "load replaces flags written after the save")
	_check(NarrativeState.relationship("frank") == 1 and NarrativeState.relationship("sarah") == 2, "load restores relationship values")
	_check(NarrativeState.quest_step("oak_street") == "friday", "load restores the quest")
	_check(DayClock.weekday_name() == "Friday" and DayClock.hour == 11 and DayClock.minute == 15, "load restores the clock")
	var clock_label := room.get_node("HUD/ClockLabel") as Label
	_check(clock_label != null and clock_label.text.contains("Friday") and clock_label.text.contains("11:15 AM"), "the restored clock is on the HUD (%s)" % (clock_label.text if clock_label != null else ""))


func _story_to_saturday() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := await _travel_to("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var margaret := room.get_node("Props/Margaret") as Node2D
	var box := room.get_node("HUD/Banner") as DialogueBox
	var label := room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "the story is missing Margaret")
		return
	_check(margaret.visible, "Margaret is here for the spare-key quest")
	await _stand_at(player, margaret)
	await _tap("interact")
	await _tap("advance_dialogue")
	await _tap("interact")
	await _tap("advance_dialogue")
	_check(label.text.contains("look around first"), "the spare-key choice is still offered")
	await _tap("dialogue_down")
	await _tap("interact")
	_check(NarrativeState.quest_step("spare_keys") == "search", "the story still starts with the spare keys")
	await _tap("advance_dialogue")
	await _tap("interact")
	_check(not box.is_conversation_open(), "Margaret's search line closes")

	room = await _travel_to("res://scenes/world/sanctuary.tscn", &"from_exterior")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var keys := room.get_node("Props/KeyRing") as Node2D
	if player == null or keys == null:
		_check(false, "the sanctuary is missing the key ring")
		return
	await _stand_at(player, keys)
	await _tap("interact")
	_check(NarrativeState.flag_is_true("has_spare_keys"), "the spare key ring is still the pickup")

	room = await _travel_to("res://scenes/world/church_exterior.tscn", &"from_sanctuary")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	margaret = room.get_node("Props/Margaret") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or box == null or label == null:
		_check(false, "Margaret is missing for the return")
		return
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(NarrativeState.quest_status("spare_keys") == "completed", "returning the ring completes the key quest")
	await _tap("advance_dialogue")
	await _tap("interact")
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(NarrativeState.quest_step("oak_street") == "hardware", "Margaret sends the story to Oak Street")
	await _tap("advance_dialogue")
	_check(label.text.contains("Oak Street"), "she names the hardware store (%s)" % _snippet(label.text))
	await _tap("interact")

	DayClock.set_time(4, 14, 0)
	room = await _travel_to("res://scenes/world/hardware_street.tscn", &"from_church")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var store_door := room.get_node("Props/StoreDoor") as Node2D
	if player == null or store_door == null:
		_check(false, "Oak Street is missing the store door")
		return
	await _stand_at(player, store_door)
	await _tap("interact")
	room = await _wait_scene("HardwareInterior")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var thomas := room.get_node("Props/Thomas") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or thomas == null or not thomas.visible or box == null or label == null:
		_check(false, "Thomas is not behind the counter Thursday afternoon")
		return
	await _stand_at(player, thomas)
	await _tap("interact")
	_check(NarrativeState.quest_step("oak_street") == "frank", "Thomas points the story at Frank")
	await _tap("advance_dialogue")
	await _tap("interact")
	var out := room.get_node("Props/Door") as Node2D
	if out == null:
		_check(false, "the store is missing its door")
		return
	await _stand_at(player, out)
	await _tap("interact")
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var bay_door := room.get_node("Props/BayDoor") as Node2D
	if player == null or bay_door == null:
		_check(false, "Oak Street is missing the bay door")
		return
	await _stand_at(player, bay_door)
	await _tap("interact")
	room = await _wait_scene("BayInterior")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	var frank := room.get_node("Props/Frank") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or frank == null or not frank.visible or box == null or label == null:
		_check(false, "Frank is not in the bay")
		return
	await _stand_at(player, frank)
	await _tap("interact")
	await _tap("advance_dialogue")
	await _tap("interact")
	_check(NarrativeState.relationship("frank") == 1, "listening raises Frank's relationship")
	_check(NarrativeState.quest_step("oak_street") == "friday", "Frank's conversation advances the week")
	await _tap("advance_dialogue")
	_check(label.text.contains("unheard"), "Frank's own line is the one that plays (%s)" % _snippet(label.text))
	await _tap("interact")
	out = room.get_node("Props/Door") as Node2D
	if player == null or out == null:
		_check(false, "the bay is missing its door")
		return
	await _stand_at(player, out)
	await _tap("interact")
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player

	DayClock.set_time(5, 10, 0)
	await _pump(2)
	var sarah := room.get_node("Props/Sarah") as Node2D
	if sarah == null or not sarah.visible:
		_check(false, "Sarah did not appear Friday morning")
		return
	await _stand_at(player, sarah)
	await _tap("interact")
	await _tap("advance_dialogue")
	await _tap("interact")
	_check(NarrativeState.relationship("sarah") == 1, "asking Sarah what the week needs is recorded")
	_check(NarrativeState.quest_step("oak_street") == "saturday", "Sarah points the story at Saturday")
	await _tap("advance_dialogue")
	await _tap("interact")

	DayClock.set_time(6, 18, 0)
	room = await _travel_to("res://scenes/world/church_exterior.tscn", &"from_street")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	margaret = room.get_node("Props/Margaret") as Node2D
	box = room.get_node("HUD/Banner") as DialogueBox
	label = room.get_node("HUD/Banner/Label") as RichTextLabel
	if player == null or margaret == null or not margaret.visible or box == null or label == null:
		_check(false, "Margaret is not on the walk Saturday evening")
		return
	_check(DayClock.weekday_name() == "Saturday" and DayClock.hour >= 17, "the story reached Saturday evening")
	_check(TimeOfDay.phase == TimeOfDay.Phase.EVENING, "Saturday evening uses the evening light")
	await _stand_at(player, margaret)
	await _tap("interact")
	_check(NarrativeState.quest_status("oak_street") == "completed", "Saturday evening completes the week")
	_check(NarrativeState.flag_is_true("sunday_ready"), "the week sets up Sunday")
	_check(NarrativeState.quest_status("spare_keys") == "completed", "the spare-key quest is still complete")
	await _tap("advance_dialogue")
	_check(label.text.contains("stayed and talked"), "the Saturday line remembers Frank (%s)" % _snippet(label.text))
	_check(label.text.contains("ten o'clock"), "Saturday evening names Sunday (%s)" % _snippet(label.text))
	await _tap("interact")
	_check(not box.is_conversation_open(), "the Saturday line closes")


func _present(node: Node, npc_id: String, day: String, hour: int, minute: int) -> bool:
	if not node is CanvasItem or not (node as CanvasItem).visible:
		return false
	if node is Interactable and not (node as Interactable).enabled:
		return false
	var place := NpcSchedule.placement(npc_id, day, hour, minute)
	if place.is_empty() or not node is Node2D:
		return false
	var pos: Vector2 = place["position"]
	return (node as Node2D).position.distance_to(pos) < 1.0


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"default"
	var packed := load(path) as PackedScene
	if packed == null:
		_check(false, "load " + path)
		return null
	var room := packed.instantiate()
	add_child(room)
	return room


func _become_observer() -> void:
	var tree := get_tree()
	if tree.current_scene != self:
		return
	var host := Node.new()
	host.name = "M3SceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


func _travel_to(path: String, spawn: StringName) -> Node:
	_release_all()
	await _pump(1)
	_become_observer()
	SceneRouter.suppress_change = false
	SceneRouter.travel(get_tree(), path, spawn)
	return await _wait_scene(_scene_name(path))


func _wait_scene(want: String) -> Node:
	for _i in 40:
		await get_tree().process_frame
		var current := get_tree().current_scene
		if current != null and String(current.name) == want:
			await _pump(2)
			return current
	var seen := "none"
	if get_tree().current_scene != null:
		seen = String(get_tree().current_scene.name)
	_check(false, "scene change did not reach %s (saw %s)" % [want, seen])
	return null


func _scene_name(path: String) -> String:
	if path.ends_with("sanctuary.tscn"):
		return "Sanctuary"
	if path.ends_with("hardware_street.tscn"):
		return "HardwareStreet"
	if path.ends_with("hardware_interior.tscn"):
		return "HardwareInterior"
	if path.ends_with("bay_interior.tscn"):
		return "BayInterior"
	return "ChurchExterior"


func _stand_at(player: Player, target: Node2D) -> void:
	_release_all()
	player.velocity = Vector2.ZERO
	player.global_position = target.global_position + Vector2(0, 26)
	player.clear_interact_lock()
	await _pump(2)


func _tap(action: String) -> void:
	_release_all()
	await _pump(2)
	Input.action_press(action)
	await _pump(2)
	Input.action_release(action)
	await _pump(2)


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _release_all() -> void:
	for action in [
		"move_up", "move_down", "move_left", "move_right",
		"interact", "pause", "cycle_time",
		"journal", "advance_dialogue", "dialogue_up", "dialogue_down",
	]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _snippet(text: String) -> String:
	var flat := text.replace("\n", " | ")
	if flat.length() > 160:
		return flat.substr(0, 160)
	return flat


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	_release_all()
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	print("M3_OK" if not _failed else "M3_FAIL")
	tree.quit(0 if not _failed else 1)
