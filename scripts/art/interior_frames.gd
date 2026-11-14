class_name InteriorFrames
extends RefCounted
## Procedural interior tiles and furniture. Palette only. Readable at the game camera.

const Draw := preload("res://scripts/art/pixel_draw.gd")
const TILE := 32


static func build_atlas() -> Image:
	var atlas := Draw.canvas(TILE * 8, TILE)
	var tiles: Array[Image] = [
		_wall(), _wood(), _kitchen_tile(), _carpet(),
		_runner(), _stone(), _lino(), _stain(),
	]
	for i in tiles.size():
		Draw.blit(atlas, tiles[i], i * TILE, 0)
	return atlas


static func build(frame_id: String) -> Image:
	match frame_id:
		"atlas":
			return build_atlas()
		"pew":
			return _pew()
		"altar":
			return _altar()
		"pulpit":
			return _pulpit()
		"platform":
			return _platform()
		"cross":
			return _cross()
		"stained_glass":
			return _stained_glass(0)
		"stained_glass_b":
			return _stained_glass(1)
		"stained_glass_c":
			return _stained_glass(2)
		"piano":
			return _piano()
		"hymn_board":
			return _hymn_board()
		"candles":
			return _candles()
		"welcome_table":
			return _welcome_table()
		"coat_rack":
			return _coat_rack()
		"guest_book":
			return _guest_book()
		"bulletin":
			return _bulletin()
		"bench":
			return _bench()
		"desk":
			return _desk()
		"office_chair":
			return _office_chair()
		"bookshelf":
			return _bookshelf()
		"filing":
			return _filing()
		"lamp":
			return _lamp()
		"photo":
			return _photo()
		"vision_sketch":
			return _vision_sketch()
		"kneeler":
			return _kneeler()
		"restroom_door":
			return _restroom_door()
		"counter":
			return _counter()
		"stove":
			return _stove()
		"fridge":
			return _fridge()
		"sink":
			return _sink()
		"pots":
			return _pots()
		"cooler":
			return _cooler()
		"round_table":
			return _round_table()
		"podium":
			return _podium()
		"coffee":
			return _coffee()
		"lost_box":
			return _lost_box()
		"speaker":
			return _speaker()
		"kids_table":
			return _kids_table()
		"kids_chair":
			return _kids_chair()
		"chalkboard":
			return _chalkboard()
		"crayons":
			return _crayons()
		"folding_tables":
			return _folding_tables()
		"stacked_chairs":
			return _stacked_chairs()
		"stain_pool":
			return _stain_pool()
		_:
			var clutter: Image = InteriorClutterFrames.build(frame_id)
			if clutter != null:
				return clutter
			return _desk()


static func texture(frame_id: String) -> Texture2D:
	var image := build(frame_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func _wall() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("plaster"))
	Draw.rect(image, 0, 0, TILE, 4, Draw.pal("wood_d"))
	Draw.rect(image, 0, 28, TILE, 4, Draw.pal("wood"))
	Draw.speckle(image, 21, 220, 255, Draw.pal("plaster_d"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 18, Draw.pal("cream"), Draw.pal("plaster_d"))
	return image


static func _wood() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("wood"))
	for y in [0, 8, 16, 24]:
		Draw.rect(image, 0, y, TILE, 1, Draw.pal("wood_d"))
		Draw.rect(image, 0, y + 1, TILE, 1, Draw.pal("wood_l"))
	Draw.speckle(image, 33, 0, 10, Draw.pal("path_c"))
	return image


static func _kitchen_tile() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("cream"))
	Draw.rect(image, 0, 0, 16, 16, Draw.pal("paper"))
	Draw.rect(image, 16, 16, 16, 16, Draw.pal("paper"))
	Draw.rect(image, 15, 0, 1, TILE, Draw.pal("cream_d"))
	Draw.rect(image, 0, 15, TILE, 1, Draw.pal("cream_d"))
	Draw.speckle(image, 12, 240, 255, Draw.pal("grey"))
	return image


static func _carpet() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("carpet"))
	Draw.speckle(image, 40, 200, 255, Draw.pal("carpet_l"))
	Draw.speckle(image, 41, 0, 18, Draw.pal("carpet_d"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 22, Draw.pal("carpet_l"), Draw.pal("carpet_d"))
	return image


static func _runner() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("carpet_d"))
	Draw.rect(image, 4, 0, 24, TILE, Draw.pal("carpet"))
	Draw.rect(image, 6, 0, 2, TILE, Draw.pal("gold"))
	Draw.rect(image, 24, 0, 2, TILE, Draw.pal("gold"))
	Draw.speckle(image, 48, 210, 255, Draw.pal("carpet_l"))
	return image


static func _stone() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("path"))
	Draw.rect(image, 0, 0, 16, 16, Draw.pal("path_l"))
	Draw.rect(image, 16, 16, 16, 16, Draw.pal("path_l"))
	Draw.rect(image, 15, 0, 2, TILE, Draw.pal("path_d"))
	Draw.rect(image, 0, 15, TILE, 2, Draw.pal("path_d"))
	Draw.speckle(image, 9, 0, 14, Draw.pal("path_c"))
	return image


static func _lino() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("cream_d"))
	Draw.rect(image, 0, 0, TILE, 1, Draw.pal("wood_l"))
	Draw.speckle(image, 27, 180, 255, Draw.pal("paper"))
	Draw.speckle(image, 28, 0, 12, Draw.pal("path_c"))
	return image


static func _stain() -> Image:
	var image := _carpet()
	Draw.ellipse(image, 10, 12, 6, 5, Color(176.0 / 255.0, 96.0 / 255.0, 92.0 / 255.0, 0.55))
	Draw.ellipse(image, 22, 18, 5, 6, Color(78.0 / 255.0, 110.0 / 255.0, 136.0 / 255.0, 0.5))
	Draw.ellipse(image, 16, 8, 4, 3, Color(196.0 / 255.0, 156.0 / 255.0, 78.0 / 255.0, 0.45))
	return image


static func _pew() -> Image:
	var image := Draw.canvas(288, 32)
	Draw.rect(image, 6, 18, 276, 10, Draw.pal("wood"))
	Draw.rect(image, 6, 18, 276, 3, Draw.pal("wood_l"))
	Draw.rect(image, 8, 8, 272, 8, Draw.pal("wood_d"))
	Draw.rect(image, 8, 8, 272, 2, Draw.pal("wood_l"))
	Draw.rect(image, 10, 10, 4, 16, Draw.pal("wood_d"))
	Draw.rect(image, 274, 10, 4, 16, Draw.pal("wood_d"))
	Draw.rect(image, 40, 12, 10, 5, Draw.pal("paper"))
	Draw.rect(image, 88, 12, 10, 5, Draw.pal("brick"))
	Draw.rect(image, 188, 12, 10, 5, Draw.pal("paper"))
	Draw.rect(image, 240, 12, 10, 5, Draw.pal("carpet_d"))
	return Draw.outline(image)


static func _altar() -> Image:
	var image := Draw.canvas(64, 40)
	Draw.rect(image, 8, 24, 8, 12, Draw.pal("wood_d"))
	Draw.rect(image, 48, 24, 8, 12, Draw.pal("wood_d"))
	Draw.rect(image, 4, 16, 56, 12, Draw.pal("wood"))
	Draw.rect(image, 4, 16, 56, 3, Draw.pal("wood_l"))
	Draw.rect(image, 10, 12, 44, 6, Draw.pal("paper"))
	Draw.rect(image, 28, 6, 8, 10, Draw.pal("gold"))
	Draw.rect(image, 30, 4, 4, 4, Draw.pal("gold"))
	return Draw.outline(image)


static func _pulpit() -> Image:
	var image := Draw.canvas(40, 44)
	Draw.rect(image, 10, 22, 20, 18, Draw.pal("wood_d"))
	Draw.rect(image, 4, 14, 32, 10, Draw.pal("wood"))
	Draw.rect(image, 6, 12, 28, 4, Draw.pal("wood_l"))
	Draw.rect(image, 12, 8, 16, 6, Draw.pal("paper"))
	return Draw.outline(image)


static func _platform() -> Image:
	var image := Draw.canvas(160, 24)
	Draw.rect(image, 0, 8, 160, 16, Draw.pal("wood"))
	Draw.rect(image, 0, 8, 160, 3, Draw.pal("wood_l"))
	Draw.rect(image, 0, 20, 160, 4, Draw.pal("wood_d"))
	Draw.speckle(image, 14, 0, 10, Draw.pal("path_c"))
	return Draw.outline(image)


static func _cross() -> Image:
	var image := Draw.canvas(20, 40)
	Draw.rect(image, 8, 4, 4, 32, Draw.pal("wood"))
	Draw.rect(image, 2, 12, 16, 4, Draw.pal("wood_l"))
	Draw.rect(image, 8, 4, 4, 2, Draw.pal("wood_l"))
	return Draw.outline(image)


static func _stained_glass(kind: int) -> Image:
	var image := Draw.canvas(32, 56)
	Draw.rect(image, 2, 2, 28, 52, Draw.pal("wood_d"))
	Draw.rect(image, 4, 6, 24, 44, Draw.pal("outline"))
	var a := Draw.pal("flower")
	var b := Draw.pal("glass_d")
	var c := Draw.pal("gold")
	if kind == 1:
		a = Draw.pal("shirt")
		b = Draw.pal("flower2")
		c = Draw.pal("glass")
	elif kind == 2:
		a = Draw.pal("gold")
		b = Draw.pal("flower")
		c = Draw.pal("shirt_l")
	Draw.rect(image, 6, 8, 10, 18, a)
	Draw.rect(image, 16, 8, 10, 18, b)
	Draw.rect(image, 6, 28, 10, 18, b)
	Draw.rect(image, 16, 28, 10, 18, c)
	Draw.rect(image, 14, 8, 4, 38, Draw.pal("gold"))
	Draw.rect(image, 6, 26, 20, 3, Draw.pal("gold"))
	Draw.px(image, 11, 16, Draw.pal("glass_h"))
	Draw.px(image, 21, 34, Draw.pal("glass_h"))
	return Draw.outline(image)


static func _piano() -> Image:
	var image := Draw.canvas(72, 40)
	Draw.rect(image, 4, 16, 64, 18, Draw.pal("pants"))
	Draw.rect(image, 4, 16, 64, 4, Draw.pal("pants_d"))
	Draw.rect(image, 8, 12, 56, 8, Draw.pal("paper"))
	for x in range(10, 60, 4):
		Draw.rect(image, x, 12, 2, 6, Draw.pal("outline"))
	Draw.rect(image, 48, 6, 14, 10, Draw.pal("pants_d"))
	return Draw.outline(image)


static func _hymn_board() -> Image:
	var image := Draw.canvas(28, 40)
	Draw.rect(image, 2, 2, 24, 36, Draw.pal("wood_d"))
	Draw.rect(image, 4, 6, 20, 28, Draw.pal("path_c"))
	Draw.rect(image, 6, 10, 16, 3, Draw.pal("paper"))
	Draw.rect(image, 6, 16, 16, 3, Draw.pal("paper"))
	Draw.rect(image, 6, 22, 16, 3, Draw.pal("paper"))
	return Draw.outline(image)


static func _candles() -> Image:
	var image := Draw.canvas(24, 28)
	Draw.rect(image, 4, 16, 16, 8, Draw.pal("wood"))
	Draw.rect(image, 6, 8, 4, 10, Draw.pal("paper"))
	Draw.rect(image, 14, 6, 4, 12, Draw.pal("paper"))
	Draw.px(image, 7, 6, Draw.pal("lamp"))
	Draw.px(image, 15, 4, Draw.pal("lamp"))
	return Draw.outline(image)


static func _welcome_table() -> Image:
	var image := Draw.canvas(80, 36)
	Draw.rect(image, 8, 20, 8, 12, Draw.pal("wood_d"))
	Draw.rect(image, 64, 20, 8, 12, Draw.pal("wood_d"))
	Draw.rect(image, 4, 12, 72, 12, Draw.pal("wood"))
	Draw.rect(image, 8, 8, 20, 8, Draw.pal("paper"))
	Draw.rect(image, 32, 8, 16, 6, Draw.pal("flower"))
	Draw.rect(image, 52, 8, 18, 8, Draw.pal("paper"))
	return Draw.outline(image)


static func _coat_rack() -> Image:
	var image := Draw.canvas(24, 48)
	Draw.rect(image, 10, 8, 4, 36, Draw.pal("wood_d"))
	Draw.rect(image, 4, 12, 16, 3, Draw.pal("wood"))
	Draw.rect(image, 6, 16, 5, 14, Draw.pal("cardigan"))
	Draw.rect(image, 14, 18, 5, 12, Draw.pal("skirt"))
	return Draw.outline(image)


static func _guest_book() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.rect(image, 4, 14, 24, 6, Draw.pal("wood"))
	Draw.rect(image, 8, 8, 16, 10, Draw.pal("paper"))
	Draw.rect(image, 10, 10, 12, 2, Draw.pal("path_c"))
	return Draw.outline(image)


static func _bulletin() -> Image:
	var image := Draw.canvas(40, 48)
	Draw.rect(image, 2, 4, 36, 40, Draw.pal("wood_d"))
	Draw.rect(image, 6, 8, 28, 32, Draw.pal("path"))
	Draw.rect(image, 8, 10, 10, 12, Draw.pal("paper"))
	Draw.rect(image, 20, 12, 10, 8, Draw.pal("flower2"))
	Draw.rect(image, 10, 24, 16, 10, Draw.pal("paper"))
	return Draw.outline(image)


static func _bench() -> Image:
	var image := Draw.canvas(56, 24)
	Draw.rect(image, 4, 12, 48, 6, Draw.pal("wood"))
	Draw.rect(image, 6, 8, 44, 4, Draw.pal("wood_l"))
	Draw.rect(image, 6, 18, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 46, 18, 4, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _desk() -> Image:
	var image := Draw.canvas(72, 40)
	Draw.rect(image, 6, 22, 8, 14, Draw.pal("wood_d"))
	Draw.rect(image, 58, 22, 8, 14, Draw.pal("wood_d"))
	Draw.rect(image, 4, 14, 64, 12, Draw.pal("wood"))
	Draw.rect(image, 8, 8, 20, 8, Draw.pal("paper"))
	Draw.rect(image, 40, 10, 12, 6, Draw.pal("grey"))
	return Draw.outline(image)


static func _office_chair() -> Image:
	var image := Draw.canvas(24, 28)
	Draw.rect(image, 6, 8, 12, 10, Draw.pal("pants_d"))
	Draw.rect(image, 4, 16, 16, 6, Draw.pal("wood"))
	Draw.rect(image, 8, 22, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 14, 22, 3, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _bookshelf() -> Image:
	var image := Draw.canvas(40, 56)
	Draw.rect(image, 2, 2, 36, 52, Draw.pal("wood_d"))
	for y in [8, 22, 36]:
		Draw.rect(image, 4, y, 32, 10, Draw.pal("wood"))
		Draw.rect(image, 6, y + 2, 6, 8, Draw.pal("brick"))
		Draw.rect(image, 14, y + 2, 6, 8, Draw.pal("shirt"))
		Draw.rect(image, 22, y + 2, 8, 8, Draw.pal("cardigan"))
	return Draw.outline(image)


static func _filing() -> Image:
	var image := Draw.canvas(28, 40)
	Draw.rect(image, 2, 4, 24, 34, Draw.pal("grey"))
	Draw.rect(image, 4, 8, 20, 8, Draw.pal("grey_d"))
	Draw.rect(image, 4, 18, 20, 8, Draw.pal("grey_d"))
	Draw.rect(image, 4, 28, 20, 6, Draw.pal("grey_d"))
	Draw.px(image, 14, 12, Draw.pal("gold"))
	return Draw.outline(image)


static func _lamp() -> Image:
	var image := Draw.canvas(16, 28)
	Draw.rect(image, 6, 14, 4, 12, Draw.pal("wood_d"))
	Draw.rect(image, 2, 4, 12, 12, Draw.pal("lamp"))
	Draw.rect(image, 4, 6, 8, 8, Draw.pal("paper"))
	return Draw.outline(image)


static func _photo() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 2, 2, 16, 20, Draw.pal("wood"))
	Draw.rect(image, 4, 4, 12, 14, Draw.pal("glass"))
	Draw.rect(image, 6, 10, 4, 6, Draw.pal("cardigan"))
	Draw.rect(image, 11, 10, 4, 6, Draw.pal("shirt"))
	return Draw.outline(image)


static func _vision_sketch() -> Image:
	var image := Draw.canvas(28, 24)
	Draw.rect(image, 2, 2, 24, 20, Draw.pal("wood_d"))
	Draw.rect(image, 4, 4, 20, 16, Draw.pal("paper"))
	Draw.rect(image, 8, 10, 6, 8, Draw.pal("path_c"))
	Draw.rect(image, 16, 8, 4, 10, Draw.pal("path_c"))
	Draw.rect(image, 12, 6, 2, 4, Draw.pal("path_d"))
	return Draw.outline(image)


static func _kneeler() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.rect(image, 4, 14, 24, 6, Draw.pal("wood"))
	Draw.rect(image, 6, 8, 20, 8, Draw.pal("carpet"))
	Draw.rect(image, 8, 4, 16, 6, Draw.pal("carpet_d"))
	return Draw.outline(image)


static func _restroom_door() -> Image:
	var image := Draw.canvas(24, 48)
	Draw.rect(image, 2, 2, 20, 44, Draw.pal("cream_d"))
	Draw.rect(image, 4, 6, 16, 36, Draw.pal("wood"))
	Draw.rect(image, 16, 22, 3, 6, Draw.pal("gold"))
	Draw.rect(image, 6, 8, 12, 6, Draw.pal("paper"))
	return Draw.outline(image)


static func _counter() -> Image:
	var image := Draw.canvas(96, 32)
	Draw.rect(image, 0, 12, 96, 16, Draw.pal("wood"))
	Draw.rect(image, 0, 12, 96, 4, Draw.pal("cream"))
	Draw.rect(image, 8, 6, 16, 8, Draw.pal("grey"))
	Draw.rect(image, 40, 4, 20, 10, Draw.pal("paper"))
	return Draw.outline(image)


static func _stove() -> Image:
	var image := Draw.canvas(40, 36)
	Draw.rect(image, 4, 10, 32, 22, Draw.pal("grey_d"))
	Draw.ellipse(image, 14, 18, 6, 4, Draw.pal("pants"))
	Draw.ellipse(image, 26, 18, 6, 4, Draw.pal("pants"))
	Draw.rect(image, 8, 26, 24, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _fridge() -> Image:
	var image := Draw.canvas(28, 48)
	Draw.rect(image, 2, 2, 24, 44, Draw.pal("grey"))
	Draw.rect(image, 4, 6, 20, 16, Draw.pal("grey_d"))
	Draw.rect(image, 4, 24, 20, 18, Draw.pal("grey_d"))
	Draw.rect(image, 20, 16, 3, 6, Draw.pal("gold"))
	return Draw.outline(image)


static func _sink() -> Image:
	var image := Draw.canvas(40, 28)
	Draw.rect(image, 2, 10, 36, 14, Draw.pal("wood"))
	Draw.rect(image, 8, 6, 24, 12, Draw.pal("glass"))
	Draw.rect(image, 18, 2, 4, 8, Draw.pal("grey"))
	return Draw.outline(image)


static func _pots() -> Image:
	var image := Draw.canvas(28, 24)
	Draw.ellipse(image, 8, 14, 7, 6, Draw.pal("grey_d"))
	Draw.ellipse(image, 20, 12, 6, 5, Draw.pal("brick_d"))
	Draw.rect(image, 6, 8, 4, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _cooler() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.rect(image, 2, 6, 28, 16, Draw.pal("shirt"))
	Draw.rect(image, 4, 8, 24, 4, Draw.pal("shirt_l"))
	Draw.rect(image, 12, 4, 8, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _round_table() -> Image:
	var image := Draw.canvas(80, 58)
	Draw.ellipse(image, 40, 48, 30, 9, Draw.pal("path_c"))
	Draw.rect(image, 18, 34, 6, 16, Draw.pal("wood_d"))
	Draw.rect(image, 56, 34, 6, 16, Draw.pal("wood_d"))
	Draw.rect(image, 24, 38, 5, 14, Draw.pal("wood_d"))
	Draw.rect(image, 51, 38, 5, 14, Draw.pal("wood_d"))
	Draw.ellipse(image, 40, 32, 33, 16, Draw.pal("wood_d"))
	Draw.ellipse(image, 40, 26, 32, 16, Draw.pal("wood"))
	Draw.ellipse(image, 40, 24, 30, 14, Draw.pal("paper"))
	Draw.ellipse(image, 40, 22, 26, 11, Draw.pal("cream"))
	Draw.ellipse(image, 32, 18, 10, 5, Draw.pal("paper"))
	Draw.rect(image, 16, 30, 48, 3, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _podium() -> Image:
	var image := Draw.canvas(32, 36)
	Draw.rect(image, 8, 16, 16, 16, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 24, 8, Draw.pal("wood"))
	Draw.rect(image, 8, 6, 16, 6, Draw.pal("paper"))
	return Draw.outline(image)


static func _coffee() -> Image:
	var image := Draw.canvas(48, 32)
	Draw.rect(image, 4, 16, 40, 12, Draw.pal("wood"))
	Draw.rect(image, 8, 6, 14, 16, Draw.pal("grey_d"))
	Draw.rect(image, 26, 10, 8, 10, Draw.pal("paper"))
	Draw.rect(image, 36, 12, 6, 8, Draw.pal("cream"))
	return Draw.outline(image)


static func _lost_box() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.rect(image, 4, 8, 24, 14, Draw.pal("wood"))
	Draw.rect(image, 6, 10, 20, 8, Draw.pal("path_c"))
	Draw.rect(image, 10, 6, 8, 6, Draw.pal("cardigan"))
	return Draw.outline(image)


static func _speaker() -> Image:
	var image := Draw.canvas(24, 32)
	Draw.rect(image, 4, 4, 16, 24, Draw.pal("pants_d"))
	Draw.ellipse(image, 12, 14, 6, 6, Draw.pal("grey"))
	return Draw.outline(image)


static func _kids_table() -> Image:
	var image := Draw.canvas(48, 28)
	Draw.rect(image, 6, 16, 6, 8, Draw.pal("wood_d"))
	Draw.rect(image, 36, 16, 6, 8, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 40, 8, Draw.pal("wood_l"))
	Draw.rect(image, 10, 6, 8, 6, Draw.pal("paper"))
	Draw.rect(image, 24, 6, 8, 6, Draw.pal("flower"))
	return Draw.outline(image)


static func _kids_chair() -> Image:
	var image := Draw.canvas(16, 20)
	Draw.rect(image, 4, 4, 8, 6, Draw.pal("flower2"))
	Draw.rect(image, 3, 10, 10, 4, Draw.pal("wood"))
	Draw.rect(image, 4, 14, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 9, 14, 3, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _chalkboard() -> Image:
	var image := Draw.canvas(56, 40)
	Draw.rect(image, 2, 2, 52, 36, Draw.pal("wood_d"))
	Draw.rect(image, 6, 6, 44, 28, Draw.pal("pants_d"))
	Draw.rect(image, 12, 14, 16, 10, Draw.pal("glass_h"))
	Draw.rect(image, 30, 18, 10, 8, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _crayons() -> Image:
	var image := Draw.canvas(20, 16)
	Draw.rect(image, 2, 6, 4, 8, Draw.pal("flower"))
	Draw.rect(image, 8, 4, 4, 10, Draw.pal("shirt"))
	Draw.rect(image, 14, 6, 4, 8, Draw.pal("gold"))
	return Draw.outline(image)


static func _folding_tables() -> Image:
	var image := Draw.canvas(48, 32)
	Draw.rect(image, 6, 8, 36, 6, Draw.pal("grey"))
	Draw.rect(image, 8, 14, 36, 6, Draw.pal("grey_d"))
	Draw.rect(image, 10, 20, 36, 6, Draw.pal("grey"))
	return Draw.outline(image)


static func _stacked_chairs() -> Image:
	var image := Draw.canvas(32, 40)
	for y in [8, 16, 24]:
		Draw.rect(image, 6, y, 20, 4, Draw.pal("wood"))
		Draw.rect(image, 6, y - 6, 4, 8, Draw.pal("grey_d"))
		Draw.rect(image, 22, y - 6, 4, 8, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _stain_pool() -> Image:
	var image := Draw.canvas(48, 32)
	image.fill(Color(0, 0, 0, 0))
	Draw.ellipse(image, 16, 16, 14, 10, Color(176.0 / 255.0, 96.0 / 255.0, 92.0 / 255.0, 0.35))
	Draw.ellipse(image, 30, 14, 12, 9, Color(78.0 / 255.0, 110.0 / 255.0, 136.0 / 255.0, 0.32))
	Draw.ellipse(image, 22, 18, 10, 7, Color(196.0 / 255.0, 156.0 / 255.0, 78.0 / 255.0, 0.28))
	return image
