extends Node
## Headless checks for Gameplay E (weekly potluck, action toasts, save v11).
## Prints GPE_OK or GPE_FAIL.
## Run: godot --headless --path . res://tests/gpe/gpe_validation.tscn

const Frames := preload("res://scripts/art/potluck_frames.gd")
const Catalog := preload("res://scripts/systems/event_catalog.gd")

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
	_art_frames()
	_toast_behavior()
	_unlock_timing()
	_prep_categories()
	_schedule_and_skip()
	await _world_and_prep_visuals()
	_moral_choice()
	_no_pull_for_success()
	_no_duplicate_rewards()
	_completion_persists()
	await _no_interference()
	await _save_and_migration()
	_restore_user_save()
	_finish()


func _art_frames() -> void:
	_check(not Catalog.title().is_empty(), "the gathering catalog has a title")
	for frame_id in PackedStringArray(["table_modest", "table_full", "dishes_simple", "dishes_varied", "centerpiece", "string_lights", "banner", "chair", "chairs_extra"]):
		var image: Image = Frames.build(frame_id)
		_check(image != null and image.get_width() >= 8 and image.get_height() >= 8, "potluck art %s is drawn" % frame_id)


func _toast_behavior() -> void:
	_check(ActionToast.HOLD_SECONDS <= 1.5, "toast hold is at most 1.5s")
	_check(ActionToast.HOLD_SECONDS + ActionToast.FADE_SECONDS <= 1.5, "toast lifetime is at most 1.5s")
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	var toast := hud.get_node_or_null("ActionToast") as ActionToast
	_check(toast != null, "the HUD has an action toast")
	if toast == null:
		hud.free()
		return
	toast.show_message("Tilled the soil.")
	_check(toast.is_showing(), "a toast appears")
	_check(toast.current_text() == "Tilled the soil.", "the first toast shows the till line")
	_check(toast.remaining() <= 1.5, "a new toast lasts at most 1.5s")
	_check(not toast.captures_input(), "the toast does not capture input")
	_check(toast.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the toast panel ignores the mouse")
	toast.show_message("Watered the soil.")
	_check(toast.current_text() == "Watered the soil.", "a new toast replaces the old one")
	_check(toast.is_showing(), "the replacement toast is still showing")
	var count := 0
	for child in hud.get_children():
		if child is ActionToast and (child as ActionToast).is_showing():
			count += 1
	_check(count == 1, "toasts do not stack")
	hud.free()


func _unlock_timing() -> void:
	_fresh()
	var events := _events()
	_check(not bool(events.call("is_unlocked")), "the potluck is locked during Chapter 1")
	DayClock.set_time(3, 12, 0)
	_check(not bool(events.call("is_live")), "Chapter 1 Wednesday is not the gathering")
	NarrativeState.set_flag("week_continues", true)
	_check(not bool(events.call("is_unlocked")), "Continue alone does not open the hall gathering")
	NarrativeState.set_flag("hall_repaired", true)
	_check(bool(events.call("is_unlocked")), "Continue plus a repaired hall unlocks the potluck")
	DayClock.set_time(8, 12, 0)
	_check(not bool(events.call("is_live")), "Monday after unlock is not the gathering")
	DayClock.set_time(10, 12, 0)
	_check(bool(events.call("is_live")), "the first Wednesday after unlock is the gathering")
	_check(HappeningSchedule.is_active("wednesday_potluck", "Wednesday", 12, 0), "the M8 happening still fires")


func _prep_categories() -> void:
	_fresh()
	_unlock()
	var events := _events()
	_check(not bool(events.call("has_prep", "vegetables")), "vegetables start unset")
	_check(not bool(events.call("has_prep", "flowers")), "flowers start unset")
	_check(not bool(events.call("has_prep", "grounds")), "grounds start unset")
	_check(not bool(events.call("has_prep", "repair")), "repair starts unset")
	_check(not bool(events.call("has_prep", "invites")), "invites start unset")
	var asks := _asks()
	asks.call("accept", "fresh_for_the_table")
	_pack().call("add", "lettuce", 2)
	_pack().call("add", "carrots", 2)
	asks.call("deliver", "fresh_for_the_table")
	_check(bool(events.call("has_prep", "vegetables")), "delivering vegetables is tracked")
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	_check(bool(events.call("has_prep", "flowers")), "sanctuary flowers count as prep")
	NarrativeState.set_flag("grounds_cared_for", true)
	_check(bool(events.call("has_prep", "grounds")), "tended grounds count as prep")
	NarrativeState.set_flag("picnic_bed_restored", true)
	_check(bool(events.call("has_prep", "repair")), "the picnic bed counts as the event repair")
	_check(bool(events.call("set_framing", "open")), "Sarah's framing can be set")
	_check(bool(events.call("invite", "ostrow")), "Ostrow can be invited")
	_check(bool(events.call("invite", "ruth")), "Ruth can be invited")
	_check(bool(events.call("invite", "dale")), "Dale can be invited")
	_check(not bool(events.call("invite", "ostrow")), "a second invite does nothing")
	_check(int(events.call("invited_count")) == 3, "three neighbors are invited")
	_check(bool(events.call("has_prep", "invites")), "invites are tracked")
	var lines := PackedStringArray()
	var raw: Variant = events.call("journal_lines")
	if raw is PackedStringArray:
		lines = raw
	var blob := " ".join(lines)
	_check(blob.contains("Sarah has everything she needs for Sunday."), "the journal names Sarah's vegetables")
	_check(blob.contains("Flowers are ready for the table."), "the journal names the flowers")
	events.call("from_dictionary", events.call("to_dictionary"))
	_check(bool(events.call("has_prep", "vegetables")), "prep survives a state round-trip")
	_check(str(events.call("framing")) == "open", "framing survives a state round-trip")


func _schedule_and_skip() -> void:
	_fresh()
	_unlock()
	var events := _events()
	DayClock.set_time(10, 10, 0)
	_check(not bool(events.call("is_live")), "Wednesday morning before 11 is not the gathering")
	DayClock.set_time(10, 12, 0)
	_check(bool(events.call("is_live")), "Wednesday noon is the gathering")
	DayClock.set_time(10, 16, 0)
	_check(not bool(events.call("is_live")), "Wednesday after 16:00 has ended")
	_check(bool(events.call("did_skip", 2)), "skipping Wednesday is recorded")
	DayClock.set_time(17, 12, 0)
	_check(bool(events.call("is_live")), "the gathering returns the next Wednesday")
	_check(not bool(events.call("did_attend", 3)), "next week has not been attended yet")


func _world_and_prep_visuals() -> void:
	_fresh()
	_unlock()
	NarrativeState.set_flag("hall_celebrated", true)
	DayClock.set_time(10, 12, 0)
	var empty := _instance("res://scenes/world/fellowship_hall.tscn")
	if empty == null:
		return
	await _pump(3)
	_check(empty.get_node_or_null("Props/Margaret") != null, "Margaret is in the hall")
	_check(_npc_visible(empty, "Margaret"), "Margaret appears with no prep")
	_check(_npc_visible(empty, "Harold"), "Harold appears with no prep")
	_check(_npc_visible(empty, "Sarah"), "Sarah appears with no prep")
	_check(not _npc_visible(empty, "Ostrow"), "Ostrow stays away with no invites")
	_check(not _npc_visible(empty, "Ruth"), "Ruth stays away with no invites")
	_check(not _npc_visible(empty, "Dale"), "Dale stays away with no invites")
	var modest := empty.get_node_or_null("Props/TableA") as Sprite2D
	_check(modest != null and modest.visible, "a modest table is out with no prep")
	var modest_tex: Texture2D = modest.texture if modest != null else null
	_check(not _node_visible(empty, "CenterA"), "centerpieces stay off with no flowers")
	_check(not _node_visible(empty, "Lights"), "string lights stay off with no grounds work")
	_check(not _node_visible(empty, "ExtraChairs"), "extra chairs stay off with no repair")
	empty.free()
	await _pump(1)
	_full_prep()
	DayClock.set_time(10, 12, 0)
	var full := _instance("res://scenes/world/fellowship_hall.tscn")
	if full == null:
		return
	await _pump(3)
	_check(_npc_visible(full, "Ostrow"), "an invited Ostrow appears")
	_check(_npc_visible(full, "Ruth"), "an invited Ruth appears")
	_check(_npc_visible(full, "Dale"), "an invited Dale appears")
	_check(_node_visible(full, "CenterA"), "flower centerpieces appear")
	_check(_node_visible(full, "Lights"), "string lights appear when the grounds are tended")
	_check(_node_visible(full, "ExtraChairs"), "extra chairs appear after the picnic bed")
	var table := full.get_node_or_null("Props/TableA") as Sprite2D
	_check(table != null and table.texture != null, "the full table has art")
	if modest_tex != null and table != null and table.texture != null:
		_check(modest_tex != table.texture, "full prep uses a different table than no prep")
	var dishes := full.get_node_or_null("Props/DishesA") as Sprite2D
	_check(dishes != null and dishes.visible, "varied dishes appear with vegetables")
	full.free()
	await _pump(1)
	var grounds := _instance("res://scenes/world/church_exterior.tscn")
	if grounds == null:
		return
	await _pump(2)
	var door := grounds.get_node_or_null("Props/HallDoor") as Door
	_check(door != null, "the repaired hall has a walk-in door")
	if door != null:
		_check(door.enabled, "the hall door is open after celebration")
		_check(str(door.destination_scene).ends_with("fellowship_hall.tscn"), "the door leads to the hall interior")
	grounds.free()


func _moral_choice() -> void:
	_fresh()
	_unlock()
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	var data := DialogueRunner.load_conversation("sarah")
	var open_run := DialogueRunner.new()
	_check(open_run.start(data), "Sarah's gathering talk starts")
	_advance_to_choices(open_run)
	_check(open_run.choice_count() == 2, "Sarah offers two framings")
	if open_run.choice_count() >= 2:
		_check(open_run.choice_text(0).contains("everyone"), "the open choice is not labeled good")
		_check(open_run.choice_text(1).contains("church-centered"), "the church choice is not labeled evil")
		open_run.choose(0)
	_check(str(_events().call("framing")) == "open", "the open branch is stored")
	_check(NarrativeState.flag_is_true("potluck_framing_open"), "the open branch is a hidden flag")
	_check(not NarrativeState.flag_is_true("potluck_framing_church"), "the church flag stays off")
	_check(NarrativeState.relationship("sarah") >= 1, "the open branch supports the relationship")
	var path := get_node_or_null("/root/PastorPath")
	_check(path != null and bool(path.call("has_reason", "potluck_open")), "the open branch nudges Shepherd")
	var journal := ""
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud != null:
		var panel := hud.get_node_or_null("Journal")
		if panel != null and panel.has_method("_body_text"):
			journal = str(panel.call("_body_text"))
		hud.free()
	_check(not journal.to_lower().contains("pull"), "the journal still hides Pull")
	_check(not journal.contains("score"), "no visible morality score")
	_fresh()
	_unlock()
	NarrativeState.start_quest("oak_street")
	NarrativeState.complete_quest("oak_street")
	var inf := _influence()
	var pull_before := 0
	if inf != null and inf.has_method("pull_total"):
		pull_before = int(inf.call("pull_total"))
	var church_run := DialogueRunner.new()
	church_run.start(DialogueRunner.load_conversation("sarah"))
	_advance_to_choices(church_run)
	if church_run.choice_count() >= 2:
		church_run.choose(1)
	_check(str(_events().call("framing")) == "church", "the church-centered branch is stored")
	_check(NarrativeState.flag_is_true("potluck_framing_church"), "the church-centered flag is hidden")
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == pull_before + 1, "church-centered framing can feed influence")
	if path != null:
		_check(bool(path.call("has_reason", "potluck_church")), "the church branch nudges Builder")


func _no_pull_for_success() -> void:
	_fresh()
	_unlock()
	_full_prep()
	var inf := _influence()
	var pull_before := 0
	if inf != null and inf.has_method("pull_total"):
		pull_before = int(inf.call("pull_total"))
	var funds_before := int(_funds().get("balance"))
	DayClock.set_time(10, 12, 0)
	_events().call("set_inside", true)
	_check(bool(_events().call("did_attend")), "walking into the hall counts as attending")
	_events().call("set_inside", true)
	if inf != null and inf.has_method("pull_total"):
		_check(int(inf.call("pull_total")) == pull_before, "a successful gathering does not raise Pull")
	_check(int(_funds().get("balance")) == funds_before, "the gathering does not touch ChurchFunds")
	_events().call("set_inside", false)


func _no_duplicate_rewards() -> void:
	_fresh()
	_unlock()
	DayClock.set_time(10, 12, 0)
	var notes_before := NarrativeState.journal_notes().size()
	_check(bool(_events().call("mark_attended")), "the first attendance grants a note")
	_check(not bool(_events().call("mark_attended")), "a second attendance this week grants nothing")
	_check(int(_events().call("last_reward_week")) == 2, "the reward week is stored")
	_check(NarrativeState.journal_notes().size() == notes_before + 1, "the attendance note is once")


func _completion_persists() -> void:
	_fresh()
	_unlock()
	_events().call("set_framing", "open")
	_events().call("invite", "ostrow")
	DayClock.set_time(10, 12, 0)
	_events().call("mark_attended")
	var blob: Dictionary = _events().call("to_dictionary")
	NarrativeState.reset()
	_events().call("from_dictionary", blob)
	_check(str(_events().call("framing")) == "open", "outcome framing persists")
	_check(bool(_events().call("did_attend", 2)), "attendance persists")


func _no_interference() -> void:
	_fresh()
	_unlock()
	_check(HappeningSchedule.is_active("wednesday_potluck", "Wednesday", 12, 0), "the M8 potluck happening remains")
	DayClock.set_time(14, 10, 0)
	_check(not bool(_events().call("is_live")), "Sunday is not the potluck")
	var sanctuary := _instance("res://scenes/world/sanctuary.tscn")
	if sanctuary == null:
		return
	await _pump(2)
	var service := sanctuary.get_node_or_null("SundayService")
	_check(service != null, "the Sunday service node is still in the sanctuary")
	sanctuary.free()
	await _pump(1)
	NarrativeState.reset()
	DayClock.reset()
	NarrativeState.set_flag("ledger_revealed", true)
	NarrativeState.set_flag("service_complete", true)
	NarrativeState.set_flag("chapter_one_complete", true)
	_check(not NarrativeState.flag_is_true("week_continues"), "Chapter 1 still has not continued")
	var ending_data := DialogueRunner.load_conversation("hall_celebration")
	_check(_conversation_has(ending_data, "potluck"), "Harold still names a potluck after the hall is repaired")


func _save_and_migration() -> void:
	_fresh()
	_unlock()
	_full_prep()
	DayClock.set_time(10, 12, 0)
	_events().call("mark_attended")
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Player
	if player == null:
		_check(false, "save round-trip needs the player")
		room.free()
		return
	player.global_position = Vector2(420, 510)
	var saved := SaveGame.save_to_disk(get_tree())
	_check(saved, "a version 11 save writes")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	var row: Dictionary = parsed if parsed is Dictionary else {}
	_check(int(row.get("version", -1)) == 11, "the save file is version 11")
	_check(row.has("event"), "the save stores the gathering")
	room.free()
	await _pump(1)
	NarrativeState.reset()
	_check(str(_events().call("framing")) == "", "reset clears gathering state")
	var loaded := SaveGame.read_file()
	_check(int(loaded.get("version", 0)) == 11, "read_file keeps version 11")
	SaveGame.apply_state(loaded)
	_check(str(_events().call("framing")) == "open", "load restores the framing")
	_check(bool(_events().call("is_invited", "ostrow")), "load restores invites")
	_check(bool(_events().call("did_attend", 2)), "load restores attendance")
	var from_v10 := SaveGame.migrate({
		"version": 10,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {
			"flags": {
				"week_continues": true,
				"hall_repaired": true,
				"potluck_vegetables": true,
			},
		},
	})
	_check(int(from_v10.get("version", 0)) == 11, "a version 10 file migrates to version 11")
	var event_v: Variant = from_v10.get("event", {})
	var event_row: Dictionary = event_v if event_v is Dictionary else {}
	_check(bool(event_row.get("vegetables", false)), "v10 potluck_vegetables becomes tracked prep")
	_check(SaveGame.migrate({"version": 12, "scene": "res://scenes/world/church_exterior.tscn"}).is_empty(), "a newer save is still rejected")
	NarrativeState.reset()


func _full_prep() -> void:
	var events := _events()
	NarrativeState.set_flag("potluck_vegetables", true)
	NarrativeState.set_flag("sanctuary_flowers_set", true)
	NarrativeState.set_flag("grounds_cared_for", true)
	NarrativeState.set_flag("picnic_bed_restored", true)
	events.call("from_dictionary", {
		"framing": "open",
		"invited": ["ostrow", "ruth", "dale"],
		"vegetables": true,
	})


func _unlock() -> void:
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.set_flag("hall_repaired", true)


func _advance_to_choices(runner: DialogueRunner) -> void:
	var guard := 0
	while runner.is_open() and runner.choice_count() == 0 and guard < 10:
		if runner.body().contains("That's all I've got"):
			break
		runner.advance()
		guard += 1


func _npc_visible(room: Node, node_name: String) -> bool:
	var node := room.get_node_or_null("Props/%s" % node_name)
	if node == null:
		return false
	if node is CanvasItem and not (node as CanvasItem).visible:
		return false
	if "enabled" in node and not bool(node.get("enabled")):
		return false
	return true


func _node_visible(room: Node, node_name: String) -> bool:
	var node := room.get_node_or_null("Props/%s" % node_name) as CanvasItem
	return node != null and node.visible


func _conversation_has(data: Dictionary, needle: String) -> bool:
	var blob := JSON.stringify(data).to_lower()
	return blob.contains(needle.to_lower())


func _fresh() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 10, 0)
	if _pack() != null:
		_pack().call("reset")
	if _asks() != null:
		_asks().call("reset")
	if _events() != null:
		_events().call("reset")


func _events() -> Node:
	return get_node_or_null("/root/EventState")


func _asks() -> Node:
	return get_node_or_null("/root/RequestState")


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


func _influence() -> Node:
	return get_node_or_null("/root/InfluenceState")


func _instance(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
	_check(room != null, "instantiate " + path)
	if room == null:
		return null
	add_child(room)
	return room


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("GPE_OK" if not _failed else "GPE_FAIL")
	tree.quit(0 if not _failed else 1)
