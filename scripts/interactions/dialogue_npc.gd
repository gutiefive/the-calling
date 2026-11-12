class_name DialogueNpc
extends SpeechProp
## Opens a JSON conversation. The lines live in data/dialogue, not on the node.

@export var dialogue_id: String = ""


func interact(_actor: Node) -> void:
	interacted.emit()
	var box := _dialogue_box()
	if box == null:
		_fallback_line()
		return
	if box.has_method("is_conversation_open") and bool(box.call("is_conversation_open")):
		return
	if box.has_method("closed_this_frame") and bool(box.call("closed_this_frame")):
		return
	var opened := false
	if box.has_method("open_conversation"):
		opened = bool(box.call("open_conversation", dialogue_id, self))
	if not opened:
		_fallback_line()


func _dialogue_box() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("dialogue_box")


func _fallback_line() -> void:
	var text := line
	if text.is_empty() and not dialogue_id.is_empty():
		var data := DialogueRunner.load_conversation(dialogue_id)
		var nodes: Variant = data.get("nodes", {})
		if nodes is Dictionary and (nodes as Dictionary).has("greet"):
			var greet: Variant = (nodes as Dictionary)["greet"]
			if greet is Dictionary:
				text = str((greet as Dictionary).get("text", ""))
	if text.is_empty():
		return
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line(speaker_name, text)
