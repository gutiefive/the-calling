class_name RepairFrames
extends RefCounted
## Worksite stages. Palette colors only. Fence art matches the garden fence tile.

const SIZE := Vector2i(32, 32)
const FENCE_SIZE := Vector2i(64, 96)
const WEEDS_SIZE := Vector2i(96, 48)
const LITTER_SIZE := Vector2i(96, 48)
const BED_SIZE := Vector2i(64, 48)
const BAG_SIZE := Vector2i(16, 18)


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
			return PixelDraw.canvas(LITTER_SIZE.x, LITTER_SIZE.y)
		"litter_bag":
			return _litter_bag()
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
	var image := PixelDraw.canvas(FENCE_SIZE.x, FENCE_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var ink := PixelDraw.pal("outline")
	# Posts on the fence line (right 32px), skipping the snapped and leaning ones.
	_stamp_fence_post(image, 32, 0, 4)
	_stamp_fence_post(image, 32, 0, 15)
	_stamp_fence_post(image, 32, 32, 4)
	_stamp_fence_post(image, 32, 32, 26)
	_stamp_fence_post(image, 32, 64, 4)
	_stamp_fence_post(image, 32, 64, 15)
	_stamp_fence_post(image, 32, 64, 26)
	# Snapped middle post on the center tile.
	PixelDraw.rect(image, 32 + 15, 32 + 6, 4, 10, wood_d)
	PixelDraw.rect(image, 32 + 16, 32 + 6, 2, 9, wood)
	PixelDraw.px(image, 32 + 16, 32 + 8, wood_l)
	PixelDraw.px(image, 32 + 15, 32 + 16, ink)
	PixelDraw.px(image, 32 + 18, 32 + 16, ink)
	PixelDraw.px(image, 32 + 16, 32 + 17, wood_d)
	# Leaning right post on the north tile.
	PixelDraw.rect(image, 32 + 28, 10, 4, 18, wood_d)
	PixelDraw.rect(image, 32 + 29, 11, 2, 16, wood)
	PixelDraw.px(image, 32 + 30, 12, wood_l)
	# Broken rails, not a full run.
	PixelDraw.rect(image, 32 + 2, 10, 12, 3, wood)
	PixelDraw.rect(image, 32 + 2, 10, 12, 1, wood_l)
	PixelDraw.px(image, 32 + 14, 11, wood_d)
	PixelDraw.px(image, 32 + 15, 12, wood_d)
	PixelDraw.rect(image, 32 + 8, 14, 6, 2, wood_d)
	PixelDraw.rect(image, 32 + 2, 32 + 18, 10, 3, wood_d)
	PixelDraw.px(image, 32 + 12, 32 + 19, wood)
	PixelDraw.px(image, 32 + 13, 32 + 20, wood_d)
	PixelDraw.rect(image, 32 + 20, 64 + 10, 8, 3, wood)
	# Splinters on the picnic grass beside the posts.
	for pair in [
		Vector2i(8, 28), Vector2i(12, 30), Vector2i(18, 44),
		Vector2i(10, 58), Vector2i(16, 72), Vector2i(6, 80),
		Vector2i(20, 88), Vector2i(14, 90), Vector2i(22, 50),
	]:
		PixelDraw.px(image, pair.x, pair.y, wood_d if pair.x % 2 == 0 else wood)
	PixelDraw.px(image, 24, 86, wood_l)
	PixelDraw.px(image, 11, 59, ink)
	return PixelDraw.outline(image)


static func _fence_cleared() -> Image:
	var image := PixelDraw.canvas(FENCE_SIZE.x, FENCE_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	_stamp_fence_tile(image, 32, 0, wood, wood_l, wood_d, false, false)
	_stamp_fence_tile(image, 32, 32, wood, wood_l, wood_d, false, false)
	_stamp_fence_tile(image, 32, 64, wood, wood_l, wood_d, false, false)
	# Old boards stacked on the picnic side, not a crate: three horizontal planks.
	PixelDraw.rect(image, 6, 70, 22, 4, wood_d)
	PixelDraw.rect(image, 7, 71, 20, 2, wood)
	PixelDraw.rect(image, 8, 74, 20, 4, wood)
	PixelDraw.rect(image, 9, 75, 18, 2, wood_l)
	PixelDraw.rect(image, 7, 78, 21, 4, wood_d)
	PixelDraw.rect(image, 8, 79, 19, 2, wood)
	PixelDraw.px(image, 10, 72, wood_l)
	PixelDraw.px(image, 24, 80, wood_d)
	return PixelDraw.outline(image)


static func _fence_new_wood() -> Image:
	var image := PixelDraw.canvas(FENCE_SIZE.x, FENCE_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var gold := PixelDraw.pal("gold")
	var cream := PixelDraw.pal("cream")
	_stamp_fence_tile(image, 32, 0, wood, wood_l, wood_d, false, false)
	_stamp_fence_tile(image, 32, 32, wood, wood_l, wood_d, false, false)
	_stamp_fence_tile(image, 32, 64, wood, wood_l, wood_d, false, false)
	# Fresh pale rails, not fully seated: gaps at the joins.
	for oy in [0, 32, 64]:
		PixelDraw.rect(image, 32 + 3, oy + 9, 12, 3, wood_l)
		PixelDraw.rect(image, 32 + 3, oy + 9, 12, 1, cream)
		PixelDraw.rect(image, 32 + 17, oy + 11, 12, 3, wood_l)
		PixelDraw.rect(image, 32 + 18, oy + 18, 11, 3, wood_l)
		PixelDraw.rect(image, 32 + 2, oy + 19, 12, 3, wood_l)
	# Small nail box on the picnic grass.
	PixelDraw.rect(image, 10, 78, 12, 8, wood_d)
	PixelDraw.rect(image, 11, 79, 10, 6, wood)
	PixelDraw.rect(image, 11, 79, 10, 1, wood_l)
	PixelDraw.px(image, 14, 82, gold)
	PixelDraw.px(image, 17, 83, gold)
	PixelDraw.px(image, 15, 81, cream)
	return PixelDraw.outline(image)


static func _fence_finished() -> Image:
	var image := PixelDraw.canvas(FENCE_SIZE.x, FENCE_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	var gold := PixelDraw.pal("gold")
	# Same posts and rails as the garden fence tile, rails a step lighter.
	_stamp_fence_tile(image, 32, 0, wood_l, wood_l, wood, true, true)
	_stamp_fence_tile(image, 32, 32, wood_l, wood_l, wood, true, true)
	_stamp_fence_tile(image, 32, 64, wood_l, wood_l, wood, true, true)
	# Nail heads so the work reads, without turning the stretch into a crate.
	for oy in [0, 32, 64]:
		for local_x in [6, 16, 27]:
			PixelDraw.px(image, 32 + local_x, oy + 11, gold)
			PixelDraw.px(image, 32 + local_x, oy + 19, wood_d)
	return PixelDraw.outline(image)


static func _stamp_fence_tile(
		image: Image,
		ox: int,
		oy: int,
		rail: Color,
		rail_hi: Color,
		rail_lo: Color,
		top_rail: bool,
		bot_rail: bool
) -> void:
	_stamp_fence_post(image, ox, oy, 4)
	_stamp_fence_post(image, ox, oy, 15)
	_stamp_fence_post(image, ox, oy, 26)
	if top_rail:
		PixelDraw.rect(image, ox + 2, oy + 10, 28, 3, rail)
		PixelDraw.rect(image, ox + 2, oy + 10, 28, 1, rail_hi)
	if bot_rail:
		PixelDraw.rect(image, ox + 2, oy + 18, 28, 3, rail_lo)


static func _stamp_fence_post(image: Image, ox: int, oy: int, local_x: int) -> void:
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	PixelDraw.rect(image, ox + local_x, oy + 6, 4, 22, wood_d)
	PixelDraw.rect(image, ox + local_x + 1, oy + 6, 2, 22, wood)
	PixelDraw.px(image, ox + local_x + 1, oy + 8, wood_l)


static func _weeds_patch() -> Image:
	var image := PixelDraw.canvas(WEEDS_SIZE.x, WEEDS_SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_d := PixelDraw.pal("grass_d")
	var grass_l := PixelDraw.pal("grass_l")
	var leaf := PixelDraw.pal("leaf")
	var leaf_d := PixelDraw.pal("leaf_d")
	var leaf_l := PixelDraw.pal("leaf_l")
	var moss := PixelDraw.pal("moss")
	var dry := PixelDraw.pal("leaf_dry")
	var flower := PixelDraw.pal("flower")
	PixelDraw.rect(image, 2, 28, 92, 18, grass)
	PixelDraw.speckle_rect(image, Rect2i(2, 28, 92, 18), 21, 200, 255, grass_l)
	PixelDraw.speckle_rect(image, Rect2i(2, 30, 92, 16), 22, 0, 24, grass_d)
	var stems: Array[Vector2i] = [
		Vector2i(10, 18), Vector2i(18, 10), Vector2i(26, 16), Vector2i(34, 8),
		Vector2i(42, 14), Vector2i(50, 6), Vector2i(58, 12), Vector2i(66, 8),
		Vector2i(74, 16), Vector2i(82, 12), Vector2i(14, 22), Vector2i(38, 20),
		Vector2i(54, 22), Vector2i(70, 20), Vector2i(22, 24), Vector2i(46, 4),
	]
	for stem in stems:
		var h := 10 + (stem.x % 7)
		PixelDraw.rect(image, stem.x, stem.y, 2, h, leaf_d)
		PixelDraw.px(image, stem.x, stem.y, leaf)
		PixelDraw.px(image, stem.x + 1, stem.y + 2, leaf_l)
		PixelDraw.px(image, stem.x - 1, stem.y + 3, leaf)
		PixelDraw.px(image, stem.x + 2, stem.y + 4, moss)
		if stem.x % 3 == 0:
			PixelDraw.px(image, stem.x, stem.y - 1, dry)
			PixelDraw.px(image, stem.x + 1, stem.y - 1, flower)
			PixelDraw.px(image, stem.x - 1, stem.y, dry)
	PixelDraw.rect(image, 30, 18, 3, 16, leaf)
	PixelDraw.rect(image, 60, 14, 3, 18, moss)
	PixelDraw.px(image, 31, 16, flower)
	PixelDraw.px(image, 61, 12, flower)
	PixelDraw.px(image, 8, 26, leaf)
	PixelDraw.px(image, 88, 24, moss)
	return PixelDraw.outline(image)


static func _weeds_cleared() -> Image:
	var image := PixelDraw.canvas(WEEDS_SIZE.x, WEEDS_SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_l := PixelDraw.pal("grass_l")
	var grass_d := PixelDraw.pal("grass_d")
	var grass_h := PixelDraw.pal("grass_h")
	var dry := PixelDraw.pal("leaf_dry")
	var leaf_d := PixelDraw.pal("leaf_d")
	var soil := PixelDraw.pal("soil")
	# Cut grass without a boxed outline so it does not read as an empty bed.
	PixelDraw.rect(image, 2, 18, 92, 28, grass)
	PixelDraw.speckle_rect(image, Rect2i(2, 18, 92, 28), 41, 210, 255, grass_l)
	PixelDraw.speckle_rect(image, Rect2i(2, 20, 92, 24), 42, 0, 18, grass_d)
	for x in range(4, 92, 3):
		PixelDraw.px(image, x, 22 + (x % 5), grass_h)
	# Small pulled-weed pile on the cut grass.
	var pile := PixelDraw.canvas(WEEDS_SIZE.x, WEEDS_SIZE.y)
	PixelDraw.rect(pile, 70, 34, 16, 8, leaf_d)
	PixelDraw.rect(pile, 72, 32, 12, 6, dry)
	PixelDraw.px(pile, 74, 31, dry)
	PixelDraw.px(pile, 80, 33, soil)
	PixelDraw.px(pile, 76, 36, grass_d)
	PixelDraw.blit(image, PixelDraw.outline(pile), 0, 0)
	return image


static func _litter_pile() -> Image:
	var image := PixelDraw.canvas(LITTER_SIZE.x, LITTER_SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_l := PixelDraw.pal("grass_l")
	var paper := PixelDraw.pal("paper")
	var cream := PixelDraw.pal("cream")
	var grey := PixelDraw.pal("grey")
	var grey_d := PixelDraw.pal("grey_d")
	var glass := PixelDraw.pal("glass")
	var glass_d := PixelDraw.pal("glass_d")
	var wood_d := PixelDraw.pal("wood_d")
	var bun := PixelDraw.pal("bun")
	var gold := PixelDraw.pal("gold")
	var ink := PixelDraw.pal("outline")
	PixelDraw.rect(image, 4, 30, 88, 16, grass)
	PixelDraw.speckle_rect(image, Rect2i(4, 32, 88, 14), 51, 220, 255, grass_l)
	# Crushed can.
	PixelDraw.rect(image, 10, 28, 10, 8, grey)
	PixelDraw.rect(image, 11, 29, 8, 6, grey_d)
	PixelDraw.px(image, 12, 30, gold)
	PixelDraw.px(image, 16, 31, grey)
	# Folded paper.
	PixelDraw.rect(image, 28, 26, 14, 10, paper)
	PixelDraw.rect(image, 30, 28, 10, 6, cream)
	PixelDraw.px(image, 32, 30, ink)
	PixelDraw.px(image, 36, 32, wood_d)
	# Bottle on its side.
	PixelDraw.rect(image, 50, 30, 16, 6, glass)
	PixelDraw.rect(image, 51, 31, 12, 4, glass_d)
	PixelDraw.rect(image, 64, 31, 4, 4, glass)
	PixelDraw.px(image, 54, 32, PixelDraw.pal("glass_h"))
	# Loose bag.
	PixelDraw.rect(image, 72, 24, 14, 14, bun)
	PixelDraw.rect(image, 74, 26, 10, 10, grey)
	PixelDraw.px(image, 76, 28, paper)
	PixelDraw.px(image, 82, 30, grey_d)
	PixelDraw.rect(image, 78, 22, 4, 4, grey_d)
	# Caps and scraps across the patch.
	PixelDraw.px(image, 22, 36, gold)
	PixelDraw.px(image, 40, 38, grey_d)
	PixelDraw.px(image, 60, 40, paper)
	PixelDraw.px(image, 84, 38, cream)
	PixelDraw.px(image, 16, 40, wood_d)
	return PixelDraw.outline(image)


static func _litter_bag() -> Image:
	var image := PixelDraw.canvas(BAG_SIZE.x, BAG_SIZE.y)
	var bun := PixelDraw.pal("bun")
	var bun_d := PixelDraw.pal("bun_d")
	var grey_d := PixelDraw.pal("grey_d")
	var cream := PixelDraw.pal("cream")
	PixelDraw.rect(image, 3, 6, 10, 10, bun_d)
	PixelDraw.rect(image, 4, 7, 8, 8, bun)
	PixelDraw.rect(image, 6, 2, 4, 5, grey_d)
	PixelDraw.px(image, 7, 1, cream)
	PixelDraw.px(image, 8, 1, cream)
	PixelDraw.px(image, 7, 4, bun)
	return PixelDraw.outline(image)


static func _bed_overgrown() -> Image:
	var image := PixelDraw.canvas(BED_SIZE.x, BED_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var soil := PixelDraw.pal("soil")
	var trunk_d := PixelDraw.pal("trunk_d")
	var leaf_d := PixelDraw.pal("leaf_d")
	var moss := PixelDraw.pal("moss")
	var grass_d := PixelDraw.pal("grass_d")
	var dry := PixelDraw.pal("leaf_dry")
	# Broken edging: gaps in the frame, cracked soil, weeds instead of blooms.
	PixelDraw.rect(image, 4, 18, 56, 26, wood_d)
	PixelDraw.rect(image, 6, 20, 52, 22, soil)
	PixelDraw.rect(image, 4, 18, 20, 3, wood)
	PixelDraw.rect(image, 40, 18, 20, 3, wood)
	PixelDraw.rect(image, 4, 41, 56, 3, wood_d)
	PixelDraw.rect(image, 4, 18, 3, 12, wood)
	PixelDraw.rect(image, 57, 28, 3, 16, wood_d)
	PixelDraw.crack(image, 16, 26, 10, trunk_d, true)
	PixelDraw.crack(image, 36, 30, 8, trunk_d, false)
	PixelDraw.px(image, 22, 28, PixelDraw.pal("gravel"))
	PixelDraw.px(image, 44, 34, trunk_d)
	for x in [10, 18, 28, 38, 48, 54]:
		PixelDraw.rect(image, x, 12, 2, 10, grass_d)
		PixelDraw.px(image, x, 10, leaf_d)
		PixelDraw.px(image, x + 1, 14, moss)
		PixelDraw.px(image, x - 1, 16, dry)
	PixelDraw.px(image, 24, 32, moss)
	PixelDraw.px(image, 40, 36, leaf_d)
	return PixelDraw.outline(image)


static func _bed_trimmed() -> Image:
	var image := PixelDraw.canvas(BED_SIZE.x, BED_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var wood_l := PixelDraw.pal("wood_l")
	var soil := PixelDraw.pal("soil")
	var soil_l := PixelDraw.pal("wood_l")
	var trunk_d := PixelDraw.pal("trunk_d")
	PixelDraw.rect(image, 4, 18, 56, 26, wood_d)
	PixelDraw.rect(image, 6, 20, 52, 22, soil)
	PixelDraw.rect(image, 4, 18, 56, 3, wood)
	PixelDraw.rect(image, 4, 41, 56, 3, wood)
	PixelDraw.rect(image, 4, 18, 3, 26, wood)
	PixelDraw.rect(image, 57, 18, 3, 26, wood)
	PixelDraw.px(image, 6, 19, wood_l)
	PixelDraw.speckle_rect(image, Rect2i(8, 22, 48, 16), 61, 0, 20, trunk_d)
	PixelDraw.px(image, 16, 30, soil_l)
	PixelDraw.px(image, 32, 28, soil_l)
	PixelDraw.px(image, 48, 32, soil_l)
	return PixelDraw.outline(image)


static func _bed_restored() -> Image:
	var image := PixelDraw.canvas(BED_SIZE.x, BED_SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var wood_l := PixelDraw.pal("wood_l")
	var soil := PixelDraw.pal("soil")
	var trunk_d := PixelDraw.pal("trunk_d")
	var leaf := PixelDraw.pal("leaf")
	var leaf_l := PixelDraw.pal("leaf_l")
	var flower := PixelDraw.pal("flower")
	var flower2 := PixelDraw.pal("flower2")
	var gold := PixelDraw.pal("gold")
	var cream := PixelDraw.pal("cream")
	PixelDraw.rect(image, 4, 18, 56, 26, wood_d)
	PixelDraw.rect(image, 6, 20, 52, 22, soil)
	PixelDraw.speckle_rect(image, Rect2i(6, 20, 52, 22), 71, 0, 28, trunk_d)
	PixelDraw.rect(image, 4, 18, 56, 3, wood)
	PixelDraw.rect(image, 4, 41, 56, 3, wood)
	PixelDraw.rect(image, 4, 18, 3, 26, wood)
	PixelDraw.rect(image, 57, 18, 3, 26, wood)
	PixelDraw.px(image, 6, 19, wood_l)
	_bloom(image, 14, 22, flower, leaf, leaf_l, cream)
	_bloom(image, 24, 18, flower2, leaf, leaf_l, cream)
	_bloom(image, 34, 20, gold, leaf, leaf_l, cream)
	_bloom(image, 44, 16, cream, leaf, leaf_l, gold)
	_bloom(image, 52, 22, flower, leaf, leaf_l, cream)
	_bloom(image, 18, 28, gold, leaf, leaf_l, cream)
	_bloom(image, 40, 26, flower, leaf, leaf_l, flower2)
	return PixelDraw.outline(image)


static func _bloom(image: Image, x: int, y: int, petal: Color, leaf: Color, leaf_l: Color, center: Color) -> void:
	PixelDraw.rect(image, x, y + 6, 2, 8, leaf)
	PixelDraw.px(image, x + 1, y + 5, leaf_l)
	PixelDraw.rect(image, x - 1, y + 2, 4, 4, petal)
	PixelDraw.px(image, x, y + 1, petal)
	PixelDraw.px(image, x + 1, y + 3, center)


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
