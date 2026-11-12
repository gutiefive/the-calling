extends Node2D
## Toolchain smoke test (environment only, not gameplay).
## Shows the LibreSprite-made 32x32 test tile scaled 4x and checks that it renders
## with nearest-neighbor filtering: every rendered pixel in the tile area must be a
## color that exists in the source PNG (linear filtering would create blended colors).

const TILE_PATH: String = "res://tests/toolchain/test_tile_32.png"

@onready var _tile: Sprite2D = $TestTile

var _ok: bool = true


func _ready() -> void:
	if _tile == null or _tile.texture == null:
		push_error("TOOLCHAIN: test tile texture missing")
		_finish(false)
		return
	var size: Vector2 = _tile.texture.get_size()
	print("TOOLCHAIN: tile size = ", size)
	if size != Vector2(32, 32):
		_ok = false
	var filter: int = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1)
	print("TOOLCHAIN: project default_texture_filter = %d (0 = Nearest)" % filter)
	print("TOOLCHAIN: sprite texture_filter = %d (0 = inherit project default)" % _tile.texture_filter)
	if filter != 0:
		_ok = false
	if DisplayServer.get_name() == "headless":
		print("TOOLCHAIN: headless run, skipping pixel readback")
		_finish(_ok)
		return
	# Wait for a couple of frames so the viewport has been drawn.
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_check_pixels()


func _check_pixels() -> void:
	var src: Image = _tile.texture.get_image()
	var palette: Dictionary = {}
	for y: int in src.get_height():
		for x: int in src.get_width():
			palette[src.get_pixel(x, y).to_rgba32()] = true
	var frame: Image = get_viewport().get_texture().get_image()
	var rect: Rect2i = Rect2i(Vector2i(_tile.global_position - Vector2(64, 64)), Vector2i(128, 128))
	var foreign: int = 0
	for y: int in range(rect.position.y + 2, rect.end.y - 2):
		for x: int in range(rect.position.x + 2, rect.end.x - 2):
			if not palette.has(frame.get_pixel(x, y).to_rgba32()):
				foreign += 1
	print("TOOLCHAIN: source colors = %d, rendered pixels not in source palette = %d" % [palette.size(), foreign])
	_finish(_ok and foreign == 0)


func _finish(ok: bool) -> void:
	print("TOOLCHAIN_OK" if ok else "TOOLCHAIN_FAIL")
