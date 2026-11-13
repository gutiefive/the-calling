class_name RepairFrames
extends RefCounted
## 32×32 worksite stages. Palette colors only. Each stage must look different.

const SIZE := Vector2i(32, 32)


static func build(frame_id: String) -> Image:
	match frame_id:
		"fence_damaged":
			return _fence_damaged()
		"fence_cleared":
			return _fence_cleared()
		"fence_new_wood":
			return _fence_new_wood()
		"fence_finished":
			return _fence_finished()
		"weeds_patch":
			return _weeds_patch()
		"weeds_cleared":
			return _weeds_cleared()
		"litter_pile":
			return _litter_pile()
		"litter_gone":
			return PixelDraw.canvas(SIZE.x, SIZE.y)
		"bed_overgrown":
			return _bed_overgrown()
		"bed_trimmed":
			return _bed_trimmed()
		"bed_restored":
			return _bed_restored()
		"fx_repair":
			return _fx_repair()
		_:
			return _fence_damaged()


static func texture(frame_id: String) -> Texture2D:
	var image := build(frame_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func _fence_damaged() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var ink := PixelDraw.pal("outline")
	var grass := PixelDraw.pal("grass")
	PixelDraw.rect(image, 4, 26, 24, 4, grass)
	# Left post still standing.
	PixelDraw.rect(image, 4, 4, 5, 24, wood_d)
	PixelDraw.rect(image, 5, 5, 2, 22, wood)
	# Right post leaning.
	PixelDraw.rect(image, 24, 8, 5, 20, wood_d)
	PixelDraw.rect(image, 25, 9, 2, 18, wood)
	PixelDraw.px(image, 29, 10, wood_l)
	# Broken rails hanging off.
	PixelDraw.rect(image, 8, 10, 10, 3, wood)
	PixelDraw.px(image, 18, 11, wood_d)
	PixelDraw.px(image, 19, 12, wood_d)
	PixelDraw.rect(image, 9, 20, 8, 3, wood_l)
	PixelDraw.px(image, 17, 21, wood_d)
	# Splinters on the ground.
	PixelDraw.px(image, 14, 27, wood_d)
	PixelDraw.px(image, 16, 28, wood)
	PixelDraw.px(image, 20, 27, wood_l)
	PixelDraw.px(image, 12, 16, ink)
	return PixelDraw.outline(image)


static func _fence_cleared() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var grass := PixelDraw.pal("grass")
	var soil := PixelDraw.pal("soil")
	PixelDraw.rect(image, 4, 26, 24, 4, grass)
	PixelDraw.rect(image, 12, 28, 8, 2, soil)
	# Two posts, empty gap.
	PixelDraw.rect(image, 5, 4, 5, 24, wood_d)
	PixelDraw.rect(image, 6, 5, 2, 22, wood)
	PixelDraw.rect(image, 22, 4, 5, 24, wood_d)
	PixelDraw.rect(image, 23, 5, 2, 22, wood)
	return PixelDraw.outline(image)


static func _fence_new_wood() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var gold := PixelDraw.pal("gold")
	var grass := PixelDraw.pal("grass")
	PixelDraw.rect(image, 4, 26, 24, 4, grass)
	PixelDraw.rect(image, 5, 4, 5, 24, wood_d)
	PixelDraw.rect(image, 6, 5, 2, 22, wood)
	PixelDraw.rect(image, 22, 4, 5, 24, wood_d)
	PixelDraw.rect(image, 23, 5, 2, 22, wood)
	# Fresh boards, not fully seated, pale wood, open gaps.
	PixelDraw.rect(image, 10, 6, 4, 20, wood_l)
	PixelDraw.rect(image, 15, 8, 4, 18, wood_l)
	PixelDraw.rect(image, 11, 7, 2, 18, wood)
	PixelDraw.px(image, 12, 12, gold)
	PixelDraw.px(image, 16, 14, gold)
	return PixelDraw.outline(image)


static func _fence_finished() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var grass := PixelDraw.pal("grass")
	PixelDraw.rect(image, 4, 26, 24, 4, grass)
	PixelDraw.rect(image, 6, 4, 6, 24, wood)
	PixelDraw.rect(image, 14, 2, 6, 26, wood_l)
	PixelDraw.rect(image, 22, 5, 6, 23, wood)
	PixelDraw.rect(image, 4, 12, 24, 3, wood_d)
	PixelDraw.rect(image, 4, 20, 24, 3, wood_d)
	PixelDraw.px(image, 16, 6, wood_d)
	PixelDraw.px(image, 8, 10, wood_l)
	return PixelDraw.outline(image)


static func _weeds_patch() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_d := PixelDraw.pal("grass_d")
	var leaf := PixelDraw.pal("leaf")
	var leaf_d := PixelDraw.pal("leaf_d")
	var moss := PixelDraw.pal("moss")
	PixelDraw.rect(image, 2, 20, 28, 10, grass)
	PixelDraw.rect(image, 4, 24, 24, 4, grass_d)
	for pair in [
		Vector2i(8, 14), Vector2i(9, 10), Vector2i(10, 16),
		Vector2i(14, 12), Vector2i(15, 8), Vector2i(16, 14),
		Vector2i(20, 13), Vector2i(21, 9), Vector2i(22, 17),
		Vector2i(12, 18), Vector2i(18, 18), Vector2i(6, 18),
	]:
		PixelDraw.px(image, pair.x, pair.y, leaf)
		PixelDraw.px(image, pair.x, pair.y + 1, leaf_d)
	PixelDraw.px(image, 11, 12, moss)
	PixelDraw.px(image, 19, 11, moss)
	PixelDraw.px(image, 15, 16, leaf)
	return PixelDraw.outline(image)


static func _weeds_cleared() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_l := PixelDraw.pal("grass_l")
	var soil := PixelDraw.pal("soil")
	PixelDraw.rect(image, 4, 22, 24, 8, grass)
	PixelDraw.rect(image, 8, 26, 16, 3, grass_l)
	PixelDraw.px(image, 12, 24, soil)
	PixelDraw.px(image, 18, 25, soil)
	return PixelDraw.outline(image)


static func _litter_pile() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var paper := PixelDraw.pal("paper")
	var cream := PixelDraw.pal("cream")
	var grey := PixelDraw.pal("grey")
	var grey_d := PixelDraw.pal("grey_d")
	var glass := PixelDraw.pal("glass")
	var wood_d := PixelDraw.pal("wood_d")
	var grass := PixelDraw.pal("grass")
	PixelDraw.rect(image, 6, 24, 20, 6, grass)
	PixelDraw.rect(image, 8, 16, 10, 8, paper)
	PixelDraw.rect(image, 9, 17, 8, 6, cream)
	PixelDraw.rect(image, 18, 18, 6, 8, grey)
	PixelDraw.rect(image, 19, 19, 4, 6, grey_d)
	PixelDraw.px(image, 20, 20, glass)
	PixelDraw.px(image, 12, 22, wood_d)
	PixelDraw.px(image, 14, 23, grey)
	return PixelDraw.outline(image)


static func _bed_overgrown() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var soil := PixelDraw.pal("soil")
	var leaf_d := PixelDraw.pal("leaf_d")
	var moss := PixelDraw.pal("moss")
	var grass_d := PixelDraw.pal("grass_d")
	PixelDraw.rect(image, 2, 18, 28, 12, wood_d)
	PixelDraw.rect(image, 4, 20, 24, 8, soil)
	PixelDraw.rect(image, 2, 18, 28, 2, wood)
	PixelDraw.rect(image, 2, 28, 28, 2, wood)
	for x in range(6, 26, 3):
		PixelDraw.px(image, x, 16, grass_d)
		PixelDraw.px(image, x + 1, 14, leaf_d)
		PixelDraw.px(image, x, 12, moss)
	PixelDraw.px(image, 12, 22, moss)
	PixelDraw.px(image, 20, 23, leaf_d)
	return PixelDraw.outline(image)


static func _bed_trimmed() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var soil := PixelDraw.pal("soil")
	var soil_l := PixelDraw.pal("wood_l")
	PixelDraw.rect(image, 2, 18, 28, 12, wood_d)
	PixelDraw.rect(image, 4, 20, 24, 8, soil)
	PixelDraw.rect(image, 2, 18, 28, 2, wood)
	PixelDraw.rect(image, 2, 28, 28, 2, wood)
	PixelDraw.px(image, 10, 24, soil_l)
	PixelDraw.px(image, 16, 23, soil_l)
	PixelDraw.px(image, 22, 24, soil_l)
	return PixelDraw.outline(image)


static func _bed_restored() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var soil := PixelDraw.pal("soil")
	var leaf := PixelDraw.pal("leaf")
	var flower := PixelDraw.pal("flower")
	var flower2 := PixelDraw.pal("gold")
	PixelDraw.rect(image, 2, 18, 28, 12, wood_d)
	PixelDraw.rect(image, 4, 20, 24, 8, soil)
	PixelDraw.rect(image, 2, 18, 28, 2, wood)
	PixelDraw.rect(image, 2, 28, 28, 2, wood)
	for pair in [Vector2i(8, 16), Vector2i(14, 14), Vector2i(20, 16), Vector2i(24, 15)]:
		PixelDraw.px(image, pair.x, pair.y + 4, leaf)
		PixelDraw.px(image, pair.x, pair.y + 3, leaf)
		PixelDraw.px(image, pair.x, pair.y + 2, flower if pair.x % 8 == 0 else flower2)
		PixelDraw.px(image, pair.x - 1, pair.y + 2, flower)
		PixelDraw.px(image, pair.x + 1, pair.y + 2, flower2)
	return PixelDraw.outline(image)


static func _fx_repair() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var gold := PixelDraw.pal("gold")
	var cream := PixelDraw.pal("cream")
	var wood_l := PixelDraw.pal("wood_l")
	PixelDraw.px(image, 16, 10, gold)
	PixelDraw.px(image, 15, 12, cream)
	PixelDraw.px(image, 17, 12, cream)
	PixelDraw.px(image, 16, 14, wood_l)
	PixelDraw.px(image, 12, 16, gold)
	PixelDraw.px(image, 20, 16, gold)
	PixelDraw.px(image, 16, 18, cream)
	return image
