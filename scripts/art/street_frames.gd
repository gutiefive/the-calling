class_name StreetFrames
extends RefCounted
## Oak Street south storefronts, Maple Lane houses, hanging signs, and street props.
## Palette only. Same pixel scale as EnvironmentFrames.

const Draw := preload("res://scripts/art/pixel_draw.gd")
const Frames := preload("res://scripts/art/environment_frames.gd")


static func build_credit_union() -> Image:
	var image := Draw.canvas(192, 128)
	Frames._roof_box(image, 8, 16, 176, 22, Draw.pal("grey"), Draw.pal("grey_d"), Draw.pal("paper"))
	Draw.rect(image, 12, 38, 168, 80, Draw.pal("cream"))
	Draw.rect(image, 12, 38, 168, 8, Draw.pal("paper"))
	Draw.rect(image, 12, 108, 168, 12, Draw.pal("brick"))
	Draw.rect(image, 24, 58, 40, 36, Draw.pal("wood_d"))
	Draw.rect(image, 28, 62, 32, 28, Draw.pal("glass_d"))
	Draw.rect(image, 128, 58, 40, 36, Draw.pal("wood_d"))
	Draw.rect(image, 132, 62, 32, 28, Draw.pal("glass"))
	Draw.px(image, 136, 64, Draw.pal("glass_h"))
	Frames._door(image, 80, 78, 36, 42)
	Frames._transom(image, 80, 64, 36)
	Draw.rect(image, 36, 14, 8, 24, Draw.pal("paper"))
	Draw.rect(image, 148, 14, 8, 24, Draw.pal("paper"))
	Frames._fascia_glass(image, 48, 16, 96, 16)
	Draw.rect(image, 18, 116, 12, 4, Draw.pal("moss"))
	return Draw.outline(image)


static func build_pharmacy() -> Image:
	var image := Draw.canvas(176, 128)
	Frames._roof_box(image, 6, 16, 164, 22, Draw.pal("carpet"), Draw.pal("carpet_d"), Draw.pal("carpet_l"))
	Draw.rect(image, 10, 38, 156, 80, Draw.pal("cream"))
	Draw.rect(image, 10, 38, 156, 8, Draw.pal("paper"))
	Draw.rect(image, 10, 108, 156, 12, Draw.pal("brick"))
	Frames._awning(image, 18, 48, 140, 14, Draw.pal("carpet_l"), Draw.pal("paper"))
	Frames._window(image, 18, 66, 36, 28)
	Frames._window(image, 122, 66, 36, 28)
	Frames._door(image, 70, 78, 36, 42)
	Frames._transom(image, 70, 64, 36)
	Frames._window_goods(image, 22, 72, 0)
	Frames._window_goods(image, 126, 72, 1)
	Draw.px(image, 48, 100, Draw.pal("flower"))
	Draw.px(image, 132, 100, Draw.pal("leaf"))
	return Draw.outline(image)


static func build_thrift() -> Image:
	var image := Draw.canvas(160, 128)
	Frames._roof_box(image, 6, 18, 148, 20, Draw.pal("wood"), Draw.pal("wood_d"), Draw.pal("wood_l"))
	Draw.rect(image, 10, 38, 140, 80, Draw.pal("plaster"))
	Draw.rect(image, 10, 38, 140, 8, Draw.pal("cream"))
	Draw.rect(image, 10, 108, 140, 12, Draw.pal("wood_d"))
	Frames._window(image, 16, 62, 32, 28)
	Frames._window(image, 112, 62, 32, 28)
	Draw.rect(image, 20, 72, 10, 8, Draw.pal("shirt"))
	Draw.rect(image, 116, 74, 12, 6, Draw.pal("carpet"))
	Frames._door(image, 64, 78, 32, 42)
	Frames._transom(image, 64, 64, 32)
	Draw.rect(image, 10, 38, 140, 4, Draw.pal("wood"))
	Draw.rect(image, 16, 116, 10, 3, Draw.pal("moss"))
	return Draw.outline(image)


static func build_feed_store() -> Image:
	var image := Draw.canvas(192, 128)
	Frames._roof_box(image, 8, 16, 176, 22, Draw.pal("roof"), Draw.pal("roof_d"), Draw.pal("roof_l"))
	Draw.rect(image, 12, 38, 168, 80, Draw.pal("wood"))
	Draw.rect(image, 12, 38, 168, 8, Draw.pal("wood_l"))
	Draw.rect(image, 12, 108, 168, 12, Draw.pal("wood_d"))
	Frames._window(image, 20, 62, 36, 28)
	Draw.rect(image, 140, 58, 28, 48, Draw.pal("wood_d"))
	Draw.rect(image, 144, 64, 20, 16, Draw.pal("path"))
	Draw.rect(image, 144, 84, 20, 16, Draw.pal("path_d"))
	Frames._door(image, 80, 78, 36, 42)
	Frames._transom(image, 80, 64, 36)
	Draw.rect(image, 56, 16, 80, 18, Draw.pal("wood_d"))
	Draw.rect(image, 60, 20, 28, 10, Draw.pal("path"))
	Draw.rect(image, 92, 20, 28, 10, Draw.pal("path_d"))
	Draw.rect(image, 124, 20, 8, 10, Draw.pal("wood"))
	Draw.rect(image, 18, 116, 14, 4, Draw.pal("moss"))
	return Draw.outline(image)


static func build_town_hall() -> Image:
	var image := Draw.canvas(208, 128)
	Frames._roof_box(image, 8, 12, 192, 26, Draw.pal("roof_d"), Draw.pal("outline"), Draw.pal("roof"))
	Draw.rect(image, 96, 4, 16, 18, Draw.pal("cream"))
	Draw.rect(image, 100, 0, 8, 8, Draw.pal("roof_d"))
	Draw.rect(image, 14, 38, 180, 80, Draw.pal("brick"))
	for y in range(42, 110, 8):
		Draw.rect(image, 14, y, 180, 1, Draw.pal("brick_d"))
		for x in range(18 + (int(y / 8) % 2) * 8, 190, 16):
			Draw.rect(image, x, y, 1, 8, Draw.pal("brick_d"))
	Draw.rect(image, 14, 38, 180, 6, Draw.pal("brick_l"))
	Frames._window(image, 28, 60, 32, 28)
	Frames._window(image, 148, 60, 32, 28)
	Frames._door(image, 86, 74, 40, 46)
	Frames._transom(image, 86, 60, 40)
	Draw.rect(image, 70, 14, 16, 22, Draw.pal("cream"))
	Draw.rect(image, 122, 14, 16, 22, Draw.pal("cream"))
	Draw.rect(image, 92, 16, 24, 18, Draw.pal("wood_d"))
	Draw.rect(image, 96, 20, 16, 10, Draw.pal("glass"))
	Draw.px(image, 104, 24, Draw.pal("gold"))
	Draw.rect(image, 20, 114, 12, 4, Draw.pal("moss"))
	return Draw.outline(image)


static func build_boarded_shop() -> Image:
	var image := Draw.canvas(160, 128)
	Frames._roof_box(image, 6, 18, 148, 20, Draw.pal("grey_d"), Draw.pal("outline"), Draw.pal("grey"))
	Draw.rect(image, 10, 38, 140, 80, Draw.pal("plaster_d"))
	Draw.rect(image, 10, 38, 140, 6, Draw.pal("cream_s"))
	Draw.rect(image, 10, 108, 140, 12, Draw.pal("wood_d"))
	Draw.rect(image, 18, 58, 36, 32, Draw.pal("wood_d"))
	Draw.rect(image, 22, 62, 12, 24, Draw.pal("wood"))
	Draw.rect(image, 36, 62, 12, 24, Draw.pal("wood"))
	Draw.rect(image, 106, 58, 36, 32, Draw.pal("wood_d"))
	Draw.rect(image, 110, 62, 12, 24, Draw.pal("wood"))
	Draw.rect(image, 124, 62, 12, 24, Draw.pal("wood"))
	Frames._door(image, 64, 78, 32, 42)
	Draw.rect(image, 68, 82, 24, 22, Draw.pal("wood"))
	Draw.rect(image, 20, 16, 120, 10, Draw.pal("grey_d"))
	Draw.rect(image, 28, 18, 40, 6, Draw.pal("wood"))
	Draw.rect(image, 76, 18, 40, 6, Draw.pal("wood_d"))
	Draw.crack(image, 40, 90, 8, Draw.pal("cream_s"))
	Draw.rect(image, 16, 116, 14, 4, Draw.pal("moss"))
	return Draw.outline(image)


static func build_house(variant: int, door_east: bool) -> Image:
	var image := Draw.canvas(144, 96)
	var roof: Color = Draw.pal("roof")
	var roof_d: Color = Draw.pal("roof_d")
	var wall: Color = Draw.pal("cream")
	var wall_d: Color = Draw.pal("cream_d")
	var trim: Color = Draw.pal("paper")
	var base: Color = Draw.pal("brick")
	match variant:
		1:
			roof = Draw.pal("grey")
			roof_d = Draw.pal("grey_d")
			wall = Draw.pal("brick")
			wall_d = Draw.pal("brick_d")
			trim = Draw.pal("cream")
			base = Draw.pal("path_c")
		2:
			roof = Draw.pal("wood_d")
			roof_d = Draw.pal("outline")
			wall = Draw.pal("wood")
			wall_d = Draw.pal("wood_d")
			trim = Draw.pal("wood_l")
			base = Draw.pal("wood_d")
		3:
			roof = Draw.pal("path_d")
			roof_d = Draw.pal("path_c")
			wall = Draw.pal("cardigan")
			wall_d = Draw.pal("cardigan_d")
			trim = Draw.pal("cream")
			base = Draw.pal("brick")
		4:
			roof = Draw.pal("shirt_d")
			roof_d = Draw.pal("outline")
			wall = Draw.pal("cream")
			wall_d = Draw.pal("cream_d")
			trim = Draw.pal("paper")
			base = Draw.pal("brick")
		5:
			roof = Draw.pal("roof")
			roof_d = Draw.pal("roof_d")
			wall = Draw.pal("brick")
			wall_d = Draw.pal("brick_d")
			trim = Draw.pal("brick_l")
			base = Draw.pal("path_c")
	for y in range(6, 40):
		var inset: int = (40 - y) / 3
		var tone: Color = roof if (y / 4) % 2 == 0 else roof_d
		Draw.rect(image, inset, y, 144 - inset * 2, 1, tone)
	Draw.rect(image, 16, 40, 112, 48, wall)
	Draw.rect(image, 16, 40, 112, 6, trim)
	Draw.rect(image, 16, 80, 112, 12, base)
	if variant == 4:
		Draw.rect(image, 110, 8, 10, 28, Draw.pal("brick"))
		Draw.rect(image, 108, 6, 14, 6, Draw.pal("brick_d"))
	var door_x := 96 if door_east else 20
	var window_x := 24 if door_east else 88
	Frames._window(image, window_x, 50, 28, 22)
	if variant == 2 or variant == 0:
		Draw.rect(image, door_x - 6, 70, 40, 8, Draw.pal("wood_d"))
		Draw.px(image, door_x, 68, Draw.pal("flower"))
		Draw.px(image, door_x + 8, 67, Draw.pal("leaf"))
	Frames._door(image, door_x, 58, 28, 34)
	if variant == 5 or variant == 3:
		Draw.rect(image, window_x - 2, 72, 32, 6, Draw.pal("wood"))
		Draw.px(image, window_x + 4, 70, Draw.pal("flower"))
		Draw.px(image, window_x + 14, 69, Draw.pal("flower2"))
		Draw.px(image, window_x + 22, 70, Draw.pal("leaf"))
	Draw.rect(image, 20, 88, 10, 3, Draw.pal("moss"))
	return Draw.outline(image)


static func build_hanging_sign(text: String, variant: int) -> Image:
	var image := Draw.canvas(128, 32)
	var back: Color = Draw.pal("wood_d")
	var face: Color = Draw.pal("cream")
	var ink: Color = Draw.pal("wood_d")
	match variant % 4:
		1:
			back = Draw.pal("shirt_d")
			face = Draw.pal("shirt")
			ink = Draw.pal("paper")
		2:
			back = Draw.pal("carpet_d")
			face = Draw.pal("lamp")
			ink = Draw.pal("wood_d")
		3:
			back = Draw.pal("grey_d")
			face = Draw.pal("grey")
			ink = Draw.pal("paper")
	Draw.rect(image, 4, 2, 4, 28, Draw.pal("wood_d"))
	Draw.rect(image, 120, 2, 4, 28, Draw.pal("wood_d"))
	Draw.rect(image, 6, 6, 116, 20, back)
	Draw.rect(image, 8, 8, 112, 16, face)
	var letter_w := 7 * 2
	var content_w := 0
	for i in text.length():
		content_w += 8 if text.substr(i, 1) == " " else letter_w
	var text_x := 10 + maxi(0, int((108 - content_w) / 2))
	Frames._stamp_text(image, text, text_x, 10, ink, 2)
	return Draw.outline(image)


static func build_newspaper_box() -> Image:
	var image := Draw.canvas(16, 24)
	Draw.rect(image, 3, 8, 10, 14, Draw.pal("shirt_d"))
	Draw.rect(image, 4, 10, 8, 8, Draw.pal("glass_d"))
	Draw.rect(image, 5, 12, 6, 4, Draw.pal("paper"))
	Draw.rect(image, 3, 6, 10, 3, Draw.pal("shirt"))
	Draw.px(image, 7, 13, Draw.pal("wood_d"))
	return Draw.outline(image)


static func build_bike_rack() -> Image:
	var image := Draw.canvas(40, 20)
	Draw.rect(image, 4, 14, 32, 3, Draw.pal("grey_d"))
	Draw.rect(image, 8, 6, 3, 12, Draw.pal("grey"))
	Draw.rect(image, 18, 6, 3, 12, Draw.pal("grey"))
	Draw.rect(image, 28, 6, 3, 12, Draw.pal("grey"))
	Draw.rect(image, 10, 8, 10, 3, Draw.pal("shirt_d"))
	Draw.rect(image, 12, 4, 6, 6, Draw.pal("grey_d"))
	Draw.rect(image, 22, 8, 10, 3, Draw.pal("brick"))
	Draw.rect(image, 24, 4, 6, 6, Draw.pal("grey_d"))
	return Draw.outline(image)


static func build_flower_box() -> Image:
	var image := Draw.canvas(24, 16)
	Draw.rect(image, 2, 8, 20, 6, Draw.pal("wood"))
	Draw.rect(image, 2, 8, 20, 2, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 16, 3, Draw.pal("path_c"))
	Draw.px(image, 6, 6, Draw.pal("flower"))
	Draw.px(image, 10, 5, Draw.pal("leaf"))
	Draw.px(image, 14, 6, Draw.pal("flower2"))
	Draw.px(image, 18, 5, Draw.pal("flower"))
	return Draw.outline(image)


static func build_swing_set() -> Image:
	var image := Draw.canvas(48, 40)
	Draw.rect(image, 6, 8, 4, 28, Draw.pal("grey_d"))
	Draw.rect(image, 38, 8, 4, 28, Draw.pal("grey_d"))
	Draw.rect(image, 6, 8, 36, 3, Draw.pal("grey"))
	Draw.rect(image, 14, 11, 2, 16, Draw.pal("path_c"))
	Draw.rect(image, 32, 11, 2, 16, Draw.pal("path_c"))
	Draw.rect(image, 12, 26, 8, 4, Draw.pal("wood"))
	Draw.rect(image, 30, 26, 8, 4, Draw.pal("wood"))
	Draw.rect(image, 4, 34, 8, 3, Draw.pal("path_c"))
	Draw.rect(image, 36, 34, 8, 3, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_kids_bike() -> Image:
	var image := Draw.canvas(24, 16)
	Draw.rect(image, 3, 8, 6, 6, Draw.pal("grey_d"))
	Draw.rect(image, 15, 8, 6, 6, Draw.pal("grey_d"))
	Draw.rect(image, 6, 6, 12, 3, Draw.pal("shirt"))
	Draw.rect(image, 10, 3, 3, 6, Draw.pal("shirt_d"))
	Draw.px(image, 16, 4, Draw.pal("flower"))
	return Draw.outline(image)


static func build_hose() -> Image:
	var image := Draw.canvas(28, 12)
	Draw.rect(image, 2, 6, 20, 3, Draw.pal("leaf_d"))
	Draw.rect(image, 20, 4, 6, 6, Draw.pal("leaf"))
	Draw.rect(image, 2, 4, 4, 6, Draw.pal("grey_d"))
	return Draw.outline(image)


static func build_dog_house() -> Image:
	var image := Draw.canvas(32, 28)
	for y in range(2, 12):
		var inset: int = (12 - y) / 2
		Draw.rect(image, inset, y, 32 - inset * 2, 1, Draw.pal("roof") if y % 2 == 0 else Draw.pal("roof_d"))
	Draw.rect(image, 4, 12, 24, 14, Draw.pal("wood"))
	Draw.rect(image, 12, 16, 8, 10, Draw.pal("outline"))
	Draw.rect(image, 6, 24, 20, 3, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_rocking_chair() -> Image:
	var image := Draw.canvas(16, 24)
	Draw.rect(image, 3, 8, 10, 8, Draw.pal("wood"))
	Draw.rect(image, 3, 6, 10, 3, Draw.pal("wood_l"))
	Draw.rect(image, 2, 16, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 11, 16, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 1, 20, 14, 2, Draw.pal("wood_d"))
	return Draw.outline(image)


static func build_picket_fence() -> Image:
	var image := Draw.canvas(64, 32)
	Draw.rect(image, 2, 14, 60, 3, Draw.pal("paper"))
	Draw.rect(image, 2, 22, 60, 3, Draw.pal("paper"))
	for x in range(4, 60, 8):
		Draw.rect(image, x, 8, 4, 20, Draw.pal("cream"))
		Draw.px(image, x + 1, 6, Draw.pal("cream"))
		Draw.px(image, x + 2, 6, Draw.pal("cream"))
		Draw.rect(image, x, 26, 4, 4, Draw.pal("wood_d"))
	return Draw.outline(image)


static func build_garden_shed(variant: int) -> Image:
	var image := Draw.canvas(48, 40)
	var wall: Color = Draw.pal("wood") if variant % 2 == 0 else Draw.pal("grey")
	var wall_d: Color = Draw.pal("wood_d") if variant % 2 == 0 else Draw.pal("grey_d")
	var roof: Color = Draw.pal("roof") if variant % 3 != 1 else Draw.pal("path_d")
	for y in range(2, 14):
		var inset: int = (14 - y) / 2
		Draw.rect(image, inset, y, 48 - inset * 2, 1, roof if y % 2 == 0 else Draw.pal("roof_d"))
	Draw.rect(image, 6, 14, 36, 22, wall)
	Draw.rect(image, 6, 14, 36, 3, wall_d)
	Draw.rect(image, 18, 20, 12, 16, Draw.pal("outline"))
	Draw.rect(image, 20, 22, 8, 12, wall_d)
	Draw.px(image, 26, 28, Draw.pal("gold"))
	if variant % 2 == 1:
		Draw.rect(image, 8, 18, 8, 6, Draw.pal("glass_d"))
	Draw.rect(image, 8, 34, 32, 4, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_hedge_bush(variant: int) -> Image:
	var image := Draw.canvas(32, 24)
	var leaf: Color = Draw.pal("leaf") if variant % 2 == 0 else Draw.pal("moss")
	var dark: Color = Draw.pal("leaf_d")
	Draw.rect(image, 4, 10, 24, 12, leaf)
	Draw.rect(image, 8, 6, 16, 10, leaf)
	Draw.rect(image, 6, 18, 20, 4, dark)
	Draw.px(image, 10, 8, Draw.pal("leaf_l") if variant % 3 == 0 else Draw.pal("flower"))
	Draw.px(image, 18, 7, Draw.pal("leaf_l"))
	if variant % 2 == 1:
		Draw.px(image, 22, 12, Draw.pal("flower2"))
	return Draw.outline(image)


static func build_for_sale_sign() -> Image:
	var image := Draw.canvas(48, 40)
	Draw.rect(image, 22, 18, 4, 20, Draw.pal("wood_d"))
	Draw.rect(image, 4, 2, 40, 22, Draw.pal("paper"))
	Draw.rect(image, 6, 4, 36, 18, Draw.pal("shirt"))
	Frames._stamp_text(image, "FOR", 14, 6, Draw.pal("paper"), 1)
	Frames._stamp_text(image, "SALE", 10, 14, Draw.pal("paper"), 1)
	Draw.rect(image, 20, 36, 8, 3, Draw.pal("path_c"))
	return Draw.outline(image)


static func build_dog() -> Image:
	var image := Draw.canvas(20, 16)
	Draw.rect(image, 4, 8, 12, 5, Draw.pal("wood"))
	Draw.rect(image, 12, 4, 6, 6, Draw.pal("wood_l"))
	Draw.rect(image, 2, 10, 3, 3, Draw.pal("wood_d"))
	Draw.rect(image, 14, 10, 3, 3, Draw.pal("wood_d"))
	Draw.px(image, 16, 6, Draw.pal("outline"))
	Draw.px(image, 4, 9, Draw.pal("wood_d"))
	return Draw.outline(image)
