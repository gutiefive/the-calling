class_name DialogueRunner
extends RefCounted
## Plays one dialogue file. The UI reveals text; this only walks nodes, choices, and effects.

var _nodes: Dictionary = {}
var _current: Dictionary = {}
var _open: bool = false


static func load_conversation(conversation_id: String) -> Dictionary:
	var path := "res://data/dialogue/%s.json" % conversation_id
	var parsed: Variant = JsonFile.read(path)
	if not parsed is Dictionary:
		push_error("Dialogue %s is not an object" % conversation_id)
		return {}
	var data: Dictionary = parsed
	var error := _validate(data)
	if not error.is_empty():
		push_error("Dialogue %s: %s" % [conversation_id, error])
		return {}
	return data


func start(data: Dictionary) -> bool:
	_nodes = data.get("nodes", {})
	_current = {}
	_open = true
	_enter(str(data.get("start", "")))
	return _open


func is_open() -> bool:
	return _open


func speaker() -> String:
	return str(_current.get("speaker", ""))


func body() -> String:
	return str(_current.get("text", ""))


func choice_count() -> int:
	return _choice_rows().size()


func choice_text(index: int) -> String:
	var rows := _choice_rows()
	if index < 0 or index >= rows.size():
		return ""
	return str((rows[index] as Dictionary).get("text", ""))


func advance() -> void:
	if not _open:
		return
	if choice_count() > 0:
		return
	if bool(_current.get("end", false)):
		_open = false
		return
	var nxt := str(_current.get("next", ""))
	if nxt.is_empty():
		_open = false
		return
	_enter(nxt)


func choose(index: int) -> void:
	if not _open:
		return
	var rows := _choice_rows()
	if index < 0 or index >= rows.size():
		return
	var choice: Dictionary = rows[index]
	_apply(choice)
	var nxt := str(choice.get("next", ""))
	if nxt.is_empty():
		_open = false
		return
	_enter(nxt)


func _enter(node_id: String) -> void:
	var guard := 0
	var cursor := node_id
	while guard < 12:
		guard += 1
		if not _nodes.has(cursor):
			push_error("Dialogue node missing: %s" % cursor)
			_open = false
			return
		var node: Dictionary = _nodes[cursor]
		_apply(node)
		if node.has("router"):
			cursor = _route(node["router"])
			if cursor.is_empty():
				push_error("Dialogue router at %s had no match" % node_id)
				_open = false
				return
			continue
		_current = node
		_open = true
		return
	push_error("Dialogue router loop at %s" % node_id)
	_open = false


func _route(routes_v: Variant) -> String:
	if not routes_v is Array:
		return ""
	for entry_v in routes_v as Array:
		if not entry_v is Dictionary:
			continue
		var entry: Dictionary = entry_v
		var condition: Variant = entry.get("if", null)
		if condition == null or (condition is Dictionary and _matches(condition)):
			return str(entry.get("next", ""))
	return ""


func _matches(condition: Dictionary) -> bool:
	if condition.has("quest_status"):
		var status_pair: Variant = condition["quest_status"]
		if status_pair is Array and (status_pair as Array).size() >= 2:
			var pair: Array = status_pair
			return NarrativeState.quest_status(str(pair[0])) == str(pair[1])
		return false
	if condition.has("quest_step"):
		var step_pair: Variant = condition["quest_step"]
		if step_pair is Array and (step_pair as Array).size() >= 2:
			var pair: Array = step_pair
			return NarrativeState.quest_step(str(pair[0])) == str(pair[1])
		return false
	if condition.has("quest_active"):
		return NarrativeState.quest_status(str(condition["quest_active"])) == "active"
	if condition.has("flag"):
		return NarrativeState.flag_is_true(str(condition["flag"]))
	if condition.has("flag_equals"):
		var flag_pair: Variant = condition["flag_equals"]
		if flag_pair is Array and (flag_pair as Array).size() >= 2:
			var pair: Array = flag_pair
			return NarrativeState.flag_equals(str(pair[0]), pair[1])
		return false
	if condition.has("relationship_at_least"):
		var rel_pair: Variant = condition["relationship_at_least"]
		if rel_pair is Array and (rel_pair as Array).size() >= 2:
			var pair: Array = rel_pair
			return NarrativeState.relationship(str(pair[0])) >= int(pair[1])
		return false
	if condition.has("weekday"):
		var clock := _clock()
		return clock != null and str(clock.call("weekday_name")) == str(condition["weekday"])
	if condition.has("hour_at_least"):
		var clock := _clock()
		return clock != null and int(clock.get("hour")) >= int(condition["hour_at_least"])
	return false


func _clock() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("DayClock")


func _apply(data: Dictionary) -> void:
	var flags_v: Variant = data.get("set_flags", null)
	if flags_v is Dictionary:
		for key in (flags_v as Dictionary).keys():
			NarrativeState.set_flag(str(key), (flags_v as Dictionary)[key])
	var add_v: Variant = data.get("add_relationships", null)
	if add_v is Dictionary:
		for key in (add_v as Dictionary).keys():
			NarrativeState.add_relationship(str(key), int((add_v as Dictionary)[key]))
	var set_rel_v: Variant = data.get("set_relationships", null)
	if set_rel_v is Dictionary:
		for key in (set_rel_v as Dictionary).keys():
			NarrativeState.set_relationship(str(key), int((set_rel_v as Dictionary)[key]))
	var notes_v: Variant = data.get("add_notes", null)
	if notes_v is Array:
		for item in notes_v as Array:
			NarrativeState.add_note(str(item))
	var quest_v: Variant = data.get("quest", null)
	if not quest_v is Dictionary:
		return
	var quest: Dictionary = quest_v
	var quest_id := str(quest.get("id", ""))
	if quest_id.is_empty():
		return
	if bool(quest.get("start", false)) or quest.has("step") or bool(quest.get("complete", false)):
		NarrativeState.start_quest(quest_id)
	if quest.has("step"):
		NarrativeState.set_step(quest_id, str(quest["step"]))
	if bool(quest.get("complete", false)):
		NarrativeState.complete_quest(quest_id)


func _choice_rows() -> Array:
	var choices_v: Variant = _current.get("choices", [])
	return choices_v if choices_v is Array else []


static func _validate(data: Dictionary) -> String:
	var nodes_v: Variant = data.get("nodes", null)
	if not nodes_v is Dictionary:
		return "missing nodes"
	var nodes: Dictionary = nodes_v
	var start := str(data.get("start", ""))
	if start.is_empty() or not nodes.has(start):
		return "missing start"
	for node_id in nodes.keys():
		var node_v: Variant = nodes[node_id]
		if not node_v is Dictionary:
			return "node %s is not an object" % str(node_id)
		var node: Dictionary = node_v
		if node.has("router"):
			var route_error := _validate_routes(nodes, node["router"])
			if not route_error.is_empty():
				return route_error
		if node.has("next"):
			var nxt := str(node["next"])
			if not nxt.is_empty() and not nodes.has(nxt):
				return "node %s points at missing %s" % [str(node_id), nxt]
		if not node.has("choices"):
			continue
		var choices_v: Variant = node["choices"]
		if not choices_v is Array:
			return "node %s choices are not a list" % str(node_id)
		for choice_v in choices_v as Array:
			if not choice_v is Dictionary:
				return "node %s has a bad choice" % str(node_id)
			var choice: Dictionary = choice_v
			if str(choice.get("text", "")).is_empty():
				return "node %s has a blank choice" % str(node_id)
			var choice_next := str(choice.get("next", ""))
			if not choice_next.is_empty() and not nodes.has(choice_next):
				return "choice in %s points at missing %s" % [str(node_id), choice_next]
	return ""


static func _validate_routes(nodes: Dictionary, routes_v: Variant) -> String:
	if not routes_v is Array:
		return "router is not a list"
	for entry_v in routes_v as Array:
		if not entry_v is Dictionary:
			return "router entry is not an object"
		var nxt := str((entry_v as Dictionary).get("next", ""))
		if nxt.is_empty() or not nodes.has(nxt):
			return "router points at missing %s" % nxt
	return ""
