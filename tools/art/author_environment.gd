extends SceneTree
## Writes the outdoor tileset, church-lot props, and Oak Street buildings.
## Run from the repo root:
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_environment.gd

const Frames := preload("res://scripts/art/environment_frames.gd")

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
	if not _write_tileset():
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
