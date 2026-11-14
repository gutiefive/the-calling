class_name PotluckFrames
extends RefCounted
## Fellowship Hall gathering props. Palette only. Not rectangles.

const Draw := preload("res://scripts/art/pixel_draw.gd")


static func build(frame_id: String) -> Image:
	match frame_id:
		"table_modest":
			return _table(false)
		"table_full":
			return _table(true)
		"dishes_simple":
			return _dishes(false)
		"dishes_varied":
			return _dishes(true)
		"centerpiece":
			return _centerpiece()
		"string_lights":
			return _lights()
		"banner":
			return _banner()
		"chair":
			return _chair()
		"chairs_extra":
			return _chairs_extra()
		_:
			return _table(false)


static func texture(frame_id: String) -> Texture2D:
	var image := build(frame_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func _table(full: bool) -> Image:
	var image := Draw.canvas(112, 52)
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var cream := Draw.pal("cream")
	var cream_d := Draw.pal("cream_d")
	var cloth := Draw.pal("paper")
	Draw.rect(image, 10, 44, 92, 6, Draw.pal("path_c"))
	Draw.rect(image, 14, 32, 7, 16, wood_d)
	Draw.rect(image, 91, 32, 7, 16, wood_d)
	Draw.rect(image, 30, 34, 6, 14, wood_d)
	Draw.rect(image, 76, 34, 6, 14, wood_d)
	Draw.rect(image, 6, 24, 100, 12, wood_d)
	Draw.rect(image, 6, 20, 100, 8, wood)
	Draw.rect(image, 8, 12, 96, 14, cloth)
	Draw.rect(image, 8, 12, 96, 3, cream)
	Draw.rect(image, 8, 24, 96, 2, cream_d)
	Draw.rect(image, 8, 28, 96, 3, wood)
	_plate(image, 18, 14, Draw.pal("cream_s"), Draw.pal("leaf"))
	_bowl(image, 42, 14, Draw.pal("brick"), Draw.pal("gold"))
	_cup(image, 66, 16, cream_d)
	if full:
		_plate(image, 30, 16, Draw.pal("flower"), Draw.pal("leaf"))
		_bowl(image, 54, 13, Draw.pal("gold"), Draw.pal("cream_s"))
		_loaf(image, 80, 16)
		_cup(image, 94, 16, cream_d)
		Draw.px(image, 22, 16, Draw.pal("leaf_l"))
		Draw.px(image, 23, 17, Draw.pal("leaf"))
		Draw.px(image, 36, 15, Draw.pal("gold"))
		Draw.rect(image, 14, 20, 4, 3, Draw.pal("flower"))
	else:
		_cup(image, 80, 16, cream_d)
		Draw.px(image, 36, 20, cream_d)
		Draw.px(image, 58, 21, wood_d)
	return Draw.outline(image)


static func _dishes(varied: bool) -> Image:
	var image := Draw.canvas(32, 16)
	_plate(image, 4, 4, Draw.pal("cream_s"), Draw.pal("leaf"))
	_bowl(image, 16, 3, Draw.pal("brick"), Draw.pal("gold"))
	if varied:
		_plate(image, 10, 6, Draw.pal("flower"), Draw.pal("gold"))
		Draw.px(image, 24, 8, Draw.pal("flower2"))
		Draw.px(image, 26, 7, Draw.pal("leaf_l"))
	else:
		_cup(image, 24, 6, Draw.pal("cream_d"))
	return Draw.outline(image)


static func _centerpiece() -> Image:
	var image := Draw.canvas(16, 24)
	Draw.rect(image, 5, 16, 6, 6, Draw.pal("wood"))
	Draw.rect(image, 6, 14, 4, 4, Draw.pal("cream_d"))
	Draw.px(image, 7, 8, Draw.pal("leaf_d"))
	Draw.px(image, 8, 7, Draw.pal("leaf_d"))
	Draw.px(image, 8, 6, Draw.pal("flower"))
	Draw.px(image, 7, 5, Draw.pal("flower2"))
	Draw.px(image, 9, 5, Draw.pal("skirt"))
	Draw.px(image, 6, 7, Draw.pal("leaf"))
	Draw.px(image, 10, 8, Draw.pal("leaf"))
	Draw.px(image, 8, 4, Draw.pal("flower"))
	Draw.px(image, 5, 9, Draw.pal("leaf_d"))
	Draw.px(image, 11, 9, Draw.pal("leaf_d"))
	Draw.px(image, 5, 8, Draw.pal("flower2"))
	Draw.px(image, 11, 7, Draw.pal("skirt"))
	return Draw.outline(image)


static func _lights() -> Image:
	var image := Draw.canvas(96, 16)
	var wire := Draw.pal("wood_d")
	var lamp := Draw.pal("lamp")
	var gold := Draw.pal("gold")
	for x in range(4, 92):
		var dip := 2 + int(absf(sin(float(x) * 0.18)) * 6.0)
		Draw.px(image, x, dip, wire)
		if x % 10 == 0:
			Draw.rect(image, x - 1, dip + 1, 3, 4, lamp)
			Draw.px(image, x, dip + 2, gold)
	return Draw.outline(image)


static func _banner() -> Image:
	var image := Draw.canvas(48, 24)
	Draw.rect(image, 4, 6, 40, 12, Draw.pal("cream"))
	Draw.rect(image, 4, 6, 40, 2, Draw.pal("wood"))
	Draw.rect(image, 4, 16, 40, 2, Draw.pal("wood"))
	Draw.px(image, 8, 4, Draw.pal("wood_d"))
	Draw.px(image, 39, 4, Draw.pal("wood_d"))
	Draw.rect(image, 10, 9, 4, 5, Draw.pal("leaf"))
	Draw.rect(image, 16, 10, 3, 4, Draw.pal("gold"))
	Draw.rect(image, 22, 9, 4, 5, Draw.pal("leaf"))
	Draw.rect(image, 28, 10, 3, 4, Draw.pal("brick"))
	Draw.rect(image, 34, 9, 4, 5, Draw.pal("leaf"))
	return Draw.outline(image)


static func _chair() -> Image:
	var image := Draw.canvas(16, 24)
	Draw.rect(image, 4, 4, 8, 10, Draw.pal("wood"))
	Draw.rect(image, 5, 5, 6, 8, Draw.pal("wood_l"))
	Draw.rect(image, 3, 12, 10, 4, Draw.pal("wood_d"))
	Draw.rect(image, 4, 16, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 9, 16, 3, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _chairs_extra() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.blit(image, _chair(), 0, 0)
	Draw.blit(image, _chair(), 14, 0)
	return image


static func _plate(image: Image, x: int, y: int, food: Color, accent: Color) -> void:
	Draw.ellipse(image, x + 5, y + 4, 5, 3, Draw.pal("cream_s"))
	Draw.ellipse(image, x + 5, y + 4, 3, 2, food)
	Draw.px(image, x + 5, y + 3, accent)


static func _bowl(image: Image, x: int, y: int, food: Color, rim: Color) -> void:
	Draw.rect(image, x, y + 2, 10, 6, rim)
	Draw.rect(image, x + 1, y + 1, 8, 6, food)
	Draw.px(image, x + 4, y + 2, Draw.pal("cream_s"))


static func _cup(image: Image, x: int, y: int, tone: Color) -> void:
	Draw.rect(image, x, y, 5, 6, tone)
	Draw.rect(image, x + 1, y + 1, 3, 3, Draw.pal("wood_d"))
	Draw.px(image, x + 5, y + 2, tone)


static func _loaf(image: Image, x: int, y: int) -> void:
	Draw.rect(image, x, y, 10, 5, Draw.pal("wood"))
	Draw.rect(image, x + 1, y + 1, 8, 3, Draw.pal("gold"))
	Draw.px(image, x + 3, y + 2, Draw.pal("wood_d"))
	Draw.px(image, x + 6, y + 2, Draw.pal("wood_d"))
