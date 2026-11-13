class_name ItemFrames
extends RefCounted
## 16×16 item icons. Palette colors only. Authored to assets/items/.

const SIZE := Vector2i(16, 16)


static func build(item_id: String) -> Image:
	match item_id:
		"watering_can":
			return _watering_can()
		"hoe":
			return _hoe()
		"hand_tools":
			return _hand_tools()
		"lettuce_seeds":
			return _seed_packet(PixelDraw.pal("leaf"), PixelDraw.pal("leaf_l"))
		"carrot_seeds":
			return _seed_packet(PixelDraw.pal("brick"), PixelDraw.pal("gold"))
		"tomato_seeds":
			return _seed_packet(PixelDraw.pal("roof"), PixelDraw.pal("flower"))
		"flower_seeds":
			return _seed_packet(PixelDraw.pal("flower"), PixelDraw.pal("gold"))
		"lettuce":
			return _lettuce()
		"carrots":
			return _carrots()
		"tomatoes":
			return _tomatoes()
		"flowers":
			return _flowers()
		"wood":
			return _wood()
		"nails":
			return _nails()
		"scrap":
			return _scrap()
		_:
			return _unknown()


static func texture(item_id: String) -> Texture2D:
	var image := build(item_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func _watering_can() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var metal := PixelDraw.pal("grey")
	var metal_d := PixelDraw.pal("grey_d")
	var metal_l := PixelDraw.pal("paper")
	var handle := PixelDraw.pal("wood")
	PixelDraw.rect(image, 3, 6, 8, 7, metal)
	PixelDraw.rect(image, 4, 7, 6, 5, metal_l)
	PixelDraw.rect(image, 3, 12, 8, 1, metal_d)
	PixelDraw.rect(image, 10, 8, 4, 2, metal)
	PixelDraw.rect(image, 12, 7, 2, 2, metal_d)
	PixelDraw.rect(image, 5, 3, 4, 1, handle)
	PixelDraw.px(image, 5, 4, handle)
	PixelDraw.px(image, 8, 4, handle)
	PixelDraw.px(image, 5, 5, handle)
	PixelDraw.px(image, 8, 5, handle)
	return PixelDraw.outline(image)


static func _hoe() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_d := PixelDraw.pal("wood_d")
	var blade := PixelDraw.pal("grey")
	var blade_d := PixelDraw.pal("grey_d")
	for i in 11:
		PixelDraw.px(image, 4, 2 + i, wood if (i % 2) == 0 else wood_d)
		PixelDraw.px(image, 5, 2 + i, wood)
	PixelDraw.rect(image, 3, 12, 10, 2, blade)
	PixelDraw.rect(image, 11, 11, 2, 3, blade_d)
	return PixelDraw.outline(image)


static func _hand_tools() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var wood := PixelDraw.pal("wood")
	var wood_l := PixelDraw.pal("wood_l")
	var head := PixelDraw.pal("grey")
	var head_d := PixelDraw.pal("grey_d")
	for i in 10:
		PixelDraw.px(image, 7, 3 + i, wood)
		PixelDraw.px(image, 8, 3 + i, wood_l)
	PixelDraw.rect(image, 4, 3, 8, 3, head)
	PixelDraw.rect(image, 3, 4, 2, 2, head_d)
	PixelDraw.rect(image, 11, 4, 2, 2, head)
	return PixelDraw.outline(image)


static func _seed_packet(face: Color, pip: Color) -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var paper := PixelDraw.pal("paper")
	var paper_d := PixelDraw.pal("cream_d")
	PixelDraw.rect(image, 4, 2, 8, 12, paper)
	PixelDraw.rect(image, 5, 3, 6, 3, face)
	PixelDraw.rect(image, 4, 13, 8, 1, paper_d)
	PixelDraw.px(image, 7, 8, pip)
	PixelDraw.px(image, 8, 9, pip)
	PixelDraw.px(image, 6, 10, pip)
	PixelDraw.px(image, 9, 10, pip)
	return PixelDraw.outline(image)


static func _lettuce() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var leaf := PixelDraw.pal("leaf")
	var leaf_l := PixelDraw.pal("leaf_l")
	var leaf_d := PixelDraw.pal("leaf_d")
	PixelDraw.ellipse(image, 8, 9, 6, 5, leaf)
	PixelDraw.ellipse(image, 8, 8, 4, 4, leaf_l)
	PixelDraw.px(image, 8, 7, leaf_d)
	PixelDraw.px(image, 7, 9, leaf_d)
	PixelDraw.px(image, 10, 10, leaf)
	return PixelDraw.outline(image)


static func _carrots() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var body := PixelDraw.pal("brick")
	var body_l := PixelDraw.pal("gold")
	var tops := PixelDraw.pal("leaf")
	PixelDraw.rect(image, 6, 5, 4, 9, body)
	PixelDraw.rect(image, 7, 6, 2, 7, body_l)
	PixelDraw.px(image, 7, 14, body)
	PixelDraw.px(image, 8, 14, body)
	PixelDraw.px(image, 6, 3, tops)
	PixelDraw.px(image, 7, 2, tops)
	PixelDraw.px(image, 8, 2, tops)
	PixelDraw.px(image, 9, 3, tops)
	PixelDraw.px(image, 8, 4, tops)
	return PixelDraw.outline(image)


static func _tomatoes() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var fruit := PixelDraw.pal("flower")
	var fruit_d := PixelDraw.pal("roof")
	var fruit_l := PixelDraw.pal("carpet_l")
	var stem := PixelDraw.pal("leaf")
	PixelDraw.ellipse(image, 8, 9, 5, 5, fruit)
	PixelDraw.px(image, 6, 7, fruit_l)
	PixelDraw.px(image, 7, 8, fruit_l)
	PixelDraw.px(image, 10, 12, fruit_d)
	PixelDraw.px(image, 8, 4, stem)
	PixelDraw.px(image, 7, 5, stem)
	PixelDraw.px(image, 9, 5, stem)
	return PixelDraw.outline(image)


static func _flowers() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var petal := PixelDraw.pal("flower")
	var petal2 := PixelDraw.pal("gold")
	var center := PixelDraw.pal("paper")
	var stem := PixelDraw.pal("leaf")
	PixelDraw.rect(image, 7, 8, 2, 6, stem)
	PixelDraw.px(image, 6, 10, stem)
	PixelDraw.px(image, 9, 11, stem)
	PixelDraw.px(image, 8, 4, petal)
	PixelDraw.px(image, 7, 5, petal)
	PixelDraw.px(image, 9, 5, petal)
	PixelDraw.px(image, 6, 6, petal)
	PixelDraw.px(image, 10, 6, petal)
	PixelDraw.px(image, 7, 7, petal)
	PixelDraw.px(image, 9, 7, petal)
	PixelDraw.px(image, 8, 6, center)
	PixelDraw.px(image, 4, 8, petal2)
	PixelDraw.px(image, 5, 7, petal2)
	PixelDraw.px(image, 5, 9, petal2)
	PixelDraw.px(image, 12, 7, petal)
	PixelDraw.px(image, 13, 8, petal)
	return PixelDraw.outline(image)


static func _wood() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var plank := PixelDraw.pal("wood")
	var plank_l := PixelDraw.pal("wood_l")
	var plank_d := PixelDraw.pal("wood_d")
	PixelDraw.rect(image, 2, 5, 12, 6, plank)
	PixelDraw.rect(image, 2, 5, 12, 1, plank_l)
	PixelDraw.rect(image, 2, 10, 12, 1, plank_d)
	PixelDraw.px(image, 5, 7, plank_d)
	PixelDraw.px(image, 6, 8, plank_d)
	PixelDraw.px(image, 10, 6, plank_d)
	return PixelDraw.outline(image)


static func _nails() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var bag := PixelDraw.pal("paper")
	var bag_d := PixelDraw.pal("cream_d")
	var nail := PixelDraw.pal("grey")
	var nail_d := PixelDraw.pal("grey_d")
	PixelDraw.rect(image, 4, 6, 8, 8, bag)
	PixelDraw.rect(image, 5, 5, 6, 2, bag_d)
	PixelDraw.px(image, 6, 8, nail)
	PixelDraw.px(image, 6, 9, nail_d)
	PixelDraw.px(image, 8, 8, nail)
	PixelDraw.px(image, 8, 9, nail_d)
	PixelDraw.px(image, 10, 8, nail)
	PixelDraw.px(image, 10, 9, nail_d)
	return PixelDraw.outline(image)


static func _scrap() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	var rust := PixelDraw.pal("brick")
	var rust_d := PixelDraw.pal("brick_d")
	var metal := PixelDraw.pal("grey_d")
	PixelDraw.rect(image, 3, 8, 6, 4, rust)
	PixelDraw.rect(image, 7, 5, 6, 5, metal)
	PixelDraw.px(image, 4, 9, rust_d)
	PixelDraw.px(image, 9, 6, rust)
	PixelDraw.px(image, 11, 8, rust_d)
	PixelDraw.px(image, 5, 6, metal)
	return PixelDraw.outline(image)


static func _unknown() -> Image:
	var image := PixelDraw.canvas(SIZE.x, SIZE.y)
	PixelDraw.rect(image, 4, 4, 8, 8, PixelDraw.pal("grey"))
	return PixelDraw.outline(image)
