extends Node
## Headless checks for Milestone 10 (Oak Street redesign).
## Prints M10_OK or M10_FAIL.
## Run: godot --headless --path . res://tests/m10/m10_validation.tscn

const STREET := "res://scenes/world/hardware_street.tscn"
const TILE := 32

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
	_static_tiles()
	await _layout_and_doors()
	await _routes_and_collision()
	await _old_save_fallback()
	_restore_user_save()
	_finish()


func _static_tiles() -> void:
	_check(FileAccess.file_exists("res://assets/tilesets/town_tiles.png"), "tileset PNG exists")
	_check(FileAccess.file_exists("res://assets/tilesets/town_tiles.tres"), "tileset resource exists")
	var tiles: TileSet = load("res://assets/tilesets/town_tiles.tres") as TileSet
	_check(tiles != null, "TileSet resource loads")
	if tiles == null:
		return
	var source := tiles.get_source(0) as TileSetAtlasSource
	_check(source != null, "TileSet has an atlas source")
	if source == null:
		return
	_check(source.has_tile(TownTiles.ASPHALT), "asphalt tile exists")
	_check(source.has_tile(TownTiles.LINE_H), "center line tile exists")
	_check(source.has_tile(TownTiles.CURB_N), "north curb tile exists")
	_check(source.has_tile(TownTiles.CURB_S), "south curb tile exists")
	_check(source.has_tile(TownTiles.SIDEWALK), "sidewalk tile exists")
	_check(source.has_tile(TownTiles.CROSSWALK_H), "crosswalk tile exists")
	_check(source.has_tile(TownTiles.DRIVEWAY), "driveway tile exists")
	_check(source.has_tile(TownTiles.PLANTER), "planter tile exists")
	_check(source.has_tile(TownTiles.FOUNDATION), "foundation tile exists")
	_check(FileAccess.file_exists("res://assets/environments/brights_diner.png"), "Bright's Diner art exists")
	_check(FileAccess.file_exists("res://assets/environments/post_office.png"), "post office art exists")
	_check(FileAccess.file_exists("res://assets/environments/barber_shop.png"), "barber art exists")
	_check(FileAccess.file_exists("res://assets/environments/vacant_shop.png"), "vacant shop art exists")
	_check(FileAccess.file_exists("res://assets/environments/parked_car_a.png"), "parked car art exists")
	_check(FileAccess.file_exists("res://assets/environments/fire_hydrant.png"), "hydrant art exists")
	_check(FileAccess.file_exists("res://assets/environments/trash_can.png"), "trash can art exists")


func _layout_and_doors() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null and ground.tile_set != null, "Oak Street has a Ground layer")
	if ground != null:
		_check(ground.get_cell_atlas_coords(Vector2i(20, 16)) == TownTiles.LINE_H, "the street has a painted center line")
		_check(ground.get_cell_atlas_coords(Vector2i(20, 15)) == TownTiles.ASPHALT, "the street uses asphalt")
		_check(ground.get_cell_atlas_coords(Vector2i(20, 14)) == TownTiles.CURB_N, "the north curb is painted")
		_check(ground.get_cell_atlas_coords(Vector2i(20, 19)) == TownTiles.CURB_S, "the south curb is painted")
		_check(TownTiles.is_sidewalk(ground.get_cell_atlas_coords(Vector2i(20, 13))), "the north sidewalk is painted")
		_check(TownTiles.is_sidewalk(ground.get_cell_atlas_coords(Vector2i(20, 20))), "the south sidewalk is painted")
		_check(ground.get_cell_atlas_coords(Vector2i(6, 16)) == TownTiles.CROSSWALK_H, "a crosswalk crosses the road")
		_check(ground.get_cell_atlas_coords(Vector2i(45, 14)) == TownTiles.DRIVEWAY, "Frank's bay has a driveway apron")
		_check(ground.get_cell_atlas_coords(Vector2i(57, 24)) == TownTiles.LINE_V, "Maple Lane branches off as a side street")
		_check(ground.get_cell_atlas_coords(Vector2i(72, 10)) == TownTiles.WATER, "the creek still uses the water tile")
		_check(ground.get_cell_atlas_coords(Vector2i(1, 13)) == TownTiles.SIDEWALK, "the church connection keeps a sidewalk")
		_check(ground.get_cell_atlas_coords(Vector2i(1, 16)) == TownTiles.LINE_H, "the church connection keeps the road")
	_check(room.get_node_or_null("Props/Diner") != null, "Bright's Diner is on the block")
	_check(room.get_node_or_null("Props/PostOffice") != null, "the post office is on the block")
	_check(room.get_node_or_null("Props/Barber") != null, "the barber is on the block")
	_check(room.get_node_or_null("Props/Vacant") != null, "a for-lease shop is on the block")
	_check(room.get_node_or_null("Props/CarA") != null and room.get_node_or_null("Props/CarB") != null, "parked cars sit on the street")
	_check(room.get_node_or_null("Props/Hydrant") != null, "a fire hydrant is on the sidewalk")
	_check(room.get_node_or_null("Props/TrashCan") != null, "a trash can is on the street")
	_check(_door_on_sidewalk(room, "Props/StoreDoor"), "the hardware door sits on the sidewalk")
	_check(_door_on_sidewalk(room, "Props/BayDoor"), "the bay door sits on the sidewalk")
	_check(not _building_on_road(room, "Props/Hardware"), "the hardware store does not overlap the road")
	_check(not _building_on_road(room, "Props/Garage"), "Frank's bay does not overlap the road")
	_check(not _building_on_road(room, "Props/Diner"), "the diner does not overlap the road")
	_check(not _building_on_road(room, "Props/Cottage"), "the cottage does not overlap the road")
	_check(_door_routes(room, "Props/StoreDoor", "hardware_interior.tscn", &"from_street"), "the store door routes to the hardware interior")
	_check(_door_routes(room, "Props/BayDoor", "bay_interior.tscn", &"from_street"), "the bay door routes to Frank's bay")
	_check(_door_routes(room, "Props/ToChurch", "church_exterior.tscn", &"from_street"), "the west door routes to the church grounds")
	_check(_door_routes(room, "Props/MapleDoor", "maple_lane.tscn", &"from_oak"), "the south door routes to Maple Lane")
	_check(_spawn_outside_door(room, "from_store", "Props/StoreDoor"), "from_store sits outside the store trigger")
	_check(_spawn_outside_door(room, "from_bay", "Props/BayDoor"), "from_bay sits outside the bay trigger")
	_check(_spawn_outside_door(room, "from_church", "Props/ToChurch"), "from_church sits outside the church trigger")
	_check(_spawn_outside_door(room, "from_maple", "Props/MapleDoor"), "from_maple sits outside the Maple Lane trigger")
	var camera := room.get_node_or_null("Props/Player/Camera2D") as Camera2D
	var world := room as WorldRoom
	if camera != null and world != null:
		_check(camera.limit_left == int(world.bounds.position.x) and camera.limit_top == int(world.bounds.position.y), "camera left/top match the street bounds")
		_check(camera.limit_right == int(world.bounds.end.x) and camera.limit_bottom == int(world.bounds.end.y), "camera right/bottom contain the street")
		_check(world.bounds.size.x >= 70.0 * TILE and world.bounds.size.y >= 32.0 * TILE, "the street is a walkable main-street block")
	room.free()
	await get_tree().process_frame


func _routes_and_collision() -> void:
	DayClock.set_time(5, 10, 0)
	var room := _instance(STREET)
	if room == null:
		return
	var sarah := room.get_node_or_null("Props/Sarah") as Node2D
	_check(sarah != null and _walkable(room, sarah.position), "Sarah stands on walkable ground")
	_check(_reachable(room, room.get_node_or_null("Spawns/default") as Node2D, sarah), "Sarah's post is reachable from the church gate")
	for node_name in ["NeighborA", "NeighborB", "NeighborC"]:
		var neighbor := room.get_node_or_null("Props/" + node_name) as AmbientTownsfolk
		_check(neighbor != null, "%s exists" % node_name)
		if neighbor == null:
			continue
		_check(_walkable(room, neighbor.position), "%s stands on walkable ground" % node_name)
		var points: Variant = neighbor.get("_points")
		# Routes are private; sample the authored loop from the node position.
		var route: Array[Vector2] = [
			neighbor.position,
			neighbor.position + Vector2(180, 0),
			neighbor.position + Vector2(180, 24),
			neighbor.position + Vector2(0, 24),
		]
		for point in route:
			_check(_walkable(room, point), "%s waypoint is walkable (%s)" % [node_name, point])
	var player := room.get_node_or_null("Props/Player") as Player
	var hardware := room.get_node_or_null("Props/Hardware") as Node2D
	if player != null and hardware != null:
		var left := hardware.global_position.x - 130.0
		player.global_position = Vector2(left, hardware.global_position.y - 56.0)
		player.velocity = Vector2.ZERO
		Input.action_press("move_right")
		for _i in 50:
			await get_tree().physics_frame
		Input.action_release("move_right")
		_check(player.global_position.x < hardware.global_position.x - 20.0, "the hardware store blocks the player")
		_check(player.global_position.x > left - 4.0, "the player reached the hardware wall")
	var car := room.get_node_or_null("Props/CarA") as Node2D
	if player != null and car != null:
		player.global_position = car.global_position + Vector2(0, 36)
		player.velocity = Vector2.ZERO
		Input.action_press("move_up")
		for _i in 40:
			await get_tree().physics_frame
		Input.action_release("move_up")
		_check(player.global_position.y > car.global_position.y, "a parked car blocks the player")
		_check(player.global_position.y < car.global_position.y + 34.0, "the player reached the parked car")
	room.free()
	await get_tree().process_frame


func _old_save_fallback() -> void:
	DayClock.set_time(4, 14, 0)
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(816, 300)
	SceneRouter.exact_facing = &"down"
	var room := _instance_keeping_exact(STREET)
	if room == null:
		return
	var player := room.get_node_or_null("Props/Player") as Node2D
	var default_spawn := room.get_node_or_null("Spawns/default") as Node2D
	_check(player != null and default_spawn != null, "an old Oak Street save can load")
	if player != null:
		_check(_walkable(room, player.global_position), "a blocked save snaps onto walkable ground")
		_check(player.global_position.distance_to(Vector2(816, 300)) > 40.0, "a save inside a shop does not keep the old coordinates")
	room.free()
	await get_tree().process_frame
	SceneRouter.exact_active = true
	SceneRouter.exact_position = Vector2(120, 544)
	SceneRouter.exact_facing = &"right"
	room = _instance_keeping_exact(STREET)
	if room == null:
		return
	player = room.get_node_or_null("Props/Player") as Node2D
	_check(player != null and player.global_position.distance_to(Vector2(120, 544)) < 2.0, "a valid Oak Street save keeps its position")
	room.free()
	await get_tree().process_frame


func _door_on_sidewalk(room: Node, node_path: String) -> bool:
	var door := room.get_node_or_null(node_path) as Node2D
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if door == null or ground == null:
		return false
	var cell := Vector2i(int(door.position.x / TILE), int(door.position.y / TILE))
	for offset in [Vector2i.ZERO, Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		if TownTiles.is_sidewalk(ground.get_cell_atlas_coords(cell + offset)):
			return true
	return false


func _building_on_road(room: Node, node_path: String) -> bool:
	var sprite := room.get_node_or_null(node_path) as Sprite2D
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if sprite == null or sprite.texture == null or ground == null:
		return true
	var sample := sprite.position + Vector2(0.0, -40.0)
	var cell := Vector2i(int(sample.x / TILE), int(sample.y / TILE))
	return TownTiles.is_road(ground.get_cell_atlas_coords(cell))


func _door_routes(room: Node, node_path: String, dest: String, spawn: StringName) -> bool:
	var door := room.get_node_or_null(node_path)
	if door == null:
		return false
	var scene := str(door.get("destination_scene"))
	var dest_spawn: StringName = door.get("destination_spawn")
	return scene.ends_with(dest) and dest_spawn == spawn


func _spawn_outside_door(room: Node, spawn_id: String, door_path: String) -> bool:
	var marker := room.get_node_or_null("Spawns/" + spawn_id) as Node2D
	var door := room.get_node_or_null(door_path) as Node2D
	if marker == null or door == null:
		return false
	var radius := 26.0
	var raw: Variant = door.get("radius")
	if raw is float or raw is int:
		radius = float(raw)
	return marker.global_position.distance_to(door.global_position) > radius + 2.0


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
		var cell := Vector2i(int(pos.x / TILE), int(pos.y / TILE))
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


func _reachable(room: Node, from_node: Node2D, to_node: Node2D) -> bool:
	if from_node == null or to_node == null:
		return false
	var blocks: Array[Rect2] = []
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids != null:
		for child in solids.get_children():
			var shape_node := child as CollisionShape2D
			if shape_node == null or not (shape_node.shape is RectangleShape2D):
				continue
			var rect := shape_node.shape as RectangleShape2D
			if rect.size.x < 24.0 and rect.size.y < 16.0:
				continue
			blocks.append(Rect2(shape_node.position - rect.size * 0.5, rect.size))
	var stand := to_node.position + Vector2(0.0, 28.0)
	var plan := NpcRoute.plan(from_node.position, stand, blocks)
	return bool(plan.get("ok", false))


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


func _instance_keeping_exact(path: String) -> Node:
	var packed := load(path) as PackedScene
	_check(packed != null, "load saved " + path)
	if packed == null:
		return null
	var room := packed.instantiate()
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
	print("M10_OK" if not _failed else "M10_FAIL")
	get_tree().quit(0 if not _failed else 1)
