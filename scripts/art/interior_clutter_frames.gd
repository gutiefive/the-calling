class_name InteriorClutterFrames
extends RefCounted
## Extra interior furniture and clutter for the M13B density pass.

const Draw := preload("res://scripts/art/pixel_draw.gd")


static func build(frame_id: String) -> Image:
	match frame_id:
		"doormat":
			return _doormat()
		"rug_narthex":
			return _narthex_rug()
		"coat_hooks":
			return _coat_hooks()
		"umbrella_stand":
			return _umbrella_stand()
		"plant":
			return _plant(false)
		"plant_tall":
			return _plant(true)
		"tract_rack":
			return _tract_rack()
		"donation_box":
			return _donation_box()
		"lost_umbrella":
			return _lost_umbrella()
		"side_table":
			return _side_table()
		"hymnal":
			return _book("brick")
		"bible":
			return _book("pants_d")
		"flower_stand":
			return _flower_stand()
		"sconce":
			return _sconce()
		"baptism_font":
			return _baptism_font()
		"sound_desk":
			return _sound_desk()
		"sanctuary_banner":
			return _banner("flower")
		"projector_screen":
			return _projector_screen()
		"candle_stand":
			return _candle_stand()
		"piano_bench":
			return _piano_bench()
		"sheet_music":
			return _sheet_music()
		"platform_chair":
			return _platform_chair()
		"rug_office":
			return _rug(80, 48, "carpet", "carpet_d", "wood")
		"armchair":
			return _armchair()
		"coffee_mug":
			return _coffee_mug()
		"paper_stack":
			return _paper_stack()
		"book_stack":
			return _book_stack()
		"coat_hook":
			return _coat_hook()
		"calendar":
			return _calendar()
		"radiator":
			return _radiator()
		"rug_prayer":
			return _rug(72, 44, "carpet_d", "carpet", "gold")
		"prayer_board":
			return _prayer_board()
		"open_book":
			return _open_book()
		"music_stand":
			return _music_stand()
		"robe_rack":
			return _robe_rack()
		"folder_shelf":
			return _folder_shelf()
		"storage_shelf":
			return _storage_shelf()
		"cardboard_box":
			return _cardboard_box()
		"vacuum":
			return _vacuum()
		"decoration_bin":
			return _decoration_bin()
		"mop_bucket":
			return _mop_bucket()
		"chair_cart":
			return _chair_cart()
		"stage":
			return _stage()
		"stage_curtain":
			return _stage_curtain()
		"kids_art":
			return _kids_art()
		"wall_banner":
			return _banner("shirt")
		"craft_table":
			return _craft_table()
		"puzzle_table":
			return _puzzle_table()
		"water_cooler":
			return _water_cooler()
		"trash_can":
			return _bin("grey_d", "grey")
		"recycling_bin":
			return _bin("leaf_l", "glass")
		"rug_hall":
			return _rug(76, 40, "shirt_d", "shirt", "cream_d")
		"long_table_runner":
			return InteriorHallFrames.build("long_table_runner")
		"upper_cabinet":
			return _upper_cabinet()
		"dish_rack":
			return _dish_rack()
		"microwave":
			return _microwave()
		"mixer":
			return _mixer()
		"island":
			return _island()
		"pantry":
			return _pantry()
		"cubbies":
			return _cubbies()
		"reading_rug":
			return InteriorHallFrames.build("rug_class_pattern")
		"beanbag":
			return _beanbag()
		"toy_bin":
			return _toy_bin()
		"globe":
			return _globe()
		"teacher_desk":
			return _teacher_desk()
		"fire_extinguisher":
			return _fire_extinguisher()
		"water_fountain":
			return _water_fountain()
		"long_table":
			return _long_table()
		"hall_chair":
			return _hall_chair()
		"stain_pool_aisle":
			return _stain_pool_aisle()
		"napkin_holder":
			return _napkin_holder()
		"salt_pepper":
			return _salt_pepper()
		"board_game":
			return _board_game()
		"table_bulletin":
			return _table_bulletin()
		"table_shadow_round":
			return _table_shadow(true)
		"table_shadow_long":
			return _table_shadow(false)
		_:
			return null


static func _narthex_rug() -> Image:
	var image := _rug(104, 60, "carpet_d", "carpet", "gold")
	for x in range(6, 98, 4):
		Draw.px(image, x, 1, Draw.pal("gold"))
		Draw.px(image, x, 2, Draw.pal("cream_d"))
		Draw.px(image, x, 57, Draw.pal("gold"))
		Draw.px(image, x, 58, Draw.pal("cream_d"))
	return image


static func _rug(w: int, h: int, field: String, inner: String, edge: String) -> Image:
	var image := Draw.canvas(w, h)
	Draw.rect(image, 2, 2, w - 4, h - 4, Draw.pal(field))
	Draw.rect(image, 6, 6, w - 12, h - 12, Draw.pal(inner))
	Draw.rect(image, 2, 2, w - 4, 2, Draw.pal(edge))
	Draw.rect(image, 2, h - 4, w - 4, 2, Draw.pal(edge))
	Draw.speckle(image, 19, 210, 255, Draw.pal(inner))
	return Draw.outline(image)


static func _doormat() -> Image:
	var image := Draw.canvas(48, 20)
	Draw.rect(image, 2, 4, 44, 12, Draw.pal("path"))
	Draw.rect(image, 4, 6, 40, 8, Draw.pal("path_c"))
	Draw.rect(image, 2, 4, 44, 2, Draw.pal("path_d"))
	return Draw.outline(image)


static func _coat_hooks() -> Image:
	var image := Draw.canvas(40, 48)
	Draw.rect(image, 4, 8, 32, 4, Draw.pal("wood_d"))
	Draw.rect(image, 8, 14, 8, 22, Draw.pal("cardigan"))
	Draw.rect(image, 20, 16, 8, 20, Draw.pal("skirt"))
	Draw.rect(image, 30, 18, 6, 16, Draw.pal("shirt"))
	Draw.px(image, 10, 10, Draw.pal("gold"))
	Draw.px(image, 22, 10, Draw.pal("gold"))
	Draw.px(image, 32, 10, Draw.pal("gold"))
	return Draw.outline(image)


static func _umbrella_stand() -> Image:
	var image := Draw.canvas(20, 36)
	Draw.rect(image, 4, 22, 12, 10, Draw.pal("grey_d"))
	Draw.rect(image, 8, 6, 3, 20, Draw.pal("shirt"))
	Draw.rect(image, 12, 8, 3, 18, Draw.pal("pants_d"))
	Draw.rect(image, 6, 4, 6, 4, Draw.pal("flower"))
	return Draw.outline(image)


static func _plant(tall: bool) -> Image:
	var h := 44 if tall else 32
	var image := Draw.canvas(24, h)
	Draw.rect(image, 6, h - 12, 12, 10, Draw.pal("brick"))
	Draw.rect(image, 8, h - 10, 8, 6, Draw.pal("brick_d"))
	Draw.ellipse(image, 12, h - 18, 8, 8, Draw.pal("leaf_l"))
	Draw.ellipse(image, 8, h - 22, 5, 5, Draw.pal("leaf_l"))
	if tall:
		Draw.ellipse(image, 14, 10, 6, 7, Draw.pal("leaf_l"))
		Draw.rect(image, 11, 16, 3, 10, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _tract_rack() -> Image:
	var image := Draw.canvas(32, 48)
	Draw.rect(image, 4, 4, 24, 40, Draw.pal("wood_d"))
	Draw.rect(image, 6, 8, 20, 8, Draw.pal("paper"))
	Draw.rect(image, 6, 18, 20, 8, Draw.pal("flower2"))
	Draw.rect(image, 6, 28, 20, 8, Draw.pal("paper"))
	Draw.rect(image, 8, 10, 16, 2, Draw.pal("path_c"))
	return Draw.outline(image)


static func _donation_box() -> Image:
	var image := Draw.canvas(28, 28)
	Draw.rect(image, 4, 10, 20, 14, Draw.pal("wood"))
	Draw.rect(image, 6, 12, 16, 4, Draw.pal("wood_d"))
	Draw.rect(image, 10, 6, 8, 8, Draw.pal("gold"))
	Draw.rect(image, 12, 8, 4, 3, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _lost_umbrella() -> Image:
	var image := Draw.canvas(28, 16)
	Draw.rect(image, 4, 8, 20, 3, Draw.pal("shirt"))
	Draw.rect(image, 2, 4, 8, 6, Draw.pal("flower"))
	Draw.px(image, 24, 9, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _side_table() -> Image:
	var image := Draw.canvas(32, 28)
	Draw.rect(image, 6, 16, 4, 10, Draw.pal("wood_d"))
	Draw.rect(image, 22, 16, 4, 10, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 24, 8, Draw.pal("wood"))
	Draw.rect(image, 4, 10, 24, 2, Draw.pal("wood_l"))
	return Draw.outline(image)


static func _book(color_name: String) -> Image:
	var image := Draw.canvas(16, 12)
	Draw.rect(image, 2, 2, 12, 8, Draw.pal(color_name))
	Draw.rect(image, 3, 3, 10, 6, Draw.pal("paper"))
	Draw.rect(image, 2, 2, 2, 8, Draw.pal(color_name))
	return Draw.outline(image)


static func _flower_stand() -> Image:
	var image := Draw.canvas(24, 40)
	Draw.rect(image, 8, 22, 8, 14, Draw.pal("wood_d"))
	Draw.rect(image, 4, 18, 16, 6, Draw.pal("wood"))
	Draw.ellipse(image, 12, 12, 8, 8, Draw.pal("flower"))
	Draw.ellipse(image, 8, 10, 4, 4, Draw.pal("flower2"))
	Draw.ellipse(image, 16, 10, 4, 4, Draw.pal("gold"))
	Draw.rect(image, 11, 16, 2, 6, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _sconce() -> Image:
	var image := Draw.canvas(16, 24)
	Draw.rect(image, 6, 14, 4, 8, Draw.pal("gold"))
	Draw.rect(image, 4, 4, 8, 12, Draw.pal("lamp"))
	Draw.rect(image, 6, 6, 4, 8, Draw.pal("paper"))
	return Draw.outline(image)


static func _baptism_font() -> Image:
	var image := Draw.canvas(36, 40)
	Draw.rect(image, 12, 24, 12, 12, Draw.pal("path_d"))
	Draw.ellipse(image, 18, 20, 14, 8, Draw.pal("path"))
	Draw.ellipse(image, 18, 18, 10, 6, Draw.pal("glass"))
	Draw.rect(image, 16, 8, 4, 8, Draw.pal("gold"))
	return Draw.outline(image)


static func _sound_desk() -> Image:
	var image := Draw.canvas(64, 36)
	Draw.rect(image, 4, 16, 56, 16, Draw.pal("pants_d"))
	Draw.rect(image, 6, 10, 52, 10, Draw.pal("grey_d"))
	Draw.rect(image, 10, 12, 8, 6, Draw.pal("grey"))
	Draw.rect(image, 24, 12, 16, 6, Draw.pal("path_c"))
	Draw.rect(image, 46, 8, 8, 10, Draw.pal("grey"))
	Draw.px(image, 14, 14, Draw.pal("lamp"))
	Draw.px(image, 30, 14, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _banner(field: String) -> Image:
	var image := Draw.canvas(28, 44)
	Draw.rect(image, 4, 4, 20, 4, Draw.pal("wood_d"))
	Draw.rect(image, 6, 8, 16, 32, Draw.pal(field))
	Draw.rect(image, 8, 12, 12, 8, Draw.pal("gold"))
	Draw.rect(image, 10, 24, 8, 10, Draw.pal("paper"))
	return Draw.outline(image)


static func _projector_screen() -> Image:
	var image := Draw.canvas(56, 40)
	Draw.rect(image, 4, 2, 48, 4, Draw.pal("grey_d"))
	Draw.rect(image, 6, 6, 44, 28, Draw.pal("paper"))
	Draw.rect(image, 8, 8, 40, 24, Draw.pal("cream"))
	Draw.rect(image, 26, 34, 4, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _candle_stand() -> Image:
	var image := Draw.canvas(20, 36)
	Draw.rect(image, 8, 16, 4, 16, Draw.pal("gold"))
	Draw.rect(image, 4, 30, 12, 4, Draw.pal("gold"))
	Draw.rect(image, 7, 8, 6, 10, Draw.pal("paper"))
	Draw.px(image, 9, 6, Draw.pal("lamp"))
	return Draw.outline(image)


static func _piano_bench() -> Image:
	var image := Draw.canvas(32, 20)
	Draw.rect(image, 4, 8, 24, 6, Draw.pal("pants_d"))
	Draw.rect(image, 6, 14, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 22, 14, 4, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _sheet_music() -> Image:
	var image := Draw.canvas(20, 16)
	Draw.rect(image, 2, 2, 16, 12, Draw.pal("paper"))
	Draw.rect(image, 4, 5, 12, 1, Draw.pal("path_c"))
	Draw.rect(image, 4, 8, 12, 1, Draw.pal("path_c"))
	Draw.rect(image, 4, 11, 10, 1, Draw.pal("path_c"))
	return Draw.outline(image)


static func _platform_chair() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 4, 4, 12, 8, Draw.pal("wood"))
	Draw.rect(image, 3, 12, 14, 5, Draw.pal("wood_l"))
	Draw.rect(image, 5, 17, 3, 6, Draw.pal("wood_d"))
	Draw.rect(image, 12, 17, 3, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _armchair() -> Image:
	var image := Draw.canvas(32, 28)
	Draw.rect(image, 4, 8, 24, 12, Draw.pal("cardigan"))
	Draw.rect(image, 6, 4, 20, 8, Draw.pal("skirt"))
	Draw.rect(image, 2, 10, 6, 10, Draw.pal("cardigan"))
	Draw.rect(image, 24, 10, 6, 10, Draw.pal("cardigan"))
	Draw.rect(image, 6, 20, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 22, 20, 4, 6, Draw.pal("wood_d"))
	return Draw.outline(image)


static func _coffee_mug() -> Image:
	var image := Draw.canvas(12, 12)
	Draw.rect(image, 2, 4, 7, 6, Draw.pal("cream"))
	Draw.rect(image, 3, 5, 5, 3, Draw.pal("path_c"))
	Draw.rect(image, 8, 6, 3, 3, Draw.pal("cream"))
	return Draw.outline(image)


static func _paper_stack() -> Image:
	var image := Draw.canvas(20, 14)
	Draw.rect(image, 2, 6, 16, 6, Draw.pal("paper"))
	Draw.rect(image, 3, 4, 14, 4, Draw.pal("cream"))
	Draw.rect(image, 4, 2, 12, 4, Draw.pal("paper"))
	Draw.rect(image, 6, 4, 8, 1, Draw.pal("path_c"))
	return Draw.outline(image)


static func _book_stack() -> Image:
	var image := Draw.canvas(20, 16)
	Draw.rect(image, 2, 10, 16, 4, Draw.pal("brick"))
	Draw.rect(image, 3, 6, 14, 4, Draw.pal("shirt"))
	Draw.rect(image, 4, 2, 12, 4, Draw.pal("cardigan"))
	return Draw.outline(image)


static func _coat_hook() -> Image:
	var image := Draw.canvas(16, 28)
	Draw.rect(image, 6, 4, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 4, 10, 8, 14, Draw.pal("cardigan"))
	Draw.px(image, 8, 6, Draw.pal("gold"))
	return Draw.outline(image)


static func _calendar() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 2, 2, 16, 20, Draw.pal("paper"))
	Draw.rect(image, 2, 2, 16, 5, Draw.pal("flower"))
	Draw.rect(image, 4, 9, 3, 3, Draw.pal("path_c"))
	Draw.rect(image, 9, 9, 3, 3, Draw.pal("path_c"))
	Draw.rect(image, 14, 9, 3, 3, Draw.pal("brick"))
	Draw.rect(image, 4, 14, 3, 3, Draw.pal("path_c"))
	Draw.rect(image, 9, 14, 3, 3, Draw.pal("path_c"))
	return Draw.outline(image)


static func _radiator() -> Image:
	var image := Draw.canvas(40, 20)
	Draw.rect(image, 2, 4, 36, 12, Draw.pal("grey"))
	for x in range(6, 36, 6):
		Draw.rect(image, x, 6, 3, 8, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _prayer_board() -> Image:
	var image := Draw.canvas(40, 48)
	Draw.rect(image, 2, 4, 36, 40, Draw.pal("wood_d"))
	Draw.rect(image, 4, 6, 32, 36, Draw.pal("path"))
	Draw.rect(image, 6, 8, 10, 8, Draw.pal("paper"))
	Draw.rect(image, 18, 12, 12, 6, Draw.pal("flower2"))
	Draw.rect(image, 8, 20, 14, 8, Draw.pal("paper"))
	Draw.rect(image, 24, 22, 8, 10, Draw.pal("cream"))
	Draw.rect(image, 10, 32, 16, 6, Draw.pal("paper"))
	Draw.px(image, 8, 10, Draw.pal("brick"))
	Draw.px(image, 20, 14, Draw.pal("gold"))
	Draw.px(image, 12, 22, Draw.pal("shirt"))
	return Draw.outline(image)


static func _open_book() -> Image:
	var image := Draw.canvas(28, 16)
	Draw.rect(image, 2, 4, 12, 10, Draw.pal("paper"))
	Draw.rect(image, 14, 4, 12, 10, Draw.pal("paper"))
	Draw.rect(image, 13, 4, 2, 10, Draw.pal("path_c"))
	Draw.rect(image, 4, 7, 8, 1, Draw.pal("path_d"))
	Draw.rect(image, 16, 7, 8, 1, Draw.pal("path_d"))
	return Draw.outline(image)


static func _music_stand() -> Image:
	var image := Draw.canvas(20, 40)
	Draw.rect(image, 9, 16, 2, 20, Draw.pal("grey_d"))
	Draw.rect(image, 4, 8, 12, 10, Draw.pal("grey"))
	Draw.rect(image, 6, 6, 8, 8, Draw.pal("paper"))
	Draw.rect(image, 6, 36, 8, 3, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _robe_rack() -> Image:
	var image := Draw.canvas(36, 48)
	Draw.rect(image, 4, 6, 28, 3, Draw.pal("wood_d"))
	Draw.rect(image, 6, 10, 6, 28, Draw.pal("shirt_l"))
	Draw.rect(image, 14, 10, 6, 30, Draw.pal("cream"))
	Draw.rect(image, 22, 10, 6, 26, Draw.pal("shirt"))
	Draw.rect(image, 16, 4, 4, 6, Draw.pal("wood"))
	return Draw.outline(image)


static func _folder_shelf() -> Image:
	var image := Draw.canvas(40, 32)
	Draw.rect(image, 2, 4, 36, 24, Draw.pal("wood_d"))
	Draw.rect(image, 4, 8, 8, 16, Draw.pal("paper"))
	Draw.rect(image, 14, 8, 8, 16, Draw.pal("flower2"))
	Draw.rect(image, 24, 8, 10, 16, Draw.pal("cream"))
	return Draw.outline(image)


static func _storage_shelf() -> Image:
	var image := Draw.canvas(48, 56)
	Draw.rect(image, 2, 2, 44, 52, Draw.pal("wood_d"))
	for y in [8, 22, 36]:
		Draw.rect(image, 4, y, 40, 10, Draw.pal("wood"))
		Draw.rect(image, 6, y + 2, 10, 6, Draw.pal("path_c"))
		Draw.rect(image, 18, y + 2, 10, 6, Draw.pal("grey"))
		Draw.rect(image, 30, y + 2, 12, 6, Draw.pal("brick"))
	return Draw.outline(image)


static func _cardboard_box() -> Image:
	var image := Draw.canvas(28, 24)
	Draw.rect(image, 2, 8, 24, 14, Draw.pal("path_c"))
	Draw.rect(image, 2, 8, 24, 4, Draw.pal("path"))
	Draw.rect(image, 12, 4, 4, 6, Draw.pal("path_d"))
	return Draw.outline(image)


static func _vacuum() -> Image:
	var image := Draw.canvas(24, 32)
	Draw.ellipse(image, 12, 20, 8, 8, Draw.pal("grey_d"))
	Draw.rect(image, 8, 8, 8, 12, Draw.pal("grey"))
	Draw.rect(image, 16, 22, 6, 4, Draw.pal("pants_d"))
	Draw.rect(image, 10, 4, 3, 6, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _decoration_bin() -> Image:
	var image := Draw.canvas(32, 24)
	Draw.rect(image, 2, 8, 28, 14, Draw.pal("shirt"))
	Draw.rect(image, 4, 4, 8, 8, Draw.pal("leaf_l"))
	Draw.rect(image, 14, 2, 6, 10, Draw.pal("gold"))
	Draw.rect(image, 22, 6, 6, 6, Draw.pal("flower"))
	return Draw.outline(image)


static func _mop_bucket() -> Image:
	var image := Draw.canvas(24, 32)
	Draw.rect(image, 6, 16, 12, 12, Draw.pal("grey"))
	Draw.rect(image, 8, 18, 8, 8, Draw.pal("glass"))
	Draw.rect(image, 10, 4, 3, 16, Draw.pal("wood_d"))
	Draw.rect(image, 8, 4, 8, 4, Draw.pal("grey_d"))
	return Draw.outline(image)


static func _chair_cart() -> Image:
	var image := Draw.canvas(28, 40)
	Draw.rect(image, 4, 8, 20, 24, Draw.pal("grey_d"))
	for y in [10, 16, 22]:
		Draw.rect(image, 6, y, 16, 4, Draw.pal("wood"))
	Draw.rect(image, 4, 32, 6, 6, Draw.pal("pants_d"))
	Draw.rect(image, 18, 32, 6, 6, Draw.pal("pants_d"))
	return Draw.outline(image)


static func _stage() -> Image:
	var image := Draw.canvas(128, 28)
	Draw.rect(image, 0, 10, 128, 18, Draw.pal("wood"))
	Draw.rect(image, 0, 10, 128, 4, Draw.pal("wood_l"))
	Draw.rect(image, 0, 24, 128, 4, Draw.pal("wood_d"))
	Draw.speckle(image, 17, 0, 12, Draw.pal("path_c"))
	return Draw.outline(image)


static func _stage_curtain() -> Image:
	var image := Draw.canvas(96, 40)
	Draw.rect(image, 2, 2, 92, 6, Draw.pal("wood_d"))
	Draw.rect(image, 4, 8, 28, 28, Draw.pal("flower"))
	Draw.rect(image, 64, 8, 28, 28, Draw.pal("flower"))
	Draw.rect(image, 30, 8, 36, 8, Draw.pal("gold"))
	for x in [8, 16, 72, 80]:
		Draw.rect(image, x, 10, 2, 24, Draw.pal("brick"))
	return Draw.outline(image)


static func _kids_art() -> Image:
	var image := Draw.canvas(28, 24)
	Draw.rect(image, 2, 2, 24, 20, Draw.pal("wood"))
	Draw.rect(image, 4, 4, 20, 16, Draw.pal("paper"))
	Draw.rect(image, 6, 10, 8, 8, Draw.pal("shirt"))
	Draw.rect(image, 16, 8, 6, 6, Draw.pal("gold"))
	Draw.rect(image, 12, 6, 4, 4, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _craft_table() -> Image:
	var image := _long_table()
	Draw.rect(image, 20, 12, 14, 8, Draw.pal("paper"))
	Draw.rect(image, 42, 14, 10, 6, Draw.pal("flower"))
	Draw.rect(image, 62, 12, 12, 8, Draw.pal("shirt"))
	Draw.rect(image, 86, 14, 10, 6, Draw.pal("gold"))
	Draw.px(image, 24, 14, Draw.pal("flower"))
	Draw.px(image, 46, 16, Draw.pal("leaf_l"))
	Draw.px(image, 66, 15, Draw.pal("gold"))
	return image


static func _puzzle_table() -> Image:
	var image := _long_table()
	Draw.rect(image, 28, 12, 72, 10, Draw.pal("paper"))
	Draw.rect(image, 32, 14, 12, 6, Draw.pal("shirt"))
	Draw.rect(image, 48, 14, 12, 6, Draw.pal("flower2"))
	Draw.rect(image, 64, 14, 12, 6, Draw.pal("leaf_l"))
	Draw.rect(image, 80, 14, 12, 6, Draw.pal("gold"))
	return image


static func _water_cooler() -> Image:
	var image := Draw.canvas(24, 40)
	Draw.rect(image, 4, 18, 16, 18, Draw.pal("grey"))
	Draw.ellipse(image, 12, 12, 8, 8, Draw.pal("glass"))
	Draw.rect(image, 10, 16, 4, 4, Draw.pal("grey_d"))
	Draw.rect(image, 16, 24, 4, 4, Draw.pal("glass_h"))
	return Draw.outline(image)


static func _bin(body: String, lid: String) -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 3, 8, 14, 14, Draw.pal(body))
	Draw.rect(image, 2, 6, 16, 4, Draw.pal(lid))
	return Draw.outline(image)


static func _upper_cabinet() -> Image:
	var image := Draw.canvas(64, 24)
	Draw.rect(image, 2, 2, 60, 20, Draw.pal("wood"))
	Draw.rect(image, 4, 4, 26, 16, Draw.pal("wood_l"))
	Draw.rect(image, 34, 4, 26, 16, Draw.pal("wood_l"))
	Draw.px(image, 26, 12, Draw.pal("gold"))
	Draw.px(image, 38, 12, Draw.pal("gold"))
	return Draw.outline(image)


static func _dish_rack() -> Image:
	var image := Draw.canvas(28, 20)
	Draw.rect(image, 2, 10, 24, 8, Draw.pal("grey"))
	Draw.rect(image, 6, 4, 4, 10, Draw.pal("glass_h"))
	Draw.rect(image, 12, 2, 4, 12, Draw.pal("paper"))
	Draw.rect(image, 18, 4, 4, 10, Draw.pal("glass_h"))
	return Draw.outline(image)


static func _microwave() -> Image:
	var image := Draw.canvas(28, 20)
	Draw.rect(image, 2, 4, 24, 14, Draw.pal("grey_d"))
	Draw.rect(image, 4, 6, 14, 10, Draw.pal("pants"))
	Draw.rect(image, 20, 8, 4, 6, Draw.pal("grey"))
	return Draw.outline(image)


static func _mixer() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 6, 12, 10, 8, Draw.pal("cream"))
	Draw.rect(image, 8, 4, 6, 10, Draw.pal("grey_d"))
	Draw.rect(image, 4, 8, 8, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _island() -> Image:
	var image := Draw.canvas(72, 32)
	Draw.rect(image, 4, 12, 64, 16, Draw.pal("wood"))
	Draw.rect(image, 4, 12, 64, 4, Draw.pal("cream"))
	Draw.rect(image, 12, 6, 12, 8, Draw.pal("paper"))
	Draw.rect(image, 40, 8, 10, 6, Draw.pal("grey"))
	return Draw.outline(image)


static func _pantry() -> Image:
	var image := Draw.canvas(32, 48)
	Draw.rect(image, 2, 2, 28, 44, Draw.pal("wood_d"))
	Draw.rect(image, 4, 6, 24, 12, Draw.pal("wood"))
	Draw.rect(image, 4, 20, 24, 12, Draw.pal("wood"))
	Draw.rect(image, 4, 34, 24, 8, Draw.pal("wood"))
	Draw.rect(image, 8, 8, 6, 8, Draw.pal("brick"))
	Draw.rect(image, 16, 8, 8, 8, Draw.pal("cream"))
	Draw.rect(image, 8, 22, 8, 8, Draw.pal("path_c"))
	return Draw.outline(image)


static func _cubbies() -> Image:
	var image := Draw.canvas(56, 40)
	Draw.rect(image, 2, 2, 52, 36, Draw.pal("wood_d"))
	for x in [6, 20, 34]:
		for y in [6, 20]:
			Draw.rect(image, x, y, 12, 12, Draw.pal("wood"))
	Draw.rect(image, 8, 8, 6, 6, Draw.pal("shirt"))
	Draw.rect(image, 22, 22, 6, 6, Draw.pal("flower"))
	Draw.rect(image, 36, 8, 8, 6, Draw.pal("paper"))
	return Draw.outline(image)


static func _beanbag() -> Image:
	var image := Draw.canvas(28, 20)
	Draw.ellipse(image, 14, 12, 12, 8, Draw.pal("flower2"))
	Draw.ellipse(image, 14, 10, 10, 6, Draw.pal("flower"))
	return Draw.outline(image)


static func _toy_bin() -> Image:
	var image := Draw.canvas(28, 20)
	Draw.rect(image, 2, 8, 24, 10, Draw.pal("wood"))
	Draw.rect(image, 6, 4, 6, 8, Draw.pal("shirt"))
	Draw.rect(image, 14, 2, 6, 10, Draw.pal("gold"))
	Draw.rect(image, 20, 6, 4, 6, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _globe() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.ellipse(image, 10, 10, 8, 8, Draw.pal("glass"))
	Draw.rect(image, 9, 18, 2, 4, Draw.pal("wood_d"))
	Draw.rect(image, 6, 20, 8, 3, Draw.pal("wood"))
	Draw.rect(image, 6, 8, 4, 6, Draw.pal("leaf_l"))
	return Draw.outline(image)


static func _teacher_desk() -> Image:
	var image := Draw.canvas(64, 36)
	Draw.rect(image, 6, 20, 6, 12, Draw.pal("wood_d"))
	Draw.rect(image, 52, 20, 6, 12, Draw.pal("wood_d"))
	Draw.rect(image, 4, 12, 56, 12, Draw.pal("wood"))
	Draw.rect(image, 8, 6, 16, 8, Draw.pal("paper"))
	Draw.rect(image, 32, 8, 10, 6, Draw.pal("grey"))
	Draw.rect(image, 46, 8, 8, 6, Draw.pal("flower"))
	return Draw.outline(image)


static func _fire_extinguisher() -> Image:
	var image := Draw.canvas(12, 24)
	Draw.rect(image, 3, 6, 6, 16, Draw.pal("flower"))
	Draw.rect(image, 4, 2, 4, 5, Draw.pal("grey_d"))
	Draw.rect(image, 8, 8, 3, 4, Draw.pal("grey"))
	return Draw.outline(image)


static func _water_fountain() -> Image:
	var image := Draw.canvas(24, 28)
	Draw.rect(image, 4, 12, 16, 14, Draw.pal("grey"))
	Draw.rect(image, 8, 8, 8, 6, Draw.pal("grey_d"))
	Draw.rect(image, 10, 4, 4, 6, Draw.pal("glass_h"))
	return Draw.outline(image)


static func _long_table() -> Image:
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
	return Draw.outline(image)


static func _hall_chair() -> Image:
	var image := Draw.canvas(20, 24)
	Draw.rect(image, 5, 2, 10, 10, Draw.pal("wood"))
	Draw.rect(image, 7, 4, 6, 7, Draw.pal("wood_l"))
	Draw.rect(image, 3, 12, 14, 5, Draw.pal("wood_l"))
	Draw.rect(image, 4, 17, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 12, 17, 4, 6, Draw.pal("wood_d"))
	Draw.rect(image, 3, 21, 5, 2, Draw.pal("path_c"))
	Draw.rect(image, 12, 21, 5, 2, Draw.pal("path_c"))
	return Draw.outline(image)


static func _napkin_holder() -> Image:
	var image := Draw.canvas(14, 12)
	Draw.rect(image, 2, 6, 10, 4, Draw.pal("wood"))
	Draw.rect(image, 3, 2, 8, 8, Draw.pal("paper"))
	Draw.rect(image, 4, 3, 6, 2, Draw.pal("cream"))
	return Draw.outline(image)


static func _salt_pepper() -> Image:
	var image := Draw.canvas(16, 12)
	Draw.rect(image, 2, 4, 5, 6, Draw.pal("paper"))
	Draw.rect(image, 9, 4, 5, 6, Draw.pal("pants_d"))
	Draw.px(image, 4, 5, Draw.pal("grey"))
	Draw.px(image, 11, 5, Draw.pal("grey"))
	return Draw.outline(image)


static func _board_game() -> Image:
	var image := Draw.canvas(20, 14)
	Draw.rect(image, 2, 2, 16, 10, Draw.pal("shirt"))
	Draw.rect(image, 4, 4, 12, 6, Draw.pal("paper"))
	Draw.rect(image, 6, 5, 3, 3, Draw.pal("flower"))
	Draw.rect(image, 11, 6, 3, 3, Draw.pal("gold"))
	return Draw.outline(image)


static func _table_bulletin() -> Image:
	var image := Draw.canvas(16, 12)
	Draw.rect(image, 2, 3, 12, 7, Draw.pal("paper"))
	Draw.rect(image, 3, 2, 10, 7, Draw.pal("cream"))
	Draw.rect(image, 5, 4, 6, 1, Draw.pal("path_c"))
	Draw.rect(image, 5, 7, 5, 1, Draw.pal("path_c"))
	return Draw.outline(image)


static func _table_shadow(round: bool) -> Image:
	var image: Image
	if round:
		image = Draw.canvas(88, 28)
		Draw.ellipse(image, 44, 14, 36, 10, Draw.pal("path_c"))
	else:
		image = Draw.canvas(116, 18)
		Draw.rect(image, 6, 5, 104, 8, Draw.pal("path_c"))
	return image


static func _stain_pool_aisle() -> Image:
	var image := Draw.canvas(80, 52)
	image.fill(Color(0, 0, 0, 0))
	# Outer wash first so the pool falls off instead of reading as a hard patch.
	Draw.ellipse(image, 40, 26, 32, 20, Color(168.0 / 255.0, 118.0 / 255.0, 112.0 / 255.0, 0.07))
	Draw.ellipse(image, 34, 26, 22, 14, Color(168.0 / 255.0, 118.0 / 255.0, 112.0 / 255.0, 0.12))
	Draw.ellipse(image, 50, 24, 18, 12, Color(118.0 / 255.0, 136.0 / 255.0, 152.0 / 255.0, 0.11))
	Draw.ellipse(image, 42, 28, 14, 9, Color(186.0 / 255.0, 160.0 / 255.0, 112.0 / 255.0, 0.10))
	return image
