extends Node
## Headless checks for Milestone 11C (rooftop signs, evening posts).
## Prints M11C_OK or M11C_FAIL.
## Run: godot --headless --path . res://tests/m11c/m11c_validation.tscn

const STREET := "res://scenes/world/hardware_street.tscn"
const MIN_SIGN := Vector2(72, 16)
const PERSON_SIZE := Vector2(32, 48)

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
	var path := get_node_or_null("/root/PastorPath")
	if path != null and path.has_method("reset"):
		path.call("reset")
	_static_data()
	await _one_sign_each()
	await _sign_placement()
	await _evening_posts()
	_restore_user_save()
	_finish()


func _static_data() -> void:
	var street_src := FileAccess.get_file_as_string("res://scripts/art/street_frames.gd")
	_check(street_src.contains("static func build_rooftop_sign"), "rooftop sign builder exists")
	_check(street_src.contains("static func build_hanging_sign"), "sign builder keeps the old name")
	var world_src := FileAccess.get_file_as_string("res://scripts/world/hardware_street.gd")
	_check(world_src.contains("_add_rooftop_sign"), "Oak Street places rooftop signs")
	_check(not world_src.contains("Y_DOOR - 12"), "Oak Street no longer hangs signs at the door")
	var hanging_at := street_src.find("static func build_hanging_sign")
	if hanging_at > 0:
		var facades := street_src.substr(0, hanging_at)
		_check(not facades.contains("_stamp_text"), "south facades have no painted names")


func _one_sign_each() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var named := 0
	for row in TownFacades.oak_storefronts():
		var sign_id := str(row.get("sign_id", ""))
		var node_name := str(row.get("node", ""))
		if sign_id.is_empty() or node_name.is_empty():
			continue
		named += 1
		var sign := room.get_node_or_null("Props/%sSign" % node_name) as Sprite2D
		_check(sign != null and sign.texture != null, "%s has exactly one rooftop sign" % node_name)
		var extras := 0
		var props := room.get_node_or_null("Props")
		if props != null:
			for child in props.get_children():
				if child.name.begins_with(node_name) and str(child.name).contains("Sign") and child != sign:
					extras += 1
		_check(extras == 0, "%s has no extra sign nodes" % node_name)
	_check(named >= 10, "both sides of Oak Street keep rooftop signs (%d)" % named)
	var group_signs := 0
	var tree := get_tree()
	if tree != null:
		for node in tree.get_nodes_in_group("shop_sign"):
			if room.is_ancestor_of(node):
				group_signs += 1
	_check(group_signs == named, "shop_sign group matches storefronts with names (%d/%d)" % [group_signs, named])
	room.free()
	await get_tree().process_frame


func _sign_placement() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	for row in TownFacades.oak_storefronts():
		var sign_id := str(row.get("sign_id", ""))
		var node_name := str(row.get("node", ""))
		if sign_id.is_empty() or node_name.is_empty():
			continue
		var building := room.get_node_or_null("Props/" + node_name) as Sprite2D
		var sign := room.get_node_or_null("Props/%sSign" % node_name) as Sprite2D
		_check(building != null and sign != null, "%s building and sign exist" % node_name)
		if building == null or sign == null or sign.texture == null:
			continue
		var size := sign.texture.get_size()
		_check(size.x >= MIN_SIGN.x and size.y >= MIN_SIGN.y, "%s sign is readable (%sx%s)" % [node_name, size.x, size.y])
		_check(absf(sign.position.y - building.position.y) <= 1.0, "%s sign shares the building y-sort origin" % node_name)
		_check(not (sign is SolidProp), "%s sign is not a sidewalk blocker" % node_name)
		var sign_rect := _sprite_rect(sign)
		var door := _storefront_door(room, row)
		_check(door != null, "%s has a door trigger" % node_name)
		if door == null:
			continue
		var opening := _door_opening(door)
		var apron := _sidewalk_apron(door)
		_check(sign_rect.end.y <= opening.position.y + 0.5, "%s sign sits above the door top" % node_name)
		_check(not sign_rect.intersects(opening), "%s sign does not cover the door opening" % node_name)
		_check(not sign_rect.intersects(apron), "%s sign does not cover the sidewalk in front of the door" % node_name)
		_check(not sign_rect.intersects(_step_rect(door)), "%s sign does not cover the step" % node_name)
	room.free()
	await get_tree().process_frame


func _evening_posts() -> void:
	DayClock.set_time(4, 18, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var people: Array[Node2D] = []
	_collect_ambient(room, people)
	_check(people.size() >= 2, "evening places ambient townsfolk on Oak Street (saw %d)" % people.size())
	var signs: Array[Rect2] = []
	var doors: Array[Node2D] = []
	for row in TownFacades.oak_storefronts():
		var sign_id := str(row.get("sign_id", ""))
		var node_name := str(row.get("node", ""))
		if sign_id.is_empty() or node_name.is_empty():
			continue
		var sign := room.get_node_or_null("Props/%sSign" % node_name) as Sprite2D
		if sign != null and sign.texture != null:
			signs.append(_sprite_rect(sign))
		var door := _storefront_door(room, row)
		if door != null:
			doors.append(door)
	for person in people:
		_check(_walkable(room, person.position), "evening %s stands on walkable ground" % person.name)
		var body := _person_rect(person)
		for sign_rect in signs:
			_check(not body.intersects(sign_rect), "evening %s does not cover a storefront sign" % person.name)
		for door in doors:
			var radius := _door_radius(door)
			var dist := person.global_position.distance_to(door.global_position)
			_check(dist > radius + 8.0, "evening %s does not block %s" % [person.name, door.name])
	room.free()
	await get_tree().process_frame


func _storefront_door(room: Node, row: Dictionary) -> Node2D:
	var scheduled := str(row.get("scheduled", ""))
	if scheduled == "thomas":
		return room.get_node_or_null("Props/StoreDoor") as Node2D
	if scheduled == "frank":
		return room.get_node_or_null("Props/BayDoor") as Node2D
	return room.get_node_or_null("Props/%sDoor" % str(row.get("node", ""))) as Node2D


func _sprite_rect(sprite: Sprite2D) -> Rect2:
	if sprite == null or sprite.texture == null:
		return Rect2()
	var size := sprite.texture.get_size()
	var origin := sprite.global_position + sprite.offset
	if sprite.centered:
		origin -= size * 0.5
	return Rect2(origin, size)


func _person_rect(person: Node2D) -> Rect2:
	return Rect2(person.global_position + Vector2(-PERSON_SIZE.x * 0.5, -PERSON_SIZE.y), PERSON_SIZE)


func _door_opening(door: Node2D) -> Rect2:
	return Rect2(door.global_position + Vector2(-22.0, -56.0), Vector2(44.0, 56.0))


func _sidewalk_apron(door: Node2D) -> Rect2:
	return Rect2(door.global_position + Vector2(-28.0, -4.0), Vector2(56.0, 40.0))


func _step_rect(door: Node2D) -> Rect2:
	return Rect2(door.global_position + Vector2(-18.0, -12.0), Vector2(36.0, 16.0))


func _door_radius(door: Node2D) -> float:
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	return radius


func _collect_ambient(room: Node, people: Array[Node2D]) -> void:
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("ambient_townsfolk"):
		if node is Node2D and room.is_ancestor_of(node) and (node as CanvasItem).visible:
			people.append(node as Node2D)


func _walkable(room: Node, pos: Vector2) -> bool:
	var world := room as WorldRoom
	if world != null:
		var pad := 10.0
		if pos.x < world.bounds.position.x + pad or pos.y < world.bounds.position.y + pad:
			return false
		if pos.x > world.bounds.end.x - pad or pos.y > world.bounds.end.y - pad:
			return false
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if ground != null:
		var cell := Vector2i(int(pos.x / 32.0), int(pos.y / 32.0))
		if ground.get_cell_atlas_coords(cell) == TownTiles.WATER:
			return false
	return not _inside_large_solid(room, pos)


func _inside_large_solid(room: Node, pos: Vector2) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	var feet := Rect2(pos + Vector2(-6.0, -8.0), Vector2(12.0, 8.0))
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		if rect.size.x < 24.0 and rect.size.y < 16.0:
			continue
		var block := Rect2(shape_node.global_position - rect.size * 0.5, rect.size)
		if block.intersects(feet):
			return true
	return false


func _instance(path: String) -> Node:
	SceneRouter.exact_active = false
	SceneRouter.next_spawn = &"from_church"
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


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
	elif FileAccess.file_exists(SaveGame.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveGame.SAVE_PATH))


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	print("M11C_OK" if not _failed else "M11C_FAIL")
	get_tree().quit(0 if not _failed else 1)
