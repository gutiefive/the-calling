extends Node
## Sunday 10:00 gathering in the sanctuary. The beats live in data/dialogue/sunday_service.json.
## Named people sit for the service, then stand for follow-up. Twelve unnamed congregants fill the pews.

const SEATS: Dictionary = {
	"harold": Vector2(300, 356),
	"margaret": Vector2(600, 356),
	"sarah": Vector2(300, 436),
	"thomas": Vector2(600, 436),
	"frank": Vector2(300, 596),
}
const FOLLOWUPS: Dictionary = {
	"margaret": "margaret_sunday",
	"harold": "harold_sunday",
	"frank": "frank_sunday",
	"sarah": "sarah_sunday",
	"thomas": "thomas_sunday",
}
const CROWD: Array[Vector2] = [
	Vector2(360, 356), Vector2(660, 356),
	Vector2(360, 436), Vector2(660, 436),
	Vector2(300, 516), Vector2(360, 516),
	Vector2(600, 516), Vector2(660, 516),
	Vector2(360, 596), Vector2(600, 596),
	Vector2(660, 596), Vector2(430, 640),
]

var _running: bool = false
var _weekly_running: bool = false
var _booted: bool = false
var _restarts: int = 0
var _weekly_restarts: int = 0
var _crowd_built: bool = false


func _ready() -> void:
	_apply_followups()
	call_deferred("_boot")


func on_clock() -> void:
	if not is_inside_tree():
		return
	if _running or _weekly_running:
		_seat_named(true)
		return
	_sync_crowd()
	_sync_ledger()
	_sync_quiet_note()
	if _should_start():
		_begin()
	elif _should_start_weekly():
		_begin_weekly()


func _boot() -> void:
	if _booted or not is_inside_tree():
		return
	_booted = true
	_build_crowd()
	_apply_followups()
	if NarrativeState.flag_is_true("service_complete"):
		_sync_crowd()
		_sync_ledger()
		_sync_quiet_note()
		if _should_start_weekly():
			_begin_weekly()
		return
	# A theme was already chosen, so do not play the sermon again and add the relationships twice.
	if str(NarrativeState.get_flag("sermon_theme", "")) != "":
		_finish_service()
		return
	_sync_crowd()
	if _should_start():
		_begin()


func _process(_delta: float) -> void:
	_sync_ledger()
	_sync_quiet_note()
	var box := _box()
	var box_open := box != null and box.has_method("is_conversation_open") and bool(box.call("is_conversation_open"))
	if _weekly_running:
		if box_open:
			return
		_weekly_running = false
		var weekly_theme := str(NarrativeState.get_flag("weekly_sermon_theme", ""))
		if weekly_theme.is_empty() and _weekly_restarts < 1:
			_weekly_restarts += 1
			_begin_weekly()
			return
		_finish_weekly()
		return
	if not _running:
		return
	if box_open:
		return
	_running = false
	var theme := str(NarrativeState.get_flag("sermon_theme", ""))
	if theme.is_empty() and _restarts < 1:
		_restarts += 1
		_begin()
		return
	_finish_service()


func _should_start() -> bool:
	if NarrativeState.flag_is_true("service_complete") or NarrativeState.ending_open:
		return false
	if str(NarrativeState.get_flag("sermon_theme", "")) != "":
		return false
	if NarrativeState.dialogue_open:
		return false
	if _is_later_sunday():
		return false
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return false
	if str(clock.call("weekday_name")) != "Sunday":
		return false
	if int(clock.get("weekday")) > 7:
		return false
	return int(clock.get("hour")) >= 10


func _should_start_weekly() -> bool:
	if not NarrativeState.flag_is_true("weekly_loop"):
		return false
	if NarrativeState.ending_open or NarrativeState.dialogue_open or NarrativeState.ledger_open:
		return false
	if _weekly_running or _running:
		return false
	if _weekly_done_this_week():
		return false
	if not _is_later_sunday():
		return false
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return false
	# Morning gathering only. Chapter 1 still starts at 10:00 with no upper bound;
	# later weeks do not reopen the sermon if the player is in the room after noon.
	var hour := int(clock.get("hour"))
	return hour >= 10 and hour < 12


func _begin_weekly() -> void:
	var box := _box()
	var player := _player()
	if box == null:
		_finish_weekly()
		return
	_seat_named(true)
	_sync_crowd()
	var opened := false
	if box.has_method("open_conversation"):
		opened = bool(box.call("open_conversation", "weekly_service", player, true))
	if not opened:
		push_error("Weekly service could not open")
		_weekly_running = false
		_finish_weekly()
		return
	_weekly_running = true


func _finish_weekly() -> void:
	_seat_named(false)
	var room := get_parent()
	if room != null:
		NpcSchedule.apply_room(room)
	_apply_followups()
	_sync_crowd()
	var theme := str(NarrativeState.get_flag("weekly_sermon_theme", ""))
	var funds := get_node_or_null("/root/ChurchFunds")
	if funds != null and funds.has_method("settle_sunday"):
		funds.call("settle_sunday", theme)
	_open_ledger()


func _weekly_done_this_week() -> bool:
	var funds := get_node_or_null("/root/ChurchFunds")
	if funds == null:
		return false
	var week := 0
	if funds.has_method("week_number"):
		week = int(funds.call("week_number"))
	return int(funds.get("last_service_week")) == week and week > 0


func _open_ledger() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var ledger := tree.get_first_node_in_group("ledger_screen")
	if ledger != null and ledger.has_method("open_from_service"):
		ledger.call("open_from_service")


func _begin() -> void:
	var box := _box()
	var room := get_parent()
	if box == null or room == null:
		_finish_service()
		return
	var player := _player()
	_seat_named(true)
	_sync_crowd()
	var opened := false
	if box.has_method("open_conversation"):
		opened = bool(box.call("open_conversation", "sunday_service", player, true))
	if not opened:
		push_error("Sunday service could not open")
		_running = false
		_finish_service()
		return
	_running = true


func _finish_service() -> void:
	var theme := str(NarrativeState.get_flag("sermon_theme", ""))
	_seat_named(false)
	var room := get_parent()
	if theme.is_empty():
		if room != null:
			NpcSchedule.apply_room(room)
		return
	NarrativeState.set_flag("service_complete", true)
	if NarrativeState.quest_status("first_sunday").is_empty():
		NarrativeState.start_quest("first_sunday")
		NarrativeState.set_step("first_sunday", "followups")
	if room != null:
		NpcSchedule.apply_room(room)
	_apply_followups()
	_sync_crowd()
	_sync_ledger()


func _apply_followups() -> void:
	if not NarrativeState.flag_is_true("service_complete"):
		return
	var room := get_parent()
	if room == null:
		return
	for npc_id in FOLLOWUPS.keys():
		var npc := _npc(room, str(npc_id))
		if npc == null:
			continue
		npc.dialogue_id = str(FOLLOWUPS[npc_id])


func _seat_named(seated: bool) -> void:
	var room := get_parent()
	if room == null:
		return
	for npc_id in SEATS.keys():
		var npc := _npc(room, str(npc_id))
		if npc == null:
			continue
		var standing := npc.get_node_or_null("Sprite") as CanvasItem
		var portrait := _seated_sprite(npc, str(npc_id))
		if seated:
			var pos_v: Variant = SEATS[npc_id]
			if pos_v is Vector2:
				npc.position = pos_v
			npc.visible = true
			npc.enabled = false
		if standing != null:
			standing.visible = not seated
		if portrait != null:
			portrait.visible = seated


func _seated_sprite(npc: Node2D, npc_id: String) -> Sprite2D:
	var found := npc.get_node_or_null("Seated") as Sprite2D
	if found != null:
		return found
	var sprite := Sprite2D.new()
	sprite.name = "Seated"
	sprite.centered = true
	sprite.offset = Vector2(0, -16)
	sprite.texture = PlaceholderArt.seated(npc_id)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.visible = false
	npc.add_child(sprite)
	return sprite


func _build_crowd() -> void:
	if _crowd_built:
		return
	var room := get_parent()
	if room == null:
		return
	var props := room.get_node_or_null("Props")
	if props == null:
		return
	_crowd_built = true
	for i in CROWD.size():
		var sprite := Sprite2D.new()
		sprite.name = "Congregant%d" % (i + 1)
		sprite.texture = PlaceholderArt.congregant(i)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.centered = true
		sprite.offset = Vector2(0, -16)
		sprite.position = CROWD[i]
		sprite.visible = false
		sprite.add_to_group("congregant")
		props.add_child(sprite)


func _sync_crowd() -> void:
	var room := get_parent()
	if room == null:
		return
	# The twelve sit for the first Sunday from 10:00 on. Later Sundays fill only after Continue.
	var show := _sunday_service_hour() and (not _is_later_sunday() or NarrativeState.flag_is_true("weekly_loop"))
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("congregant"):
		if node is CanvasItem and room.is_ancestor_of(node):
			(node as CanvasItem).visible = show


func _sync_ledger() -> void:
	var room := get_parent()
	if room == null:
		return
	var ledger := room.get_node_or_null("Props/Ledger") as Interactable
	if ledger == null:
		return
	var show := NarrativeState.flag_is_true("margaret_sunday") and not NarrativeState.flag_is_true("ledger_revealed")
	ledger.visible = show
	ledger.enabled = show


func _sync_quiet_note() -> void:
	var room := get_parent()
	if room == null:
		return
	var clock := get_node_or_null("/root/DayClock")
	var show := _is_later_sunday() and clock != null and int(clock.get("hour")) < 12
	if _weekly_running or _weekly_done_this_week():
		show = false
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("quiet_sunday"):
		if not room.is_ancestor_of(node):
			continue
		if node is CanvasItem:
			(node as CanvasItem).visible = show
		if node is Interactable:
			(node as Interactable).enabled = show


func _is_later_sunday() -> bool:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null or not clock.has_method("is_later_sunday"):
		return false
	return bool(clock.call("is_later_sunday"))


func _sunday_service_hour() -> bool:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return false
	if str(clock.call("weekday_name")) != "Sunday":
		return false
	return int(clock.get("hour")) >= 10


func _npc(room: Node, npc_id: String) -> DialogueNpc:
	var tree := get_tree()
	if tree == null:
		return null
	for node in tree.get_nodes_in_group("scheduled_npc"):
		if node is DialogueNpc and room.is_ancestor_of(node) and str(node.get("npc_id")) == npc_id:
			return node as DialogueNpc
	return null


func _box() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("dialogue_box")


func _player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("player") as Node2D
