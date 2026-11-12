class_name PlaceholderArt
extends RefCounted
## Original blockout art, drawn in code from the master palette.
## Flat colors only. Not traced from another game.

const OUTLINE := Color(42.0 / 255.0, 36.0 / 255.0, 48.0 / 255.0, 1.0)
const GRASS_D := Color(58.0 / 255.0, 86.0 / 255.0, 48.0 / 255.0)
const GRASS := Color(78.0 / 255.0, 112.0 / 255.0, 58.0 / 255.0)
const GRASS_L := Color(108.0 / 255.0, 138.0 / 255.0, 70.0 / 255.0)
const GRASS_H := Color(148.0 / 255.0, 168.0 / 255.0, 92.0 / 255.0)
const PATH := Color(154.0 / 255.0, 136.0 / 255.0, 114.0 / 255.0)
const PATH_D := Color(118.0 / 255.0, 102.0 / 255.0, 86.0 / 255.0)
const PATH_L := Color(186.0 / 255.0, 168.0 / 255.0, 142.0 / 255.0)
const PATH_C := Color(96.0 / 255.0, 84.0 / 255.0, 72.0 / 255.0)
const GRAVEL := Color(132.0 / 255.0, 122.0 / 255.0, 112.0 / 255.0)
const GRAVEL_D := Color(104.0 / 255.0, 96.0 / 255.0, 88.0 / 255.0)
const BRICK := Color(150.0 / 255.0, 84.0 / 255.0, 68.0 / 255.0)
const BRICK_D := Color(112.0 / 255.0, 60.0 / 255.0, 54.0 / 255.0)
const BRICK_L := Color(176.0 / 255.0, 112.0 / 255.0, 90.0 / 255.0)
const CREAM := Color(214.0 / 255.0, 198.0 / 255.0, 170.0 / 255.0)
const CREAM_D := Color(176.0 / 255.0, 158.0 / 255.0, 132.0 / 255.0)
const CREAM_S := Color(148.0 / 255.0, 128.0 / 255.0, 112.0 / 255.0)
const ROOF := Color(112.0 / 255.0, 62.0 / 255.0, 68.0 / 255.0)
const ROOF_D := Color(74.0 / 255.0, 44.0 / 255.0, 52.0 / 255.0)
const ROOF_L := Color(148.0 / 255.0, 86.0 / 255.0, 90.0 / 255.0)
const WOOD := Color(124.0 / 255.0, 84.0 / 255.0, 52.0 / 255.0)
const WOOD_D := Color(86.0 / 255.0, 58.0 / 255.0, 38.0 / 255.0)
const WOOD_L := Color(164.0 / 255.0, 118.0 / 255.0, 74.0 / 255.0)
const GLASS := Color(126.0 / 255.0, 162.0 / 255.0, 176.0 / 255.0)
const GLASS_D := Color(78.0 / 255.0, 110.0 / 255.0, 136.0 / 255.0)
const GLASS_H := Color(186.0 / 255.0, 206.0 / 255.0, 196.0 / 255.0)
const LEAF := Color(52.0 / 255.0, 96.0 / 255.0, 58.0 / 255.0)
const LEAF_D := Color(36.0 / 255.0, 70.0 / 255.0, 48.0 / 255.0)
const LEAF_L := Color(86.0 / 255.0, 128.0 / 255.0, 72.0 / 255.0)
const TRUNK := Color(98.0 / 255.0, 68.0 / 255.0, 46.0 / 255.0)
const TRUNK_D := Color(68.0 / 255.0, 48.0 / 255.0, 36.0 / 255.0)
const SKIN := Color(214.0 / 255.0, 164.0 / 255.0, 132.0 / 255.0)
const SKIN_D := Color(176.0 / 255.0, 122.0 / 255.0, 98.0 / 255.0)
const HAIR := Color(72.0 / 255.0, 52.0 / 255.0, 40.0 / 255.0)
const HAIR_L := Color(108.0 / 255.0, 78.0 / 255.0, 56.0 / 255.0)
const SHIRT := Color(70.0 / 255.0, 96.0 / 255.0, 142.0 / 255.0)
const SHIRT_D := Color(48.0 / 255.0, 68.0 / 255.0, 108.0 / 255.0)
const SHIRT_L := Color(104.0 / 255.0, 128.0 / 255.0, 168.0 / 255.0)
const PANTS := Color(54.0 / 255.0, 52.0 / 255.0, 68.0 / 255.0)
const PANTS_D := Color(40.0 / 255.0, 38.0 / 255.0, 52.0 / 255.0)
const SHOE := Color(48.0 / 255.0, 40.0 / 255.0, 38.0 / 255.0)
const GOLD := Color(196.0 / 255.0, 156.0 / 255.0, 78.0 / 255.0)
const PAPER := Color(220.0 / 255.0, 210.0 / 255.0, 190.0 / 255.0)
const GREY := Color(168.0 / 255.0, 164.0 / 255.0, 158.0 / 255.0)
const GREY_D := Color(112.0 / 255.0, 108.0 / 255.0, 104.0 / 255.0)
const BUN := Color(186.0 / 255.0, 180.0 / 255.0, 170.0 / 255.0)
const BUN_D := Color(140.0 / 255.0, 134.0 / 255.0, 126.0 / 255.0)
const CARDIGAN := Color(96.0 / 255.0, 112.0 / 255.0, 78.0 / 255.0)
const CARDIGAN_D := Color(68.0 / 255.0, 82.0 / 255.0, 58.0 / 255.0)
const SKIRT := Color(92.0 / 255.0, 64.0 / 255.0, 72.0 / 255.0)
const SKIRT_D := Color(68.0 / 255.0, 46.0 / 255.0, 54.0 / 255.0)
const CARPET := Color(128.0 / 255.0, 64.0 / 255.0, 68.0 / 255.0)
const CARPET_D := Color(96.0 / 255.0, 48.0 / 255.0, 54.0 / 255.0)
const CARPET_L := Color(156.0 / 255.0, 90.0 / 255.0, 90.0 / 255.0)
const PLASTER := Color(196.0 / 255.0, 184.0 / 255.0, 164.0 / 255.0)
const PLASTER_D := Color(158.0 / 255.0, 146.0 / 255.0, 128.0 / 255.0)
const MOSS := Color(70.0 / 255.0, 102.0 / 255.0, 64.0 / 255.0)
const LAMP := Color(232.0 / 255.0, 196.0 / 255.0, 140.0 / 255.0)
const FLOWER := Color(176.0 / 255.0, 96.0 / 255.0, 92.0 / 255.0)
const FLOWER2 := Color(196.0 / 255.0, 164.0 / 255.0, 78.0 / 255.0)
const SOIL := Color(92.0 / 255.0, 70.0 / 255.0, 52.0 / 255.0)
const LEAF_DRY := Color(128.0 / 255.0, 112.0 / 255.0, 64.0 / 255.0)

static var _cache: Dictionary = {}


static func by_id(art_id: String) -> Texture2D:
	match art_id:
		"margaret":
			return margaret()
		"harold":
			return harold()
		"keys":
			return key_ring()
		"notice":
			return notice_board()
		"frank":
			return frank()
		"thomas":
			return thomas()
		"sarah":
			return sarah()
		"crate":
			return crate()
		"mailbox":
			return mailbox()
		_:
			return null


static func grounds_atlas() -> Texture2D:
	return _cached("atlas", _grounds_atlas())


static func church_front() -> Texture2D:
	return _cached("church", _church())


static func player_sheet() -> Texture2D:
	return _cached("player", _player_sheet())


static func margaret() -> Texture2D:
	return _cached("margaret", _margaret())


static func harold() -> Texture2D:
	return _cached("harold", _harold_sheet())


static func key_ring() -> Texture2D:
	return _cached("keys", _key_ring())


static func tree(kind: int) -> Texture2D:
	return _cached("tree%d" % kind, _tree(kind))


static func bench() -> Texture2D:
	return _cached("bench", _bench())


static func notice_board() -> Texture2D:
	return _cached("notice", _notice())


static func lamp_post() -> Texture2D:
	return _cached("lamp", _lamp())


static func flowers() -> Texture2D:
	return _cached("flowers", _flowers())


static func door_mat() -> Texture2D:
	return _cached("mat", _mat())


static func pew() -> Texture2D:
	return _cached("pew", _pew())


static func altar() -> Texture2D:
	return _cached("altar", _altar())


static func chairs() -> Texture2D:
	return _cached("chairs", _chairs())


static func cross() -> Texture2D:
	return _cached("cross", _cross())


static func sanctuary_window() -> Texture2D:
	return _cached("window", _window())


static func glow() -> Texture2D:
	return _cached("glow", _glow())


static func frank() -> Texture2D:
	return _cached("frank", _npc_sheet(GREY, GREY_D, HAIR, SHIRT_D, true, false))


static func thomas() -> Texture2D:
	return _cached("thomas", _npc_sheet(WOOD, WOOD_D, HAIR_L, PANTS, false, true))


static func sarah() -> Texture2D:
	return _cached("sarah", _npc_sheet(FLOWER, BRICK_D, BUN, PANTS, false, false))


static func hardware_store() -> Texture2D:
	return _cached("hardware", _hardware())


static func auto_shop() -> Texture2D:
	return _cached("garage", _garage())


static func cottage() -> Texture2D:
	return _cached("cottage", _cottage())


static func crate() -> Texture2D:
	return _cached("crate", _crate())


static func mailbox() -> Texture2D:
	return _cached("mailbox", _mailbox())


static func _cached(key: String, image: Image) -> Texture2D:
	if _cache.has(key):
		return _cache[key] as Texture2D
	var texture := ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture


static func _new(w: int, h: int) -> Image:
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


static func _px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)


static func _rect(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			_px(image, xx, yy, color)


static func _ellipse(image: Image, cx: int, cy: int, rx: int, ry: int, color: Color) -> void:
	if rx <= 0 or ry <= 0:
		return
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var nx := float(x - cx) / float(rx)
			var ny := float(y - cy) / float(ry)
			if nx * nx + ny * ny <= 1.0:
				_px(image, x, y, color)


static func _blit(dst: Image, src: Image, ox: int, oy: int) -> void:
	for y in src.get_height():
		for x in src.get_width():
			var pixel := src.get_pixel(x, y)
			if pixel.a == 0.0:
				continue
			_px(dst, ox + x, oy + y, pixel)


static func _outline(image: Image) -> Image:
	var w := image.get_width()
	var h := image.get_height()
	var copy := image.duplicate()
	for y in h:
		for x in w:
			if image.get_pixel(x, y).a > 0.78:
				continue
			var touch := false
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + offset.x
				var ny: int = y + offset.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and image.get_pixel(nx, ny).a > 0.78:
					touch = true
					break
			if touch:
				copy.set_pixel(x, y, OUTLINE)
	return copy


static func _mirror(image: Image) -> Image:
	var copy := _new(image.get_width(), image.get_height())
	var w := image.get_width()
	for y in image.get_height():
		for x in w:
			copy.set_pixel(w - 1 - x, y, image.get_pixel(x, y))
	return copy


static func _noise(x: int, y: int) -> int:
	return ((x * 73 + y * 151) ^ (x * 17 + y * 31)) & 255


static func _grounds_atlas() -> Image:
	var atlas := _new(32 * 7, 32)
	_blit(atlas, _grass(false), 0, 0)
	_blit(atlas, _grass(true), 32, 0)
	_blit(atlas, _path_tile(), 64, 0)
	_blit(atlas, _gravel_tile(), 96, 0)
	_blit(atlas, _wood_tile(), 128, 0)
	_blit(atlas, _carpet_tile(), 160, 0)
	_blit(atlas, _plaster_tile(), 192, 0)
	return atlas


static func _grass(alt: bool) -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, GRASS)
	var shift := 17 if alt else 0
	for y in 32:
		for x in 32:
			var n := _noise(x + shift, y)
			if n > 210:
				_px(image, x, y, GRASS_L)
			elif n < 30:
				_px(image, x, y, GRASS_D)
			elif alt and (n == 40 or n == 41):
				_px(image, x, y, GRASS_H)
	return image


static func _path_tile() -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, PATH_D)
	_rect(image, 1, 1, 14, 14, PATH)
	_rect(image, 17, 1, 14, 14, PATH)
	_rect(image, 1, 17, 14, 14, PATH_L)
	_rect(image, 17, 17, 14, 14, PATH)
	_px(image, 8, 22, PATH_C)
	_px(image, 9, 23, PATH_C)
	_px(image, 24, 6, PATH_C)
	return image


static func _gravel_tile() -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, GRAVEL)
	for y in 32:
		for x in 32:
			var n := _noise(x + 3, y + 9)
			if n > 190:
				_px(image, x, y, GRAVEL_D)
			elif n < 18:
				_px(image, x, y, PATH_L)
	return image


static func _wood_tile() -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, WOOD)
	for y in [0, 8, 16, 24]:
		_rect(image, 0, y, 32, 1, WOOD_D)
		_rect(image, 0, y + 1, 32, 1, WOOD_L)
	for x in [6, 20]:
		_rect(image, x, 0, 1, 8, WOOD_D)
		_rect(image, x + 8, 8, 1, 8, WOOD_D)
		_rect(image, x, 16, 1, 8, WOOD_D)
		_rect(image, x + 4, 24, 1, 8, WOOD_D)
	return image


static func _carpet_tile() -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, CARPET)
	_rect(image, 0, 0, 2, 32, CARPET_D)
	_rect(image, 30, 0, 2, 32, CARPET_D)
	_rect(image, 14, 0, 4, 32, CARPET_L)
	return image


static func _plaster_tile() -> Image:
	var image := _new(32, 32)
	_rect(image, 0, 0, 32, 32, PLASTER)
	_rect(image, 0, 28, 32, 4, WOOD_D)
	for y in 32:
		for x in 32:
			if _noise(x + 4, y + 2) > 230:
				_px(image, x, y, PLASTER_D)
	return image


static func _church() -> Image:
	var image := _new(384, 160)
	_rect(image, 180, 4, 24, 48, ROOF_D)
	_rect(image, 188, 0, 8, 10, ROOF)
	_rect(image, 189, 1, 6, 14, CREAM)
	_rect(image, 184, 5, 16, 4, CREAM)
	for y in range(36, 96):
		var inset := maxi(0, (52 - y) / 2)
		var tone := ROOF_D if (y / 5) % 2 == 0 else ROOF
		if absi((y / 3) - 20) < 2:
			tone = ROOF_L
		_rect(image, inset, y, 384 - inset * 2, 1, tone)
	_rect(image, 188, 40, 8, 56, ROOF_L)
	_rect(image, 0, 92, 384, 6, ROOF_D)
	_rect(image, 6, 98, 372, 48, CREAM)
	for y in range(100, 144):
		for x in range(8, 376):
			if _noise(x, y) > 240:
				_px(image, x, y, CREAM_D)
	_rect(image, 6, 140, 372, 14, BRICK)
	for x in range(8, 376, 10):
		_px(image, x, 146, BRICK_D)
		_px(image, x + 4, 142, BRICK_L)
	_rect(image, 18, 150, 10, 3, MOSS)
	_rect(image, 340, 148, 8, 2, MOSS)
	_px(image, 210, 152, BRICK_D)
	_px(image, 211, 153, BRICK_D)
	_px(image, 212, 154, PATH_C)
	for wx in [52, 292]:
		_rect(image, wx, 104, 40, 28, WOOD_D)
		_rect(image, wx + 3, 107, 34, 22, GLASS)
		_rect(image, wx + 18, 107, 2, 22, WOOD_D)
		_rect(image, wx + 3, 116, 34, 2, WOOD_D)
		_px(image, wx + 8, 110, GLASS_H)
		_px(image, wx + 28, 122, GLASS_D)
	_rect(image, 164, 108, 56, 46, WOOD_D)
	_rect(image, 168, 112, 22, 38, WOOD)
	_rect(image, 194, 112, 22, 38, WOOD_L)
	_rect(image, 176, 120, 8, 12, WOOD_D)
	_rect(image, 200, 120, 8, 12, WOOD_D)
	_px(image, 188, 132, GOLD)
	_px(image, 196, 132, GOLD)
	_rect(image, 156, 152, 72, 6, PATH_D)
	_rect(image, 160, 154, 64, 3, PATH)
	return _outline(image)


static func _player_sheet() -> Image:
	var sheet := _new(192, 192)
	for row in 4:
		var facing: String = ["down", "up", "left", "right"][row]
		for col in 6:
			var frame := _actor("left" if facing == "right" else facing, col, false)
			if facing == "right":
				frame = _mirror(frame)
			_blit(sheet, frame, col * 32, row * 48)
	return sheet


static func _margaret() -> Image:
	var sheet := _new(64, 48)
	_blit(sheet, _actor("down", 0, true), 0, 0)
	_blit(sheet, _actor("down", 1, true), 32, 0)
	return sheet


static func _harold_sheet() -> Image:
	var sheet := _new(64, 48)
	_blit(sheet, _harold_frame(0), 0, 0)
	_blit(sheet, _harold_frame(1), 32, 0)
	return sheet


static func _harold_frame(frame: int) -> Image:
	var image := _new(32, 48)
	var y0 := 1 if frame == 1 else 0
	_rect(image, 12, y0 + 33, 4, 8, PANTS)
	_rect(image, 17, y0 + 33, 4, 8, PANTS_D)
	_rect(image, 12, y0 + 40, 4, 3, SHOE)
	_rect(image, 17, y0 + 40, 4, 3, SHOE)
	_rect(image, 9, y0 + 21, 14, 13, WOOD)
	_rect(image, 9, y0 + 21, 14, 2, WOOD_L)
	_rect(image, 7, y0 + 23, 3, 9, WOOD_D)
	_rect(image, 22, y0 + 23, 3, 9, WOOD_D)
	_rect(image, 14, y0 + 22, 4, 3, CREAM)
	_rect(image, 11, y0 + 11, 10, 11, SKIN)
	_rect(image, 11, y0 + 19, 10, 2, SKIN_D)
	_rect(image, 11, y0 + 8, 10, 5, GREY)
	_rect(image, 12, y0 + 7, 8, 2, GREY_D)
	_px(image, 13, y0 + 15, OUTLINE)
	_px(image, 18, y0 + 15, OUTLINE)
	_px(image, 12, y0 + 15, GOLD)
	_px(image, 19, y0 + 15, GOLD)
	_px(image, 14, y0 + 14, GOLD)
	_px(image, 17, y0 + 14, GOLD)
	var framed := _outline(image)
	_ellipse(framed, 16, 45, 6, 2, Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 90.0 / 255.0))
	return framed


static func _key_ring() -> Image:
	var image := _new(32, 32)
	_ellipse(image, 12, 14, 6, 6, GOLD)
	_ellipse(image, 12, 14, 3, 3, Color(0, 0, 0, 0))
	_rect(image, 17, 13, 10, 3, GOLD)
	_rect(image, 24, 16, 2, 4, WOOD_D)
	_rect(image, 21, 16, 2, 3, WOOD_D)
	return _outline(image)


static func _actor(facing: String, frame: int, elder: bool) -> Image:
	var image := _new(32, 48)
	var bob := 0
	if frame == 1:
		bob = 1
	elif frame == 2 or frame == 4:
		bob = -1
	var shifts := [0, 0, -2, 0, 2, 0]
	var left_dx: int = 0 if elder else shifts[frame]
	var right_dx: int = 0 if elder else -shifts[frame]
	var shirt := CARDIGAN if elder else SHIRT
	var shirt_d := CARDIGAN_D if elder else SHIRT_D
	var shirt_l := MOSS if elder else SHIRT_L
	var hair := BUN if elder else HAIR
	var hair_l := BUN_D if elder else HAIR_L
	var legs := SKIRT if elder else PANTS
	var legs_d := SKIRT_D if elder else PANTS_D
	var y0 := bob
	if facing == "down" or facing == "up":
		_rect(image, 11, y0 + 22, 10, 11, shirt)
		_rect(image, 11, y0 + 22, 10, 2, shirt_l)
		_rect(image, 8, y0 + 24, 3, 8, shirt_d)
		_rect(image, 21, y0 + 24, 3, 8, shirt_d)
		if not elder:
			_rect(image, 14, y0 + 22, 4, 2, PAPER)
		_rect(image, 12 + left_dx, y0 + 33, 4, 8, legs)
		_rect(image, 17 + right_dx, y0 + 33, 4, 8, legs_d if frame == 2 or frame == 4 else legs)
		_rect(image, 12 + left_dx, y0 + 40, 4, 3, SHOE)
		_rect(image, 17 + right_dx, y0 + 40, 4, 3, SHOE)
	if facing == "down":
		_rect(image, 11, y0 + 10, 10, 12, SKIN)
		_rect(image, 11, y0 + 18, 10, 3, SKIN_D)
		_rect(image, 10, y0 + 8, 12, 7, hair)
		_rect(image, 11, y0 + 14, 10, 2, hair)
		_px(image, 15, y0 + 9, hair_l)
		_px(image, 13, y0 + 15, OUTLINE)
		_px(image, 18, y0 + 15, OUTLINE)
		if elder:
			_rect(image, 9, y0 + 6, 14, 6, hair)
			_px(image, 12, y0 + 15, GREY_D)
			_px(image, 19, y0 + 15, GREY_D)
			_px(image, 15, y0 + 15, GREY_D)
		elif frame == 1:
			_px(image, 13, y0 + 15, SKIN_D)
			_px(image, 18, y0 + 15, SKIN_D)
	elif facing == "up":
		_rect(image, 10, y0 + 8, 12, 14, hair)
		_rect(image, 12, y0 + 16, 8, 4, SKIN_D)
		_px(image, 14, y0 + 10, hair_l)
		if elder:
			_rect(image, 9, y0 + 5, 14, 8, hair)
	else:
		_rect(image, 12, y0 + 22, 9, 11, shirt)
		_rect(image, 12, y0 + 22, 9, 2, shirt_l)
		_rect(image, 18, y0 + 24, 3, 8, shirt_d)
		if not elder:
			_px(image, 14, y0 + 23, PAPER)
		_rect(image, 13 + left_dx, y0 + 33, 3, 8, legs)
		_rect(image, 17 + right_dx, y0 + 33, 3, 8, legs_d)
		_rect(image, 13 + left_dx, y0 + 40, 3, 3, SHOE)
		_rect(image, 17 + right_dx, y0 + 40, 3, 3, SHOE)
		_rect(image, 11, y0 + 10, 9, 11, SKIN)
		_rect(image, 10, y0 + 8, 10, 6, hair)
		_rect(image, 10, y0 + 12, 3, 6, hair)
		_px(image, 12, y0 + 15, OUTLINE)
		if elder:
			_rect(image, 12, y0 + 5, 8, 6, hair)
			_px(image, 12, y0 + 15, GREY_D)
	var framed := _outline(image)
	_ellipse(framed, 16, 45, 6, 2, Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 90.0 / 255.0))
	return framed


static func _tree(kind: int) -> Image:
	var image := _new(48, 80)
	_ellipse(image, 24, 74, 10, 3, Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 80.0 / 255.0))
	_rect(image, 21, 48, 6, 26, TRUNK_D)
	_rect(image, 22, 48, 3, 26, TRUNK)
	if kind == 0:
		_ellipse(image, 24, 36, 16, 16, LEAF_D)
		_ellipse(image, 22, 34, 12, 12, LEAF)
		_ellipse(image, 18, 30, 5, 4, LEAF_L)
	elif kind == 1:
		_ellipse(image, 24, 34, 14, 18, LEAF_D)
		_ellipse(image, 24, 32, 10, 13, LEAF)
		_ellipse(image, 20, 26, 4, 4, LEAF_L)
	else:
		_ellipse(image, 22, 38, 18, 13, LEAF_D)
		_ellipse(image, 28, 30, 8, 8, LEAF)
		_ellipse(image, 16, 34, 8, 7, LEAF_L)
	return _outline(image)


static func _bench() -> Image:
	var image := _new(48, 32)
	_rect(image, 6, 18, 4, 10, WOOD_D)
	_rect(image, 38, 18, 4, 10, WOOD_D)
	_rect(image, 4, 14, 40, 6, WOOD)
	_rect(image, 4, 14, 40, 2, WOOD_L)
	_rect(image, 6, 8, 36, 3, WOOD_D)
	_rect(image, 8, 6, 3, 8, WOOD_D)
	_rect(image, 37, 6, 3, 8, WOOD_D)
	return _outline(image)


static func _notice() -> Image:
	var image := _new(32, 48)
	_rect(image, 14, 28, 4, 18, WOOD_D)
	_rect(image, 4, 6, 24, 26, WOOD_D)
	_rect(image, 6, 8, 20, 22, PAPER)
	_px(image, 16, 10, GOLD)
	for y in [14, 17, 20, 23]:
		_rect(image, 9, y, 14, 1, CREAM_S)
	return _outline(image)


static func _lamp() -> Image:
	var image := _new(24, 56)
	_rect(image, 10, 18, 4, 34, GREY_D)
	_rect(image, 11, 18, 2, 34, GREY)
	_rect(image, 4, 8, 16, 12, GREY_D)
	_rect(image, 6, 10, 12, 8, LAMP)
	_rect(image, 8, 6, 8, 3, GREY_D)
	return _outline(image)


static func _flowers() -> Image:
	var image := _new(48, 32)
	_ellipse(image, 24, 22, 16, 6, SOIL)
	_rect(image, 10, 16, 2, 8, LEAF_D)
	_rect(image, 18, 14, 2, 8, MOSS)
	_rect(image, 28, 15, 2, 8, LEAF)
	_rect(image, 34, 17, 2, 7, LEAF_D)
	_rect(image, 8, 12, 4, 4, FLOWER)
	_rect(image, 16, 10, 4, 4, FLOWER2)
	_rect(image, 26, 11, 4, 4, CREAM_D)
	_rect(image, 33, 13, 3, 3, FLOWER)
	_px(image, 22, 18, LEAF_DRY)
	_px(image, 23, 19, LEAF_DRY)
	return _outline(image)


static func _mat() -> Image:
	var image := _new(48, 16)
	_rect(image, 2, 3, 44, 10, BRICK_D)
	_rect(image, 4, 5, 40, 6, BRICK)
	_px(image, 12, 8, BRICK_L)
	_px(image, 30, 7, PATH_C)
	return _outline(image)


static func _pew() -> Image:
	var image := _new(80, 24)
	_rect(image, 4, 14, 72, 6, WOOD)
	_rect(image, 4, 14, 72, 2, WOOD_L)
	_rect(image, 4, 6, 72, 4, WOOD_D)
	_rect(image, 6, 8, 3, 12, WOOD_D)
	_rect(image, 71, 8, 3, 12, WOOD_D)
	_rect(image, 36, 10, 6, 3, CARPET_D)
	return _outline(image)


static func _altar() -> Image:
	var image := _new(48, 32)
	_rect(image, 8, 20, 4, 8, WOOD_D)
	_rect(image, 36, 20, 4, 8, WOOD_D)
	_rect(image, 4, 14, 40, 8, WOOD)
	_rect(image, 8, 12, 32, 4, PAPER)
	_rect(image, 22, 8, 4, 6, GOLD)
	return _outline(image)


static func _chairs() -> Image:
	var image := _new(32, 40)
	for y in [8, 14, 20]:
		_rect(image, 6, y, 20, 3, WOOD)
		_rect(image, 6, y - 4, 3, 6, GREY_D)
		_rect(image, 23, y - 4, 3, 6, GREY_D)
		_rect(image, 8, y + 3, 2, 6, GREY)
		_rect(image, 22, y + 3, 2, 6, GREY)
	return _outline(image)


static func _cross() -> Image:
	var image := _new(16, 32)
	_rect(image, 6, 4, 4, 24, WOOD)
	_rect(image, 2, 10, 12, 4, WOOD_L)
	return _outline(image)


static func _window() -> Image:
	var image := _new(32, 48)
	_rect(image, 4, 6, 24, 36, WOOD_D)
	_rect(image, 7, 10, 18, 28, GLASS_D)
	_rect(image, 8, 18, 16, 8, GLASS)
	_rect(image, 12, 12, 8, 8, CARPET)
	_rect(image, 15, 10, 2, 28, GOLD)
	_rect(image, 7, 22, 18, 2, GOLD)
	_rect(image, 10, 8, 12, 3, WOOD)
	return _outline(image)


static func _glow() -> Image:
	var image := _new(64, 64)
	for y in 64:
		for x in 64:
			var d := Vector2(x - 31, y - 31).length()
			if d > 31.0:
				continue
			var band := 24.0
			if d < 6.0:
				band = 220.0
			elif d < 12.0:
				band = 160.0
			elif d < 18.0:
				band = 100.0
			elif d < 24.0:
				band = 55.0
			image.set_pixel(x, y, Color(LAMP.r, LAMP.g, LAMP.b, band / 255.0))
	return image


static func _npc_sheet(shirt: Color, shirt_d: Color, hair: Color, legs: Color, hat: bool, apron: bool) -> Image:
	var sheet := _new(64, 48)
	_blit(sheet, _npc_frame(shirt, shirt_d, hair, legs, hat, apron, 0), 0, 0)
	_blit(sheet, _npc_frame(shirt, shirt_d, hair, legs, hat, apron, 1), 32, 0)
	return sheet


static func _npc_frame(shirt: Color, shirt_d: Color, hair: Color, legs: Color, hat: bool, apron: bool, frame: int) -> Image:
	var image := _new(32, 48)
	var bob := 1 if frame == 1 else 0
	_rect(image, 11, bob + 22, 10, 11, shirt)
	_rect(image, 11, bob + 22, 10, 2, shirt_d)
	_rect(image, 8, bob + 24, 3, 8, shirt_d)
	_rect(image, 21, bob + 24, 3, 8, shirt_d)
	if apron:
		_rect(image, 13, bob + 24, 6, 8, CREAM)
	_rect(image, 12, bob + 33, 4, 8, legs)
	_rect(image, 17, bob + 33, 4, 8, legs)
	_rect(image, 12, bob + 40, 4, 3, SHOE)
	_rect(image, 17, bob + 40, 4, 3, SHOE)
	_rect(image, 11, bob + 11, 10, 11, SKIN)
	_rect(image, 11, bob + 19, 10, 2, SKIN_D)
	_rect(image, 10, bob + 8, 12, 6, hair)
	if hat:
		_rect(image, 8, bob + 6, 16, 4, GREY_D)
		_rect(image, 6, bob + 9, 20, 2, GREY)
	_px(image, 14, bob + 15, OUTLINE)
	_px(image, 18, bob + 15, OUTLINE)
	var framed := _outline(image)
	_ellipse(framed, 16, 45, 6, 2, Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 90.0 / 255.0))
	return framed


static func _hardware() -> Image:
	var image := _new(224, 128)
	_rect(image, 8, 28, 208, 18, ROOF_D)
	_rect(image, 16, 18, 192, 14, ROOF)
	_rect(image, 12, 46, 200, 70, WOOD)
	_rect(image, 12, 46, 200, 6, WOOD_L)
	_rect(image, 12, 104, 200, 16, WOOD_D)
	_rect(image, 28, 58, 36, 28, GLASS_D)
	_rect(image, 31, 61, 30, 22, GLASS)
	_rect(image, 160, 58, 36, 28, GLASS_D)
	_rect(image, 163, 61, 30, 22, GLASS)
	_rect(image, 86, 78, 52, 42, WOOD_D)
	_rect(image, 90, 82, 20, 34, WOOD_L)
	_rect(image, 114, 82, 20, 34, WOOD)
	_rect(image, 70, 36, 84, 16, CREAM_D)
	_rect(image, 74, 39, 76, 10, CREAM)
	_rect(image, 96, 41, 10, 6, GREY_D)
	_rect(image, 104, 43, 18, 2, GREY)
	_rect(image, 18, 118, 14, 4, MOSS)
	return _outline(image)


static func _garage() -> Image:
	var image := _new(256, 128)
	_rect(image, 6, 22, 244, 16, GREY_D)
	_rect(image, 10, 38, 236, 78, CREAM_D)
	_rect(image, 10, 38, 236, 8, CREAM)
	_rect(image, 24, 58, 140, 58, GREY_D)
	_rect(image, 30, 64, 128, 46, GREY)
	for y in range(70, 104, 8):
		_rect(image, 30, y, 128, 2, GREY_D)
	_rect(image, 178, 56, 48, 28, GLASS_D)
	_rect(image, 182, 60, 40, 20, GLASS)
	_rect(image, 186, 88, 40, 28, WOOD_D)
	_rect(image, 48, 78, 36, 14, SHIRT_D)
	_rect(image, 84, 82, 28, 12, BRICK_D)
	_rect(image, 58, 74, 16, 8, GLASS_H)
	return _outline(image)


static func _cottage() -> Image:
	var image := _new(160, 112)
	for y in range(8, 48):
		var inset := (48 - y) / 2
		_rect(image, inset, y, 160 - inset * 2, 1, ROOF if (y / 4) % 2 == 0 else ROOF_D)
	_rect(image, 16, 48, 128, 52, CREAM)
	_rect(image, 16, 90, 128, 12, BRICK)
	_rect(image, 28, 60, 28, 22, WOOD_D)
	_rect(image, 31, 63, 22, 16, GLASS)
	_rect(image, 104, 60, 28, 22, WOOD_D)
	_rect(image, 107, 63, 22, 16, GLASS)
	_rect(image, 66, 72, 28, 30, WOOD_D)
	_rect(image, 70, 76, 20, 22, WOOD)
	_rect(image, 20, 98, 10, 3, MOSS)
	return _outline(image)


static func _crate() -> Image:
	var image := _new(32, 32)
	_rect(image, 4, 8, 24, 20, WOOD)
	_rect(image, 4, 8, 24, 3, WOOD_L)
	_rect(image, 4, 25, 24, 3, WOOD_D)
	_rect(image, 6, 12, 20, 2, WOOD_D)
	_rect(image, 15, 10, 2, 14, WOOD_D)
	return _outline(image)


static func _mailbox() -> Image:
	var image := _new(32, 40)
	_rect(image, 14, 18, 4, 18, GREY_D)
	_rect(image, 6, 8, 20, 12, GREY)
	_rect(image, 6, 8, 20, 3, GREY_D)
	_rect(image, 8, 12, 10, 5, CREAM)
	_px(image, 22, 13, BRICK)
	return _outline(image)
