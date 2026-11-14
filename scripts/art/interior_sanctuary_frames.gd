class_name InteriorSanctuaryFrames
extends RefCounted
## Extra sanctuary furniture for the M13E gameplay polish pass.

const Draw := preload("res://scripts/art/pixel_draw.gd")


static func build(frame_id: String) -> Image:
	match frame_id:
		"offering_plates":
			return _offering_plates()
		"pendant_light":
			return _pendant_light()
		"church_flag":
			return _church_flag()
		"prayer_box":
			return _prayer_box()
		"diploma":
			return _diploma()
		"desk_phone":
			return _desk_phone()
		"prayer_cross":
			return _prayer_cross()
		"prayer_cushion":
			return _prayer_cushion()
		"journal_stand":
			return _journal_stand()
		"choir_riser":
			return _choir_riser()
		"practice_board":
			return _practice_board()
		"storage_ladder":
			return _storage_ladder()
		"baptistry":
			return _baptistry()
		"kids_play_rug":
			return _kids_play_rug()
		"kids_book_bin":
			return _kids_book_bin()
		"kids_wall_drawing":
			return _kids_wall_drawing()
		_:
			return null


static func _offering_plates() -> Image:
	var image := Draw.canvas(28, 16)
	Draw.ellipse(image, 8, 9, 7, 5, Draw.pal("gold"))
	Draw.ellipse(image, 8, 9, 4, 3, Draw.pal("wood_d"))
	Draw.ellipse(image, 18, 8, 7, 5, Draw.pal("gold"))
	Draw.ellipse(image, 18, 8, 4, 3, Draw.pal("wood"))
	return Draw.outline(image)


static func _pendant_light() -> Image:
	var image := Draw.canvas(18, 28)
	Draw.rect(image, 8, 2, 2, 8, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 10, 4, Draw.pal("gold"))
	Draw.rect(image, 5, 14, 8, 8, Draw.pal("lamp"))
	Draw.rect(image, 7, 16, 4, 4, Draw.pal("paper"))
	return Draw.outline(image)


static func _church_flag() -> Image:
	var image := Draw.canvas(20, 36)
	Draw.rect(image, 3, 2, 3, 32, Draw.pal("wood_d"))
	Draw.rect(image, 6, 4, 12, 16, Draw.pal("carpet_d"))
	Draw.rect(image, 7, 6, 10, 4, Draw.pal("gold"))
	Draw.rect(image, 8, 12, 8, 6, Draw.pal("cream"))
	Draw.px(image, 4, 2, Draw.pal("gold"))
	return Draw.outline(image)


static func _prayer_box() -> Image:
	var image := Draw.canvas(22, 22)
	Draw.rect(image, 3, 8, 16, 12, Draw.pal("wood"))
	Draw.rect(image, 3, 8, 16, 3, Draw.pal("wood_l"))
	Draw.rect(image, 7, 4, 8, 6, Draw.pal("wood_d"))
	Draw.rect(image, 8, 12, 6, 4, Draw.pal("paper"))
	Draw.px(image, 11, 14, Draw.pal("gold"))
	return Draw.outline(image)


static func _diploma() -> Image:
	var image := Draw.canvas(22, 26)
	Draw.rect(image, 2, 2, 18, 22, Draw.pal("wood"))
	Draw.rect(image, 4, 4, 14, 18, Draw.pal("paper"))
	Draw.rect(image, 6, 8, 10, 2, Draw.pal("gold"))
	Draw.rect(image, 7, 12, 8, 1, Draw.pal("path_c"))
	Draw.rect(image, 7, 15, 8, 1, Draw.pal("path_c"))
	Draw.ellipse(image, 11, 18, 2, 2, Draw.pal("brick"))
	return Draw.outline(image)


static func _desk_phone() -> Image:
	var image := Draw.canvas(16, 12)
	Draw.rect(image, 2, 6, 12, 5, Draw.pal("grey_d"))
	Draw.rect(image, 4, 2, 8, 5, Draw.pal("grey"))
	Draw.rect(image, 6, 3, 4, 3, Draw.pal("pants_d"))
	Draw.px(image, 3, 8, Draw.pal("gold"))
	return Draw.outline(image)


static func _prayer_cross() -> Image:
	var image := Draw.canvas(16, 28)
	Draw.rect(image, 6, 2, 4, 24, Draw.pal("wood"))
	Draw.rect(image, 2, 8, 12, 4, Draw.pal("wood_l"))
	Draw.rect(image, 6, 2, 4, 2, Draw.pal("wood_l"))
	return Draw.outline(image)


static func _prayer_cushion() -> Image:
	var image := Draw.canvas(20, 12)
	Draw.ellipse(image, 10, 6, 8, 5, Draw.pal("carpet"))
	Draw.ellipse(image, 10, 6, 5, 3, Draw.pal("carpet_l"))
	Draw.rect(image, 6, 5, 8, 2, Draw.pal("gold"))
	return Draw.outline(image)


static func _journal_stand() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 8, 14, 4, 8, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 12, 6, Draw.pal("wood"))
	Draw.rect(image, 5, 4, 10, 8, Draw.pal("paper"))
	Draw.rect(image, 6, 6, 8, 1, Draw.pal("path_c"))
	Draw.rect(image, 6, 8, 6, 1, Draw.pal("path_c"))
	return Draw.outline(image)


static func _choir_riser() -> Image:
	var image := Draw.canvas(72, 28)
	Draw.rect(image, 4, 16, 64, 10, Draw.pal("wood"))
	Draw.rect(image, 8, 10, 56, 8, Draw.pal("wood_l"))
	Draw.rect(image, 12, 6, 48, 6, Draw.pal("wood"))
	Draw.rect(image, 4, 24, 64, 3, Draw.pal("wood_d"))
	Draw.speckle(image, 19, 0, 12, Draw.pal("path_c"))
	return Draw.outline(image)


static func _practice_board() -> Image:
	var image := Draw.canvas(28, 32)
	Draw.rect(image, 2, 2, 24, 28, Draw.pal("wood_d"))
	Draw.rect(image, 4, 4, 20, 24, Draw.pal("cream"))
	Draw.rect(image, 6, 8, 16, 2, Draw.pal("brick"))
	Draw.rect(image, 6, 12, 12, 1, Draw.pal("path_c"))
	Draw.rect(image, 6, 16, 14, 1, Draw.pal("path_c"))
	Draw.rect(image, 6, 20, 10, 1, Draw.pal("gold"))
	return Draw.outline(image)


static func _storage_ladder() -> Image:
	var image := Draw.canvas(16, 40)
	Draw.rect(image, 2, 2, 3, 36, Draw.pal("wood_d"))
	Draw.rect(image, 11, 2, 3, 36, Draw.pal("wood_d"))
	for y in [6, 14, 22, 30]:
		Draw.rect(image, 3, y, 10, 2, Draw.pal("wood"))
	return Draw.outline(image)


static func _baptistry() -> Image:
	var image := Draw.canvas(40, 32)
	Draw.rect(image, 4, 10, 32, 18, Draw.pal("wood_d"))
	Draw.rect(image, 6, 12, 28, 12, Draw.pal("glass_d"))
	Draw.rect(image, 8, 14, 24, 8, Draw.pal("glass"))
	Draw.rect(image, 16, 4, 8, 8, Draw.pal("wood"))
	Draw.rect(image, 18, 2, 4, 6, Draw.pal("wood_l"))
	return Draw.outline(image)


static func _kids_play_rug() -> Image:
	var image := Draw.canvas(88, 56)
	Draw.rect(image, 6, 8, 76, 40, Draw.pal("flower2"))
	Draw.rect(image, 12, 14, 64, 28, Draw.pal("cream"))
	Draw.rect(image, 6, 8, 76, 3, Draw.pal("gold"))
	Draw.rect(image, 6, 45, 76, 3, Draw.pal("gold"))
	Draw.rect(image, 6, 8, 3, 40, Draw.pal("gold"))
	Draw.rect(image, 79, 8, 3, 40, Draw.pal("gold"))
	for x in range(10, 78, 6):
		Draw.px(image, x, 4, Draw.pal("gold"))
		Draw.px(image, x, 52, Draw.pal("gold"))
	Draw.ellipse(image, 30, 28, 6, 6, Draw.pal("shirt_l"))
	Draw.ellipse(image, 56, 30, 5, 5, Draw.pal("flower"))
	Draw.speckle(image, 21, 200, 255, Draw.pal("paper"))
	return Draw.outline(image)


static func _kids_book_bin() -> Image:
	var image := Draw.canvas(22, 18)
	Draw.rect(image, 3, 8, 16, 8, Draw.pal("wood"))
	Draw.rect(image, 5, 4, 4, 10, Draw.pal("brick"))
	Draw.rect(image, 10, 3, 4, 11, Draw.pal("shirt"))
	Draw.rect(image, 15, 5, 4, 9, Draw.pal("gold"))
	return Draw.outline(image)


static func _kids_wall_drawing() -> Image:
	var image := Draw.canvas(20, 18)
	Draw.rect(image, 2, 2, 16, 14, Draw.pal("paper"))
	Draw.rect(image, 4, 8, 4, 6, Draw.pal("shirt"))
	Draw.rect(image, 10, 6, 6, 8, Draw.pal("flower"))
	Draw.px(image, 6, 6, Draw.pal("gold"))
	return Draw.outline(image)
