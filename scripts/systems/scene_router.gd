class_name SceneRouter
extends RefCounted
## Remembers which spawn marker the next room should use.
## A static class is enough: the id only has to survive one scene change.
## Headless tests set suppress_change so they can assert a door without unloading themselves.

static var next_spawn: StringName = &"default"
static var last_path: String = ""
static var suppress_change: bool = false


static func travel(tree: SceneTree, scene_path: String, spawn: StringName) -> void:
	if tree == null:
		push_error("SceneRouter: no scene tree")
		return
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("SceneRouter: missing destination %s" % scene_path)
		return
	next_spawn = spawn
	last_path = scene_path
	if suppress_change:
		return
	tree.change_scene_to_file(scene_path)


static func consume_spawn() -> StringName:
	var id := next_spawn
	next_spawn = &"default"
	return id
