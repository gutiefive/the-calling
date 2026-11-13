extends Node
## Headless checks for Milestone 6A part 1 (character sprites).
## Prints M6A_OK or M6A_FAIL.
## Run: godot --headless --path . res://tests/m6a/m6a_validation.tscn

const SHEETS: Dictionary = {
	"player": "res://assets/characters/player_sheet.png",
	"margaret": "res://assets/characters/npc_margaret_sheet.png",
	"harold": "res://assets/characters/npc_harold_sheet.png",
	"thomas": "res://assets/characters/npc_thomas_sheet.png",
	"frank": "res://assets/characters/npc_frank_sheet.png",
	"sarah": "res://assets/characters/npc_sarah_sheet.png",
}
const FACINGS: PackedStringArray = ["down", "up", "left", "right"]
const ROOMS: PackedStringArray = [
	"res://scenes/world/church_exterior.tscn",
	"res://scenes/world/sanctuary.tscn",
	"res://scenes/world/hardware_street.tscn",
	"res://scenes/world/hardware_interior.tscn",
	"res://scenes/world/bay_interior.tscn",
	"res://scenes/world/maple_lane.tscn",
	"res://scenes/world/parsonage.tscn",
	"res://scenes/actors/player.tscn",
	"res://scenes/main.tscn",
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
	for who in SHEETS.keys():
		var path := str(SHEETS[who])
		_check(FileAccess.file_exists(path), "file " + path)
		if not FileAccess.file_exists(path):
			continue
		var bytes := FileAccess.get_file_as_bytes(path)
		var image := Image.new()
		var loaded := image.load_png_from_buffer(bytes)
		_check(loaded == OK and image.get_width() == 192 and image.get_height() == 192, "%s sheet is 192x192" % who)
		if loaded != OK:
			continue
		var off := _first_off_palette(image, allowed)
		_check(off.is_empty(), "%s uses only palette colors%s" % [who, "" if off.is_empty() else " (%s)" % off])
	_check(FileAccess.file_exists("res://tools/art/author_sprites.gd"), "sprite generator exists")
	_check(FileAccess.file_exists("res://tools/art/README.md"), "art tool readme exists")
	_check(FileAccess.file_exists("res://scripts/art/character_frames.gd"), "character template exists")
	_check(FileAccess.file_exists("res://scripts/art/character_sheets.gd"), "character sheet loader exists")


func _scene_checks() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(4, 14, 0)
	var church := _instance("res://scenes/world/church_exterior.tscn")
	if church == null:
		return
	var player := church.get_node_or_null("Props/Player") as Player
	_check(player != null, "church grounds has the player")
	if player != null:
		_check_actor_frames(player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D, "player", "player")
		var shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		_check(shape != null and shape.position == Vector2(0, -4), "player collision origin is unchanged")
		var rect: RectangleShape2D = null
		if shape != null and shape.shape is RectangleShape2D:
			rect = shape.shape as RectangleShape2D
		_check(rect != null and rect.size == Vector2(12, 8), "player collision size is unchanged")
		var sprite := player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
		_check(sprite != null and sprite.offset == Vector2(0, -24), "player sprite origin is at the feet")
	_check_named(church, "Props/Margaret", "margaret")
	church.free()
	var sanctuary := _instance("res://scenes/world/sanctuary.tscn")
	if sanctuary == null:
		return
	_check_named(sanctuary, "Props/Harold", "harold")
	sanctuary.free()
	var store := _instance("res://scenes/world/hardware_interior.tscn")
	if store == null:
		return
	_check_named(store, "Props/Thomas", "thomas")
	store.free()
	var bay := _instance("res://scenes/world/bay_interior.tscn")
	if bay == null:
		return
	_check_named(bay, "Props/Frank", "frank")
	bay.free()
	var street := _instance("res://scenes/world/hardware_street.tscn")
	if street == null:
		return
	_check_named(street, "Props/Sarah", "sarah")
	street.free()
	for path in ROOMS:
		var room := _instance(path)
		_check(room != null, "boots " + path)
		if room != null:
			room.free()
	await get_tree().process_frame


func _check_named(room: Node, node_path: String, who: String) -> void:
	var node := room.get_node_or_null(node_path)
	_check(node != null, "%s node %s exists" % [who, node_path])
	if node == null:
		return
	_check_actor_frames(node.get_node_or_null("Sprite") as AnimatedSprite2D, who, who)


func _check_actor_frames(sprite: AnimatedSprite2D, who: String, sheet_key: String) -> void:
	_check(sprite != null, "%s has an AnimatedSprite2D" % who)
	if sprite == null:
		return
	var frames := sprite.sprite_frames
	_check(frames != null, "%s has SpriteFrames" % who)
	if frames == null:
		return
	for facing in FACINGS:
		var idle_name := facing + "_idle"
		var walk_name := facing + "_walk"
		_check(frames.has_animation(idle_name), "%s has %s" % [who, idle_name])
		_check(frames.has_animation(walk_name), "%s has %s" % [who, walk_name])
		if frames.has_animation(idle_name):
			_check(frames.get_frame_count(idle_name) == 2, "%s %s is 2 frames" % [who, idle_name])
		if frames.has_animation(walk_name):
			_check(frames.get_frame_count(walk_name) == 4, "%s %s is 4 frames" % [who, walk_name])
			var speed := frames.get_animation_speed(walk_name)
			_check(speed >= 8.0 and speed <= 10.0, "%s walk is 8-10 fps (%s)" % [who, snappedf(speed, 0.1)])
	if not frames.has_animation("down_idle") or frames.get_frame_count("down_idle") < 1:
		return
	var tex := frames.get_frame_texture("down_idle", 0)
	var atlas := tex as AtlasTexture
	_check(atlas != null and atlas.atlas != null, "%s frames use an atlas" % who)
	if atlas == null or atlas.atlas == null:
		return
	_check(atlas.region.size == Vector2(32, 48), "%s cell is 32x48" % who)
	var path := atlas.atlas.resource_path
	var expected := str(SHEETS[sheet_key])
	_check(path == expected or path.ends_with(expected.get_file()), "%s uses %s" % [who, expected])


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
	print("M6A_OK" if not _failed else "M6A_FAIL")
	get_tree().quit(0 if not _failed else 1)
