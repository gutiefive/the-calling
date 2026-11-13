class_name EnvironmentFrames
extends RefCounted
## Original outdoor tiles and church-lot props. 32x32 cells, palette only.
## Buildings keep the same pixel sizes as the M1 placeholders so collision stays put.

const Draw := preload("res://scripts/art/pixel_draw.gd")
const TILE := 32
const ATLAS_COLS := 8
const ATLAS_ROWS := 2


static func build_atlas() -> Image:
	var atlas := Draw.canvas(TILE * ATLAS_COLS, TILE * ATLAS_ROWS)
	var tiles: Array[Image] = [
		_grass(0), _grass(1), _path(), _sidewalk(),
		_grass(2), _road(), _curb(), _water(),
		_fence(), _hedge(), _flower_bed(), _church_floor(),
		_wood_floor(), _wall_base(),
	]
	for i in tiles.size():
		var col: int = i % ATLAS_COLS
		var row: int = int(i / ATLAS_COLS)
		Draw.blit(atlas, tiles[i], col * TILE, row * TILE)
	return atlas


static func build_church() -> Image:
	var image := Draw.canvas(384, 160)
	var roof := Draw.pal("roof")
	var roof_d := Draw.pal("roof_d")
	var roof_l := Draw.pal("roof_l")
	var cream := Draw.pal("cream")
	var cream_d := Draw.pal("cream_d")
	var cream_s := Draw.pal("cream_s")
	var brick := Draw.pal("brick")
	var brick_d := Draw.pal("brick_d")
	var brick_l := Draw.pal("brick_l")
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var wood_l := Draw.pal("wood_l")
	var glass := Draw.pal("glass")
	var glass_d := Draw.pal("glass_d")
	var glass_h := Draw.pal("glass_h")
	var gold := Draw.pal("gold")
	var moss := Draw.pal("moss")
	var path := Draw.pal("path")
	var path_d := Draw.pal("path_d")
	var path_c := Draw.pal("path_c")
	Draw.rect(image, 180, 4, 24, 48, roof_d)
	Draw.rect(image, 188, 0, 8, 10, roof)
	Draw.rect(image, 189, 1, 6, 14, cream)
	Draw.rect(image, 184, 5, 16, 4, cream)
	Draw.px(image, 191, 2, gold)
	Draw.px(image, 192, 3, gold)
	for y in range(36, 96):
		var inset: int = maxi(0, (52 - y) >> 1)
		var tone: Color = roof_d if (y / 5) % 2 == 0 else roof
		if absi((y / 3) - 20) < 2:
			tone = roof_l
		Draw.rect(image, inset, y, 384 - inset * 2, 1, tone)
	Draw.speckle_rect(image, Rect2i(8, 40, 368, 52), 11, 232, 255, roof_l)
	Draw.speckle_rect(image, Rect2i(8, 40, 368, 52), 12, 0, 18, roof_d)
	Draw.rect(image, 188, 40, 8, 56, roof_l)
	Draw.rect(image, 0, 92, 384, 6, roof_d)
	Draw.rect(image, 6, 98, 372, 48, cream)
	Draw.shade(image, Rect2i(6, 98, 372, 48), 21, Draw.pal("paper"), cream_s)
	Draw.speckle_rect(image, Rect2i(8, 100, 368, 40), 8, 236, 255, cream_d)
	Draw.rect(image, 6, 140, 372, 14, brick)
	for x in range(8, 376, 10):
		Draw.px(image, x, 146, brick_d)
		Draw.px(image, x + 4, 142, brick_l)
		Draw.rect(image, x, 140, 1, 14, brick_d)
	Draw.rect(image, 18, 150, 10, 3, moss)
	Draw.rect(image, 340, 148, 8, 2, moss)
	Draw.px(image, 210, 152, brick_d)
	Draw.px(image, 211, 153, brick_d)
	Draw.px(image, 212, 154, path_c)
	Draw.crack(image, 40, 118, 7, cream_s)
	Draw.crack(image, 300, 124, 8, cream_s, false)
	_church_window(image, 52, glass, glass_d, glass_h, wood_d)
	_church_window(image, 292, glass, glass_d, glass_h, wood_d)
	Draw.rect(image, 164, 108, 56, 46, wood_d)
	Draw.rect(image, 168, 112, 22, 38, wood)
	Draw.rect(image, 194, 112, 22, 38, wood_l)
	Draw.rect(image, 176, 120, 8, 12, wood_d)
	Draw.rect(image, 200, 120, 8, 12, wood_d)
	Draw.px(image, 188, 132, gold)
	Draw.px(image, 196, 132, gold)
	Draw.rect(image, 156, 152, 72, 6, path_d)
	Draw.rect(image, 160, 154, 64, 3, path)
	return Draw.outline(image)


static func build_fellowship_hall(repaired: bool) -> Image:
	var image := Draw.canvas(192, 112)
	var roof := Draw.pal("roof")
	var roof_d := Draw.pal("roof_d")
	var roof_l := Draw.pal("roof_l")
	var cream := Draw.pal("cream")
	var cream_d := Draw.pal("cream_d")
	var cream_s := Draw.pal("cream_s")
	var brick := Draw.pal("brick")
	var brick_d := Draw.pal("brick_d")
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var wood_l := Draw.pal("wood_l")
	var glass := Draw.pal("glass")
	var glass_d := Draw.pal("glass_d")
	var glass_h := Draw.pal("glass_h")
	var moss := Draw.pal("moss")
	var path := Draw.pal("path")
	var flower := Draw.pal("flower")
	var flower2 := Draw.pal("flower2")
	for y in range(6, 44):
		var inset: int = (44 - y) / 3
		var tone: Color = roof if (y / 3) % 2 == 0 else roof_d
		if repaired and absi((y / 4) - 5) < 1:
			tone = roof_l
		Draw.rect(image, inset, y, 192 - inset * 2, 1, tone)
	if not repaired:
		Draw.rect(image, 48, 18, 18, 8, cream_s)
		Draw.rect(image, 130, 22, 14, 6, cream_d)
		Draw.rect(image, 88, 14, 10, 5, cream_s)
	Draw.rect(image, 16, 44, 160, 52, cream if repaired else cream_d)
	Draw.rect(image, 16, 86, 160, 14, brick)
	for x in range(20, 172, 10):
		Draw.px(image, x, 92, brick_d)
	_hall_window(image, 36, repaired, wood_d, wood, glass, glass_d, glass_h)
	_hall_window(image, 128, repaired, wood_d, wood, glass, glass_d, glass_h)
	Draw.rect(image, 80, 64, 32, 38, wood_d)
	Draw.rect(image, 84, 68, 12, 30, wood if repaired else wood_d)
	Draw.rect(image, 98, 68, 12, 30, wood_l if repaired else wood)
	Draw.px(image, 94, 84, Draw.pal("gold") if repaired else wood_d)
	Draw.rect(image, 72, 100, 48, 6, path)
	if repaired:
		Draw.rect(image, 32, 78, 28, 6, wood)
		Draw.px(image, 36, 76, flower)
		Draw.px(image, 44, 75, flower2)
		Draw.px(image, 52, 76, flower)
		Draw.rect(image, 132, 78, 28, 6, wood)
		Draw.px(image, 138, 76, flower2)
		Draw.px(image, 146, 75, flower)
		Draw.rect(image, 20, 96, 10, 3, moss)
	else:
		Draw.rect(image, 22, 96, 16, 4, moss)
		Draw.rect(image, 150, 94, 14, 4, moss)
		Draw.crack(image, 50, 54, 8, cream_s)
		Draw.crack(image, 118, 60, 7, cream_s, false)
	return Draw.outline(image)


static func _hall_window(
	image: Image,
	x: int,
	repaired: bool,
	wood_d: Color,
	wood: Color,
	glass: Color,
	glass_d: Color,
	glass_h: Color
) -> void:
	Draw.rect(image, x, 52, 28, 22, wood_d)
	if repaired:
		Draw.rect(image, x + 3, 55, 22, 16, glass_d)
		Draw.rect(image, x + 5, 57, 18, 8, glass)
		Draw.px(image, x + 8, 58, glass_h)
		Draw.rect(image, x + 13, 55, 2, 16, wood)
	else:
		Draw.rect(image, x + 3, 55, 22, 16, wood)
		Draw.rect(image, x + 5, 57, 18, 3, wood_d)
		Draw.rect(image, x + 5, 64, 18, 3, wood_d)
		Draw.rect(image, x + 9, 55, 3, 16, wood_d)


static func build_tree() -> Image:
	var image := Draw.canvas(48, 80)
	var leaf := Draw.pal("leaf")
	var leaf_d := Draw.pal("leaf_d")
	var leaf_l := Draw.pal("leaf_l")
	var trunk := Draw.pal("trunk")
	var trunk_d := Draw.pal("trunk_d")
	var moss := Draw.pal("moss")
	var ink := Draw.pal("outline")
	ink.a = 80.0 / 255.0
	Draw.ellipse(image, 24, 74, 10, 3, ink)
	Draw.rect(image, 21, 48, 6, 26, trunk_d)
	Draw.rect(image, 22, 48, 3, 26, trunk)
	Draw.px(image, 23, 52, Draw.pal("wood_l"))
	Draw.px(image, 23, 60, Draw.pal("wood_l"))
	Draw.ellipse(image, 24, 36, 16, 16, leaf_d)
	Draw.ellipse(image, 22, 34, 12, 12, leaf)
	Draw.ellipse(image, 18, 30, 5, 4, leaf_l)
	Draw.ellipse(image, 28, 38, 6, 5, leaf)
	Draw.speckle_rect(image, Rect2i(8, 18, 32, 32), 4, 220, 255, leaf_l)
	Draw.speckle_rect(image, Rect2i(8, 18, 32, 32), 5, 0, 22, leaf_d)
	Draw.px(image, 16, 44, moss)
	Draw.px(image, 17, 45, moss)
	var framed := Draw.outline(image)
	Draw.ellipse(framed, 24, 74, 10, 3, ink)
	return framed


static func build_bench() -> Image:
	var image := Draw.canvas(48, 32)
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var wood_l := Draw.pal("wood_l")
	Draw.rect(image, 6, 18, 4, 10, wood_d)
	Draw.rect(image, 38, 18, 4, 10, wood_d)
	Draw.rect(image, 4, 14, 40, 6, wood)
	Draw.rect(image, 4, 14, 40, 2, wood_l)
	Draw.rect(image, 6, 8, 36, 3, wood_d)
	Draw.rect(image, 8, 6, 3, 8, wood_d)
	Draw.rect(image, 37, 6, 3, 8, wood_d)
	Draw.px(image, 12, 16, wood_d)
	Draw.px(image, 24, 17, wood_d)
	Draw.px(image, 34, 16, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_lamp() -> Image:
	var image := Draw.canvas(24, 56)
	var grey := Draw.pal("grey")
	var grey_d := Draw.pal("grey_d")
	var lamp := Draw.pal("lamp")
	var gold := Draw.pal("gold")
	Draw.rect(image, 10, 18, 4, 34, grey_d)
	Draw.rect(image, 11, 18, 2, 34, grey)
	Draw.rect(image, 4, 8, 16, 12, grey_d)
	Draw.rect(image, 6, 10, 12, 8, lamp)
	Draw.px(image, 8, 12, gold)
	Draw.px(image, 14, 14, Draw.pal("paper"))
	Draw.rect(image, 8, 6, 8, 3, grey_d)
	Draw.rect(image, 9, 50, 6, 4, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_notice() -> Image:
	var image := Draw.canvas(32, 48)
	var wood_d := Draw.pal("wood_d")
	var paper := Draw.pal("paper")
	var cream_s := Draw.pal("cream_s")
	var gold := Draw.pal("gold")
	Draw.rect(image, 14, 28, 4, 18, wood_d)
	Draw.rect(image, 4, 6, 24, 26, wood_d)
	Draw.rect(image, 6, 8, 20, 22, paper)
	Draw.px(image, 16, 10, gold)
	for y in [14, 17, 20, 23]:
		Draw.rect(image, 9, y, 14, 1, cream_s)
	Draw.px(image, 11, 15, Draw.pal("flower"))
	Draw.px(image, 22, 21, Draw.pal("shirt"))
	return Draw.outline(image)


static func build_mailbox() -> Image:
	var image := Draw.canvas(32, 40)
	var grey := Draw.pal("grey")
	var grey_d := Draw.pal("grey_d")
	var cream := Draw.pal("cream")
	var brick := Draw.pal("brick")
	Draw.rect(image, 14, 18, 4, 18, grey_d)
	Draw.rect(image, 6, 8, 20, 12, grey)
	Draw.rect(image, 6, 8, 20, 3, grey_d)
	Draw.rect(image, 8, 12, 10, 5, cream)
	Draw.px(image, 22, 13, brick)
	Draw.px(image, 10, 14, Draw.pal("outline"))
	Draw.rect(image, 12, 34, 8, 3, Draw.pal("path_c"))
	return Draw.outline(image)


static func _church_window(
		image: Image,
		wx: int,
		glass: Color,
		glass_d: Color,
		glass_h: Color,
		wood_d: Color
) -> void:
	Draw.rect(image, wx, 104, 40, 28, wood_d)
	Draw.rect(image, wx + 3, 107, 34, 22, glass)
	Draw.rect(image, wx + 18, 107, 2, 22, wood_d)
	Draw.rect(image, wx + 3, 116, 34, 2, wood_d)
	Draw.px(image, wx + 8, 110, glass_h)
	Draw.px(image, wx + 28, 122, glass_d)
	Draw.px(image, wx + 12, 118, Draw.pal("carpet"))
	Draw.px(image, wx + 24, 112, Draw.pal("gold"))


static func _grass(variant: int) -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("grass"))
	Draw.speckle(image, 3 + variant * 11, 210, 255, Draw.pal("grass_l"))
	Draw.speckle(image, 4 + variant * 11, 0, 28, Draw.pal("grass_d"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 9 + variant, Draw.pal("grass_h"), Draw.pal("moss"))
	if variant == 1:
		Draw.speckle(image, 40, 40, 42, Draw.pal("grass_h"))
		Draw.px(image, 7, 18, Draw.pal("moss"))
		Draw.px(image, 22, 9, Draw.pal("moss"))
	elif variant == 2:
		Draw.speckle(image, 18, 200, 210, Draw.pal("leaf_dry"))
		Draw.px(image, 14, 24, Draw.pal("soil"))
		Draw.px(image, 15, 25, Draw.pal("soil"))
	return image


static func _path() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("path_d"))
	Draw.rect(image, 1, 1, 14, 14, Draw.pal("path"))
	Draw.rect(image, 17, 1, 14, 14, Draw.pal("path"))
	Draw.rect(image, 1, 17, 14, 14, Draw.pal("path_l"))
	Draw.rect(image, 17, 17, 14, 14, Draw.pal("path"))
	Draw.speckle(image, 6, 220, 255, Draw.pal("path_l"))
	Draw.speckle(image, 7, 0, 16, Draw.pal("path_c"))
	Draw.px(image, 8, 22, Draw.pal("path_c"))
	Draw.px(image, 9, 23, Draw.pal("path_c"))
	Draw.px(image, 24, 6, Draw.pal("path_c"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 14, Draw.pal("path_l"), Draw.pal("path_c"))
	return image


static func _sidewalk() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("grey"))
	for y in [0, 16]:
		for x in [0, 16]:
			Draw.rect(image, x, y, 15, 15, Draw.pal("grey"))
			Draw.rect(image, x, y, 15, 1, Draw.pal("grey_d"))
			Draw.rect(image, x, y, 1, 15, Draw.pal("grey_d"))
	Draw.crack(image, 6, 4, 6, Draw.pal("path_c"))
	Draw.crack(image, 22, 18, 5, Draw.pal("path_c"), false)
	Draw.speckle(image, 22, 0, 14, Draw.pal("moss"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 16, Draw.pal("paper"), Draw.pal("grey_d"))
	return image


static func _road() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("gravel_d"))
	Draw.speckle(image, 8, 180, 255, Draw.pal("gravel"))
	Draw.speckle(image, 9, 0, 20, Draw.pal("path_c"))
	Draw.crack(image, 4, 8, 10, Draw.pal("path_c"))
	Draw.crack(image, 18, 4, 8, Draw.pal("outline"), false)
	Draw.rect(image, 12, 14, 8, 5, Draw.pal("gravel"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 19, Draw.pal("grey"), Draw.pal("outline"))
	return image


static func _curb() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("grey"))
	Draw.rect(image, 0, 0, 32, 18, Draw.pal("grey"))
	Draw.rect(image, 0, 18, 32, 14, Draw.pal("grey_d"))
	Draw.rect(image, 0, 18, 32, 2, Draw.pal("paper"))
	Draw.rect(image, 0, 30, 32, 2, Draw.pal("path_c"))
	Draw.speckle_rect(image, Rect2i(0, 0, 32, 18), 25, 0, 18, Draw.pal("moss"))
	Draw.px(image, 8, 22, Draw.pal("path_c"))
	Draw.px(image, 20, 24, Draw.pal("gravel"))
	return image


static func _water() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("glass_d"))
	Draw.speckle(image, 11, 200, 255, Draw.pal("glass"))
	Draw.speckle(image, 12, 0, 36, Draw.pal("glass_h"))
	Draw.rect(image, 0, 10, 32, 2, Draw.pal("glass"))
	Draw.rect(image, 0, 22, 32, 2, Draw.pal("glass_h"))
	return image


static func _fence() -> Image:
	var image := Draw.canvas(TILE, TILE)
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var wood_l := Draw.pal("wood_l")
	for x in [4, 15, 26]:
		Draw.rect(image, x, 6, 4, 22, wood_d)
		Draw.rect(image, x + 1, 6, 2, 22, wood)
		Draw.px(image, x + 1, 8, wood_l)
	Draw.rect(image, 2, 10, 28, 3, wood)
	Draw.rect(image, 2, 10, 28, 1, wood_l)
	Draw.rect(image, 2, 18, 28, 3, wood_d)
	var framed := Draw.outline(image)
	Draw.fill_empty(framed, Draw.pal("grass"))
	Draw.speckle(framed, 30, 220, 255, Draw.pal("grass_l"), true)
	return framed


static func _hedge() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.ellipse(image, 16, 18, 14, 12, Draw.pal("leaf_d"))
	Draw.ellipse(image, 14, 16, 10, 10, Draw.pal("leaf"))
	Draw.ellipse(image, 10, 14, 5, 4, Draw.pal("leaf_l"))
	Draw.ellipse(image, 22, 20, 6, 5, Draw.pal("leaf"))
	Draw.speckle_rect(image, Rect2i(2, 6, 28, 24), 33, 210, 255, Draw.pal("leaf_l"))
	Draw.speckle_rect(image, Rect2i(2, 6, 28, 24), 34, 0, 20, Draw.pal("leaf_d"))
	Draw.px(image, 8, 22, Draw.pal("moss"))
	var framed := Draw.outline(image)
	Draw.fill_empty(framed, Draw.pal("grass"))
	return framed


static func _flower_bed() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.rect(image, 2, 16, 28, 14, Draw.pal("soil"))
	Draw.rect(image, 2, 16, 28, 2, Draw.pal("wood_d"))
	Draw.rect(image, 8, 10, 2, 8, Draw.pal("leaf_d"))
	Draw.rect(image, 14, 8, 2, 10, Draw.pal("moss"))
	Draw.rect(image, 20, 11, 2, 8, Draw.pal("leaf"))
	Draw.rect(image, 24, 12, 2, 7, Draw.pal("leaf_d"))
	Draw.rect(image, 6, 8, 4, 4, Draw.pal("flower"))
	Draw.rect(image, 13, 6, 4, 4, Draw.pal("flower2"))
	Draw.rect(image, 19, 8, 4, 3, Draw.pal("cream_d"))
	Draw.rect(image, 24, 10, 3, 3, Draw.pal("flower"))
	Draw.speckle_rect(image, Rect2i(2, 18, 28, 12), 41, 0, 24, Draw.pal("path_c"))
	var framed := Draw.outline(image)
	Draw.fill_empty(framed, Draw.pal("grass"))
	return framed


static func _church_floor() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("carpet"))
	Draw.rect(image, 0, 0, 2, 32, Draw.pal("carpet_d"))
	Draw.rect(image, 30, 0, 2, 32, Draw.pal("carpet_d"))
	Draw.rect(image, 14, 0, 4, 32, Draw.pal("carpet_l"))
	Draw.speckle(image, 44, 230, 255, Draw.pal("carpet_l"))
	Draw.speckle(image, 45, 0, 16, Draw.pal("carpet_d"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 28, Draw.pal("carpet_l"), Draw.pal("carpet_d"))
	return image


static func _wood_floor() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("wood"))
	for y in [0, 8, 16, 24]:
		Draw.rect(image, 0, y, 32, 1, Draw.pal("wood_d"))
		Draw.rect(image, 0, y + 1, 32, 1, Draw.pal("wood_l"))
	for x in [6, 20]:
		Draw.rect(image, x, 0, 1, 8, Draw.pal("wood_d"))
		Draw.rect(image, x + 8, 8, 1, 8, Draw.pal("wood_d"))
		Draw.rect(image, x, 16, 1, 8, Draw.pal("wood_d"))
		Draw.rect(image, x + 4, 24, 1, 8, Draw.pal("wood_d"))
	Draw.speckle(image, 50, 0, 12, Draw.pal("path_c"))
	Draw.shade(image, Rect2i(0, 0, TILE, TILE), 31, Draw.pal("wood_l"), Draw.pal("wood_d"))
	return image


static func _wall_base() -> Image:
	var image := Draw.canvas(TILE, TILE)
	Draw.fill(image, Draw.pal("plaster"))
	Draw.rect(image, 0, 26, 32, 6, Draw.pal("wood_d"))
	Draw.rect(image, 0, 26, 32, 1, Draw.pal("wood"))
	Draw.speckle(image, 55, 230, 255, Draw.pal("plaster_d"))
	Draw.shade(image, Rect2i(0, 0, 32, 26), 36, Draw.pal("paper"), Draw.pal("plaster_d"))
	Draw.crack(image, 20, 8, 6, Draw.pal("plaster_d"))
	Draw.px(image, 5, 20, Draw.pal("moss"))
	return image
