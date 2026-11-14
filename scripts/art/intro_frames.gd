class_name IntroFrames
extends RefCounted
## Original procedural intro panels. Palette colors only. No traced or generated images.

const W := 800
const H := 280
const VIEW_W := 640
const VIEW_H := 360

static var _cache: Dictionary = {}
static var _portraits: Dictionary = {}


static func has_panel(panel_id: String) -> bool:
	match panel_id:
		"letter", "drive", "town_sign", "oak_street", "church_reveal", "overgrown_garden", "locked_door", "vignette_margaret", "vignette_harold", "vignette_thomas", "vignette_frank", "vignette_sarah", "porch_close", "closing":
			return true
		_:
			return false


static func texture(panel_id: String) -> Texture2D:
	var image := build(panel_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func overlay_texture(kind: String) -> Texture2D:
	var image := _overlay(kind)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


static func build(panel_id: String) -> Image:
	if _cache.has(panel_id):
		return _cache[panel_id]
	var image: Image = null
	match panel_id:
		"letter":
			image = _letter()
		"drive":
			image = _drive()
		"town_sign":
			image = _town_sign()
		"oak_street":
			image = _oak_street()
		"church_reveal":
			image = _church_reveal()
		"overgrown_garden":
			image = _overgrown_garden()
		"locked_door":
			image = _locked_door()
		"vignette_margaret":
			image = _vignette("margaret", "office")
		"vignette_harold":
			image = _vignette("harold", "sanctuary")
		"vignette_thomas":
			image = _vignette("thomas", "hardware")
		"vignette_frank":
			image = _vignette("frank", "bay")
		"vignette_sarah":
			image = _vignette("sarah", "lane")
		"porch_close":
			image = _porch_close()
		"closing":
			image = _closing()
		_:
			return null
	_cache[panel_id] = image
	return image


static func _letter() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("pants"), PixelDraw.pal("wood_d"), PixelDraw.pal("wood"))
	PixelDraw.rect(image, 0, 96, W, 184, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 0, 98, W, 8, PixelDraw.pal("wood"))
	PixelDraw.speckle_rect(image, Rect2i(0, 106, W, 174), 11, 0, 18, PixelDraw.pal("wood_l"), false)
	# Desk blotter and lamp.
	PixelDraw.rect(image, 90, 118, 620, 90, PixelDraw.pal("wood"))
	PixelDraw.rect(image, 96, 124, 608, 8, PixelDraw.pal("wood_l"))
	PixelDraw.rect(image, 118, 140, 420, 56, PixelDraw.pal("paper"))
	PixelDraw.rect(image, 126, 148, 404, 40, PixelDraw.pal("cream"))
	for i in 6:
		PixelDraw.rect(image, 140, 154 + i * 4, 280 - i * 8, 2, PixelDraw.pal("cream_s"))
	PixelDraw.rect(image, 140, 154, 90, 2, PixelDraw.pal("brick"))
	# Envelope.
	PixelDraw.rect(image, 520, 132, 150, 58, PixelDraw.pal("paper"))
	PixelDraw.rect(image, 520, 132, 150, 4, PixelDraw.pal("cream_d"))
	for x in range(520, 670):
		var peak := 132 + int(abs(x - 595) * 0.22)
		PixelDraw.px(image, x, peak, PixelDraw.pal("cream_d"))
	PixelDraw.rect(image, 582, 160, 28, 10, PixelDraw.pal("brick"))
	# Lamp.
	PixelDraw.rect(image, 86, 78, 10, 40, PixelDraw.pal("grey_d"))
	PixelDraw.rect(image, 70, 62, 42, 18, PixelDraw.pal("lamp"))
	PixelDraw.rect(image, 76, 58, 30, 6, PixelDraw.pal("gold"))
	return image


static func _drive() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("shirt_d"), PixelDraw.pal("flower"), PixelDraw.pal("gold"))
	_sun(image, 620, 48, 22)
	# Hills and fields.
	PixelDraw.ellipse(image, 160, 170, 220, 40, PixelDraw.pal("leaf_d"))
	PixelDraw.ellipse(image, 420, 176, 260, 36, PixelDraw.pal("leaf"))
	PixelDraw.ellipse(image, 680, 172, 180, 38, PixelDraw.pal("moss"))
	PixelDraw.rect(image, 0, 186, W, 40, PixelDraw.pal("grass"))
	PixelDraw.speckle_rect(image, Rect2i(0, 186, W, 40), 4, 0, 22, PixelDraw.pal("grass_l"), false)
	# Water tower in the distance.
	PixelDraw.rect(image, 508, 118, 8, 56, PixelDraw.pal("grey"))
	PixelDraw.rect(image, 528, 118, 8, 56, PixelDraw.pal("grey"))
	PixelDraw.ellipse(image, 522, 112, 22, 16, PixelDraw.pal("grey_d"))
	PixelDraw.ellipse(image, 522, 108, 18, 12, PixelDraw.pal("cream"))
	# Road.
	PixelDraw.rect(image, 0, 226, W, 54, PixelDraw.pal("path_c"))
	PixelDraw.rect(image, 0, 230, W, 40, PixelDraw.pal("path_d"))
	var dash := 0
	while dash < W:
		PixelDraw.rect(image, dash, 248, 18, 3, PixelDraw.pal("cream"))
		dash += 34
	# Fence posts.
	for x in range(20, W, 46):
		PixelDraw.rect(image, x, 200, 3, 26, PixelDraw.pal("wood_d"))
	return image


static func _town_sign() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("shirt"), PixelDraw.pal("flower2"), PixelDraw.pal("lamp"))
	_sun(image, 80, 40, 18)
	PixelDraw.ellipse(image, 240, 188, 300, 50, PixelDraw.pal("grass"))
	PixelDraw.rect(image, 0, 196, W, 84, PixelDraw.pal("grass_d"))
	# Water tower.
	PixelDraw.rect(image, 118, 70, 10, 110, PixelDraw.pal("grey"))
	PixelDraw.rect(image, 156, 70, 10, 110, PixelDraw.pal("grey"))
	PixelDraw.rect(image, 118, 96, 48, 6, PixelDraw.pal("grey_d"))
	PixelDraw.ellipse(image, 142, 64, 34, 24, PixelDraw.pal("grey_d"))
	PixelDraw.ellipse(image, 142, 58, 28, 18, PixelDraw.pal("cream"))
	PixelDraw.rect(image, 138, 78, 8, 70, PixelDraw.pal("grey_d"))
	# Town sign.
	PixelDraw.rect(image, 430, 148, 12, 90, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 540, 148, 12, 90, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 400, 118, 196, 70, PixelDraw.pal("wood"))
	PixelDraw.rect(image, 408, 126, 180, 54, PixelDraw.pal("cream"))
	PixelDraw.rect(image, 420, 138, 110, 6, PixelDraw.pal("brick"))
	PixelDraw.rect(image, 420, 150, 86, 4, PixelDraw.pal("cream_s"))
	PixelDraw.rect(image, 420, 160, 64, 4, PixelDraw.pal("cream_s"))
	# Road edge.
	PixelDraw.rect(image, 0, 250, W, 30, PixelDraw.pal("path_d"))
	return image


static func _oak_street() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("shirt_d"), PixelDraw.pal("flower"), PixelDraw.pal("gold"))
	PixelDraw.rect(image, 0, 150, W, 80, PixelDraw.pal("plaster"))
	_shop(image, 20, 96, 130, 90, PixelDraw.pal("brick"), PixelDraw.pal("roof"), "diner")
	_shop(image, 160, 88, 140, 98, PixelDraw.pal("wood"), PixelDraw.pal("roof_d"), "hardware")
	_shop(image, 314, 100, 120, 86, PixelDraw.pal("cream"), PixelDraw.pal("brick_d"), "barber")
	_shop(image, 450, 92, 150, 94, PixelDraw.pal("grey"), PixelDraw.pal("path_c"), "bay")
	_shop(image, 620, 104, 140, 82, PixelDraw.pal("plaster_d"), PixelDraw.pal("roof"), "lease")
	PixelDraw.rect(image, 0, 186, W, 18, PixelDraw.pal("path_l"))
	PixelDraw.rect(image, 0, 204, W, 8, PixelDraw.pal("path_c"))
	PixelDraw.rect(image, 0, 212, W, 68, PixelDraw.pal("path_d"))
	var dash := 10
	while dash < W:
		PixelDraw.rect(image, dash, 242, 16, 3, PixelDraw.pal("cream"))
		dash += 32
	# Awnings and windows already in _shop. Steam from diner.
	PixelDraw.ellipse(image, 64, 90, 8, 6, PixelDraw.pal("cream"))
	PixelDraw.ellipse(image, 78, 82, 6, 5, PixelDraw.pal("paper"))
	return image


static func _church_reveal() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("shirt_d"), PixelDraw.pal("flower"), PixelDraw.pal("lamp"))
	_sun(image, 86, 44, 20)
	PixelDraw.rect(image, 0, 188, W, 92, PixelDraw.pal("grass"))
	PixelDraw.speckle_rect(image, Rect2i(0, 188, W, 92), 7, 0, 20, PixelDraw.pal("grass_l"), false)
	_path(image, 360, 210, 80, 70)
	_church(image, 250, 40)
	# Overgrown bed.
	PixelDraw.rect(image, 168, 200, 70, 22, PixelDraw.pal("soil"))
	PixelDraw.speckle_rect(image, Rect2i(168, 194, 70, 28), 9, 0, 40, PixelDraw.pal("leaf"), false)
	PixelDraw.speckle_rect(image, Rect2i(168, 194, 70, 28), 13, 200, 255, PixelDraw.pal("flower"), false)
	# Fence.
	for x in range(40, 760, 18):
		PixelDraw.rect(image, x, 214, 3, 22, PixelDraw.pal("wood"))
	PixelDraw.rect(image, 40, 218, 720, 3, PixelDraw.pal("wood_d"))
	return image


static func _overgrown_garden() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("pants"), PixelDraw.pal("shirt"), PixelDraw.pal("gold"))
	PixelDraw.rect(image, 0, 160, W, 120, PixelDraw.pal("grass_d"))
	PixelDraw.speckle_rect(image, Rect2i(0, 160, W, 120), 21, 0, 28, PixelDraw.pal("moss"), false)
	PixelDraw.rect(image, 90, 70, 280, 130, PixelDraw.pal("plaster"))
	PixelDraw.rect(image, 90, 54, 280, 22, PixelDraw.pal("roof"))
	PixelDraw.rect(image, 210, 150, 44, 70, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 226, 176, 8, 12, PixelDraw.pal("gold"))
	PixelDraw.rect(image, 118, 96, 36, 40, PixelDraw.pal("glass_d"))
	PixelDraw.rect(image, 300, 96, 36, 40, PixelDraw.pal("lamp"))
	PixelDraw.rect(image, 430, 84, 14, 96, PixelDraw.pal("wood_d"))
	PixelDraw.ellipse(image, 437, 78, 22, 16, PixelDraw.pal("lamp"))
	# Garden tangle.
	for i in 18:
		var x := 470 + (i * 17) % 260
		var y := 170 + (i * 11) % 70
		PixelDraw.rect(image, x, y, 5, 18, PixelDraw.pal("leaf"))
		PixelDraw.rect(image, x + 2, y - 6, 3, 8, PixelDraw.pal("leaf_l"))
	PixelDraw.speckle_rect(image, Rect2i(460, 168, 280, 90), 3, 0, 30, PixelDraw.pal("flower"), false)
	return image


static func _locked_door() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("pants_d"), PixelDraw.pal("plaster_d"), PixelDraw.pal("plaster"))
	PixelDraw.rect(image, 220, 20, 360, 260, PixelDraw.pal("plaster"))
	PixelDraw.speckle_rect(image, Rect2i(220, 20, 360, 260), 15, 0, 14, PixelDraw.pal("cream_s"), false)
	PixelDraw.rect(image, 300, 48, 200, 232, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 308, 56, 184, 216, PixelDraw.pal("wood"))
	PixelDraw.rect(image, 308, 156, 184, 6, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 396, 56, 8, 216, PixelDraw.pal("wood_d"))
	PixelDraw.ellipse(image, 470, 170, 8, 8, PixelDraw.pal("gold"))
	PixelDraw.rect(image, 468, 170, 12, 4, PixelDraw.pal("gold"))
	PixelDraw.rect(image, 250, 36, 40, 12, PixelDraw.pal("cream_s"))
	PixelDraw.rect(image, 510, 40, 36, 10, PixelDraw.pal("cream_s"))
	return image


static func _vignette(who: String, place: String) -> Image:
	var image := _canvas()
	match place:
		"office":
			_fill_sky(image, PixelDraw.pal("wood_d"), PixelDraw.pal("wood"), PixelDraw.pal("plaster"))
			PixelDraw.rect(image, 0, 40, W, 160, PixelDraw.pal("plaster_d"))
			PixelDraw.rect(image, 80, 60, 70, 80, PixelDraw.pal("glass"))
			PixelDraw.rect(image, 0, 200, W, 80, PixelDraw.pal("carpet_d"))
			PixelDraw.rect(image, 520, 140, 90, 70, PixelDraw.pal("wood"))
		"sanctuary":
			_fill_sky(image, PixelDraw.pal("pants"), PixelDraw.pal("carpet_d"), PixelDraw.pal("plaster"))
			PixelDraw.rect(image, 0, 36, W, 170, PixelDraw.pal("plaster"))
			PixelDraw.rect(image, 140, 50, 40, 90, PixelDraw.pal("glass"))
			PixelDraw.rect(image, 200, 50, 40, 90, PixelDraw.pal("glass_d"))
			PixelDraw.rect(image, 0, 206, W, 74, PixelDraw.pal("carpet"))
			PixelDraw.rect(image, 80, 214, 200, 18, PixelDraw.pal("wood_d"))
		"hardware":
			_fill_sky(image, PixelDraw.pal("path_c"), PixelDraw.pal("wood"), PixelDraw.pal("wood_l"))
			PixelDraw.rect(image, 0, 40, W, 170, PixelDraw.pal("wood"))
			for x in range(60, 700, 48):
				PixelDraw.rect(image, x, 70, 30, 70, PixelDraw.pal("grey"))
			PixelDraw.rect(image, 0, 210, W, 70, PixelDraw.pal("path_d"))
			PixelDraw.rect(image, 200, 150, 220, 16, PixelDraw.pal("wood_l"))
		"bay":
			_fill_sky(image, PixelDraw.pal("shirt_d"), PixelDraw.pal("grey_d"), PixelDraw.pal("grey"))
			PixelDraw.rect(image, 0, 50, W, 150, PixelDraw.pal("grey_d"))
			PixelDraw.rect(image, 180, 70, 280, 130, PixelDraw.pal("path_c"))
			PixelDraw.rect(image, 0, 200, W, 80, PixelDraw.pal("path_d"))
			PixelDraw.rect(image, 80, 186, 90, 40, PixelDraw.pal("grey"))
		"lane":
			_fill_sky(image, PixelDraw.pal("shirt"), PixelDraw.pal("gold"), PixelDraw.pal("lamp"))
			PixelDraw.rect(image, 0, 170, W, 110, PixelDraw.pal("grass"))
			_shop(image, 80, 90, 160, 100, PixelDraw.pal("cream"), PixelDraw.pal("roof"), "house")
			_shop(image, 300, 100, 140, 90, PixelDraw.pal("brick"), PixelDraw.pal("roof_d"), "house")
			PixelDraw.rect(image, 0, 230, W, 50, PixelDraw.pal("path"))
		_:
			_fill_sky(image, PixelDraw.pal("pants"), PixelDraw.pal("plaster"), PixelDraw.pal("cream"))
	var portrait := _scaled_portrait(who)
	if portrait != null:
		PixelDraw.blit(image, portrait, 368, 120)
	return image


static func _porch_close() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("pants_d"), PixelDraw.pal("shirt_d"), PixelDraw.pal("flower"))
	PixelDraw.rect(image, 120, 40, 420, 200, PixelDraw.pal("plaster"))
	PixelDraw.rect(image, 120, 24, 420, 24, PixelDraw.pal("roof_d"))
	PixelDraw.rect(image, 280, 120, 70, 120, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 160, 70, 50, 60, PixelDraw.pal("glass_d"))
	PixelDraw.rect(image, 430, 70, 50, 60, PixelDraw.pal("lamp"))
	PixelDraw.rect(image, 548, 88, 10, 70, PixelDraw.pal("wood_d"))
	PixelDraw.ellipse(image, 553, 82, 16, 12, PixelDraw.pal("lamp"))
	PixelDraw.rect(image, 0, 220, W, 60, PixelDraw.pal("wood"))
	PixelDraw.rect(image, 40, 200, 16, 40, PixelDraw.pal("wood_d"))
	PixelDraw.rect(image, 700, 200, 16, 40, PixelDraw.pal("wood_d"))
	return image


static func _closing() -> Image:
	var image := _canvas()
	_fill_sky(image, PixelDraw.pal("pants_d"), PixelDraw.pal("shirt_d"), PixelDraw.pal("brick_d"))
	PixelDraw.ellipse(image, 640, 56, 28, 28, PixelDraw.pal("cream"))
	PixelDraw.rect(image, 0, 190, W, 90, PixelDraw.pal("grass_d"))
	_church(image, 250, 48)
	# Darken the church a little so it reads as dusk.
	PixelDraw.speckle_rect(image, Rect2i(250, 48, 300, 170), 8, 0, 16, PixelDraw.pal("pants_d"), true)
	PixelDraw.rect(image, 360, 210, 80, 50, PixelDraw.pal("path_d"))
	return image


static func _overlay(kind: String) -> Image:
	match kind:
		"car":
			return _car()
		"leaf":
			return _leaf()
		"bird":
			return _bird()
		"window_glow":
			var glow := PixelDraw.canvas(50, 60)
			PixelDraw.rect(glow, 0, 0, 50, 60, PixelDraw.pal("lamp"))
			return glow
		_:
			return PixelDraw.canvas(8, 8)


static func _car() -> Image:
	var image := PixelDraw.canvas(70, 28)
	PixelDraw.rect(image, 6, 12, 58, 10, PixelDraw.pal("shirt_d"))
	PixelDraw.rect(image, 18, 4, 32, 10, PixelDraw.pal("shirt"))
	PixelDraw.rect(image, 22, 6, 12, 8, PixelDraw.pal("glass"))
	PixelDraw.rect(image, 38, 6, 10, 8, PixelDraw.pal("glass_d"))
	PixelDraw.ellipse(image, 18, 22, 7, 6, PixelDraw.pal("shoe"))
	PixelDraw.ellipse(image, 52, 22, 7, 6, PixelDraw.pal("shoe"))
	PixelDraw.rect(image, 60, 14, 6, 4, PixelDraw.pal("lamp"))
	return image


static func _leaf() -> Image:
	var image := PixelDraw.canvas(10, 8)
	PixelDraw.ellipse(image, 5, 4, 4, 3, PixelDraw.pal("leaf"))
	PixelDraw.px(image, 5, 4, PixelDraw.pal("leaf_l"))
	return image


static func _bird() -> Image:
	var image := PixelDraw.canvas(10, 6)
	PixelDraw.px(image, 4, 3, PixelDraw.pal("pants_d"))
	PixelDraw.px(image, 5, 3, PixelDraw.pal("pants"))
	PixelDraw.px(image, 3, 2, PixelDraw.pal("pants_d"))
	PixelDraw.px(image, 2, 2, PixelDraw.pal("pants_d"))
	PixelDraw.px(image, 6, 2, PixelDraw.pal("pants_d"))
	PixelDraw.px(image, 7, 2, PixelDraw.pal("pants_d"))
	return image


static func _canvas() -> Image:
	return PixelDraw.canvas(W, H)


static func _fill_sky(image: Image, top: Color, mid: Color, bottom: Color) -> void:
	for y in H:
		var t := float(y) / float(maxi(H - 1, 1))
		var color: Color = top.lerp(mid, clampf(t * 1.4, 0.0, 1.0))
		if t > 0.55:
			color = mid.lerp(bottom, clampf((t - 0.55) / 0.45, 0.0, 1.0))
		for x in W:
			PixelDraw.px(image, x, y, color)


static func _sun(image: Image, cx: int, cy: int, r: int) -> void:
	PixelDraw.ellipse(image, cx, cy, r, r, PixelDraw.pal("lamp"))
	PixelDraw.ellipse(image, cx, cy, r - 6, r - 6, PixelDraw.pal("gold"))


static func _shop(image: Image, x: int, y: int, w: int, h: int, face: Color, roof: Color, kind: String) -> void:
	PixelDraw.rect(image, x, y + 12, w, h, face)
	PixelDraw.rect(image, x - 4, y, w + 8, 16, roof)
	PixelDraw.rect(image, x + 10, y + 28, 28, 24, PixelDraw.pal("glass_d"))
	PixelDraw.rect(image, x + 48, y + 28, 28, 24, PixelDraw.pal("glass"))
	if kind == "bay":
		PixelDraw.rect(image, x + 20, y + 40, w - 40, h - 44, PixelDraw.pal("path_c"))
	elif kind == "diner":
		PixelDraw.rect(image, x + 8, y + 18, w - 16, 8, PixelDraw.pal("brick"))
	elif kind == "hardware":
		PixelDraw.rect(image, x + 16, y + 18, 70, 8, PixelDraw.pal("gold"))


static func _church(image: Image, x: int, y: int) -> void:
	PixelDraw.rect(image, x + 40, y + 70, 220, 110, PixelDraw.pal("cream"))
	PixelDraw.rect(image, x + 36, y + 58, 228, 18, PixelDraw.pal("roof"))
	PixelDraw.rect(image, x + 120, y + 20, 44, 50, PixelDraw.pal("cream"))
	PixelDraw.rect(image, x + 128, y, 28, 24, PixelDraw.pal("roof_d"))
	PixelDraw.rect(image, x + 138, y - 16, 8, 20, PixelDraw.pal("gold"))
	PixelDraw.rect(image, x + 70, y + 90, 28, 40, PixelDraw.pal("glass"))
	PixelDraw.rect(image, x + 200, y + 90, 28, 40, PixelDraw.pal("glass_d"))
	PixelDraw.rect(image, x + 126, y + 120, 36, 60, PixelDraw.pal("wood_d"))
	PixelDraw.crack(image, x + 52, y + 88, 18, PixelDraw.pal("cream_s"), true)
	PixelDraw.crack(image, x + 210, y + 100, 14, PixelDraw.pal("cream_s"), false)


static func _path(image: Image, x: int, y: int, w: int, h: int) -> void:
	PixelDraw.rect(image, x, y, w, h, PixelDraw.pal("path"))
	PixelDraw.speckle_rect(image, Rect2i(x, y, w, h), 5, 0, 18, PixelDraw.pal("path_l"), false)


static func _scaled_portrait(who: String) -> Image:
	if _portraits.has(who):
		return _portraits[who]
	var sheet: Image = CharacterFrames.build_sheet(who)
	if sheet == null:
		return null
	var cell := sheet.get_region(Rect2i(0, 0, 32, 48))
	var scaled := PixelDraw.canvas(64, 96)
	for py in 48:
		for px in 32:
			var color := cell.get_pixel(px, py)
			if color.a == 0.0:
				continue
			PixelDraw.rect(scaled, px * 2, py * 2, 2, 2, color)
	_portraits[who] = scaled
	return scaled
