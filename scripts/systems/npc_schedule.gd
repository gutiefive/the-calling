class_name NpcSchedule
extends RefCounted
## Data-driven presence. A matching day and time window puts an NPC in one scene.
## No match means the NPC is absent. Windows are [from, until).

const PATH := "res://data/schedules/week.json"

static var _npcs: Dictionary = {}
static var _loaded: bool = false
static var _ok: bool = false
## Extra rectangles for the blocked-path check. Tests set this, then clear it.
static var debug_blocks: Array[Rect2] = []


static func placement(npc_id: String, day_name: String, hour: int, minute: int) -> Dictionary:
	if not _ensure():
		return {}
	var rows: Variant = _npcs.get(npc_id, [])
	if not rows is Array:
		return {}
	var now := hour * 60 + minute
	for entry_v in rows as Array:
		if not entry_v is Dictionary:
			continue
		var entry: Dictionary = entry_v
		if not _day_matches(entry.get("days", []), day_name):
			continue
		var start := _minutes(str(entry.get("from", "00:00")))
		var until := _minutes(str(entry.get("until", "24:00")))
		if now < start or now >= until:
			continue
		var pos_v: Variant = entry.get("position", [])
		if not pos_v is Array or (pos_v as Array).size() < 2:
			continue
		var pos_a: Array = pos_v
		return {
			"scene": str(entry.get("scene", "")),
			"position": Vector2(float(pos_a[0]), float(pos_a[1])),
		}
	return {}


static func apply_room(room: Node, snap: bool = true) -> void:
	if room == null:
		return
	var clock := _clock(room)
	if clock == null or not _ensure():
		# Fail open: a missing clock or file leaves the scene's authored NPCs in place.
		return
	var day := str(clock.call("weekday_name"))
	var hour := int(clock.get("hour"))
	var minute := int(clock.get("minute"))
	var here_id := scene_id(room)
	var blocks := _blockers(room)
	for extra in debug_blocks:
		blocks.append(extra)
	for node in _npcs_in(room):
		var npc_id := str(node.get("npc_id"))
		var place := placement(npc_id, day, hour, minute)
		var here := not place.is_empty() and str(place.get("scene", "")) == here_id
		var agent := _agent(node)
		if not here:
			agent.stop()
			node.set_meta("schedule_walking", false)
			node.set_meta("scheduled_away", true)
			node.visible = false
			if node is Interactable:
				(node as Interactable).enabled = false
			continue
		var target: Vector2 = place["position"]
		node.set_meta("scheduled_away", false)
		node.visible = true
		if node is Interactable:
			(node as Interactable).enabled = true
		var dist := node.position.distance_to(target)
		if snap or dist <= 1.0:
			agent.stop()
			node.position = target
			node.set_meta("schedule_walking", false)
			node.set_meta("schedule_fallback", false)
			continue
		var route := NpcRoute.plan(node.position, target, blocks)
		var raw_points: Variant = route.get("points", [])
		var points: Array = raw_points if raw_points is Array else []
		if bool(route.get("ok", false)) and not points.is_empty():
			node.set_meta("schedule_walking", true)
			node.set_meta("schedule_fallback", false)
			agent.begin(points)
			continue
		# No clear path. Teleport so a chair or a test wall cannot trap them.
		agent.stop()
		node.position = target
		node.set_meta("schedule_walking", false)
		node.set_meta("schedule_fallback", true)


static func signature(room: Node) -> String:
	var clock := _clock(room)
	if clock == null or room == null:
		return ""
	var day := str(clock.call("weekday_name"))
	var hour := int(clock.get("hour"))
	var minute := int(clock.get("minute"))
	var here_id := scene_id(room)
	var ids: Array[String] = []
	for node in _npcs_in(room):
		var npc_id := str(node.get("npc_id"))
		if not npc_id.is_empty():
			ids.append(npc_id)
	ids.sort()
	var parts: PackedStringArray = PackedStringArray()
	for npc_id in ids:
		var place := placement(npc_id, day, hour, minute)
		if place.is_empty() or str(place.get("scene", "")) != here_id:
			parts.append(npc_id + ":away")
		else:
			var pos: Vector2 = place["position"]
			parts.append("%s:%d,%d" % [npc_id, int(pos.x), int(pos.y)])
	return "|".join(parts)


static func scene_id(room: Node) -> String:
	if room == null:
		return ""
	return room.scene_file_path.get_file().get_basename()


static func _ensure() -> bool:
	if _loaded:
		return _ok
	_loaded = true
	var parsed: Variant = JsonFile.read(PATH)
	if not parsed is Dictionary:
		push_error("Schedule file is not an object")
		return false
	var rows: Variant = (parsed as Dictionary).get("npcs", [])
	if not rows is Array:
		push_error("Schedule file has no npcs list")
		return false
	for row_v in rows as Array:
		if not row_v is Dictionary:
			continue
		var row: Dictionary = row_v
		var npc_id := str(row.get("id", ""))
		if npc_id.is_empty():
			continue
		var entries: Variant = row.get("entries", [])
		_npcs[npc_id] = entries if entries is Array else []
	_ok = true
	return true


static func _agent(body: Node2D) -> ScheduleAgent:
	var found := body.get_node_or_null("ScheduleAgent") as ScheduleAgent
	if found != null:
		return found
	var agent := ScheduleAgent.new()
	agent.name = "ScheduleAgent"
	body.add_child(agent)
	return agent


static func _blockers(room: Node) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return rects
	for child in solids.get_children():
		if not child is CollisionShape2D:
			continue
		var shape_node := child as CollisionShape2D
		if not shape_node.shape is RectangleShape2D:
			continue
		var rect_shape := shape_node.shape as RectangleShape2D
		var size := rect_shape.size
		var center := shape_node.position
		rects.append(Rect2(center - size * 0.5, size))
	return rects


static func _npcs_in(room: Node) -> Array[Node2D]:
	var found: Array[Node2D] = []
	var tree := room.get_tree()
	if tree == null:
		return found
	for node in tree.get_nodes_in_group("scheduled_npc"):
		if node is Node2D and room.is_ancestor_of(node):
			found.append(node as Node2D)
	return found


static func _clock(room: Node) -> Node:
	var tree := room.get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("DayClock")


static func _day_matches(days_v: Variant, day_name: String) -> bool:
	if not days_v is Array:
		return false
	for day_v in days_v as Array:
		if str(day_v) == day_name:
			return true
	return false


static func _minutes(text: String) -> int:
	var parts := text.split(":")
	if parts.size() < 2:
		return 0
	return int(parts[0]) * 60 + int(parts[1])
