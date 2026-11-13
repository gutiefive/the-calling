extends Node
## Headless checks for Gameplay C2 (dirt tiles, bigger crops, journal sections).
## Prints GPC2_OK or GPC2_FAIL.
## Run: godot --headless --path . res://tests/gpc2/gpc2_validation.tscn

const Frames := preload("res://scripts/art/crop_frames.gd")

const CROPS: PackedStringArray = ["lettuce", "carrots", "tomatoes", "flowers"]
const STAGES: PackedStringArray = ["sprout", "growing", "mature"]

## Bounding boxes of the pre-C2 sprites (with outline). New art must beat these.
const OLD_BBOX := {
	"lettuce_sprout": Vector2i(6, 7),
	"lettuce_growing": Vector2i(15, 13),
	"lettuce_mature": Vector2i(21, 19),
	"carrots_sprout": Vector2i(5, 4),
	"carrots_growing": Vector2i(6, 11),
	"carrots_mature": Vector2i(8, 20),
	"tomatoes_sprout": Vector2i(6, 7),
	"tomatoes_growing": Vector2i(8, 14),
	"tomatoes_mature": Vector2i(13, 20),
	"flowers_sprout": Vector2i(4, 8),
	"flowers_growing": Vector2i(6, 15),
	"flowers_mature": Vector2i(16, 19),
}

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
	_soil_textures()
	_neighbor_blending()
	_crop_stages()
	_journal_sections()
	await _journal_fits_and_hides_banner()
	await _garden_props()
	_restore_user_save()
	_finish()


func _soil_textures() -> void:
	_check(FileAccess.file_exists("res://assets/garden/soil_tilled.png"), "dry tilled soil texture exists")
	_check(FileAccess.file_exists("res://assets/garden/soil_tilled_wet.png"), "watered tilled soil texture exists")
	var dry := Frames.ground(false, 15, "tilled", Vector2i(42, 35))
	var wet := Frames.ground(true, 15, "tilled", Vector2i(42, 35))
	_check(dry != null and wet != null, "procedural dry and wet soil build")
	_check(_images_differ(dry, wet), "watered soil is darker than dry soil")
	_check(_longest_run(dry, Frames.pal_color("wood_d")) < 24, "dry soil has no plank-wide wood stripes")
	_check(_longest_run(dry, Frames.pal_color("wood")) < 24, "dry soil has no plank-wide wood lines")
	var dry_file := _png("res://assets/garden/soil_tilled.png")
	var wet_file := _png("res://assets/garden/soil_tilled_wet.png")
	_check(dry_file != null and wet_file != null, "authored soil PNGs load")
	_check(_images_differ(dry_file, wet_file), "authored dry and wet soil PNGs differ")


func _neighbor_blending() -> void:
	var grass := Frames.pal_color("grass")
	var isolated := Frames.ground(false, 0, "tilled", Vector2i(42, 35))
	var inner := Frames.ground(false, 15, "tilled", Vector2i(43, 36))
	var north := Frames.ground(false, 1, "tilled", Vector2i(43, 36))
	_check(_row_has_color(isolated, 0, grass), "an isolated tile keeps a grass edge")
	_check(not _row_has_color(inner, 0, grass), "an interior tile skips the north grass border")
	_check(not _row_has_color(inner, 31, grass), "an interior tile skips the south grass border")
	_check(not _col_has_color(inner, 0, grass), "an interior tile skips the west grass border")
	_check(not _col_has_color(inner, 31, grass), "an interior tile skips the east grass border")
	_check(not _row_span_has_color(north, 0, 2, 30, grass), "a north neighbor skips the internal north border")
	_check(_row_has_color(north, 31, grass), "a north-only neighbor still meets grass on the south")
	var left := Frames.ground(false, 2, "tilled", Vector2i(42, 35))
	var right := Frames.ground(false, 8, "tilled", Vector2i(43, 35))
	_check(not _col_span_has_color(left, 31, 2, 30, grass), "the shared east edge is dirt, not a grass grid line")
	_check(not _col_span_has_color(right, 0, 2, 30, grass), "the shared west edge is dirt, not a grass grid line")


func _crop_stages() -> void:
	for crop_id in CROPS:
		for stage in STAGES:
			var frame_id := "%s_%s" % [crop_id, stage]
			var path := "res://assets/garden/%s.png" % frame_id
			_check(FileAccess.file_exists(path), "%s texture exists" % frame_id)
			var image := Frames.build(frame_id)
			_check(image != null, "%s builds" % frame_id)
			var file_img := _png(path)
			var measured: Image = file_img if file_img != null else image
			if measured == null:
				continue
			var box := _opaque_bbox(measured)
			var old_v: Variant = OLD_BBOX.get(frame_id, Vector2i(1, 1))
			var old: Vector2i = old_v if old_v is Vector2i else Vector2i(1, 1)
			var bigger := box.size.x * box.size.y > old.x * old.y and (box.size.x > old.x or box.size.y > old.y)
			_check(bigger, "%s is bigger than before (%dx%d vs %dx%d)" % [frame_id, box.size.x, box.size.y, old.x, old.y])
			if stage == "sprout":
				_check(box.size.x >= 6 and box.size.y >= 6, "%s sprout is visible against soil" % crop_id)
			if stage == "mature":
				if crop_id == "tomatoes":
					_check(measured.get_height() >= 40 and box.size.y >= 30, "mature tomatoes are tall enough to overhang")
				else:
					_check(box.size.x >= 20 and box.size.y >= 20, "%s mature fills most of the tile" % crop_id)


func _journal_sections() -> void:
	NarrativeState.reset()
	var asks := get_node_or_null("/root/RequestState")
	if asks != null and asks.has_method("reset"):
		asks.call("reset")
	var hud := _instance("res://scenes/ui/hud.tscn")
	if hud == null:
		return
	var journal := hud.get_node_or_null("Journal")
	_check(journal != null, "the HUD has a journal")
	if journal == null:
		hud.free()
		return
	if journal.has_method("_set_open"):
		journal.call("_set_open", true)
	var empty := str(journal.call("_body_text"))
	_check(empty.contains("Story"), "the journal labels story quests")
	_check(empty.contains("Requests"), "the journal labels community requests")
	_check(empty.contains("No active quests."), "the story empty line shows when story is empty")
	_check(empty.contains("No open asks."), "the request empty line shows when requests are empty")
	NarrativeState.start_quest("oak_street")
	var story_only := str(journal.call("_body_text"))
	_check(story_only.contains("Oak Street") or story_only.contains("oak"), "an active story quest is listed")
	_check(not story_only.contains("No active quests."), "the story empty line hides when a story quest is active")
	_check(story_only.contains("No open asks."), "the request empty line still shows when only story is active")
	NarrativeState.complete_quest("oak_street")
	NarrativeState.set_flag("week_continues", true)
	if asks != null and asks.has_method("accept"):
		asks.call("accept", "fresh_for_the_table")
	var request_only := str(journal.call("_body_text"))
	_check(request_only.contains("Fresh for the Table"), "an active request is listed")
	_check(request_only.contains("No active quests."), "the story empty line shows when only a request is active")
	_check(not request_only.contains("No open asks."), "the request empty line hides when a request is active")
	NarrativeState.start_quest("spare_keys")
	var both := str(journal.call("_body_text"))
	_check(not both.contains("No active quests."), "neither empty line shows when both sections have work")
	_check(not both.contains("No open asks."), "the request empty line stays hidden while a request is active")
	if journal.has_method("_set_open"):
		journal.call("_set_open", false)
	hud.free()
	NarrativeState.reset()
	if asks != null and asks.has_method("reset"):
		asks.call("reset")


func _journal_fits_and_hides_banner() -> void:
	NarrativeState.reset()
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(2)
	var journal := room.get_node_or_null("HUD/Journal") as Control
	_check(journal != null, "the church HUD has a journal panel")
	if journal != null:
		_check(journal.offset_bottom <= 360.0, "the journal bottom stays inside 640x360")
		_check(journal.offset_right <= 640.0, "the journal right edge stays inside 640x360")
		_check(journal.offset_top >= 28.0, "the journal sits below the clock")
		_check(journal.get_node_or_null("Scroll") != null, "the journal scrolls when the page is long")
	var banner := room.get_node_or_null("HUD/LocationBanner") as Label
	if banner != null and banner.has_method("show_place"):
		banner.call("show_place", "Church grounds")
		await _pump(1)
		_check(banner.visible and banner.text == "Church grounds", "the area label is shown before the journal opens")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", true)
		await get_tree().process_frame
		await _pump(1)
		_check(not banner.visible, "the area label is hidden while the journal is open")
		if journal != null and journal.has_method("_set_open"):
			journal.call("_set_open", false)
	room.free()
	await _pump(1)


func _garden_props() -> void:
	var garden := get_node_or_null("/root/GardenState")
	_check(garden != null, "GardenState autoload exists")
	if garden != null:
		_check(not bool(garden.call("is_tillable", Vector2i(40, 33))), "the water barrel tile is not tillable")
		_check(not bool(garden.call("is_tillable", Vector2i(46, 33))), "the wheelbarrow tile is not tillable")
		_check(not bool(garden.call("is_tillable", Vector2i(46, 39))), "the compost tile is not tillable")
		_check(not bool(garden.call("is_tillable", Vector2i(43, 39))), "the garden bench tile is not tillable")
		_check(bool(garden.call("is_tillable", Vector2i(45, 37))), "open interior grass is still tillable")
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(2)
	var names: PackedStringArray = ["GardenBarrel", "GardenWheelbarrow", "GardenCompost", "VegGardenBench"]
	for node_name in names:
		var node := room.get_node_or_null("Props/%s" % node_name) as Node2D
		_check(node != null, "%s is in the garden" % node_name)
		if node == null:
			continue
		_check(not _blocks_path(node), "%s does not block the garden path or gate" % node_name)
	room.free()
	await _pump(1)


func _blocks_path(node: Node2D) -> bool:
	var size_v: Variant = node.get("block_size")
	var offset_v: Variant = node.get("block_offset")
	var size: Vector2 = size_v if size_v is Vector2 else Vector2(16, 10)
	var offset: Vector2 = offset_v if offset_v is Vector2 else Vector2(0, -4)
	var center := node.global_position + offset
	var body := Rect2(center - size * 0.5, size)
	for cell in GroundsLayout.veg_path_cells():
		var tile := Rect2(Vector2(cell) * GroundsLayout.TILE, Vector2(GroundsLayout.TILE, GroundsLayout.TILE))
		if body.intersects(tile):
			return true
	return false


func _opaque_bbox(image: Image) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a < 0.5:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _images_differ(a: Image, b: Image) -> bool:
	if a == null or b == null:
		return false
	if a.get_width() != b.get_width() or a.get_height() != b.get_height():
		return true
	var diffs := 0
	for y in a.get_height():
		for x in a.get_width():
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				diffs += 1
	return diffs > 80


func _longest_run(image: Image, color: Color) -> int:
	var longest := 0
	for y in image.get_height():
		var run := 0
		for x in image.get_width():
			if image.get_pixel(x, y).is_equal_approx(color):
				run += 1
				longest = maxi(longest, run)
			else:
				run = 0
	return longest


func _row_has_color(image: Image, y: int, color: Color) -> bool:
	return _row_span_has_color(image, y, 0, image.get_width(), color)


func _row_span_has_color(image: Image, y: int, x0: int, x1: int, color: Color) -> bool:
	for x in range(x0, x1):
		if image.get_pixel(x, y).is_equal_approx(color):
			return true
	return false


func _col_has_color(image: Image, x: int, color: Color) -> bool:
	return _col_span_has_color(image, x, 0, image.get_height(), color)


func _col_span_has_color(image: Image, x: int, y0: int, y1: int, color: Color) -> bool:
	for y in range(y0, y1):
		if image.get_pixel(x, y).is_equal_approx(color):
			return true
	return false


func _png(path: String) -> Image:
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	return tex.get_image()


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


func _pump(count: int) -> void:
	for _i in count:
		await get_tree().physics_frame


func _restore_user_save() -> void:
	if _had_save:
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(_save_backup)
		return
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("the_calling_save.json"):
		dir.remove("the_calling_save.json")


func _check(ok: bool, message: String) -> void:
	print("CHECK ", "OK   " if ok else "FAIL ", message)
	if not ok:
		_failed = true


func _finish() -> void:
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
	NarrativeState.reset()
	DayClock.reset()
	print("GPC2_OK" if not _failed else "GPC2_FAIL")
	tree.quit(0 if not _failed else 1)
