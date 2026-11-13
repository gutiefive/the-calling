extends Node
## Headless checks for Milestone 5A. Prints M5A_OK or M5A_FAIL.
## Run: godot --headless --path . res://tests/m5a/m5a_validation.tscn

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
	_growth_and_frank()
	await _grounds_and_journal()
	await _sleep()
	await _garden()
	await _chapter_without_tasks()
	await _town_and_shops()
	await _save_roundtrip()
	_restore_user_save()
	_finish()


func _static_checks() -> void:
	for path in [
		"res://scenes/world/parsonage.tscn",
		"res://scenes/world/maple_lane.tscn",
		"res://scenes/world/hardware_interior.tscn",
		"res://scenes/world/bay_interior.tscn",
		"res://data/dialogue/garden_help.json",
		"res://scripts/ui/day_card.gd",
		"res://scripts/interactions/scheduled_door.gd",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	_check(InputMap.has_action("cycle_time"), "T is still the debug skip")
	_check(InputMap.has_action("town_map") and InputMap.has_action("journal"), "map and journal keys stay")
	var house := PlaceholderArt.parsonage()
	var plot := PlaceholderArt.garden_plot(0)
	var bed := PlaceholderArt.bed()
	_check(house != null and house.get_width() % 32 == 0, "parsonage art is on the 32 grid")
	_check(plot != null and plot.get_width() == 64, "garden plot is a 64px prop")
	_check(bed != null and bed.get_height() == 64, "bed art is readable")
	var sarah := NpcSchedule.placement("sarah", "Friday", 14, 0)
	var thomas := NpcSchedule.placement("thomas", "Saturday", 16, 0)
	var dale := NpcSchedule.placement("dale", "Friday", 10, 0)
	var ruth := NpcSchedule.placement("ruth", "Saturday", 11, 0)
	_check(str(sarah.get("scene", "")) == "maple_lane", "Sarah has a Maple Lane hour")
	_check(str(thomas.get("scene", "")) == "maple_lane", "Thomas has a Maple Lane hour")
	_check(str(dale.get("scene", "")) == "maple_lane" and str(ruth.get("scene", "")) == "maple_lane", "two neighbors are scheduled on Maple Lane")
	var street_sarah := NpcSchedule.placement("sarah", "Friday", 10, 0)
	_check(str(street_sarah.get("scene", "")) == "hardware_street", "Sarah still keeps Friday morning on Oak Street")
	DayClock.set_time(5, 10, 0)
	_check(ShopHours.is_open("thomas") and ShopHours.is_open("frank"), "store and bay are open Friday morning")
	_check(ShopHours.closed_line("frank").contains("Closed") and ShopHours.closed_line("frank").contains("8"), "the bay's closed line names 8")
	DayClock.set_time(4, 21, 0)
	_check(not ShopHours.is_open("thomas") and not ShopHours.is_open("frank"), "both shops are shut Thursday night")
	DayClock.reset()


func _growth_and_frank() -> void:
	NarrativeState.reset()
	_check(NarrativeState.growth_word("congregation_health") == "Strained", "a new week starts Strained")
	_check(NarrativeState.growth_word("attendance") == "a small gathering", "attendance is a phrase, not a number")
	var service := DialogueRunner.load_conversation("sunday_service")
	var runner := DialogueRunner.new()
	_check(runner.start(service), "the service still loads")
	runner.advance()
	runner.advance()
	runner.advance()
	_check(runner.choice_count() == 3, "the sermon still offers three themes")
	runner.choose(0)
	_check(NarrativeState.growth_value("congregation_health") == 1, "hope moves congregation health")
	_check(NarrativeState.growth_word("congregation_health") == "Steady", "one step reads as Steady")
	_check(NarrativeState.relationship("sarah") == 1 and NarrativeState.relationship("frank") == 0, "hope still moves Sarah, not Frank")
	NarrativeState.add_growth("congregation_health", 1)
	_check(NarrativeState.growth_word("congregation_health") == "Growing", "two steps read as Growing")
	var joined := " ".join(NarrativeState.growth_lines())
	_check(joined.contains("Growing") and joined.contains("a small gathering") and not joined.contains("17"), "the journal words hide the raw numbers (%s)" % joined)

	NarrativeState.reset()
	DayClock.set_time(5, 9, 0)
	NarrativeState.set_flag("frank_listened", true)
	NarrativeState.set_relationship("frank", 1)
	var frank := DialogueRunner.load_conversation("frank")
	runner = DialogueRunner.new()
	_check(runner.start(frank), "Friday morning at the bay loads")
	_check(runner.body().contains("quieter"), "Friday morning asks you to come back (%s)" % _snippet(runner.body()))
	_check(NarrativeState.flag_is_true("frank_arc_wait"), "the morning visit is remembered")
	_check(NarrativeState.relationship("frank") == 1, "waiting does not raise Frank")
	DayClock.set_time(6, 10, 0)
	runner = DialogueRunner.new()
	_check(runner.start(frank), "Saturday at the bay continues")
	_check(runner.choice_count() == 2, "the second visit offers listen or press")
	runner.choose(0)
	_check(NarrativeState.flag_is_true("frank_arc_heard"), "listening learns why he stopped")
	_check(runner.body().contains("hospital"), "he names the hospital week (%s)" % _snippet(runner.body()))
	_check(NarrativeState.relationship("frank") == 2, "listening raises Frank")
	_check(NarrativeState.growth_value("community_trust") >= 1, "listening moves community trust")
	var heard := _line_for("frank_sunday", {"frank_arc_heard": true, "sermon_theme": "hope", "frank_listened": true})
	var old := _line_for("frank_sunday", {"sermon_theme": "forgiveness", "frank_listened": true})
	_check(heard.contains("let me finish") and old.contains("did not say his name") and heard != old, "the arc changes Sunday and the old line remains")

	NarrativeState.reset()
	DayClock.set_time(5, 9, 0)
	NarrativeState.set_flag("frank_listened", true)
	NarrativeState.set_relationship("frank", 1)
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("frank"))
	DayClock.set_time(6, 10, 0)
	runner = DialogueRunner.new()
	runner.start(DialogueRunner.load_conversation("frank"))
	runner.choose(1)
	_check(NarrativeState.flag_is_true("frank_arc_pushed") and not NarrativeState.flag_is_true("frank_arc_heard"), "pressing him does not count as listening")
	_check(NarrativeState.relationship("frank") == 1, "pressing him does not raise the relationship")
	var pushed := _line_for("frank_sunday", {"frank_arc_pushed": true, "frank_listened": true, "sermon_theme": "hope"})
	_check(pushed.contains("Don't spend it") and pushed != heard, "pressing him changes the Sunday line")
	DayClock.reset()


func _grounds_and_journal() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 14, 0)
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var flowers := room.get_node_or_null("Props/Flowers") as Sprite2D
	var before := flowers.texture if flowers != null else null
	_check(before == PlaceholderArt.overgrown_bed(), "the flower bed starts overgrown")
	for chore_name in ["LitterA", "LitterB", "FlowerBed"]:
		var chore := room.get_node_or_null("Props/" + chore_name) as Node2D
		if player == null or chore == null:
			_check(false, "missing grounds chore " + chore_name)
			continue
		await _stand_at(player, chore)
		await _tap("interact")
	_check(NarrativeState.flag_is_true("grounds_tidy"), "clearing the grounds finishes the work")
	_check(NarrativeState.growth_word("facility_condition") == "Steady", "the grounds move the building")
	var litter := room.get_node_or_null("Props/LitterA") as CanvasItem
	_check(litter != null and not litter.visible, "picked-up litter is gone")
	_check(flowers != null and flowers.texture == PlaceholderArt.flowers(), "the bed looks tended")
	var home := room.get_node_or_null("Props/HomeDoor") as Door
	_check(home != null and home.destination_scene.ends_with("parsonage.tscn"), "the parsonage door is on the grounds")
	var tidy := _line_for("thomas", {"grounds_tidy": true})
	_check(tidy.contains("walk looks better"), "Thomas notices the grounds (%s)" % _snippet(tidy))
	var journal := room.get_node_or_null("HUD/Journal/Body") as Label
	await _tap("journal")
	var page := journal.text if journal != null else ""
	_check(page.contains("The church") and page.contains("Steady") and page.contains("a small gathering"), "the journal shows soft church words (%s)" % _snippet(page))
	_check(not page.contains("Congregation: 1") and not page.contains("17"), "the journal does not print the numbers")
	await _tap("journal")
	room.free()
	await _pump(1)


func _sleep() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 15, 30)
	var room := _instance("res://scenes/world/parsonage.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var bed := room.get_node_or_null("Props/Bed") as Node2D
	var card := room.get_node_or_null("HUD/DayCard") as DayCard
	if player == null or bed == null or card == null:
		_check(false, "the parsonage is missing the bed or the day card")
		room.free()
		return
	_check(room.get_node_or_null("HUD/LocationBanner") != null, "the parsonage has a location banner")
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.text == "Parsonage", "the banner names the parsonage")
	await _stand_at(player, bed)
	await _tap("interact")
	var guard := 0
	while not card.is_card_visible() and guard < 180:
		await _pump(1)
		guard += 1
	_check(card.is_card_visible(), "sleeping shows the morning card")
	_check(DayClock.weekday_name() == "Friday" and DayClock.hour == 6 and DayClock.minute == 0, "sleep lands on the next morning (%s %d:%02d)" % [DayClock.weekday_name(), DayClock.hour, DayClock.minute])
	var text := card.card_text()
	_check(text.contains("Friday") and text.contains("church walk") and text.contains("community garden"), "the card names the day and a few optional ideas (%s)" % _snippet(text))
	_check(not text.contains("must") and not text.contains("quest"), "the card does not assign a task")
	_check(NarrativeState.movement_locked(), "the card holds the player")
	await _tap("interact")
	_check(not card.is_card_visible() and not NarrativeState.day_card_open, "the card closes")
	var before := DayClock.hour
	DayClock.skip_ahead()
	_check(DayClock.hour != before and InputMap.has_action("cycle_time"), "T still skips after sleep")
	room.free()
	await _pump(1)
	DayClock.reset()


func _garden() -> void:
	NarrativeState.reset()
	DayClock.set_time(5, 14, 0)
	var room := _instance("res://scenes/world/maple_lane.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	var plot := room.get_node_or_null("Props/Garden") as GardenPlot
	var helper := room.get_node_or_null("Props/GardenNeighbor") as Node2D
	_check(plot != null and plot.shown_stage == 0, "the garden starts overgrown")
	_check(_visible_count(room, "ambient_townsfolk") == 2, "two neighbors are out on Maple Lane")
	var sarah := room.get_node_or_null("Props/Sarah") as CanvasItem
	_check(sarah != null and sarah.visible, "Sarah is on Maple Lane Friday afternoon")
	if player != null and plot != null:
		await _stand_at(player, plot)
		await _tap("interact")
	_check(NarrativeState.flag_is_true("garden_cleared") and plot != null and plot.shown_stage == 1, "clearing the weeds changes the plot")
	if player != null and helper != null:
		await _stand_at(player, helper)
		var guard := 0
		while not NarrativeState.flag_is_true("garden_planted") and guard < 6:
			await _tap("interact")
			guard += 1
	_check(NarrativeState.flag_is_true("garden_planted"), "a neighbor helps plant the garden")
	_check(NarrativeState.growth_value("community_impact") >= 1, "planting moves community impact")
	_check(plot != null and plot.shown_stage == 2, "the planted plot shows seed")
	var ruth := room.get_node_or_null("Props/NeighborRuth") as AmbientTownsfolk
	_check(ruth != null and ruth.bark_text().contains("in the ground"), "a neighbor mentions the garden")
	var note := _line_for("thomas", {"garden_planted": true})
	_check(note.contains("garden on Maple Lane"), "Thomas mentions the garden (%s)" % _snippet(note))
	DayClock.set_time(6, 8, 0)
	await _pump(2)
	_check(plot != null and plot.shown_stage >= 3, "the garden grows on a later morning (%d)" % (plot.shown_stage if plot != null else -1))
	var lane_map := room.get_node_or_null("HUD/TownMap") as TownMap
	if lane_map != null:
		lane_map.open()
		_check(lane_map.place_names().has("Maple Lane"), "the map includes Maple Lane")
		_check(lane_map.marker_region() == "maple", "the map marks the player on Maple Lane")
		lane_map.close()
	room.free()
	await _pump(1)


func _town_and_shops() -> void:
	NarrativeState.reset()
	DayClock.set_time(4, 21, 0)
	var room := await _enter("res://scenes/world/hardware_street.tscn", &"from_church")
	if room == null:
		return
	var gate := room.get_node_or_null("Props/MapleGate") as SpeechProp
	_check(gate != null and gate.line.contains("bridge") and not gate.blocks_movement, "the bridge sign explains that it is open")
	var player := room.get_node_or_null("Props/Player") as Player
	var store := room.get_node_or_null("Props/StoreDoor") as Node2D
	var bay := room.get_node_or_null("Props/BayDoor") as Node2D
	if player == null or store == null or bay == null:
		_check(false, "Oak Street is missing the shop doors")
		return
	await _walk_into(player, store)
	_check(String(get_tree().current_scene.name) == "HardwareStreet", "a shut store does not change rooms")
	var label := room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
	var shut := label.text if label != null else ""
	_check(shut.contains("Closed") and shut.contains("Back at"), "the shut store says when it opens (%s)" % _snippet(shut))
	await _walk_into(player, bay)
	_check(String(get_tree().current_scene.name) == "HardwareStreet", "a shut bay does not change rooms")
	label = room.get_node_or_null("HUD/Banner/Label") as RichTextLabel
	shut = label.text if label != null else ""
	_check(shut.contains("Closed") and shut.contains("8"), "the shut bay names 8 (%s)" % _snippet(shut))

	DayClock.set_time(5, 10, 0)
	await _pump(2)
	player = room.get_node_or_null("Props/Player") as Player
	store = room.get_node_or_null("Props/StoreDoor") as Node2D
	if player != null and store != null:
		await _walk_into(player, store)
	room = await _wait_scene("HardwareInterior")
	if room == null:
		return
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.text == "Hardware store", "the store banner names the shop")
	var thomas := room.get_node_or_null("Props/Thomas") as CanvasItem
	var screws := room.get_node_or_null("Props/Screws") as SpeechProp
	_check(thomas != null and thomas.visible, "Thomas is behind the counter during hours")
	_check(screws != null and screws.line.contains("Number eight"), "a shelf has flavor text")
	player = room.get_node_or_null("Props/Player") as Player
	var out := room.get_node_or_null("Props/Door") as Node2D
	if player != null and out != null:
		await _walk_into(player, out)
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	bay = room.get_node_or_null("Props/BayDoor") as Node2D
	if player != null and bay != null:
		await _walk_into(player, bay)
	room = await _wait_scene("BayInterior")
	if room == null:
		return
	var frank := room.get_node_or_null("Props/Frank") as CanvasItem
	var tools := room.get_node_or_null("Props/Tools") as SpeechProp
	_check(frank != null and frank.visible, "Frank is working in the bay during hours")
	_check(tools != null and tools.line.contains("wrench"), "the bay has tools you can look at")
	player = room.get_node_or_null("Props/Player") as Player
	out = room.get_node_or_null("Props/Door") as Node2D
	if player != null and out != null:
		await _walk_into(player, out)
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	var lane := room.get_node_or_null("Props/MapleDoor") as Node2D
	if player != null and lane != null:
		await _walk_into(player, lane)
	room = await _wait_scene("MapleLane")
	if room == null:
		return
	banner = room.get_node_or_null("HUD/LocationBanner") as Label
	_check(banner != null and banner.text == "Maple Lane", "arriving shows the Maple Lane banner")
	player = room.get_node_or_null("Props/Player") as Player
	var arrived := room.get_node_or_null("Spawns/from_oak") as Node2D
	_check(player != null and arrived != null and player.global_position.distance_to(arrived.global_position) < 2.0, "Maple Lane spawn is inside the lane")
	var back := room.get_node_or_null("Props/ToOak") as Node2D
	if player != null and back != null:
		await _walk_into(player, back)
	room = await _wait_scene("HardwareStreet")
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Player
	var home := room.get_node_or_null("Spawns/from_maple") as Node2D
	_check(player != null and home != null and player.global_position.distance_to(home.global_position) < 2.0, "the lane returns to Oak Street")


func _chapter_without_tasks() -> void:
	NarrativeState.reset()
	DayClock.set_time(0, 11, 0)
	_check(not NarrativeState.flag_is_true("grounds_tidy"), "the chapter check starts with the grounds untouched")
	_check(not NarrativeState.flag_is_true("garden_planted"), "the chapter check starts with the garden untouched")
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("sermon_theme", "hope")
	NarrativeState.set_flag("margaret_sunday", true)
	var room := _instance("res://scenes/world/sanctuary.tscn")
	if room == null:
		return
	await _pump(3)
	var ledger := room.get_node_or_null("Props/Ledger") as CanvasItem
	_check(ledger != null and ledger.visible, "the ledger is available without the new tasks")
	var box := room.get_node_or_null("HUD/Banner") as DialogueBox
	var player := room.get_node_or_null("Props/Player") as Player
	if box == null or player == null:
		_check(false, "the sanctuary is missing the dialogue box")
		room.free()
		return
	_check(box.open_conversation("sunday_ledger", player), "the ledger conversation opens")
	var guard := 0
	while box.is_conversation_open() and guard < 12:
		await _tap("advance_dialogue")
		guard += 1
	_check(NarrativeState.flag_is_true("ledger_revealed"), "the ledger still ends the chapter")
	await _pump(2)
	var ending := room.get_node_or_null("ChapterEnd")
	_check(ending != null and ending.has_method("is_showing") and bool(ending.call("is_showing")), "the chapter ending still appears")
	_check(not NarrativeState.flag_is_true("grounds_tidy") and not NarrativeState.flag_is_true("garden_planted"), "the grounds and the garden are not required")
	room.free()
	await _pump(1)


func _save_roundtrip() -> void:
	NarrativeState.reset()
	DayClock.set_time(5, 9, 20)
	NarrativeState.add_growth("community_trust", 2)
	NarrativeState.set_flag("garden_planted", true)
	NarrativeState.set_flag("grounds_tidy", true)
	var room := await _enter("res://scenes/world/church_exterior.tscn", &"default")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	if player == null:
		_check(false, "save test is missing the player")
		room.free()
		return
	player.global_position = Vector2(420, 510)
	player.velocity = Vector2.ZERO
	player.set_facing(&"up")
	var pause := room.get_node("HUD/Pause")
	pause.toggle_pause()
	await _tap("dialogue_down")
	await _tap("interact")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	_check(parsed is Dictionary and int((parsed as Dictionary).get("version", -1)) == SaveGame.SAVE_VERSION, "the save file is the current version")
	pause.toggle_pause()
	NarrativeState.reset()
	DayClock.reset()
	_check(NarrativeState.growth_value("community_trust") == 0, "state was cleared after the save")
	pause.toggle_pause()
	await _tap("dialogue_down")
	await _tap("dialogue_down")
	await _tap("interact")
	room = await _wait_scene("ChurchExterior")
	if room == null:
		return
	_check(NarrativeState.growth_value("community_trust") == 2, "load restores church growth")
	_check(NarrativeState.growth_word("community_trust") == "Growing", "the restored measure still maps to a word")
	_check(NarrativeState.flag_is_true("garden_planted") and NarrativeState.flag_is_true("grounds_tidy"), "load restores the optional work")
	_check(DayClock.weekday_name() == "Friday" and DayClock.hour == 9 and DayClock.minute == 20, "load restores the clock")
	var old := SaveGame.migrate({
		"version": 2,
		"scene": "res://scenes/world/church_exterior.tscn",
		"position": [420, 510],
		"facing": "down",
		"clock": {"weekday": 4, "hour": 14, "minute": 0},
		"narrative": {
			"version": 1,
			"flags": {"frank_listened": true},
			"quests": {},
			"relationships": {"frank": 1},
			"notes": ["A note from the week."],
		},
	})
	var narrative: Dictionary = {}
	var narrative_v: Variant = old.get("narrative", {})
	if narrative_v is Dictionary:
		narrative = narrative_v
	var growth: Dictionary = {}
	var growth_v: Variant = narrative.get("growth", {})
	if growth_v is Dictionary:
		growth = growth_v
	var flags: Dictionary = {}
	var flags_v: Variant = narrative.get("flags", {})
	if flags_v is Dictionary:
		flags = flags_v
	_check(int(old.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 2 file migrates to the current save")
	_check(int(growth.get("community_trust", -1)) == 0 and int(growth.get("attendance", 0)) == 17, "migration adds the measures without inventing progress")
	_check(bool(flags.get("frank_listened", false)) and str(narrative.get("notes", [])).contains("A note"), "migration keeps the old story")
	_check(SaveGame.migrate({"version": SaveGame.SAVE_VERSION + 1, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	var from_v1 := SaveGame.migrate({
		"version": 1,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {"flags": {"sunday_ready": true}, "quests": {}, "relationships": {"sarah": 2}},
	})
	_check(int(from_v1.get("version", 0)) == SaveGame.SAVE_VERSION, "a version 1 file still migrates forward")


func _line_for(conversation_id: String, flags: Dictionary) -> String:
	var story := NarrativeState.to_dictionary()
	var clock := DayClock.to_dictionary()
	NarrativeState.reset()
	for key in flags.keys():
		NarrativeState.set_flag(str(key), flags[key])
	var data := DialogueRunner.load_conversation(conversation_id)
	var runner := DialogueRunner.new()
	var text := ""
	if runner.start(data):
		text = runner.body()
	NarrativeState.from_dictionary(story)
	DayClock.from_dictionary(clock)
	return text


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
	host.name = "M5ASceneHost"
	tree.root.add_child(host)
	tree.current_scene = host


func _enter(path: String, spawn: StringName) -> Node:
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
	if path.ends_with("maple_lane.tscn"):
		return "MapleLane"
	if path.ends_with("hardware_interior.tscn"):
		return "HardwareInterior"
	if path.ends_with("bay_interior.tscn"):
		return "BayInterior"
	if path.ends_with("parsonage.tscn"):
		return "Parsonage"
	if path.ends_with("sanctuary.tscn"):
		return "Sanctuary"
	if path.ends_with("hardware_street.tscn"):
		return "HardwareStreet"
	return "ChurchExterior"


func _visible_count(room: Node, group_name: String) -> int:
	var count := 0
	var tree := get_tree()
	if tree == null:
		return 0
	for node in tree.get_nodes_in_group(group_name):
		if node is CanvasItem and room.is_ancestor_of(node) and (node as CanvasItem).visible:
			count += 1
	return count


func _stand_at(player: Player, target: Node2D) -> void:
	_release_all()
	player.velocity = Vector2.ZERO
	player.global_position = target.global_position + Vector2(0, 26)
	player.clear_interact_lock()
	await _pump(2)


func _walk_into(player: Player, door: Node2D) -> void:
	if player == null or door == null:
		return
	_release_all()
	player.clear_interact_lock()
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	var dest := door.global_position
	var away := Vector2(0.0, 1.0)
	if player.global_position.distance_to(dest) > 1.0:
		away = (player.global_position - dest).normalized()
	player.global_position = dest + away * (radius + 20.0)
	player.velocity = Vector2.ZERO
	await _pump(3)
	if not is_instance_valid(player):
		return
	var delta := dest - player.global_position
	var action := "move_up"
	if absf(delta.x) > absf(delta.y):
		action = "move_right" if delta.x > 0.0 else "move_left"
	else:
		action = "move_down" if delta.y > 0.0 else "move_up"
	Input.action_press(action)
	var start := get_tree().current_scene
	var guard := 0
	while guard < 55:
		await get_tree().physics_frame
		guard += 1
		if get_tree().current_scene != start:
			break
		if not is_instance_valid(player):
			break
	Input.action_release(action)
	_release_all()
	await _pump(1)


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
		"interact", "pause", "cycle_time", "town_map",
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
	var flat := text.replace("\n", " ")
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
	DayClock.reset()
	print("M5A_OK" if not _failed else "M5A_FAIL")
	tree.quit(0 if not _failed else 1)
