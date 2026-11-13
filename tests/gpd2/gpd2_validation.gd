extends Node
## Headless checks for Gameplay D2 (repair worksite art polish).
## Prints GPD2_OK or GPD2_FAIL.
## Run: godot --headless --path . res://tests/gpd2/gpd2_validation.tscn

const Frames := preload("res://scripts/art/repair_frames.gd")
const Repairs := preload("res://scripts/systems/repair_catalog.gd")

const PIXEL_DELTA := 80
const FENCE_STAGES: PackedStringArray = [
	"fence_damaged",
	"fence_cleared",
	"fence_new_wood",
	"fence_finished",
]

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
	_fence_stage_art()
	_fence_layout_and_gate()
	_before_after_art()
	_flags_and_saves()
	await _scene_and_walk()
	_restore_user_save()
	_finish()


func _fence_stage_art() -> void:
	var previous: Image = null
	for frame_id in FENCE_STAGES:
		var image := Frames.build(frame_id)
		_check(image != null, "%s builds" % frame_id)
		if image == null:
			continue
		_check(image.get_width() >= 64 or image.get_height() >= 64, "%s spans 2 or more tiles (%dx%d)" % [frame_id, image.get_width(), image.get_height()])
		_check(FileAccess.file_exists("res://assets/repairs/%s.png" % frame_id), "%s PNG exists" % frame_id)
		if previous != null:
			var delta := _pixel_delta(previous, image)
			_check(delta >= PIXEL_DELTA, "%s differs from the previous stage by %d pixels (need %d)" % [frame_id, delta, PIXEL_DELTA])
		previous = image
	var damaged := Frames.build("fence_damaged")
	var finished := Frames.build("fence_finished")
	_check(_pixel_delta(damaged, finished) >= PIXEL_DELTA, "damaged and finished fence differ clearly")
	_check(_has_horizontal_rail(finished), "the finished stretch has fence rails, not a crate")
	_check(_has_horizontal_rail(damaged) or _opaque_count(damaged) > 80, "the damaged stretch still reads as fence posts")


func _fence_layout_and_gate() -> void:
	var cells := GroundsLayout.veg_fence_mend_cells()
	_check(cells.size() >= 2, "the fence repair spans 2 or more tiles")
	_check(not GroundsLayout.veg_fence_overlaps_gate(), "the fence repair does not overlap the garden gate")
	var garden := GroundsLayout.VEG_GARDEN
	for cell in cells:
		_check(cell.x == garden.position.x, "mend cell %s sits on the west garden fence" % str(cell))
		_check(cell.y >= garden.position.y and cell.y < garden.end.y, "mend cell %s stays on the garden fence line" % str(cell))
		for gate in GroundsLayout.veg_path_cells():
			_check(cell != gate, "mend cell %s is not the gate opening %s" % [str(cell), str(gate)])
	_check(GroundsLayout.REPAIR_FENCE == GroundsLayout.VEG_FENCE_MEND, "the layout point still aliases VEG_FENCE_MEND")
	_check(Repairs.complete_flag("church_fence") == "church_fence_mended", "RepairState still uses church_fence_mended")
	_check(Repairs.stage_count("church_fence") == 4, "the fence still has four stages")


func _before_after_art() -> void:
	var weeds_before := Frames.build("weeds_patch")
	var weeds_after := Frames.build("weeds_cleared")
	_check(weeds_before != null and weeds_after != null, "weed stages build")
	_check(weeds_before.get_width() >= 64, "the weed patch spans more than one tile")
	_check(_pixel_delta(weeds_before, weeds_after) >= PIXEL_DELTA, "cleared weeds differ clearly from the overgrown patch")
	_check(_count_color(weeds_before, PixelDraw.pal("leaf")) > _count_color(weeds_after, PixelDraw.pal("leaf")), "tall weeds are gone after clearing")
	var litter_before := Frames.build("litter_pile")
	var litter_after := Frames.build("litter_gone")
	_check(litter_before != null and litter_after != null, "litter stages build")
	_check(litter_before.get_width() >= 64, "the litter patch spans more than one tile")
	_check(_pixel_delta(litter_before, litter_after) >= PIXEL_DELTA, "picked-up litter differs clearly from the pile")
	_check(_opaque_count(litter_before) > 80, "scattered litter is visible before pickup")
	_check(Frames.build("litter_bag") != null, "a tied bag by the bin exists")
	var bed_before := Frames.build("bed_overgrown")
	var bed_after := Frames.build("bed_restored")
	_check(bed_before != null and bed_after != null, "flower-bed stages build")
	_check(_pixel_delta(bed_before, bed_after) >= PIXEL_DELTA, "the restored bed differs clearly from the overgrown bed")
	_check(_pixel_delta(bed_before, Frames.build("bed_trimmed")) >= PIXEL_DELTA / 2, "trimming the bed is a visible step")
	_check(_has_color(bed_after, PixelDraw.pal("flower")), "the restored bed has blooms")
	_check(_has_color(bed_after, PixelDraw.pal("flower2")) or _has_color(bed_after, PixelDraw.pal("gold")), "the restored bed uses more than one flower color")


func _flags_and_saves() -> void:
	_fresh()
	var pack := _pack()
	var repairs := _repairs()
	_check(repairs != null, "RepairState autoload exists")
	if pack != null:
		pack.call("reset")
		pack.call("add", "hand_tools", 1)
		pack.call("equip", "hand_tools")
		pack.call("add", "wood", 3)
		pack.call("add", "nails", 2)
	if repairs != null:
		_check(str(repairs.call("art_id", "church_fence")) == "fence_damaged", "the fence still starts damaged")
		repairs.call("interact", "church_fence")
		repairs.call("interact", "church_fence")
		repairs.call("interact", "church_fence")
		_check(bool(repairs.call("is_finished", "church_fence")), "finishing the fence still works")
		_check(NarrativeState.flag_is_true("church_fence_mended"), "church_fence_mended still sets")
		_check(NarrativeState.flag_is_true("fence_kindness"), "fence_kindness still sets")
		_check(str(repairs.call("art_id", "church_fence")) == "fence_finished", "finished art id is unchanged")
	var blob: Dictionary = {}
	if repairs != null and repairs.has_method("to_dictionary"):
		var raw: Variant = repairs.call("to_dictionary")
		if raw is Dictionary:
			blob = raw
	NarrativeState.reset()
	_check(not NarrativeState.flag_is_true("church_fence_mended"), "reset still clears the fence flag")
	if repairs != null and repairs.has_method("from_dictionary"):
		repairs.call("from_dictionary", blob)
	_check(bool(repairs.call("is_finished", "church_fence")), "a saved finished fence still loads")
	_check(NarrativeState.flag_is_true("church_fence_mended") or bool(repairs.call("is_finished", "church_fence")), "loaded repairs keep the finished stage")
	var from_v9 := SaveGame.migrate({
		"version": 9,
		"scene": "res://scenes/world/church_exterior.tscn",
		"narrative": {
			"flags": {"church_fence_mended": true, "week_continues": true},
		},
	})
	_check(int(from_v9.get("version", 0)) == 10, "v9 still migrates to v10")
	NarrativeState.reset()
	SaveGame.apply_state(from_v9)
	_check(bool(_repairs().call("is_finished", "church_fence")), "a v9 mended flag still finishes the fence")
	_check(NarrativeState.flag_is_true("church_fence_mended"), "a v9 mended flag still keeps church_fence_mended")
	NarrativeState.reset()


func _scene_and_walk() -> void:
	_fresh()
	var room := _instance("res://scenes/world/church_exterior.tscn")
	if room == null:
		return
	await _pump(2)
	var fence := room.get_node_or_null("Props/FenceWork") as RepairSite
	_check(fence != null, "the fence worksite is on the grounds")
	if fence != null:
		_check(fence.position.distance_to(GroundsLayout.REPAIR_FENCE) < 1.0, "the fence sits at the layout point")
		_check(fence.current_art() == "fence_damaged", "the instanced fence shows the damaged stretch")
		var tex := RepairArt.texture("fence_damaged")
		_check(tex != null and (tex.get_width() >= 64 or tex.get_height() >= 64), "the instanced fence texture spans 2+ tiles")
	for cell in GroundsLayout.veg_path_cells():
		var pos := GroundsLayout.tile_center(cell)
		_check(_walkable(room, pos), "garden gate cell %s stays walkable" % str(cell))
	var ground := room.get_node_or_null("Ground") as TileMapLayer
	if ground != null:
		for cell in GroundsLayout.veg_path_cells():
			_check(GroundsLayout.is_path_atlas(ground.get_cell_atlas_coords(cell)), "gate tile %s is still path" % str(cell))
		for cell in GroundsLayout.veg_fence_mend_cells():
			_check(not GroundsLayout.is_perimeter_atlas(ground.get_cell_atlas_coords(cell)), "mend cell %s is not a leftover fence tile" % str(cell))
	var weeds := room.get_node_or_null("Props/PicnicWeeds") as RepairSite
	var litter := room.get_node_or_null("Props/LotLitter") as RepairSite
	var bed := room.get_node_or_null("Props/PicnicBed") as RepairSite
	_check(weeds != null and weeds.visible, "the weed worksite is visible")
	_check(litter != null and litter.visible, "the litter worksite is visible")
	_check(bed != null and bed.visible, "the flower-bed worksite is visible")
	var bag := room.get_node_or_null("Props/LitterBag") as Sprite2D
	_check(bag != null, "a tied bag waits by the shed bin")
	if bag != null:
		_check(not bag.visible, "the tied bag stays hidden before litter is cleared")
	var repairs := _repairs()
	if repairs != null:
		if _pack() != null:
			_pack().call("reset")
			_pack().call("add", "hand_tools", 1)
			_pack().call("equip", "hand_tools")
		repairs.call("interact", "lot_litter")
		await _pump(1)
		if bag != null:
			_check(bag.visible, "the tied bag appears once the litter is gone")
	room.free()
	await _pump(1)


func _fresh() -> void:
	NarrativeState.reset()
	DayClock.reset()
	DayClock.set_time(8, 10, 0)
	NarrativeState.set_flag("week_continues", true)


func _pixel_delta(a: Image, b: Image) -> int:
	if a == null or b == null:
		return 0
	if a.get_width() != b.get_width() or a.get_height() != b.get_height():
		return maxi(a.get_width() * a.get_height(), b.get_width() * b.get_height())
	var n := 0
	for y in a.get_height():
		for x in a.get_width():
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				n += 1
	return n


func _opaque_count(image: Image) -> int:
	if image == null:
		return 0
	var n := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.5:
				n += 1
	return n


func _has_horizontal_rail(image: Image) -> bool:
	if image == null:
		return false
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	for y in image.get_height():
		var run := 0
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel == wood or pixel == wood_l or pixel == wood_d:
				run += 1
				if run >= 20:
					return true
			else:
				run = 0
	return false


func _count_color(image: Image, color: Color) -> int:
	if image == null:
		return 0
	var n := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y) == color:
				n += 1
	return n


func _has_color(image: Image, color: Color) -> bool:
	if image == null:
		return false
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y) == color:
				return true
	return false


func _walkable(room: Node, pos: Vector2) -> bool:
	var world := room as WorldRoom
	if world != null:
		var pad := 10.0
		if pos.x < world.bounds.position.x + pad or pos.y < world.bounds.position.y + pad:
			return false
		if pos.x > world.bounds.end.x - pad or pos.y > world.bounds.end.y - pad:
			return false
	return not _inside_solid(room, pos)


func _inside_solid(room: Node, pos: Vector2) -> bool:
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


func _repairs() -> Node:
	return get_node_or_null("/root/RepairState")


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


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
	print("GPD2_OK" if not _failed else "GPD2_FAIL")
	tree.quit(0 if not _failed else 1)
