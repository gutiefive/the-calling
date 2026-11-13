class_name CropFrames
extends RefCounted
## 32×32 soil states, crop stages, and action flashes. Palette colors only.

const SIZE := Vector2i(32, 32)


static func build(frame_id: String) -> Image:
	match frame_id:
		"soil_untouched":
			return _soil_untouched()
		"soil_tilled":
			return _soil(false)
		"soil_tilled_wet":
			return _soil(true)
		"soil_seeded":
			return _seeded(false)
		"soil_seeded_wet":
			return _seeded(true)
		"soil_harvested":
			return _harvested()
		"fx_hoe":
			return _fx_hoe()
		"fx_water":
			return _fx_water()
		"fx_plant":
			return _fx_plant()
		"fx_harvest":
			return _fx_harvest()
		"fx_target":
			return _fx_target()
		"fence_patch":
			return _fence_patch()
		"water_barrel":
			return _water_barrel()
		"wheelbarrow":
			return _wheelbarrow()
		"compost_bin":
			return _compost_bin()
		_:
			if frame_id.ends_with("_sprout") or frame_id.ends_with("_growing") or frame_id.ends_with("_mature"):
				return _plant(frame_id)
			return _soil(false)


static func pal_color(color_name: String) -> Color:
	return PixelDraw.pal(color_name)


static func texture(frame_id: String) -> Texture2D:
	var image := build(frame_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func ground(wet: bool, neighbor_mask: int, stage: String, cell: Vector2i = Vector2i.ZERO) -> Image:
	var image := _soil(wet, neighbor_mask, cell)
	if stage == "seeded":
		_seed_pips(image, wet)
	elif stage == "harvested":
		_stubble(image)
	return image


static func _soil_untouched() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var grass := PixelDraw.pal("grass")
	var grass_d := PixelDraw.pal("grass_d")
	var soil := PixelDraw.pal("soil")
	var weed := PixelDraw.pal("leaf_dry")
	var moss := PixelDraw.pal("moss")
	PixelDraw.rect(image, 2, 10, 28, 20, grass)
	PixelDraw.rect(image, 4, 14, 24, 14, soil)
	PixelDraw.speckle_rect(image, Rect2i(4, 14, 24, 14), 11, 200, 255, grass_d)
	PixelDraw.rect(image, 6, 8, 6, 10, weed)
	PixelDraw.rect(image, 14, 6, 5, 12, moss)
	PixelDraw.rect(image, 22, 9, 6, 9, weed)
	PixelDraw.px(image, 8, 7, PixelDraw.pal("leaf"))
	PixelDraw.px(image, 16, 5, PixelDraw.pal("leaf_d"))
	PixelDraw.px(image, 24, 8, PixelDraw.pal("leaf"))
	return PixelDraw.outline(image)


static func _soil(wet: bool, neighbor_mask: int = 15, cell: Vector2i = Vector2i.ZERO) -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var dirt := PixelDraw.pal("soil")
	var dirt_d := PixelDraw.pal("trunk_d")
	var dirt_m := PixelDraw.pal("wood_d")
	var pebble := PixelDraw.pal("gravel")
	var pebble_d := PixelDraw.pal("gravel_d")
	var grass := PixelDraw.pal("grass")
	var grass_d := PixelDraw.pal("grass_d")
	var sheen := PixelDraw.pal("glass_h")
	var wet_base := PixelDraw.pal("trunk_d")
	var wet_mix := PixelDraw.pal("soil")
	if wet:
		PixelDraw.rect(image, 0, 0, 32, 32, wet_base)
	else:
		PixelDraw.rect(image, 0, 0, 32, 32, dirt)
	var ox: int = cell.x * SIZE.x
	var oy: int = cell.y * SIZE.y
	for y in SIZE.y:
		for x in SIZE.x:
			var n: int = PixelDraw.noise(ox + x, oy + y, 11)
			var n2: int = PixelDraw.noise(ox + x, oy + y, 29)
			if wet:
				if n < 28:
					PixelDraw.px(image, x, y, wet_mix)
				elif n > 248:
					PixelDraw.px(image, x, y, sheen)
				elif n2 < 10:
					PixelDraw.px(image, x, y, PixelDraw.pal("outline"))
			else:
				if n < 24:
					PixelDraw.px(image, x, y, dirt_d)
				elif n < 36:
					PixelDraw.px(image, x, y, dirt_m)
				elif n > 246:
					PixelDraw.px(image, x, y, pebble)
				elif n2 > 252:
					PixelDraw.px(image, x, y, pebble_d)
	_hoe_marks(image, cell, wet)
	_soil_edge(image, neighbor_mask, wet, grass, grass_d, dirt_d)
	return image


static func _hoe_marks(image: Image, cell: Vector2i, wet: bool) -> void:
	var mark := PixelDraw.pal("outline") if wet else PixelDraw.pal("trunk_d")
	var seed: int = cell.x * 13 + cell.y * 29 + 7
	for i in 3:
		var n: int = PixelDraw.noise(cell.x + i * 3, cell.y + i * 5, seed)
		var x0: int = 3 + (n % 20)
		var y0: int = 5 + int((n / 6) % 18)
		var length: int = 4 + (n % 4)
		PixelDraw.crack(image, x0, y0, length, mark, (n % 2) == 0)


static func _soil_edge(
		image: Image,
		neighbor_mask: int,
		wet: bool,
		grass: Color,
		grass_d: Color,
		dirt_d: Color
) -> void:
	# Grass and a soft darker lip only on sides that meet untilled ground.
	if (neighbor_mask & 1) == 0:
		PixelDraw.rect(image, 0, 0, 32, 1, grass)
		PixelDraw.rect(image, 0, 1, 32, 1, dirt_d)
		PixelDraw.speckle_rect(image, Rect2i(0, 1, 32, 2), 8, 0, 90, grass_d)
	if (neighbor_mask & 2) == 0:
		PixelDraw.rect(image, 31, 0, 1, 32, grass)
		PixelDraw.rect(image, 30, 0, 1, 32, dirt_d)
		PixelDraw.speckle_rect(image, Rect2i(29, 0, 2, 32), 9, 0, 90, grass_d)
	if (neighbor_mask & 4) == 0:
		PixelDraw.rect(image, 0, 31, 32, 1, grass)
		PixelDraw.rect(image, 0, 30, 32, 1, dirt_d)
		PixelDraw.speckle_rect(image, Rect2i(0, 29, 32, 2), 10, 0, 90, grass_d)
	if (neighbor_mask & 8) == 0:
		PixelDraw.rect(image, 0, 0, 1, 32, grass)
		PixelDraw.rect(image, 1, 0, 1, 32, dirt_d)
		PixelDraw.speckle_rect(image, Rect2i(1, 0, 2, 32), 11, 0, 90, grass_d)
	if wet:
		PixelDraw.speckle_rect(image, Rect2i(2, 2, 28, 28), 4, 250, 255, PixelDraw.pal("glass_h"))


static func _seeded(wet: bool) -> Image:
	var image := _soil(wet, 15)
	_seed_pips(image, wet)
	return image


static func _harvested() -> Image:
	var image := _soil(false, 15)
	_stubble(image)
	return image


static func _seed_pips(image: Image, wet: bool) -> void:
	var pip := PixelDraw.pal("gold")
	var pip_d := PixelDraw.pal("paper")
	if wet:
		pip_d = PixelDraw.pal("wood")
	for spot in [Vector2i(8, 14), Vector2i(16, 12), Vector2i(24, 15), Vector2i(12, 20), Vector2i(20, 22)]:
		PixelDraw.px(image, spot.x, spot.y, pip)
		PixelDraw.px(image, spot.x + 1, spot.y, pip_d)
		PixelDraw.px(image, spot.x, spot.y + 1, pip_d)


static func _stubble(image: Image) -> void:
	var stubble := PixelDraw.pal("leaf_dry")
	PixelDraw.px(image, 9, 16, stubble)
	PixelDraw.px(image, 10, 17, stubble)
	PixelDraw.px(image, 16, 15, stubble)
	PixelDraw.px(image, 22, 17, stubble)
	PixelDraw.px(image, 23, 18, stubble)
	PixelDraw.px(image, 14, 22, stubble)


static func _plant(frame_id: String) -> Image:
	var crop_id := frame_id.get_slice("_", 0)
	var stage := "sprout"
	if frame_id.ends_with("_growing"):
		stage = "growing"
	elif frame_id.ends_with("_mature"):
		stage = "mature"
	var tall := crop_id == "tomatoes" and stage != "sprout"
	var image := PixelDraw.canvas(SIZE.x, 48 if tall else SIZE.y)
	match crop_id:
		"lettuce":
			_lettuce(image, stage)
		"carrots":
			_carrots(image, stage)
		"tomatoes":
			_tomatoes(image, stage)
		_:
			_flowers(image, stage)
	return PixelDraw.outline(image)


static func _lettuce(image: Image, stage: String) -> void:
	var leaf := PixelDraw.pal("leaf")
	var leaf_l := PixelDraw.pal("leaf_l")
	var leaf_d := PixelDraw.pal("leaf_d")
	var moss := PixelDraw.pal("moss")
	if stage == "sprout":
		PixelDraw.ellipse(image, 12, 22, 4, 3, leaf_l)
		PixelDraw.ellipse(image, 20, 22, 4, 3, leaf_l)
		PixelDraw.rect(image, 15, 20, 2, 4, leaf)
		PixelDraw.px(image, 16, 19, leaf_d)
		return
	if stage == "growing":
		PixelDraw.ellipse(image, 16, 20, 10, 8, leaf)
		PixelDraw.ellipse(image, 12, 19, 6, 5, leaf_l)
		PixelDraw.ellipse(image, 21, 21, 6, 5, leaf_d)
		PixelDraw.px(image, 16, 14, leaf_l)
		PixelDraw.px(image, 8, 18, moss)
		PixelDraw.px(image, 24, 17, leaf)
		return
	PixelDraw.ellipse(image, 16, 17, 14, 12, leaf)
	PixelDraw.ellipse(image, 10, 16, 8, 8, leaf_l)
	PixelDraw.ellipse(image, 22, 18, 8, 7, leaf_d)
	PixelDraw.ellipse(image, 16, 15, 7, 6, moss)
	PixelDraw.ellipse(image, 16, 16, 4, 3, leaf_l)
	PixelDraw.px(image, 16, 13, PixelDraw.pal("paper"))
	PixelDraw.px(image, 6, 18, leaf)
	PixelDraw.px(image, 26, 17, leaf_l)


static func _carrots(image: Image, stage: String) -> void:
	var tops := PixelDraw.pal("leaf")
	var tops_l := PixelDraw.pal("leaf_l")
	var tops_d := PixelDraw.pal("leaf_d")
	var body := PixelDraw.pal("brick")
	var body_l := PixelDraw.pal("gold")
	if stage == "sprout":
		PixelDraw.rect(image, 14, 18, 2, 6, tops)
		PixelDraw.rect(image, 17, 19, 2, 5, tops_l)
		PixelDraw.px(image, 13, 19, tops_l)
		PixelDraw.px(image, 19, 20, tops)
		PixelDraw.px(image, 16, 17, tops_d)
		return
	if stage == "growing":
		PixelDraw.rect(image, 12, 12, 2, 14, tops)
		PixelDraw.rect(image, 15, 10, 2, 16, tops_l)
		PixelDraw.rect(image, 18, 13, 2, 13, tops)
		PixelDraw.px(image, 11, 14, tops_l)
		PixelDraw.px(image, 20, 16, tops_d)
		PixelDraw.px(image, 14, 11, tops)
		PixelDraw.rect(image, 14, 24, 4, 3, body)
		return
	PixelDraw.rect(image, 8, 8, 2, 16, tops_d)
	PixelDraw.rect(image, 11, 6, 2, 18, tops)
	PixelDraw.rect(image, 14, 4, 3, 20, tops_l)
	PixelDraw.rect(image, 18, 6, 2, 18, tops)
	PixelDraw.rect(image, 21, 9, 2, 15, tops_d)
	PixelDraw.px(image, 7, 12, tops)
	PixelDraw.px(image, 24, 14, tops_l)
	PixelDraw.px(image, 16, 3, tops)
	PixelDraw.rect(image, 12, 22, 8, 7, body)
	PixelDraw.rect(image, 14, 23, 4, 5, body_l)
	PixelDraw.px(image, 15, 29, body)
	PixelDraw.px(image, 17, 21, body_l)
	PixelDraw.px(image, 16, 20, PixelDraw.pal("paper"))


static func _tomatoes(image: Image, stage: String) -> void:
	var stem := PixelDraw.pal("leaf_d")
	var leaf := PixelDraw.pal("leaf")
	var leaf_l := PixelDraw.pal("leaf_l")
	var stake := PixelDraw.pal("wood")
	var stake_d := PixelDraw.pal("wood_d")
	var fruit := PixelDraw.pal("flower")
	var fruit_l := PixelDraw.pal("carpet_l")
	var fruit_d := PixelDraw.pal("roof")
	if stage == "sprout":
		PixelDraw.rect(image, 15, 16, 3, 10, stem)
		PixelDraw.ellipse(image, 12, 18, 3, 2, leaf_l)
		PixelDraw.ellipse(image, 21, 20, 3, 2, leaf)
		PixelDraw.px(image, 16, 15, leaf)
		return
	var base_y: int = image.get_height() - 2
	PixelDraw.rect(image, 16, 6, 2, base_y - 6, stake)
	PixelDraw.rect(image, 17, 6, 1, base_y - 6, stake_d)
	PixelDraw.px(image, 16, 5, stake_d)
	PixelDraw.rect(image, 15, 10, 2, base_y - 12, stem)
	if stage == "growing":
		PixelDraw.ellipse(image, 11, 16, 4, 3, leaf)
		PixelDraw.ellipse(image, 22, 20, 4, 3, leaf_l)
		PixelDraw.ellipse(image, 12, 26, 3, 3, leaf)
		PixelDraw.ellipse(image, 21, 30, 4, 3, leaf_l)
		PixelDraw.ellipse(image, 12, 34, 2, 2, fruit_d)
		PixelDraw.ellipse(image, 21, 24, 2, 2, fruit_d)
		return
	PixelDraw.ellipse(image, 10, 12, 5, 4, leaf)
	PixelDraw.ellipse(image, 23, 16, 5, 4, leaf_l)
	PixelDraw.ellipse(image, 9, 22, 4, 3, leaf_l)
	PixelDraw.ellipse(image, 24, 26, 4, 3, leaf)
	PixelDraw.ellipse(image, 11, 32, 4, 3, leaf)
	PixelDraw.ellipse(image, 22, 36, 4, 3, leaf_l)
	PixelDraw.ellipse(image, 11, 18, 4, 4, fruit)
	PixelDraw.ellipse(image, 22, 14, 4, 4, fruit)
	PixelDraw.ellipse(image, 12, 28, 4, 4, fruit_d)
	PixelDraw.ellipse(image, 21, 22, 4, 4, fruit)
	PixelDraw.ellipse(image, 16, 34, 4, 4, fruit)
	PixelDraw.px(image, 10, 16, fruit_l)
	PixelDraw.px(image, 21, 12, fruit_l)
	PixelDraw.px(image, 20, 20, fruit_l)
	PixelDraw.px(image, 16, 32, PixelDraw.pal("paper"))


static func _flowers(image: Image, stage: String) -> void:
	var stem := PixelDraw.pal("leaf")
	var stem_d := PixelDraw.pal("leaf_d")
	var petal := PixelDraw.pal("flower")
	var petal2 := PixelDraw.pal("gold")
	var petal3 := PixelDraw.pal("flower2")
	var center := PixelDraw.pal("paper")
	if stage == "sprout":
		PixelDraw.rect(image, 15, 16, 3, 10, stem)
		PixelDraw.px(image, 14, 18, stem)
		PixelDraw.px(image, 18, 19, stem_d)
		PixelDraw.px(image, 16, 15, stem_d)
		return
	if stage == "growing":
		PixelDraw.rect(image, 10, 14, 2, 14, stem_d)
		PixelDraw.rect(image, 15, 8, 3, 20, stem)
		PixelDraw.rect(image, 21, 16, 2, 12, stem)
		PixelDraw.ellipse(image, 16, 8, 3, 3, petal)
		PixelDraw.px(image, 11, 13, petal2)
		PixelDraw.px(image, 22, 15, petal)
		return
	PixelDraw.rect(image, 6, 14, 2, 14, stem_d)
	PixelDraw.rect(image, 12, 10, 2, 18, stem)
	PixelDraw.rect(image, 16, 6, 3, 22, stem)
	PixelDraw.rect(image, 22, 12, 2, 16, stem)
	PixelDraw.rect(image, 26, 16, 2, 12, stem_d)
	_bloom(image, 17, 6, petal, center)
	_bloom(image, 7, 12, petal2, center)
	_bloom(image, 23, 10, petal3, PixelDraw.pal("gold"))
	_bloom(image, 12, 8, petal, center)
	_bloom(image, 27, 14, petal2, center)
	PixelDraw.px(image, 17, 5, PixelDraw.pal("paper"))


static func _bloom(image: Image, cx: int, cy: int, petal: Color, center: Color) -> void:
	PixelDraw.px(image, cx, cy - 2, petal)
	PixelDraw.px(image, cx - 1, cy - 1, petal)
	PixelDraw.px(image, cx + 1, cy - 1, petal)
	PixelDraw.px(image, cx - 2, cy, petal)
	PixelDraw.px(image, cx + 2, cy, petal)
	PixelDraw.px(image, cx - 1, cy + 1, petal)
	PixelDraw.px(image, cx + 1, cy + 1, petal)
	PixelDraw.px(image, cx, cy + 2, petal)
	PixelDraw.px(image, cx, cy, center)


static func _fx_hoe() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var dirt := PixelDraw.pal("soil")
	var dirt_l := PixelDraw.pal("path")
	PixelDraw.px(image, 8, 18, dirt)
	PixelDraw.px(image, 10, 16, dirt_l)
	PixelDraw.px(image, 14, 14, dirt)
	PixelDraw.px(image, 18, 15, dirt_l)
	PixelDraw.px(image, 22, 17, dirt)
	PixelDraw.px(image, 16, 12, dirt_l)
	return image


static func _fx_water() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var drop := PixelDraw.pal("glass")
	var drop_d := PixelDraw.pal("glass_d")
	PixelDraw.px(image, 10, 8, drop)
	PixelDraw.px(image, 10, 9, drop_d)
	PixelDraw.px(image, 16, 6, drop)
	PixelDraw.px(image, 16, 7, drop)
	PixelDraw.px(image, 22, 9, drop)
	PixelDraw.px(image, 14, 12, drop_d)
	PixelDraw.px(image, 20, 13, drop)
	return image


static func _fx_plant() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var pip := PixelDraw.pal("gold")
	var leaf := PixelDraw.pal("leaf_l")
	PixelDraw.px(image, 12, 14, pip)
	PixelDraw.px(image, 18, 12, pip)
	PixelDraw.px(image, 15, 10, leaf)
	PixelDraw.px(image, 20, 16, leaf)
	return image


static func _fx_target() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var ink := PixelDraw.pal("paper")
	var gold := PixelDraw.pal("gold")
	for pair in [
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2),
		Vector2i(29, 1), Vector2i(30, 1), Vector2i(30, 2),
		Vector2i(1, 29), Vector2i(1, 30), Vector2i(2, 30),
		Vector2i(30, 29), Vector2i(29, 30), Vector2i(30, 30),
	]:
		PixelDraw.px(image, pair.x, pair.y, ink)
	PixelDraw.px(image, 3, 1, gold)
	PixelDraw.px(image, 28, 1, gold)
	PixelDraw.px(image, 1, 3, gold)
	PixelDraw.px(image, 30, 3, gold)
	PixelDraw.px(image, 3, 30, gold)
	PixelDraw.px(image, 28, 30, gold)
	return image


static func _fence_patch() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var wood_d := PixelDraw.pal("wood_d")
	PixelDraw.rect(image, 6, 4, 6, 26, wood)
	PixelDraw.rect(image, 14, 2, 6, 28, wood_l)
	PixelDraw.rect(image, 22, 5, 6, 25, wood)
	PixelDraw.rect(image, 4, 12, 24, 3, wood_d)
	PixelDraw.rect(image, 4, 20, 24, 3, wood_d)
	PixelDraw.px(image, 16, 6, wood_d)
	PixelDraw.px(image, 8, 10, wood_l)
	return PixelDraw.outline(image)


static func _water_barrel() -> Image:
	var image := PixelDraw.canvas(20, 28)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var wood_l := PixelDraw.pal("wood_l")
	var hoop := PixelDraw.pal("grey_d")
	var water := PixelDraw.pal("glass_d")
	var water_l := PixelDraw.pal("glass")
	PixelDraw.ellipse(image, 10, 6, 8, 4, wood_d)
	PixelDraw.ellipse(image, 10, 6, 6, 3, water)
	PixelDraw.px(image, 8, 5, water_l)
	PixelDraw.rect(image, 2, 6, 16, 18, wood)
	PixelDraw.rect(image, 3, 6, 2, 18, wood_l)
	PixelDraw.rect(image, 2, 10, 16, 2, hoop)
	PixelDraw.rect(image, 2, 18, 16, 2, hoop)
	PixelDraw.ellipse(image, 10, 24, 8, 3, wood_d)
	PixelDraw.rect(image, 16, 12, 3, 2, PixelDraw.pal("grey"))
	PixelDraw.px(image, 18, 14, PixelDraw.pal("glass"))
	return PixelDraw.outline(image)


static func _wheelbarrow() -> Image:
	var image := PixelDraw.canvas(32, 22)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var wood_l := PixelDraw.pal("wood_l")
	var iron := PixelDraw.pal("grey_d")
	var dirt := PixelDraw.pal("soil")
	PixelDraw.rect(image, 2, 8, 10, 2, wood_d)
	PixelDraw.rect(image, 2, 6, 2, 4, wood)
	PixelDraw.rect(image, 10, 8, 16, 8, wood)
	PixelDraw.rect(image, 12, 6, 12, 6, wood_l)
	PixelDraw.rect(image, 13, 7, 10, 4, dirt)
	PixelDraw.rect(image, 10, 16, 16, 2, wood_d)
	PixelDraw.ellipse(image, 24, 18, 5, 4, iron)
	PixelDraw.ellipse(image, 24, 18, 2, 2, wood_l)
	PixelDraw.px(image, 14, 8, PixelDraw.pal("leaf_d"))
	return PixelDraw.outline(image)


static func _compost_bin() -> Image:
	var image := PixelDraw.canvas(24, 24)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var wood_l := PixelDraw.pal("wood_l")
	var soil := PixelDraw.pal("soil")
	var leaf := PixelDraw.pal("leaf_dry")
	PixelDraw.rect(image, 2, 8, 20, 14, wood)
	for y in range(10, 20, 3):
		PixelDraw.rect(image, 3, y, 18, 1, wood_d)
	PixelDraw.rect(image, 2, 8, 20, 2, wood_l)
	PixelDraw.rect(image, 4, 4, 16, 6, soil)
	PixelDraw.px(image, 6, 5, leaf)
	PixelDraw.px(image, 10, 3, PixelDraw.pal("leaf_d"))
	PixelDraw.px(image, 14, 5, leaf)
	PixelDraw.px(image, 16, 4, PixelDraw.pal("moss"))
	PixelDraw.rect(image, 2, 20, 20, 2, wood_d)
	return PixelDraw.outline(image)


static func _fx_harvest() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var spark := PixelDraw.pal("paper")
	var gold := PixelDraw.pal("gold")
	PixelDraw.px(image, 16, 8, spark)
	PixelDraw.px(image, 15, 9, gold)
	PixelDraw.px(image, 17, 9, gold)
	PixelDraw.px(image, 10, 12, spark)
	PixelDraw.px(image, 22, 11, spark)
	PixelDraw.px(image, 16, 14, gold)
	return image
