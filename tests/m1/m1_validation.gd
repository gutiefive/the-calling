extends Node
## Headless checks for Milestone 1. Prints M1_OK or M1_FAIL.
## Run: godot --headless --path . res://tests/m1/m1_validation.tscn

var _failed: bool = false
var _hits: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_static_checks()
	await _check_exterior()
	_check_sanctuary()
	_finish()


func _static_checks() -> void:
	print("ENGINE ", Engine.get_version_info().string)
	for path in [
		"res://scenes/main.tscn",
		"res://scenes/world/church_exterior.tscn",
		"res://scenes/world/sanctuary.tscn",
		"res://scenes/actors/player.tscn",
		"res://scripts/art/placeholder_art.gd",
		"res://assets/source/palette/the_calling_master.gpl",
	]:
		_check(FileAccess.file_exists(path), "file " + path)
	var main := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	_check(main.ends_with("main.tscn"), "main scene is res://scenes/main.tscn")
	for action in ["move_up", "move_down", "move_left", "move_right", "interact", "pause", "cycle_time"]:
		_check(InputMap.has_action(action), "input action " + action)
		if InputMap.has_action(action):
			_check(InputMap.action_get_events(action).size() > 0, action + " has a key")
	var diagonal := Player.velocity_from_input(Vector2(1, 1), 100.0)
	var cardinal := Player.velocity_from_input(Vector2(1, 0), 100.0)
	_check(is_equal_approx(diagonal.length(), cardinal.length()), "diagonal speed matches cardinal speed")
	_check(Player.velocity_from_input(Vector2.ZERO, 100.0) == Vector2.ZERO, "no input means no velocity")
	var church_tex := PlaceholderArt.church_front()
	var sheet := PlaceholderArt.player_sheet()
	_check(church_tex != null and church_tex.get_size() == Vector2(384, 160), "church placeholder is 384x160")
	_check(sheet != null and sheet.get_size() == Vector2(192, 192), "player sheet is 6 by 4 frames")
	_check(TimeOfDay.phase == TimeOfDay.Phase.DAY, "a fresh process starts at day")
	TimeOfDay.cycle()
	_check(TimeOfDay.phase_name() == "Evening", "cycle reaches evening")
	TimeOfDay.cycle()
	_check(TimeOfDay.phase_name() == "Night", "cycle reaches night")
	var night := TimeOfDay.ambient(false)
	_check(night.r > 0.45 and night.g > 0.45 and night.b > 0.45, "exterior night ambient stays legible")
	TimeOfDay.cycle()
	_check(TimeOfDay.phase == TimeOfDay.Phase.DAY, "cycle wraps back to day")
	Input.action_press("move_right")
	Input.action_press("move_down")
	var vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_check(is_equal_approx(vector.length(), 1.0), "Input.get_vector normalizes diagonals")
	_release()


func _check_exterior() -> void:
	SceneRouter.next_spawn = &"default"
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var spawn := room.get_node("Spawns/default") as Node2D
	_check(player.global_position.distance_to(spawn.global_position) < 1.0, "default spawn placement")
	_check(player.get_facing() == &"up", "default spawn faces the church")
	room.free()

	SceneRouter.next_spawn = &"from_sanctuary"
	room = _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	player = room.get_node("Props/Player") as Player
	spawn = room.get_node("Spawns/from_sanctuary") as Node2D
	_check(player.global_position.distance_to(spawn.global_position) < 1.0, "return spawn placement")
	_check(player.get_facing() == &"down", "return spawn faces away from the door")
	_check(player.interact_lock_active(), "interact lock is on at spawn")

	var camera := player.get_node("Camera2D") as Camera2D
	_check(camera.limit_right == 36 * 32 and camera.limit_bottom == 26 * 32, "camera stays inside the grounds")
	_check(not camera.position_smoothing_enabled, "camera smoothing is off")
	var ground := room.get_node("Ground") as TileMapLayer
	_check(ground.get_cell_source_id(Vector2i(0, 0)) != -1, "grass is painted")
	_check(ground.get_cell_atlas_coords(Vector2i(18, 12)) == Vector2i(2, 0), "path leads to the church")
	_check(_count_interactables(room) >= 2, "Margaret and the notice are still interactable")

	var right_dist := await _travel(player, ["move_right"], 18)
	var diagonal_dist := await _travel(player, ["move_right", "move_down"], 18)
	_check(right_dist > 8.0, "holding D moves the player (%s px)" % snappedf(right_dist, 0.1))
	_check(diagonal_dist > 8.0, "diagonal movement moves the player")
	_check(diagonal_dist < right_dist * 1.15, "diagonal is not faster (%s vs %s)" % [snappedf(diagonal_dist, 0.1), snappedf(right_dist, 0.1)])
	player.global_position = Vector2(400, 640)
	player.velocity = Vector2.ZERO
	Input.action_press("move_left")
	await get_tree().physics_frame
	Input.action_release("move_left")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(player.velocity.length() < 0.01, "releasing the keys stops movement")

	var tree := room.get_node("Props/Tree1") as Node2D
	player.global_position = tree.global_position + Vector2(0, 42)
	player.velocity = Vector2.ZERO
	Input.action_press("move_up")
	for _i in 40:
		await get_tree().physics_frame
	Input.action_release("move_up")
	_check(player.global_position.y > tree.global_position.y, "tree collision stops the player")
	_check(player.global_position.y < tree.global_position.y + 38.0, "player actually walked up to the tree")

	var church := room.get_node("Props/Church") as Sprite2D
	var left := church.global_position.x - church.texture.get_width() * 0.5
	player.global_position = Vector2(left - 28.0, church.global_position.y - 70.0)
	player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	for _i in 45:
		await get_tree().physics_frame
	Input.action_release("move_right")
	_check(player.global_position.x < left + 2.0, "church wall blocks the player")
	_check(player.global_position.x > left - 26.0, "player reached the church wall")

	var door := room.get_node("Props/Door") as Door
	_check(door is Area2D and not door.is_in_group("interactable"), "the sanctuary door is a walk-in trigger")
	SceneRouter.suppress_change = true
	SceneRouter.last_path = ""
	player.global_position = door.global_position + Vector2(0, 90)
	player.velocity = Vector2.ZERO
	Input.action_press("move_up")
	for _i in 80:
		await get_tree().physics_frame
	Input.action_release("move_up")
	var bottom := church.global_position.y
	_check(player.global_position.y < bottom - 6.0, "the doorway can be walked into")
	_check(player.global_position.y > bottom - 36.0, "the inner church wall still blocks")

	var margaret := room.get_node("Props/Margaret") as SpeechProp
	_hits = 0
	margaret.interacted.connect(_on_hit)
	player.global_position = margaret.global_position + Vector2(0, 28)
	player.velocity = Vector2.ZERO
	player.set_interact_lock(5.0)
	Input.action_press("interact")
	for _i in 4:
		await get_tree().physics_frame
	_check(_hits == 0, "interact lock ignores E")
	_release()
	await get_tree().physics_frame
	player.clear_interact_lock()
	Input.action_press("interact")
	for _i in 10:
		await get_tree().physics_frame
	_check(_hits == 1, "holding E interacts once")
	_release()
	await get_tree().physics_frame
	Input.action_press("interact")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(_hits == 2, "a new press interacts again")
	_release()
	var banner := room.get_node("HUD/Banner/Label") as RichTextLabel
	_check(room.get_node("HUD/Banner").visible, "Margaret's line is shown")
	_check(banner.text.contains("Margaret"), "the line names Margaret")

	await get_tree().process_frame
	var prompt := room.get_node("HUD/Prompt")
	_check(prompt.visible and player.get_focus() == margaret, "prompt appears beside Margaret")
	player.global_position = Vector2(80, 760)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(player.get_focus() == null and not prompt.visible, "prompt hides out of range")

	SceneRouter.suppress_change = true
	SceneRouter.last_path = ""
	player.global_position = door.global_position + Vector2(0, 70)
	player.velocity = Vector2.ZERO
	player.clear_interact_lock()
	_release()
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_press("move_up")
	for _i in 40:
		await get_tree().physics_frame
	Input.action_release("move_up")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(SceneRouter.last_path.ends_with("sanctuary.tscn"), "walking into the door requests the sanctuary")
	_check(SceneRouter.next_spawn == &"from_exterior", "door sets the interior spawn")
	_release()
	await get_tree().physics_frame
	SceneRouter.last_path = ""
	player.global_position = door.global_position + Vector2(0, 20)
	player.velocity = Vector2.ZERO
	player.clear_interact_lock()
	await get_tree().physics_frame
	Input.action_press("interact")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(SceneRouter.last_path == "", "E on a door does not change rooms")
	_release()
	SceneRouter.suppress_change = false

	var modulate := room.get_node("Lighting/CanvasModulate") as CanvasModulate
	var lamp := room.get_node("Props/Lamp/Glow") as PointLight2D
	var window := room.get_node("Lighting/WindowL") as PointLight2D
	var view := room.get_node("Lighting")
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	view.apply()
	var day: Color = modulate.color
	var day_lamp := lamp.energy
	TimeOfDay.set_phase(TimeOfDay.Phase.EVENING)
	view.apply()
	var evening: Color = modulate.color
	TimeOfDay.set_phase(TimeOfDay.Phase.NIGHT)
	view.apply()
	_check(day != evening and evening != modulate.color, "day, evening, and night look different")
	_check(modulate.color.r > 0.45 and modulate.color.g > 0.45 and modulate.color.b > 0.45, "night on the grounds stays legible")
	_check(lamp.energy > day_lamp and lamp.energy > 0.8, "the lamp brightens at night")
	_check(window.energy > 0.4, "church windows glow at night")
	_check(room.get_node("HUD/PhaseLabel").text == "Night", "the phase label follows the cycle")
	var pause := room.get_node("HUD/Pause")
	pause.toggle_pause()
	_check(get_tree().paused and pause.visible, "pause turns on")
	pause.toggle_pause()
	_check(not get_tree().paused and not pause.visible, "pause turns off")
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	room.free()


func _check_sanctuary() -> void:
	SceneRouter.next_spawn = &"from_exterior"
	var room := _instance("res://scenes/world/sanctuary.tscn")
	if room == null:
		return
	var player := room.get_node("Props/Player") as Player
	var spawn := room.get_node("Spawns/from_exterior") as Node2D
	_check(player.global_position.distance_to(spawn.global_position) < 1.0, "sanctuary spawn placement")
	_check(player.get_facing() == &"up", "sanctuary spawn faces the front")
	var door := room.get_node("Props/Door") as Door
	_check(door.destination_scene.ends_with("church_exterior.tscn"), "exit door targets the grounds")
	_check(door.destination_spawn == &"from_sanctuary", "exit door uses the outdoor return spawn")
	var ground := room.get_node("Ground") as TileMapLayer
	_check(ground.get_cell_atlas_coords(Vector2i(14, 8)) == Vector2i(5, 0), "sanctuary aisle is carpet")
	TimeOfDay.set_phase(TimeOfDay.Phase.NIGHT)
	room.get_node("Lighting").apply()
	var modulate := room.get_node("Lighting/CanvasModulate") as CanvasModulate
	var sconce := room.get_node("Lighting/SconceL") as PointLight2D
	_check(modulate.color.r > 0.5 and modulate.color.g > 0.45 and modulate.color.b > 0.4, "interior night stays legible")
	_check(sconce.energy > 0.8, "interior lamps are on at night")
	TimeOfDay.set_phase(TimeOfDay.Phase.DAY)
	room.free()


func _instance(path: String) -> Node:
	var packed := load(path) as PackedScene
	if packed == null:
		_check(false, "load " + path)
		return null
	var room := packed.instantiate()
	add_child(room)
	return room


func _travel(player: Player, actions: Array[String], frames: int) -> float:
	_release()
	player.global_position = Vector2(400, 640)
	player.velocity = Vector2.ZERO
	for action in actions:
		Input.action_press(action)
	var start := player.global_position
	for _i in frames:
		await get_tree().physics_frame
	var dist := player.global_position.distance_to(start)
	_release()
	await get_tree().physics_frame
	return dist


func _count_interactables(room: Node) -> int:
	var found := 0
	for node in get_tree().get_nodes_in_group("interactable"):
		if room.is_ancestor_of(node):
			found += 1
	return found


func _on_hit() -> void:
	_hits += 1


func _release() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right", "interact", "pause", "cycle_time"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	_release()
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	print("M1_OK" if not _failed else "M1_FAIL")
	tree.quit(0 if not _failed else 1)
