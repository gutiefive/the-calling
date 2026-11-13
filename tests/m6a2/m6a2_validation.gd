extends Node
## Headless checks for Milestone 6A part 2 (environment art).
## Prints M6A2_OK or M6A2_FAIL.
## Run: godot --headless --path . res://tests/m6a2/m6a2_validation.tscn

const TILESET_PNG := "res://assets/tilesets/town_tiles.png"
const TILESET_TRES := "res://assets/tilesets/town_tiles.tres"
const PROP_PATHS: PackedStringArray = [
	"res://assets/environments/church_front.png",
	"res://assets/environments/tree.png",
	"res://assets/environments/bench.png",
	"res://assets/environments/lamp_post.png",
	"res://assets/environments/notice_board.png",
	"res://assets/environments/mailbox.png",
]
const PROP_SIZES: Array[Vector2i] = [
	Vector2i(384, 160),
	Vector2i(48, 80),
	Vector2i(48, 32),
	Vector2i(24, 56),
	Vector2i(32, 48),
	Vector2i(32, 40),
]
const ROOMS: PackedStringArray = [
	"res://scenes/world/church_exterior.tscn",
	"res://scenes/world/hardware_street.tscn",
	"res://scenes/world/maple_lane.tscn",
]

var _failed: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_static_checks()
	await _scene_checks()
	_finish()


func _static_checks() -> void:
	var allowed := _palette_keys()
	_check(not allowed.is_empty(), "master palette loaded")
	_check(FileAccess.file_exists(TILESET_PNG), "file " + TILESET_PNG)
	_check(FileAccess.file_exists(TILESET_TRES), "file " + TILESET_TRES)
	_check(FileAccess.file_exists("res://tools/art/author_environment.gd"), "environment generator exists")
	_check(FileAccess.file_exists("res://scripts/art/environment_frames.gd"), "environment frames exist")
	_check(FileAccess.file_exists("res://scripts/art/town_tiles.gd"), "tile atlas map exists")
	if FileAccess.file_exists(TILESET_PNG):
		var atlas := _load_png(TILESET_PNG)
		_check(atlas != null and atlas.get_width() == 256 and atlas.get_height() == 128, "tileset PNG is 256x128")
		if atlas != null:
			var off := _first_off_palette(atlas, allowed)
			_check(off.is_empty(), "tileset uses only palette colors%s" % ("" if off.is_empty() else " (%s)" % off))
	var tiles: TileSet = load(TILESET_TRES) as TileSet
	_check(tiles != null, "TileSet resource loads")
	if tiles != null:
		_check(tiles.tile_size == Vector2i(32, 32), "TileSet cell is 32x32")
		var source := tiles.get_source(0) as TileSetAtlasSource
		_check(source != null, "TileSet has an atlas source")
		if source != null:
			_check(source.has_tile(Vector2i(2, 0)), "path tile exists")
			_check(source.has_tile(Vector2i(5, 0)), "road tile exists")
			_check(source.has_tile(Vector2i(7, 0)), "water tile exists")
			_check(source.has_tile(Vector2i(3, 1)), "church floor tile exists")
			_check(source.has_tile(Vector2i(0, 2)), "asphalt tile exists")
			_check(source.has_tile(Vector2i(7, 2)), "crosswalk tile exists")
	for i in PROP_PATHS.size():
		var path := PROP_PATHS[i]
		var size := PROP_SIZES[i]
		_check(FileAccess.file_exists(path), "file " + path)
		if not FileAccess.file_exists(path):
			continue
		var image := _load_png(path)
		_check(image != null and image.get_width() == size.x and image.get_height() == size.y, "%s is %dx%d" % [path.get_file(), size.x, size.y])
		if image == null:
			continue
		var off_prop := _first_off_palette(image, allowed)
		_check(off_prop.is_empty(), "%s uses only palette colors%s" % [path.get_file(), "" if off_prop.is_empty() else " (%s)" % off_prop])


func _scene_checks() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	var church := _instance("res://scenes/world/church_exterior.tscn")
	if church == null:
		return
	_check_tileset(church, "church grounds")
	var ground := church.get_node_or_null("Ground") as TileMapLayer
	if ground != null:
		_check(ground.get_cell_atlas_coords(GroundsLayout.PATH_CHURCH) == TownTiles.PATH, "church path still uses atlas (2,0)")
		_check(ground.get_cell_source_id(Vector2i(0, 0)) != -1, "church grass is painted")
	_check_authored_sprite(church, "Props/Church", "church_front.png", Vector2(384, 160))
	_check_authored_sprite(church, "Props/Tree1", "tree.png", Vector2(48, 80))
	_check_authored_sprite(church, "Props/Bench", "bench.png", Vector2(48, 32))
	_check_authored_sprite(church, "Props/Lamp", "lamp_post.png", Vector2(24, 56))
	_check_authored_sprite(church, "Props/Mailbox", "mailbox.png", Vector2(32, 40))
	_check_notice(church)
	_check_church_collision(church)
	_check_block(church, "Props/Tree1", Vector2(14, 8))
	_check_block(church, "Props/Bench", Vector2(36, 10))
	_check_block(church, "Props/Lamp", Vector2(10, 8))
	_check_block(church, "Props/Notice", Vector2(14, 8))
	_check_block(church, "Props/Mailbox", Vector2(12, 8))
	var player := church.get_node_or_null("Props/Player") as Player
	if player != null:
		var shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		_check(shape != null and shape.position == Vector2(0, -4), "player collision origin is unchanged")
		var rect: RectangleShape2D = null
		if shape != null and shape.shape is RectangleShape2D:
			rect = shape.shape as RectangleShape2D
		_check(rect != null and rect.size == Vector2(12, 8), "player collision size is unchanged")
	church.free()
	var street := _instance("res://scenes/world/hardware_street.tscn")
	if street == null:
		return
	_check_tileset(street, "Oak Street")
	var street_ground := street.get_node_or_null("Ground") as TileMapLayer
	if street_ground != null:
		_check(street_ground.get_cell_atlas_coords(Vector2i(72, 10)) == TownTiles.WATER, "creek still uses atlas (7,0)")
	_check_authored_sprite(street, "Props/Tree", "tree.png", Vector2(48, 80))
	_check_authored_sprite(street, "Props/Bench", "bench.png", Vector2(48, 32))
	_check_authored_sprite(street, "Props/Lamp", "lamp_post.png", Vector2(24, 56))
	_check_authored_sprite(street, "Props/Mailbox", "mailbox.png", Vector2(32, 40))
	_check_block(street, "Props/Tree", Vector2(14, 8))
	_check_block(street, "Props/Bench", Vector2(36, 10))
	_check_block(street, "Props/Lamp", Vector2(10, 8))
	_check_block(street, "Props/Mailbox", Vector2(12, 8))
	street.free()
	var lane := _instance("res://scenes/world/maple_lane.tscn")
	if lane == null:
		return
	_check_tileset(lane, "Maple Lane")
	_check_authored_sprite(lane, "Props/Bench", "bench.png", Vector2(48, 32))
	_check_block(lane, "Props/Bench", Vector2(36, 10))
	lane.free()
	for path in ROOMS:
		var room := _instance(path)
		_check(room != null, "boots " + path)
		if room != null:
			room.free()
	await get_tree().process_frame


func _check_tileset(room: Node, label: String) -> void:
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	_check(ground != null, "%s has a Ground layer" % label)
	if ground == null or ground.tile_set == null:
		_check(false, "%s uses town_tiles.tres" % label)
		return
	_check(ground.tile_set.resource_path.ends_with("town_tiles.tres"), "%s uses town_tiles.tres" % label)


func _check_authored_sprite(room: Node, node_path: String, file_name: String, size: Vector2) -> void:
	var sprite := room.get_node_or_null(node_path) as Sprite2D
	_check(sprite != null and sprite.texture != null, "%s exists" % node_path)
	if sprite == null or sprite.texture == null:
		return
	_check(sprite.texture.get_size() == size, "%s size is unchanged" % node_path)
	var path := sprite.texture.resource_path
	_check(path.ends_with(file_name), "%s uses %s" % [node_path, file_name])
	_check(sprite.centered and is_equal_approx(sprite.offset.y, -size.y * 0.5), "%s origin is at the base" % node_path)


func _check_notice(room: Node) -> void:
	var notice := room.get_node_or_null("Props/Notice") as SpeechProp
	_check(notice != null, "notice board exists")
	if notice == null:
		return
	var sprite := notice.get_node_or_null("Sprite") as AnimatedSprite2D
	_check(sprite != null and sprite.sprite_frames != null, "notice has frames")
	if sprite == null or sprite.sprite_frames == null or not sprite.sprite_frames.has_animation("idle"):
		return
	var tex := sprite.sprite_frames.get_frame_texture("idle", 0)
	var atlas := tex as AtlasTexture
	_check(atlas != null and atlas.atlas != null, "notice frames use an atlas")
	if atlas == null or atlas.atlas == null:
		return
	_check(atlas.atlas.resource_path.ends_with("notice_board.png"), "notice uses notice_board.png")
	_check(is_equal_approx(sprite.offset.y, -24.0), "notice origin is at the base")


func _check_church_collision(room: Node) -> void:
	_check(_has_rect(room, GroundsLayout.church_body_center(), GroundsLayout.church_body_size()), "church body collision matches the church sprite")
	_check(_has_rect(room, GroundsLayout.church_west_jamb_center(), GroundsLayout.church_jamb_size()), "church west jamb matches the doorway")
	_check(_has_rect(room, GroundsLayout.church_east_jamb_center(), GroundsLayout.church_jamb_size()), "church east jamb matches the doorway")
	_check(_has_rect(room, GroundsLayout.north_border_center(), GroundsLayout.north_border_size()), "grounds north border matches the map")


func _check_block(room: Node, node_path: String, size: Vector2) -> void:
	var node := room.get_node_or_null(node_path)
	_check(node != null, "%s exists for collision" % node_path)
	if node == null:
		return
	var block: Vector2 = node.get("block_size")
	_check(block == size, "%s collision size is unchanged" % node_path)


func _has_rect(room: Node, center: Vector2, size: Vector2) -> bool:
	var solids := room.get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return false
	for child in solids.get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var rect := shape_node.shape as RectangleShape2D
		if shape_node.position.is_equal_approx(center) and rect.size.is_equal_approx(size):
			return true
	return false


func _load_png(path: String) -> Image:
	var bytes := FileAccess.get_file_as_bytes(path)
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK:
		return null
	return image


func _palette_keys() -> Dictionary:
	var allowed: Dictionary = {}
	var text := FileAccess.get_file_as_string("res://assets/source/palette/the_calling_master.gpl")
	for line in text.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.is_empty() or trimmed.begins_with("#") or trimmed.begins_with("GIMP") or trimmed.begins_with("Name:") or trimmed.begins_with("Columns:"):
			continue
		var parts := trimmed.split(" ", false)
		if parts.size() < 3:
			continue
		allowed["%s,%s,%s" % [parts[0], parts[1], parts[2]]] = true
	return allowed


func _first_off_palette(image: Image, allowed: Dictionary) -> String:
	for y in image.get_height():
		for x in image.get_width():
			var px: Color = image.get_pixel(x, y)
			if px.a <= 0.001:
				continue
			var key := "%d,%d,%d" % [roundi(px.r * 255.0), roundi(px.g * 255.0), roundi(px.b * 255.0)]
			if not allowed.has(key):
				return "%s at %d,%d" % [key, x, y]
	return ""


func _instance(path: String) -> Node:
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


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	print("M6A2_OK" if not _failed else "M6A2_FAIL")
	get_tree().quit(0 if not _failed else 1)
