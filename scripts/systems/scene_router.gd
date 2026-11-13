class_name SceneRouter
extends RefCounted
## Remembers which spawn marker the next room should use.
## A static class is enough: the id only has to survive one scene change.
## Headless tests set suppress_change so they can assert a door without unloading themselves.

static var next_spawn: StringName = &"default"
static var last_path: String = ""
static var suppress_change: bool = false
static var exact_active: bool = false
static var exact_position: Vector2 = Vector2.ZERO
static var exact_facing: StringName = &"down"


static func travel(tree: SceneTree, scene_path: String, spawn: StringName) -> void:
	if tree == null:
		push_error("SceneRouter: no scene tree")
		return
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("SceneRouter: missing destination %s" % scene_path)
		exact_active = false
		return
	# A door names a spawn marker. Only a save load keeps an exact position.
	if spawn != &"saved":
		exact_active = false
	next_spawn = spawn
	last_path = scene_path
	if suppress_change:
		return
	var fade := tree.root.get_node_or_null("SceneFade")
	if fade != null and fade.has_method("play"):
		fade.call("play")
	tree.change_scene_to_file(scene_path)


static func travel_exact(tree: SceneTree, scene_path: String, pos: Vector2, facing: StringName) -> void:
	exact_active = true
	exact_position = pos
	exact_facing = facing
	travel(tree, scene_path, &"saved")


static func apply_exact(player: Node2D) -> bool:
	if not exact_active or player == null:
		return false
	exact_active = false
	next_spawn = &"default"
	player.global_position = exact_position
	if player is CharacterBody2D:
		(player as CharacterBody2D).velocity = Vector2.ZERO
	if player.has_method("set_facing"):
		player.call("set_facing", exact_facing)
	if player.has_method("set_interact_lock"):
		player.call("set_interact_lock", 0.35)
	return true


static func consume_spawn() -> StringName:
	var id := next_spawn
	next_spawn = &"default"
	return id
