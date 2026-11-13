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
		_:
			if frame_id.ends_with("_sprout") or frame_id.ends_with("_growing") or frame_id.ends_with("_mature"):
				return _plant(frame_id)
			return _soil(false)


static func texture(frame_id: String) -> Texture2D:
	var image := build(frame_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func ground(wet: bool, neighbor_mask: int, stage: String) -> Image:
	var image := _soil(wet, neighbor_mask)
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


static func _soil(wet: bool, neighbor_mask: int = 15) -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var dirt := PixelDraw.pal("soil")
	var dirt_d := PixelDraw.pal("trunk_d") if wet else PixelDraw.pal("wood_d")
	var dirt_l := PixelDraw.pal("path") if not wet else PixelDraw.pal("soil")
	var grass := PixelDraw.pal("grass")
	PixelDraw.rect(image, 0, 0, 32, 32, dirt)
	for y in range(2, 30, 4):
		PixelDraw.rect(image, 1, y, 30, 1, dirt_d)
		PixelDraw.rect(image, 2, y + 1, 28, 1, dirt_l)
	PixelDraw.speckle_rect(image, Rect2i(0, 0, 32, 32), 9 if wet else 4, 0, 18, dirt_d)
	if wet:
		PixelDraw.speckle_rect(image, Rect2i(1, 1, 30, 30), 5, 40, 80, PixelDraw.pal("trunk_d"))
	if neighbor_mask & 1 == 0:
		PixelDraw.rect(image, 0, 0, 32, 1, grass)
		PixelDraw.rect(image, 0, 1, 32, 1, dirt_d)
	if neighbor_mask & 2 == 0:
		PixelDraw.rect(image, 31, 0, 1, 32, grass)
		PixelDraw.rect(image, 30, 0, 1, 32, dirt_d)
	if neighbor_mask & 4 == 0:
		PixelDraw.rect(image, 0, 31, 32, 1, grass)
		PixelDraw.rect(image, 0, 30, 32, 1, dirt_d)
	if neighbor_mask & 8 == 0:
		PixelDraw.rect(image, 0, 0, 1, 32, grass)
		PixelDraw.rect(image, 1, 0, 1, 32, dirt_d)
	return image


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
	var pip_d := PixelDraw.pal("wood")
	if wet:
		pip_d = PixelDraw.pal("trunk_d")
	for spot in [Vector2i(8, 14), Vector2i(16, 12), Vector2i(24, 15), Vector2i(12, 20), Vector2i(20, 22)]:
		PixelDraw.px(image, spot.x, spot.y, pip)
		PixelDraw.px(image, spot.x + 1, spot.y, pip_d)


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
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
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
	if stage == "sprout":
		PixelDraw.rect(image, 14, 20, 4, 4, leaf)
		PixelDraw.px(image, 15, 19, leaf_l)
		return
	if stage == "growing":
		PixelDraw.ellipse(image, 16, 20, 6, 5, leaf)
		PixelDraw.ellipse(image, 16, 19, 4, 3, leaf_l)
		PixelDraw.px(image, 14, 18, leaf_d)
		return
	PixelDraw.ellipse(image, 16, 18, 9, 8, leaf)
	PixelDraw.ellipse(image, 14, 17, 5, 5, leaf_l)
	PixelDraw.ellipse(image, 18, 19, 5, 4, leaf_d)
	PixelDraw.px(image, 16, 15, leaf_l)
	PixelDraw.px(image, 12, 16, leaf)
	PixelDraw.px(image, 20, 16, leaf)


static func _carrots(image: Image, stage: String) -> void:
	var tops := PixelDraw.pal("leaf")
	var tops_l := PixelDraw.pal("leaf_l")
	var body := PixelDraw.pal("brick")
	var body_l := PixelDraw.pal("gold")
	if stage == "sprout":
		PixelDraw.px(image, 15, 20, tops)
		PixelDraw.px(image, 16, 19, tops_l)
		PixelDraw.px(image, 17, 20, tops)
		return
	if stage == "growing":
		PixelDraw.rect(image, 15, 16, 2, 8, tops)
		PixelDraw.px(image, 14, 17, tops_l)
		PixelDraw.px(image, 17, 18, tops)
		PixelDraw.px(image, 15, 24, body)
		return
	PixelDraw.rect(image, 14, 12, 2, 10, tops)
	PixelDraw.rect(image, 16, 11, 2, 11, tops_l)
	PixelDraw.px(image, 13, 14, tops)
	PixelDraw.px(image, 18, 15, tops)
	PixelDraw.rect(image, 14, 22, 4, 6, body)
	PixelDraw.rect(image, 15, 23, 2, 4, body_l)
	PixelDraw.px(image, 15, 28, body)


static func _tomatoes(image: Image, stage: String) -> void:
	var stem := PixelDraw.pal("leaf_d")
	var leaf := PixelDraw.pal("leaf")
	var fruit := PixelDraw.pal("flower")
	var fruit_l := PixelDraw.pal("carpet_l")
	var fruit_d := PixelDraw.pal("roof")
	if stage == "sprout":
		PixelDraw.rect(image, 15, 20, 2, 5, stem)
		PixelDraw.px(image, 14, 21, leaf)
		PixelDraw.px(image, 17, 22, leaf)
		return
	if stage == "growing":
		PixelDraw.rect(image, 15, 14, 2, 12, stem)
		PixelDraw.px(image, 13, 16, leaf)
		PixelDraw.px(image, 14, 17, leaf)
		PixelDraw.px(image, 18, 18, leaf)
		PixelDraw.px(image, 17, 15, leaf)
		PixelDraw.px(image, 14, 22, fruit_d)
		return
	PixelDraw.rect(image, 15, 10, 2, 16, stem)
	PixelDraw.px(image, 12, 14, leaf)
	PixelDraw.px(image, 13, 15, leaf)
	PixelDraw.px(image, 18, 13, leaf)
	PixelDraw.px(image, 19, 16, leaf)
	PixelDraw.ellipse(image, 13, 20, 3, 3, fruit)
	PixelDraw.ellipse(image, 19, 18, 3, 3, fruit)
	PixelDraw.ellipse(image, 16, 24, 3, 3, fruit_d)
	PixelDraw.px(image, 12, 19, fruit_l)
	PixelDraw.px(image, 18, 17, fruit_l)


static func _flowers(image: Image, stage: String) -> void:
	var stem := PixelDraw.pal("leaf")
	var stem_d := PixelDraw.pal("leaf_d")
	var petal := PixelDraw.pal("flower")
	var petal2 := PixelDraw.pal("gold")
	var center := PixelDraw.pal("paper")
	if stage == "sprout":
		PixelDraw.rect(image, 15, 20, 2, 5, stem)
		PixelDraw.px(image, 16, 19, stem_d)
		return
	if stage == "growing":
		PixelDraw.rect(image, 15, 14, 2, 12, stem)
		PixelDraw.px(image, 14, 16, stem)
		PixelDraw.px(image, 17, 18, stem_d)
		PixelDraw.px(image, 15, 13, petal)
		return
	PixelDraw.rect(image, 10, 16, 2, 10, stem_d)
	PixelDraw.rect(image, 15, 12, 2, 14, stem)
	PixelDraw.rect(image, 21, 17, 2, 9, stem)
	_bloom(image, 16, 10, petal, center)
	_bloom(image, 11, 14, petal2, center)
	_bloom(image, 22, 15, petal, PixelDraw.pal("gold"))


static func _bloom(image: Image, cx: int, cy: int, petal: Color, center: Color) -> void:
	PixelDraw.px(image, cx, cy - 1, petal)
	PixelDraw.px(image, cx - 1, cy, petal)
	PixelDraw.px(image, cx + 1, cy, petal)
	PixelDraw.px(image, cx, cy + 1, petal)
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
