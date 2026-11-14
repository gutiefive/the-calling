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
	var image := Draw.canvas(128, 56)
	var wood := Draw.pal("wood")
	var wood_d := Draw.pal("wood_d")
	var cream := Draw.pal("cream")
	var cream_d := Draw.pal("cream_d")
	var cloth := Draw.pal("paper")
	Draw.rect(image, 12, 48, 104, 6, Draw.pal("path_c"))
	Draw.rect(image, 16, 34, 8, 18, wood_d)
	Draw.rect(image, 104, 34, 8, 18, wood_d)
	Draw.rect(image, 36, 36, 6, 16, wood_d)
	Draw.rect(image, 86, 36, 6, 16, wood_d)
	Draw.rect(image, 6, 26, 116, 12, wood_d)
	Draw.rect(image, 6, 22, 116, 8, wood)
	Draw.rect(image, 8, 10, 112, 18, cloth)
	Draw.rect(image, 8, 10, 112, 3, cream)
	Draw.rect(image, 40, 12, 1, 14, cream_d)
	Draw.rect(image, 88, 13, 1, 12, cream_d)
	Draw.rect(image, 8, 26, 112, 2, cream_d)
	Draw.rect(image, 8, 28, 112, 3, wood)
	Draw.rect(image, 8, 28, 5, 7, cloth)
	Draw.rect(image, 115, 28, 5, 7, cloth)
	_plate(image, 18, 14, Draw.pal("cream_s"), Draw.pal("leaf"))
	_bowl(image, 46, 13, Draw.pal("brick"), Draw.pal("gold"))
	_cup(image, 74, 16, cream_d)
	if full:
		_plate(image, 32, 16, Draw.pal("flower"), Draw.pal("leaf"))
		_bowl(image, 60, 12, Draw.pal("gold"), Draw.pal("cream_s"))
		_loaf(image, 88, 16)
		_cup(image, 108, 16, cream_d)
		Draw.px(image, 24, 16, Draw.pal("leaf_l"))
		Draw.px(image, 25, 17, Draw.pal("leaf"))
		Draw.px(image, 40, 15, Draw.pal("gold"))
		Draw.rect(image, 16, 20, 5, 3, Draw.pal("flower"))
		Draw.rect(image, 56, 11, 16, 16, Draw.pal("flower"))
		Draw.rect(image, 58, 12, 12, 14, Draw.pal("flower2"))
	else:
		_cup(image, 96, 16, cream_d)
		Draw.px(image, 40, 20, cream_d)
		Draw.px(image, 64, 21, wood_d)
	return Draw.outline(image)


static func _dishes(varied: bool) -> Image:
	var image := Draw.canvas(56, 22)
	_plate(image, 4, 6, Draw.pal("cream_s"), Draw.pal("leaf"))
	_bowl(image, 20, 5, Draw.pal("brick"), Draw.pal("gold"))
	if varied:
		_plate(image, 14, 8, Draw.pal("flower"), Draw.pal("gold"))
		_loaf(image, 36, 8)
		Draw.px(image, 48, 10, Draw.pal("flower2"))
		Draw.px(image, 50, 9, Draw.pal("leaf_l"))
	else:
		_cup(image, 40, 8, Draw.pal("cream_d"))
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
	var image := Draw.canvas(360, 24)
	var wire := Draw.pal("wood_d")
	var lamp := Draw.pal("lamp")
	var gold := Draw.pal("gold")
	for x in range(8, 352):
		var dip := 4 + int(absf(sin(float(x) * 0.12)) * 10.0)
		Draw.px(image, x, dip, wire)
		if x % 14 == 0:
			Draw.rect(image, x - 1, dip + 1, 3, 5, lamp)
			Draw.px(image, x, dip + 2, gold)
	return Draw.outline(image)


static func _banner() -> Image:
	var image := Draw.canvas(96, 28)
	Draw.rect(image, 6, 8, 84, 14, Draw.pal("cream"))
	Draw.rect(image, 6, 8, 84, 2, Draw.pal("wood"))
	Draw.rect(image, 6, 20, 84, 2, Draw.pal("wood"))
	Draw.px(image, 10, 5, Draw.pal("wood_d"))
	Draw.px(image, 85, 5, Draw.pal("wood_d"))
	Draw.rect(image, 14, 11, 8, 6, Draw.pal("leaf"))
	Draw.rect(image, 28, 12, 6, 5, Draw.pal("gold"))
	Draw.rect(image, 42, 11, 8, 6, Draw.pal("leaf"))
	Draw.rect(image, 58, 12, 6, 5, Draw.pal("brick"))
	Draw.rect(image, 72, 11, 8, 6, Draw.pal("leaf"))
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
