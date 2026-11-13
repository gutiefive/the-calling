class_name StoryQuery
extends RefCounted
## Shared dialogue / happening / bark conditions for leanings and threads.


static func holds(condition: Dictionary) -> bool:
	if condition.has("lean_at_least"):
		var pair_v: Variant = condition["lean_at_least"]
		if pair_v is Array and (pair_v as Array).size() >= 2:
			var pair: Array = pair_v
			var path := _pastor_path()
			return path != null and bool(path.call("lean_at_least", str(pair[0]), int(pair[1])))
		return false
	if condition.has("dominant_is"):
		var path := _pastor_path()
		if path == null:
			return str(condition["dominant_is"]) == ""
		return str(path.call("dominant")) == str(condition["dominant_is"])
	if condition.has("thread_is"):
		var pair_v: Variant = condition["thread_is"]
		if pair_v is Array and (pair_v as Array).size() >= 2:
			var pair: Array = pair_v
			var threads := _threads()
			return threads != null and bool(threads.call("is_state", str(pair[0]), str(pair[1])))
		return false
	if condition.has("thread_open"):
		var threads := _threads()
		return threads != null and bool(threads.call("is_open", str(condition["thread_open"])))
	if condition.has("thread_missed"):
		var threads := _threads()
		return threads != null and bool(threads.call("is_missed", str(condition["thread_missed"])))
	return false


static func _pastor_path() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("PastorPath")


static func _threads() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("StoryThreads")
