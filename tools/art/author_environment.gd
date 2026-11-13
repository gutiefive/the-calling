extends SceneTree
## Writes the outdoor tileset, church-lot props, and Oak Street buildings.
## Run from the repo root:
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_environment.gd

const Frames := preload("res://scripts/art/environment_frames.gd")
const Street := preload("res://scripts/art/street_frames.gd")
const Items := preload("res://scripts/art/item_frames.gd")

const TILESET_PNG := "res://assets/tilesets/town_tiles.png"
const TILESET_TRES := "res://assets/tilesets/town_tiles.tres"


func _init() -> void:
	var failed := false
	if not _write_image(TILESET_PNG, Frames.build_atlas(), Vector2i(256, 128)):
		failed = true
	if not _write_image("res://assets/environments/church_front.png", Frames.build_church(), Vector2i(384, 160)):
		failed = true
	if not _write_image("res://assets/environments/tree.png", Frames.build_tree(), Vector2i(48, 80)):
		failed = true
	if not _write_image("res://assets/environments/bench.png", Frames.build_bench(), Vector2i(48, 32)):
		failed = true
	if not _write_image("res://assets/environments/lamp_post.png", Frames.build_lamp(), Vector2i(24, 56)):
		failed = true
	if not _write_image("res://assets/environments/notice_board.png", Frames.build_notice(), Vector2i(32, 48)):
		failed = true
	if not _write_image("res://assets/environments/mailbox.png", Frames.build_mailbox(), Vector2i(32, 40)):
		failed = true
	if not _write_image("res://assets/environments/fellowship_hall_worn.png", Frames.build_fellowship_hall(false), Vector2i(192, 112)):
		failed = true
	if not _write_image("res://assets/environments/fellowship_hall_repaired.png", Frames.build_fellowship_hall(true), Vector2i(192, 112)):
		failed = true
	if not _write_image("res://assets/environments/hardware_store.png", Frames.build_hardware_store(), Vector2i(224, 128)):
		failed = true
	if not _write_image("res://assets/environments/auto_shop.png", Frames.build_auto_shop(), Vector2i(256, 128)):
		failed = true
	if not _write_image("res://assets/environments/cottage.png", Frames.build_cottage(), Vector2i(160, 112)):
		failed = true
	if not _write_image("res://assets/environments/brights_diner.png", Frames.build_diner(), Vector2i(224, 128)):
		failed = true
	if not _write_image("res://assets/environments/post_office.png", Frames.build_post_office(), Vector2i(192, 128)):
		failed = true
	if not _write_image("res://assets/environments/barber_shop.png", Frames.build_barber(), Vector2i(160, 128)):
		failed = true
	if not _write_image("res://assets/environments/vacant_shop.png", Frames.build_vacant_shop(), Vector2i(192, 128)):
		failed = true
	if not _write_image("res://assets/environments/parked_car_a.png", Frames.build_parked_car(0), Vector2i(64, 32)):
		failed = true
	if not _write_image("res://assets/environments/parked_car_b.png", Frames.build_parked_car(1), Vector2i(64, 32)):
		failed = true
	if not _write_image("res://assets/environments/trash_can.png", Frames.build_trash_can(), Vector2i(16, 24)):
		failed = true
	if not _write_image("res://assets/environments/fire_hydrant.png", Frames.build_hydrant(), Vector2i(16, 24)):
		failed = true
	if not _write_image("res://assets/environments/church_monument.png", Frames.build_monument_sign(), Vector2i(128, 64)):
		failed = true
	if not _write_image("res://assets/environments/church_pillar.png", Frames.build_gate_pillar(), Vector2i(24, 56)):
		failed = true
	if not _write_image("res://assets/environments/survey_stakes.png", Frames.build_survey_stakes(), Vector2i(48, 24)):
		failed = true
	if not _write_image("res://assets/environments/future_site_sign.png", Frames.build_future_site_sign(), Vector2i(64, 40)):
		failed = true
	if not _write_image("res://assets/environments/headstone.png", Frames.build_headstone(), Vector2i(24, 32)):
		failed = true
	if not _write_image("res://assets/environments/memorial_wall.png", Frames.build_memorial_wall(), Vector2i(80, 32)):
		failed = true
	if not _write_image("res://assets/environments/picnic_table.png", Frames.build_picnic_table(), Vector2i(48, 24)):
		failed = true
	if not _write_image("res://assets/environments/courtyard_cross.png", Frames.build_courtyard_cross(), Vector2i(16, 48)):
		failed = true
	if not _write_image("res://assets/environments/walkway_post.png", Frames.build_walkway_post(), Vector2i(12, 40)):
		failed = true
	if not _write_image("res://assets/environments/church_bell.png", Frames.build_church_bell(), Vector2i(16, 40)):
		failed = true
	if not _write_image("res://assets/environments/credit_union.png", Street.build_credit_union(), Vector2i(192, 128)):
		failed = true
	if not _write_image("res://assets/environments/pharmacy.png", Street.build_pharmacy(), Vector2i(176, 128)):
		failed = true
	if not _write_image("res://assets/environments/thrift_shop.png", Street.build_thrift(), Vector2i(160, 128)):
		failed = true
	if not _write_image("res://assets/environments/feed_store.png", Street.build_feed_store(), Vector2i(192, 128)):
		failed = true
	if not _write_image("res://assets/environments/town_hall.png", Street.build_town_hall(), Vector2i(208, 128)):
		failed = true
	if not _write_image("res://assets/environments/boarded_shop.png", Street.build_boarded_shop(), Vector2i(160, 128)):
		failed = true
	if not _write_image("res://assets/environments/newspaper_box.png", Street.build_newspaper_box(), Vector2i(16, 24)):
		failed = true
	if not _write_image("res://assets/environments/bike_rack.png", Street.build_bike_rack(), Vector2i(40, 20)):
		failed = true
	if not _write_image("res://assets/environments/flower_box.png", Street.build_flower_box(), Vector2i(24, 16)):
		failed = true
	if not _write_image("res://assets/environments/swing_set.png", Street.build_swing_set(), Vector2i(48, 40)):
		failed = true
	if not _write_image("res://assets/environments/kids_bike.png", Street.build_kids_bike(), Vector2i(24, 16)):
		failed = true
	if not _write_image("res://assets/environments/garden_hose.png", Street.build_hose(), Vector2i(28, 12)):
		failed = true
	if not _write_image("res://assets/environments/dog_house.png", Street.build_dog_house(), Vector2i(32, 28)):
		failed = true
	if not _write_image("res://assets/environments/rocking_chair.png", Street.build_rocking_chair(), Vector2i(16, 24)):
		failed = true
	if not _write_image("res://assets/environments/picket_fence.png", Street.build_picket_fence(), Vector2i(64, 32)):
		failed = true
	if not _write_image("res://assets/environments/garden_shed.png", Street.build_garden_shed(0), Vector2i(48, 40)):
		failed = true
	if not _write_image("res://assets/environments/garden_shed_b.png", Street.build_garden_shed(1), Vector2i(48, 40)):
		failed = true
	if not _write_image("res://assets/environments/hedge_bush.png", Street.build_hedge_bush(0), Vector2i(32, 24)):
		failed = true
	if not _write_image("res://assets/environments/hedge_bush_b.png", Street.build_hedge_bush(1), Vector2i(32, 24)):
		failed = true
	if not _write_image("res://assets/environments/for_sale_sign.png", Street.build_for_sale_sign(), Vector2i(48, 40)):
		failed = true
	if not _write_image("res://assets/environments/dog.png", Street.build_dog(), Vector2i(20, 16)):
		failed = true
	for variant in range(6):
		if not _write_image("res://assets/environments/house_%d_east.png" % variant, Street.build_house(variant, true), Vector2i(144, 96)):
			failed = true
		if not _write_image("res://assets/environments/house_%d_west.png" % variant, Street.build_house(variant, false), Vector2i(144, 96)):
			failed = true
	var signs: Array[Dictionary] = [
		{"file": "sign_hardware.png", "text": "HARDWARE", "variant": 0},
		{"file": "sign_miller.png", "text": "MILLER", "variant": 3},
		{"file": "sign_brights.png", "text": "BRIGHT'S", "variant": 2},
		{"file": "sign_post.png", "text": "POST", "variant": 1},
		{"file": "sign_barber.png", "text": "BARBER", "variant": 0},
		{"file": "sign_lease.png", "text": "LEASE", "variant": 3},
		{"file": "sign_credit.png", "text": "CREDIT", "variant": 1},
		{"file": "sign_pearls.png", "text": "PEARL'S", "variant": 2},
		{"file": "sign_thrift.png", "text": "THRIFT", "variant": 0},
		{"file": "sign_feed.png", "text": "FEED", "variant": 0},
		{"file": "sign_hall.png", "text": "HALL", "variant": 1},
		{"file": "sign_closed.png", "text": "CLOSED", "variant": 3},
	]
	for row in signs:
		var sign_file := str(row.get("file", ""))
		var sign_text := str(row.get("text", ""))
		var sign_variant := int(row.get("variant", 0))
		if not _write_image("res://assets/environments/%s" % sign_file, Street.build_hanging_sign(sign_text, sign_variant), Vector2i(128, 32)):
			failed = true
	if not _write_tileset():
		failed = true
	if not _write_items():
		failed = true
	quit(1 if failed else 0)


func _write_image(rel: String, image: Image, size: Vector2i) -> bool:
	if image == null or image.get_width() != size.x or image.get_height() != size.y:
		print("AUTHOR FAIL ", rel, " bad size")
		return false
	var abs_path := ProjectSettings.globalize_path(rel)
	var err := image.save_png(abs_path)
	if err != OK:
		print("AUTHOR FAIL ", rel, " save ", err)
		return false
	print("WROTE ", rel, " ", image.get_width(), "x", image.get_height())
	return true


func _write_items() -> bool:
	var dir := DirAccess.open("res://assets")
	if dir == null:
		print("AUTHOR FAIL items dir")
		return false
	if not dir.dir_exists("items"):
		var err := dir.make_dir("items")
		if err != OK:
			print("AUTHOR FAIL items mkdir ", err)
			return false
	var ids: PackedStringArray = [
		"watering_can",
		"hoe",
		"hand_tools",
		"lettuce_seeds",
		"carrot_seeds",
		"tomato_seeds",
		"flower_seeds",
		"lettuce",
		"carrots",
		"tomatoes",
		"flowers",
		"wood",
		"nails",
		"scrap",
	]
	var ok := true
	for item_id in ids:
		if not _write_image("res://assets/items/%s.png" % item_id, Items.build(item_id), Vector2i(16, 16)):
			ok = false
	return ok


func _write_tileset() -> bool:
	var cells := PackedStringArray()
	for row in range(4):
		for col in range(8):
			cells.append("%d:%d/0 = 0" % [col, row])
	var body := """[gd_resource type=\"TileSet\" load_steps=3 format=3]

[ext_resource type=\"Texture2D\" path=\"res://assets/tilesets/town_tiles.png\" id=\"1_tiles\"]

[sub_resource type=\"TileSetAtlasSource\" id=\"TileSetAtlasSource_town\"]
texture = ExtResource(\"1_tiles\")
texture_region_size = Vector2i(32, 32)
%s

[resource]
tile_size = Vector2i(32, 32)
sources/0 = SubResource(\"TileSetAtlasSource_town\")
""" % "\n".join(cells)
	var abs_path := ProjectSettings.globalize_path(TILESET_TRES)
	var file := FileAccess.open(abs_path, FileAccess.WRITE)
	if file == null:
		print("AUTHOR FAIL ", TILESET_TRES, " save ", FileAccess.get_open_error())
		return false
	file.store_string(body)
	file.close()
	print("WROTE ", TILESET_TRES)
	return true
