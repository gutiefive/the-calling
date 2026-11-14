class_name InteriorHallFrames
extends RefCounted
## Fellowship Hall polish frames: larger tables, rugs with fringe, and room zones.

const Draw := preload("res://scripts/art/pixel_draw.gd")


static func build(frame_id: String) -> Image:
	match frame_id:
		"long_table_runner":
			return _long_table(true)
		"hall_chair_back":
			return _chair_back()
		"hall_chair_front":
			return _chair_front()
		"rug_aisle_runner":
			return _aisle_runner()
		"rug_stage":
			return _rug_fringe(88, 52, "shirt_d", "shirt", "gold")
		"rug_sitting":
			return _rug_fringe(80, 52, "brick", "carpet", "gold")
		"rug_class_pattern":
			return _class_rug()
		"rug_hallway":
			return _hallway_runner()
		"flower_vase":
			return _flower_vase()
		"hymnal_stack":
			return _hymnal_stack()
		"card_game":
			return _card_game()
		"clipboard":
			return _clipboard()
		"laptop":
			return _laptop()
		"donut_box":
			return _donut_box()
		"cup_stack":
			return _cup_stack()
		"coffee_urn":
			return _coffee_urn()
		"couch":
			return _couch()
		"floor_lamp":
			return _floor_lamp()
		"mic_stand":
			return _mic_stand()
		"pa_speaker":
			return _pa_speaker()
		"trophy_shelf":
			return _trophy_shelf()
		"photo_wall":
			return _photo_wall()
		"folded_table_rack":
			return _folded_table_rack()
		"alphabet_strip":
			return _alphabet_strip()
		"hanging_utensils":
			return _hanging_utensils()
		"backsplash":
			return _backsplash()
		"kitchen_window":
			return _kitchen_window()
		"meal_train":
			return _meal_train()
		"labeled_bin":
			return _labeled_bin()
		"window_pool":
			return _window_pool()
		"kids_easel":
			return _kids_easel()
		"toy_blocks":
			return _toy_blocks()
		"snack_counter":
			return _snack_counter()
		_:
			return null


static func _long_table(runner: bool) -> Image:
	var image := Draw.canvas(128, 56)
	Draw.rect(image, 12, 48, 104, 6, Draw.pal("path_c"))
	Draw.rect(image, 16, 34, 8, 18, Draw.pal("wood_d"))
	Draw.rect(image, 104, 34, 8, 18, Draw.pal("wood_d"))
	Draw.rect(image, 36, 36, 6, 16, Draw.pal("wood_d"))
	Draw.rect(image, 86, 36, 6, 16, Draw.pal("wood_d"))
	Draw.rect(image, 6, 26, 116, 12, Draw.pal("wood_d"))
	Draw.rect(image, 6, 22, 116, 8, Draw.pal("wood"))
	Draw.rect(image, 8, 10, 112, 18, Draw.pal("paper"))
	Draw.rect(image, 8, 10, 112, 3, Draw.pal("cream"))
	Draw.rect(image, 40, 12, 1, 14, Draw.pal("cream_d"))
	Draw.rect(image, 88, 13, 1, 12, Draw.pal("cream_d"))
	Draw.rect(image, 8, 26, 112, 2, Draw.pal("cream_d"))
	Draw.rect(image, 8, 28, 112, 3, Draw.pal("wood"))
	Draw.rect(image, 8, 28, 5, 7, Draw.pal("paper"))
	Draw.rect(image, 115, 28, 5, 7, Draw.pal("paper"))
	Draw.px(image, 10, 32, Draw.pal("cream_d"))
	Draw.px(image, 117, 32, Draw.pal("cream_d"))
	if runner:
		Draw.rect(image, 56, 11, 16, 16, Draw.pal("flower"))
		Draw.rect(image, 58, 12, 12, 14, Draw.pal("flower2"))
		Draw.rect(image, 62, 14, 4, 10, Draw.pal("gold"))
	return Draw.outline(image)


static func _chair_back() -> Image:
	var image := Draw.canvas(20, 26)
	Draw.rect(image, 4, 18, 4, 7, Draw.pal("wood_d"))
	Draw.rect(image, 12, 18, 4, 7, Draw.pal("wood_d"))
	Draw.rect(image, 3, 22, 5, 2, Draw.pal("path_c"))
	Draw.rect(image, 12, 22, 5, 2, Draw.pal("path_c"))
	Draw.rect(image, 3, 14, 14, 6, Draw.pal("wood"))
	Draw.rect(image, 4, 2, 12, 14, Draw.pal("wood"))
	Draw.rect(image, 6, 4, 8, 10, Draw.pal("wood_l"))
	Draw.rect(image, 7, 6, 6, 2, Draw.pal("wood_d"))
	Draw.rect(image, 7, 10, 6, 2, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _chair_front() -> Image:
	var image := Draw.canvas(20, 22)
	Draw.rect(image, 4, 14, 4, 7, Draw.pal("wood_d"))
	Draw.rect(image, 12, 14, 4, 7, Draw.pal("wood_d"))
	Draw.rect(image, 3, 18, 5, 2, Draw.pal("path_c"))
	Draw.rect(image, 12, 18, 5, 2, Draw.pal("path_c"))
	Draw.rect(image, 3, 8, 14, 8, Draw.pal("wood_l"))
	Draw.rect(image, 4, 9, 12, 5, Draw.pal("cream"))
	Draw.rect(image, 5, 2, 10, 8, Draw.pal("wood"))
	Draw.rect(image, 7, 3, 6, 5, Draw.pal("wood_l"))
	return Draw.outline(image)


static func _aisle_runner() -> Image:
	var image := Draw.canvas(56, 360)
	Draw.rect(image, 6, 8, 44, 344, Draw.pal("carpet_d"))
	Draw.rect(image, 10, 12, 36, 336, Draw.pal("carpet"))
	for y in range(12, 348, 16):
		Draw.rect(image, 10, y, 36, 2, Draw.pal("carpet_d"))
		Draw.px(image, 12, y + 4, Draw.pal("gold"))
		Draw.px(image, 42, y + 4, Draw.pal("gold"))
	Draw.rect(image, 6, 8, 44, 4, Draw.pal("gold"))
	Draw.rect(image, 6, 348, 44, 4, Draw.pal("gold"))
	Draw.rect(image, 6, 8, 3, 344, Draw.pal("gold"))
	Draw.rect(image, 47, 8, 3, 344, Draw.pal("gold"))
	for x in range(8, 48, 3):
		Draw.px(image, x, 4, Draw.pal("gold"))
		Draw.px(image, x, 5, Draw.pal("cream_d"))
		Draw.px(image, x, 354, Draw.pal("gold"))
		Draw.px(image, x, 355, Draw.pal("cream_d"))
	Draw.speckle(image, 17, 210, 255, Draw.pal("carpet_l"))
	return Draw.outline(image)


static func _rug_fringe(w: int, h: int, field: String, inner: String, edge: String) -> Image:
	var image := Draw.canvas(w, h)
	Draw.rect(image, 4, 6, w - 8, h - 12, Draw.pal(field))
	Draw.rect(image, 8, 10, w - 16, h - 20, Draw.pal(inner))
	Draw.rect(image, 4, 6, w - 8, 3, Draw.pal(edge))
	Draw.rect(image, 4, h - 9, w - 8, 3, Draw.pal(edge))
	Draw.rect(image, 4, 6, 3, h - 12, Draw.pal(edge))
	Draw.rect(image, w - 7, 6, 3, h - 12, Draw.pal(edge))
	for x in range(6, w - 6, 4):
		Draw.px(image, x, 8, Draw.pal(inner))
		Draw.px(image, x + 1, h - 8, Draw.pal(field))
		Draw.px(image, x, 2, Draw.pal(edge))
		Draw.px(image, x, 3, Draw.pal(field))
		Draw.px(image, x, h - 3, Draw.pal(edge))
		Draw.px(image, x, h - 4, Draw.pal(field))
	Draw.speckle(image, 23, 200, 255, Draw.pal(inner))
	return Draw.outline(image)


static func _class_rug() -> Image:
	var image := _rug_fringe(72, 52, "flower2", "carpet", "gold")
	for y in range(14, 40, 8):
		for x in range(14, 58, 8):
			var tone := "gold" if ((x + y) % 16) == 0 else "flower"
			Draw.rect(image, x, y, 4, 4, Draw.pal(tone))
	return image


static func _hallway_runner() -> Image:
	var image := Draw.canvas(280, 28)
	Draw.rect(image, 8, 6, 264, 16, Draw.pal("brick"))
	Draw.rect(image, 12, 8, 256, 12, Draw.pal("carpet"))
	Draw.rect(image, 8, 6, 264, 2, Draw.pal("gold"))
	Draw.rect(image, 8, 20, 264, 2, Draw.pal("gold"))
	for x in range(12, 268, 4):
		Draw.px(image, x, 3, Draw.pal("gold"))
		Draw.px(image, x, 24, Draw.pal("gold"))
	return Draw.outline(image)


static func _flower_vase() -> Image:
	var image := Draw.canvas(14, 20)
	Draw.rect(image, 4, 12, 6, 6, Draw.pal("glass"))
	Draw.rect(image, 5, 10, 4, 4, Draw.pal("glass_h"))
	Draw.px(image, 6, 6, Draw.pal("leaf_l"))
	Draw.px(image, 7, 5, Draw.pal("leaf"))
	Draw.px(image, 8, 4, Draw.pal("flower"))
	Draw.px(image, 6, 4, Draw.pal("flower2"))
	Draw.px(image, 9, 6, Draw.pal("gold"))
	Draw.px(image, 5, 7, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _hymnal_stack() -> Image:
	var image := Draw.canvas(16, 14)
	Draw.rect(image, 2, 8, 12, 4, Draw.pal("brick"))
	Draw.rect(image, 3, 5, 11, 4, Draw.pal("pants_d"))
	Draw.rect(image, 4, 2, 10, 4, Draw.pal("cardigan"))
	Draw.rect(image, 5, 3, 6, 1, Draw.pal("gold"))
	return Draw.outline(image)


static func _card_game() -> Image:
	var image := Draw.canvas(22, 16)
	Draw.rect(image, 2, 3, 18, 11, Draw.pal("shirt"))
	Draw.rect(image, 4, 5, 14, 7, Draw.pal("paper"))
	Draw.rect(image, 6, 6, 4, 5, Draw.pal("flower"))
	Draw.rect(image, 12, 7, 4, 5, Draw.pal("leaf_l"))
	Draw.px(image, 8, 8, Draw.pal("gold"))
	return Draw.outline(image)


static func _clipboard() -> Image:
	var image := Draw.canvas(14, 16)
	Draw.rect(image, 2, 3, 10, 12, Draw.pal("wood"))
	Draw.rect(image, 3, 4, 8, 10, Draw.pal("paper"))
	Draw.rect(image, 5, 1, 4, 3, Draw.pal("grey_d"))
	Draw.rect(image, 4, 6, 6, 1, Draw.pal("path_c"))
	Draw.rect(image, 4, 9, 5, 1, Draw.pal("path_c"))
	Draw.rect(image, 4, 12, 4, 1, Draw.pal("brick"))
	return Draw.outline(image)


static func _laptop() -> Image:
	var image := Draw.canvas(20, 14)
	Draw.rect(image, 2, 8, 16, 4, Draw.pal("grey_d"))
	Draw.rect(image, 4, 2, 12, 8, Draw.pal("pants_d"))
	Draw.rect(image, 5, 3, 10, 6, Draw.pal("glass"))
	Draw.px(image, 10, 10, Draw.pal("grey"))
	return Draw.outline(image)


static func _donut_box() -> Image:
	var image := Draw.canvas(24, 16)
	Draw.rect(image, 2, 4, 20, 10, Draw.pal("paper"))
	Draw.rect(image, 2, 4, 20, 3, Draw.pal("cream"))
	Draw.ellipse(image, 8, 10, 3, 2, Draw.pal("gold"))
	Draw.ellipse(image, 16, 10, 3, 2, Draw.pal("flower"))
	Draw.px(image, 8, 9, Draw.pal("cream"))
	Draw.px(image, 16, 9, Draw.pal("cream"))
	return Draw.outline(image)


static func _cup_stack() -> Image:
	var image := Draw.canvas(14, 16)
	Draw.rect(image, 3, 10, 8, 4, Draw.pal("paper"))
	Draw.rect(image, 4, 7, 6, 4, Draw.pal("cream"))
	Draw.rect(image, 5, 4, 4, 4, Draw.pal("paper"))
	Draw.px(image, 11, 8, Draw.pal("cream"))
	return Draw.outline(image)


static func _coffee_urn() -> Image:
	var image := Draw.canvas(18, 24)
	Draw.rect(image, 4, 8, 10, 14, Draw.pal("grey_d"))
	Draw.rect(image, 5, 10, 8, 8, Draw.pal("grey"))
	Draw.rect(image, 6, 4, 6, 6, Draw.pal("grey"))
	Draw.rect(image, 14, 14, 3, 4, Draw.pal("gold"))
	Draw.px(image, 8, 12, Draw.pal("lamp"))
	return Draw.outline(image)


static func _couch() -> Image:
	var image := Draw.canvas(56, 28)
	Draw.rect(image, 6, 12, 44, 10, Draw.pal("cardigan"))
	Draw.rect(image, 8, 8, 18, 10, Draw.pal("skirt"))
	Draw.rect(image, 28, 8, 18, 10, Draw.pal("skirt"))
	Draw.rect(image, 2, 10, 8, 12, Draw.pal("cardigan"))
	Draw.rect(image, 46, 10, 8, 12, Draw.pal("cardigan"))
	Draw.rect(image, 8, 22, 6, 5, Draw.pal("wood_d"))
	Draw.rect(image, 42, 22, 6, 5, Draw.pal("wood_d"))
	Draw.rect(image, 6, 12, 44, 2, Draw.pal("cream_d"))
	return Draw.outline(image)


static func _floor_lamp() -> Image:
	var image := Draw.canvas(16, 40)
	Draw.rect(image, 7, 16, 2, 20, Draw.pal("grey_d"))
	Draw.rect(image, 4, 34, 8, 4, Draw.pal("wood_d"))
	Draw.rect(image, 3, 4, 10, 14, Draw.pal("lamp"))
	Draw.rect(image, 5, 6, 6, 10, Draw.pal("paper"))
	Draw.px(image, 8, 8, Draw.pal("gold"))
	return Draw.outline(image)


static func _mic_stand() -> Image:
	var image := Draw.canvas(14, 36)
	Draw.rect(image, 6, 10, 2, 22, Draw.pal("grey_d"))
	Draw.rect(image, 3, 32, 8, 3, Draw.pal("grey"))
	Draw.rect(image, 5, 4, 4, 8, Draw.pal("grey"))
	Draw.rect(image, 6, 2, 2, 4, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _pa_speaker() -> Image:
	var image := Draw.canvas(20, 28)
	Draw.rect(image, 3, 4, 14, 20, Draw.pal("pants_d"))
	Draw.ellipse(image, 10, 12, 5, 5, Draw.pal("grey"))
	Draw.ellipse(image, 10, 20, 3, 3, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _trophy_shelf() -> Image:
	var image := Draw.canvas(48, 32)
	Draw.rect(image, 2, 6, 44, 22, Draw.pal("wood_d"))
	Draw.rect(image, 4, 8, 40, 8, Draw.pal("wood"))
	Draw.rect(image, 4, 18, 40, 8, Draw.pal("wood"))
	Draw.rect(image, 8, 10, 6, 6, Draw.pal("gold"))
	Draw.rect(image, 20, 10, 6, 6, Draw.pal("grey"))
	Draw.rect(image, 32, 10, 6, 6, Draw.pal("gold"))
	Draw.rect(image, 10, 20, 8, 5, Draw.pal("paper"))
	Draw.rect(image, 26, 20, 8, 5, Draw.pal("paper"))
	return Draw.outline(image)


static func _photo_wall() -> Image:
	var image := Draw.canvas(52, 28)
	Draw.rect(image, 2, 4, 14, 18, Draw.pal("wood"))
	Draw.rect(image, 4, 6, 10, 14, Draw.pal("glass"))
	Draw.rect(image, 18, 6, 14, 16, Draw.pal("wood_d"))
	Draw.rect(image, 20, 8, 10, 12, Draw.pal("cream"))
	Draw.rect(image, 34, 4, 14, 18, Draw.pal("wood"))
	Draw.rect(image, 36, 6, 10, 14, Draw.pal("glass"))
	Draw.rect(image, 6, 12, 6, 6, Draw.pal("cardigan"))
	Draw.rect(image, 38, 12, 6, 6, Draw.pal("shirt"))
	return Draw.outline(image)


static func _folded_table_rack() -> Image:
	var image := Draw.canvas(36, 40)
	Draw.rect(image, 4, 8, 28, 26, Draw.pal("grey_d"))
	Draw.rect(image, 6, 10, 24, 4, Draw.pal("wood"))
	Draw.rect(image, 8, 16, 24, 4, Draw.pal("wood_l"))
	Draw.rect(image, 6, 22, 24, 4, Draw.pal("wood"))
	Draw.rect(image, 8, 28, 24, 4, Draw.pal("grey"))
	Draw.rect(image, 4, 34, 6, 4, Draw.pal("pants_d"))
	Draw.rect(image, 26, 34, 6, 4, Draw.pal("pants_d"))
	return Draw.outline(image)


static func _alphabet_strip() -> Image:
	var image := Draw.canvas(120, 16)
	Draw.rect(image, 2, 2, 116, 12, Draw.pal("paper"))
	var tones: PackedStringArray = ["flower", "gold", "shirt", "leaf_l", "brick", "cardigan"]
	for i in 10:
		var tone := tones[i % tones.size()]
		Draw.rect(image, 6 + i * 11, 4, 8, 8, Draw.pal(tone))
		Draw.rect(image, 8 + i * 11, 6, 4, 4, Draw.pal("paper"))
	return Draw.outline(image)


static func _hanging_utensils() -> Image:
	var image := Draw.canvas(28, 24)
	Draw.rect(image, 2, 4, 24, 3, Draw.pal("wood_d"))
	Draw.rect(image, 6, 8, 3, 12, Draw.pal("grey"))
	Draw.rect(image, 12, 8, 3, 10, Draw.pal("grey_d"))
	Draw.rect(image, 18, 8, 4, 12, Draw.pal("wood"))
	Draw.rect(image, 5, 18, 5, 3, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _backsplash() -> Image:
	var image := Draw.canvas(96, 20)
	for y in range(0, 20, 5):
		for x in range(0, 96, 8):
			var ox := 0 if (y % 10) == 0 else 4
			Draw.rect(image, x + ox, y, 7, 4, Draw.pal("cream"))
			Draw.rect(image, x + ox + 1, y + 1, 5, 2, Draw.pal("paper"))
	return Draw.outline(image)


static func _kitchen_window() -> Image:
	var image := Draw.canvas(32, 28)
	Draw.rect(image, 2, 2, 28, 24, Draw.pal("wood_d"))
	Draw.rect(image, 4, 4, 24, 20, Draw.pal("glass"))
	Draw.rect(image, 15, 4, 2, 20, Draw.pal("wood"))
	Draw.rect(image, 4, 13, 24, 2, Draw.pal("wood"))
	Draw.rect(image, 6, 6, 8, 6, Draw.pal("glass_h"))
	return Draw.outline(image)


static func _meal_train() -> Image:
	var image := Draw.canvas(28, 32)
	Draw.rect(image, 2, 2, 24, 28, Draw.pal("wood_d"))
	Draw.rect(image, 4, 4, 20, 24, Draw.pal("path"))
	Draw.rect(image, 6, 6, 16, 6, Draw.pal("paper"))
	Draw.rect(image, 6, 14, 16, 5, Draw.pal("cream"))
	Draw.rect(image, 6, 21, 16, 5, Draw.pal("paper"))
	Draw.px(image, 8, 8, Draw.pal("brick"))
	Draw.px(image, 8, 16, Draw.pal("shirt"))
	Draw.px(image, 8, 23, Draw.pal("gold"))
	return Draw.outline(image)


static func _labeled_bin() -> Image:
	var image := Draw.canvas(28, 22)
	Draw.rect(image, 2, 6, 24, 14, Draw.pal("path_c"))
	Draw.rect(image, 2, 6, 24, 4, Draw.pal("path"))
	Draw.rect(image, 6, 10, 16, 5, Draw.pal("paper"))
	Draw.rect(image, 8, 12, 12, 1, Draw.pal("path_d"))
	Draw.rect(image, 12, 2, 4, 6, Draw.pal("path_d"))
	return Draw.outline(image)


static func _window_pool() -> Image:
	var image := Draw.canvas(48, 32)
	image.fill(Color(0, 0, 0, 0))
	Draw.ellipse(image, 24, 16, 18, 12, Color(220.0 / 255.0, 196.0 / 255.0, 120.0 / 255.0, 0.28))
	Draw.ellipse(image, 24, 16, 10, 7, Color(236.0 / 255.0, 216.0 / 255.0, 150.0 / 255.0, 0.22))
	return image


static func _kids_easel() -> Image:
	var image := Draw.canvas(24, 36)
	Draw.rect(image, 10, 16, 3, 16, Draw.pal("wood_d"))
	Draw.rect(image, 4, 28, 16, 3, Draw.pal("wood"))
	Draw.rect(image, 4, 6, 16, 16, Draw.pal("wood"))
	Draw.rect(image, 6, 8, 12, 12, Draw.pal("paper"))
	Draw.rect(image, 8, 12, 6, 6, Draw.pal("shirt"))
	Draw.px(image, 14, 10, Draw.pal("gold"))
	return Draw.outline(image)


static func _toy_blocks() -> Image:
	var image := Draw.canvas(20, 14)
	Draw.rect(image, 2, 6, 6, 6, Draw.pal("flower"))
	Draw.rect(image, 7, 4, 6, 8, Draw.pal("gold"))
	Draw.rect(image, 12, 7, 6, 5, Draw.pal("shirt"))
	return Draw.outline(image)


static func _snack_counter() -> Image:
	var image := Draw.canvas(72, 32)
	Draw.rect(image, 2, 14, 68, 14, Draw.pal("wood"))
	Draw.rect(image, 2, 14, 68, 4, Draw.pal("cream"))
	Draw.rect(image, 8, 4, 12, 12, Draw.pal("grey_d"))
	Draw.rect(image, 24, 8, 10, 8, Draw.pal("paper"))
	Draw.rect(image, 40, 8, 16, 8, Draw.pal("paper"))
	Draw.ellipse(image, 46, 12, 3, 2, Draw.pal("gold"))
	Draw.ellipse(image, 52, 12, 3, 2, Draw.pal("flower"))
	Draw.rect(image, 60, 10, 8, 6, Draw.pal("cream"))
	return Draw.outline(image)
