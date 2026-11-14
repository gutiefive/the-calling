extends WorldRoom
## Multi-room sanctuary: narthex, worship hall, office, prayer room, choir, and storage.


func area_name() -> String:
	return "Sanctuary"


func _on_time_changed() -> void:
	super._on_time_changed()
	var service := get_node_or_null("SundayService")
	if service != null and service.has_method("on_clock"):
		service.call("on_clock")


func _build() -> void:
	bounds = InteriorLayout.sanctuary_bounds()
	_ensure_pews()
	_assign_art()
	_place_props()
	_add_furniture()
	_add_flavor_props()
	_add_ambients()
	_paint_ground()
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	_add_rect(Vector2(736, float(InteriorLayout.SANCTUARY_SIZE.y * InteriorLayout.TILE) - 6.0), Vector2(72, 12))


func rebuild_collision() -> void:
	_clear_solids()
	_add_walls()
	_add_prop_blocks()
	_add_rect(Vector2(736, float(InteriorLayout.SANCTUARY_SIZE.y * InteriorLayout.TILE) - 6.0), Vector2(72, 12))


func _assign_art() -> void:
	_set_sprite("Props/Window", InteriorArt.texture("stained_glass"))
	_set_sprite("Props/Cross", InteriorArt.texture("cross"))
	_set_sprite("Props/Altar", InteriorArt.texture("altar"))
	_set_sprite("Props/Chairs", InteriorArt.texture("stacked_chairs"))
	var pew_count := InteriorLayout.pew_rows().size()
	for i in pew_count:
		_set_sprite("Props/PewL%d" % (i + 1), InteriorArt.texture("pew"))
		_set_sprite("Props/PewR%d" % (i + 1), InteriorArt.texture("pew"))
	_set_light_texture("Lighting/SconceL")
	_set_light_texture("Lighting/SconceR")
	_set_light_texture("Lighting/SconceN")


func _place_props() -> void:
	_place("Props/Door", InteriorLayout.POS_SANCT_DOOR)
	_place("Props/Altar", InteriorLayout.POS_SANCT_ALTAR)
	_feet_offset("Props/Altar")
	_place("Props/Cross", InteriorLayout.POS_SANCT_CROSS)
	_feet_offset("Props/Cross")
	_place("Props/Window", Vector2(240, 404))
	_feet_offset("Props/Window")
	_place("Props/Chairs", InteriorLayout.POS_SANCT_KEYS + Vector2(-36, 8))
	_feet_offset("Props/Chairs")
	_place("Props/Harold", InteriorLayout.POS_SANCT_HAROLD)
	_place("Props/Margaret", InteriorLayout.POS_SANCT_MARGARET)
	_place("Props/KeyRing", InteriorLayout.POS_SANCT_KEYS)
	_place("Props/Ledger", InteriorLayout.POS_SANCT_LEDGER)
	_add_quiet_note()
	_add_sanctuary_flowers()
	_place("Props/Thomas", InteriorLayout.POS_SANCT_THOMAS)
	_place("Props/Frank", InteriorLayout.POS_SANCT_FRANK)
	_place("Props/Sarah", InteriorLayout.POS_SANCT_SARAH)
	var pew_ys := InteriorLayout.pew_rows()
	for i in pew_ys.size():
		_place("Props/PewL%d" % (i + 1), Vector2(InteriorLayout.PEW_LEFT_X, pew_ys[i]))
		_place("Props/PewR%d" % (i + 1), Vector2(InteriorLayout.PEW_RIGHT_X, pew_ys[i]))
		_feet_offset("Props/PewL%d" % (i + 1))
		_feet_offset("Props/PewR%d" % (i + 1))
		_set_pew_block("Props/PewL%d" % (i + 1))
		_set_pew_block("Props/PewR%d" % (i + 1))
	_place("Spawns/default", InteriorLayout.POS_SANCT_SPAWN)
	_place("Spawns/from_exterior", InteriorLayout.POS_SANCT_SPAWN)
	var spawn := get_node_or_null("Spawns/default")
	var entered := get_node_or_null("Spawns/from_exterior")
	if spawn != null:
		spawn.set_meta("facing", &"up")
	if entered != null:
		entered.set_meta("facing", &"up")
	_place("Lighting/SconceL", Vector2(420, 1064))
	_place("Lighting/SconceR", Vector2(1050, 1064))
	_place("Lighting/SconceN", Vector2(736, 424))
	for node_name in PackedStringArray(["Altar", "Cross", "Chairs", "Window", "Ledger", "KeyRing"]):
		_mark_prop(get_node_or_null("Props/%s" % node_name))


func _set_pew_block(node_path: String) -> void:
	var pew := get_node_or_null(node_path)
	if pew != null and "block_size" in pew:
		pew.set("block_size", InteriorLayout.PEW_BLOCK)
	_mark_prop(pew)


func _refresh_living() -> void:
	super._refresh_living()
	_apply_sanctuary_flowers()


func _add_sanctuary_flowers() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("SanctuaryFlowers") != null:
		return
	var bouquet := Sprite2D.new()
	bouquet.name = "SanctuaryFlowers"
	bouquet.texture = PlaceholderArt.flowers()
	bouquet.centered = true
	bouquet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bouquet.position = InteriorLayout.POS_SANCT_FLOWERS
	if bouquet.texture != null:
		bouquet.offset = Vector2(0, -bouquet.texture.get_height() * 0.5)
	bouquet.visible = false
	props.add_child(bouquet)
	_apply_sanctuary_flowers()


func _apply_sanctuary_flowers() -> void:
	var bouquet := get_node_or_null("Props/SanctuaryFlowers") as CanvasItem
	if bouquet == null:
		return
	bouquet.visible = NarrativeState.flag_is_true("sanctuary_flowers_set")


func _add_quiet_note() -> void:
	var props := get_node_or_null("Props")
	if props == null or props.get_node_or_null("QuietSunday") != null:
		return
	var note := SpeechProp.new()
	note.name = "QuietSunday"
	note.position = Vector2(736, 764)
	note.sheet = PlaceholderArt.ledger()
	note.frame_size = Vector2i(32, 32)
	note.frame_count = 1
	note.speaker_name = "Note"
	note.prompt_text = "Read"
	note.line = DayClock.LATER_SUNDAY_NOTE
	note.radius = 36.0
	note.visible = false
	note.enabled = false
	note.add_to_group("quiet_sunday")
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	note.add_child(sprite)
	props.add_child(note)


func _add_furniture() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_narthex(props)
	_add_worship(props)
	_add_office_room(props)
	_add_prayer_room(props)
	_add_choir_room(props)
	_add_storage_room(props)
	_add_hallway_clutter(props)
	_add_glass(props, "GlassE1", "stained_glass_b", Vector2(1220, 424))
	_add_glass(props, "GlassE2", "stained_glass_c", Vector2(1220, 584))
	_add_glass(props, "GlassE3", "stained_glass_b", Vector2(1220, 744))
	_add_glass(props, "GlassW1", "stained_glass_c", Vector2(250, 584))
	_add_glass(props, "GlassW2", "stained_glass", Vector2(250, 744))
	_add_stain_pool(props, "StainE", Vector2(1180, 564))
	_add_stain_pool(props, "StainW", Vector2(280, 564))
	_add_aisle_color(props)
	_add_office_window(props)


func _add_narthex(props: Node) -> void:
	_add_solid(props, "WelcomeTable", "welcome_table", Vector2(560, 1044), Vector2(64, 12))
	_add_solid(props, "CoatRack", "coat_rack", Vector2(400, 1024), Vector2(14, 10))
	_add_solid(props, "NarthexBench", "bench", Vector2(1000, 1084), Vector2(44, 10))
	_add_solid(props, "CoatHooks", "coat_hooks", Vector2(360, 994), Vector2(18, 10))
	_add_solid(props, "UmbrellaStand", "umbrella_stand", Vector2(380, 1104), Vector2(12, 10))
	_add_solid(props, "NarthexPlantW", "plant_tall", Vector2(340, 1064), Vector2(12, 10))
	_add_solid(props, "NarthexPlantE", "plant", Vector2(1120, 1164), Vector2(12, 10))
	_add_solid(props, "TractRack", "tract_rack", Vector2(840, 1044), Vector2(16, 12))
	_add_solid(props, "DonationBox", "donation_box", Vector2(500, 1104), Vector2(16, 10))
	_add_solid(props, "NarthexSideTable", "side_table", Vector2(1080, 1044), Vector2(22, 10))
	_add_deco(props, "NarthexLamp", "lamp", Vector2(1080, 1032), 1)
	_add_rug(props, "NarthexRug", "rug_narthex", Vector2(736, 1104))
	_add_rug(props, "NarthexRugW", "rug_narthex", Vector2(520, 1164))
	_add_rug(props, "NarthexRugE", "rug_narthex", Vector2(960, 1164))
	_add_solid(props, "NarthexBenchW", "bench", Vector2(460, 1164), Vector2(44, 10))
	_add_solid(props, "NarthexPlantS", "plant", Vector2(1120, 1084), Vector2(12, 10))
	_add_deco(props, "NarthexDoormat", "doormat", Vector2(736, 1220), -2)
	_add_deco(props, "LostUmbrella", "lost_umbrella", Vector2(1060, 1172), 0)
	_add_wall_deco(props, "NarthexPhotoA", "photo", Vector2(480, InteriorLayout.sanct_narthex_wall_foot_y()))
	_add_wall_deco(props, "NarthexPhotoB", "photo", Vector2(980, InteriorLayout.sanct_narthex_wall_foot_y()))
	_add_wall_deco(props, "NarthexPhotoC", "photo", Vector2(860, InteriorLayout.sanct_narthex_wall_foot_y()))
	_add_deco(props, "NarthexBulletins", "paper_stack", Vector2(548, 1032), 1)
	_add_lamp_light("NarthexGlow", Vector2(736, 1104), Color(1, 0.86, 0.62), 0.55)
	_add_lamp_light("NarthexLampGlow", Vector2(1080, 1032), Color(1, 0.86, 0.62), 0.45)


func _add_worship(props: Node) -> void:
	_add_solid(props, "Pulpit", "pulpit", InteriorLayout.POS_SANCT_PULPIT, Vector2(28, 12))
	_add_solid(props, "Platform", "platform", Vector2(736, 412), Vector2(140, 10))
	_add_solid(props, "SideCandles", "candles", Vector2(680, 416), Vector2(12, 8))
	_add_solid(props, "AltarCandles", "candles", Vector2(780, 416), Vector2(12, 8))
	_add_solid(props, "CandleStandL", "candle_stand", Vector2(600, 424), Vector2(10, 8))
	_add_solid(props, "CandleStandR", "candle_stand", Vector2(870, 424), Vector2(10, 8))
	_add_solid(props, "PlatformChairA", "platform_chair", Vector2(800, 436), Vector2(12, 8))
	_add_solid(props, "PlatformChairB", "platform_chair", Vector2(832, 436), Vector2(12, 8))
	_add_solid(props, "BaptismFont", "baptism_font", Vector2(1188, 424), Vector2(20, 12))
	_add_solid(props, "Baptistry", "baptistry", Vector2(830, 396), Vector2(28, 12))
	_add_solid(props, "FlowerStandE", "flower_stand", Vector2(1210, 584), Vector2(12, 10))
	_add_solid(props, "FlowerStandW", "flower_stand", Vector2(250, 684), Vector2(12, 10))
	_add_solid(props, "WorshipPlantE", "plant_tall", Vector2(1210, 684), Vector2(12, 10))
	_add_solid(props, "WorshipPlantW", "plant", Vector2(250, 504), Vector2(12, 10))
	_add_solid(props, "SoundDesk", "sound_desk", Vector2(300, 864), Vector2(48, 12))
	_add_solid(props, "PianoBench", "piano_bench", Vector2(1080, 476), Vector2(22, 8))
	_add_deco(props, "SheetMusic", "sheet_music", Vector2(1080, 464), 1)
	_add_deco(props, "ProjectorScreen", "projector_screen", Vector2(736, 382), 0)
	_add_deco(props, "BannerW", "sanctuary_banner", Vector2(320, 424), 0)
	_add_deco(props, "BannerE", "sanctuary_banner", Vector2(1150, 424), 0)
	_add_deco(props, "FlagW", "church_flag", Vector2(560, 400), 0)
	_add_deco(props, "FlagE", "church_flag", Vector2(910, 400), 0)
	_add_deco(props, "SconceSpriteW1", "sconce", Vector2(230, 544), 0)
	_add_deco(props, "SconceSpriteW2", "sconce", Vector2(230, 704), 0)
	_add_deco(props, "SconceSpriteE1", "sconce", Vector2(1240, 544), 0)
	_add_deco(props, "SconceSpriteE2", "sconce", Vector2(1240, 704), 0)
	_add_deco(props, "PendantA", "pendant_light", Vector2(736, 500), 2)
	_add_deco(props, "PendantB", "pendant_light", Vector2(736, 630), 2)
	_add_deco(props, "PendantC", "pendant_light", Vector2(736, 760), 2)
	_add_rug(props, "SideRugW", "rug_hall", Vector2(260, 624))
	_add_rug(props, "SideRugE", "rug_hall", Vector2(1180, 624))
	_add_deco(props, "HymnalA", "hymnal", Vector2(400, 504), 1)
	_add_deco(props, "HymnalB", "bible", Vector2(500, 600), 1)
	_add_deco(props, "HymnalC", "hymnal", Vector2(1040, 504), 1)
	_add_deco(props, "HymnalD", "bible", Vector2(1100, 696), 1)
	_add_lamp_light("WorshipSconceW1", Vector2(250, 564), Color(1, 0.82, 0.55), 0.5)
	_add_lamp_light("WorshipSconceW2", Vector2(250, 724), Color(1, 0.82, 0.55), 0.5)
	_add_lamp_light("WorshipSconceE1", Vector2(1220, 564), Color(1, 0.82, 0.55), 0.5)
	_add_lamp_light("WorshipSconceE2", Vector2(1220, 724), Color(1, 0.82, 0.55), 0.5)
	_add_lamp_light("PendantGlowA", Vector2(736, 520), Color(1, 0.88, 0.64), 0.45)
	_add_lamp_light("PendantGlowB", Vector2(736, 650), Color(1, 0.88, 0.64), 0.45)
	_add_lamp_light("PendantGlowC", Vector2(736, 780), Color(1, 0.88, 0.64), 0.45)


func _add_office_room(props: Node) -> void:
	_add_solid(props, "OfficeDesk", "desk", Vector2(192, 140), Vector2(56, 14))
	_add_solid(props, "OfficeChair", "office_chair", Vector2(192, 176), Vector2(14, 10))
	_add_solid(props, "OfficeShelf", "bookshelf", Vector2(80, 80), Vector2(28, 14))
	_add_solid(props, "OfficeShelfB", "bookshelf", Vector2(40, 50), Vector2(28, 14))
	_add_solid(props, "OfficeShelfC", "bookshelf", Vector2(80, 210), Vector2(28, 14))
	_add_solid(props, "OfficeFiling", "filing", Vector2(300, 80), Vector2(18, 12))
	_add_solid(props, "OfficeLamp", "lamp", Vector2(120, 100), Vector2(10, 8))
	_add_solid(props, "OfficeArmchair", "armchair", Vector2(300, 150), Vector2(20, 10))
	_add_solid(props, "OfficeGuestChair", "armchair", Vector2(300, 200), Vector2(20, 10))
	_add_solid(props, "OfficePlant", "plant", Vector2(320, 110), Vector2(10, 8))
	_add_solid(props, "OfficeRadiator", "radiator", Vector2(150, 50), Vector2(28, 8))
	_add_deco(props, "OfficeMug", "coffee_mug", Vector2(210, 128), 1)
	_add_deco(props, "OfficePapers", "paper_stack", Vector2(170, 128), 1)
	_add_deco(props, "OfficeBooks", "book_stack", Vector2(250, 128), 1)
	_add_deco(props, "OfficeBible", "bible", Vector2(200, 122), 1)
	_add_deco(props, "OfficePhone", "desk_phone", Vector2(230, 122), 1)
	_add_deco(props, "OfficeCoat", "coat_hook", Vector2(40, 70), 0)
	_add_wall_deco(props, "OfficeCalendar", "calendar", Vector2(250, InteriorLayout.sanct_north_wall_foot_y()))
	_add_wall_deco(props, "OfficeDiploma", "diploma", Vector2(120, InteriorLayout.sanct_north_wall_foot_y()))
	_add_rug(props, "OfficeRug", "rug_office", Vector2(192, 150))


func _add_prayer_room(props: Node) -> void:
	_add_solid(props, "Kneeler", "kneeler", Vector2(500, 120), Vector2(22, 10))
	_add_solid(props, "PrayerBench", "bench", Vector2(620, 150), Vector2(44, 10))
	_add_solid(props, "PrayerCandles", "candles", Vector2(460, 80), Vector2(12, 8))
	_add_solid(props, "PrayerCandlesB", "candles", Vector2(430, 90), Vector2(12, 8))
	_add_solid(props, "PrayerTable", "side_table", Vector2(580, 80), Vector2(20, 10))
	_add_solid(props, "PrayerPlant", "plant", Vector2(640, 80), Vector2(10, 8))
	_add_deco(props, "PrayerBoard", "prayer_board", Vector2(420, 55), 0)
	_add_deco(props, "PrayerBook", "open_book", Vector2(580, 70), 1)
	_add_deco(props, "PrayerCross", "prayer_cross", Vector2(500, 55), 0)
	_add_deco(props, "PrayerCushionA", "prayer_cushion", Vector2(470, 160), 0)
	_add_deco(props, "PrayerCushionB", "prayer_cushion", Vector2(540, 180), 0)
	_add_rug(props, "PrayerRug", "rug_prayer", Vector2(530, 150))
	_add_lamp_light("PrayerGlow", Vector2(520, 130), Color(1, 0.82, 0.55), 0.5)


func _add_choir_room(props: Node) -> void:
	_add_solid(props, "ChoirPiano", "piano", Vector2(820, 100), Vector2(56, 14))
	_add_solid(props, "ChoirChairA", "platform_chair", Vector2(740, 150), Vector2(12, 8))
	_add_solid(props, "ChoirChairB", "platform_chair", Vector2(770, 150), Vector2(12, 8))
	_add_solid(props, "ChoirChairC", "platform_chair", Vector2(800, 150), Vector2(12, 8))
	_add_solid(props, "ChoirChairD", "platform_chair", Vector2(740, 175), Vector2(12, 8))
	_add_solid(props, "ChoirChairE", "platform_chair", Vector2(770, 175), Vector2(12, 8))
	_add_solid(props, "MusicStandA", "music_stand", Vector2(900, 90), Vector2(10, 8))
	_add_solid(props, "MusicStandB", "music_stand", Vector2(930, 90), Vector2(10, 8))
	_add_solid(props, "RobeRack", "robe_rack", Vector2(1000, 80), Vector2(18, 12))
	_add_solid(props, "FolderShelf", "folder_shelf", Vector2(740, 80), Vector2(24, 10))
	_add_solid(props, "ChoirRiser", "choir_riser", Vector2(780, 210), Vector2(56, 10))
	_add_solid(props, "ChoirChairF", "platform_chair", Vector2(760, 200), Vector2(12, 8))
	_add_solid(props, "ChoirChairG", "platform_chair", Vector2(792, 200), Vector2(12, 8))
	_add_solid(props, "MusicStandC", "music_stand", Vector2(900, 200), Vector2(10, 8))
	_add_deco(props, "ChoirMusic", "sheet_music", Vector2(820, 88), 1)
	_add_lamp_light("ChoirGlow", Vector2(860, 130), Color(1, 0.86, 0.62), 0.45)


func _add_storage_room(props: Node) -> void:
	_add_solid(props, "ChoirSupplies", "folding_tables", Vector2(1248, 120), Vector2(36, 12))
	_add_solid(props, "StorageShelfA", "storage_shelf", Vector2(1120, 80), Vector2(28, 14))
	_add_solid(props, "StorageShelfB", "storage_shelf", Vector2(1348, 80), Vector2(28, 14))
	_add_solid(props, "StorageBoxA", "cardboard_box", Vector2(1180, 140), Vector2(16, 10))
	_add_solid(props, "StorageBoxB", "cardboard_box", Vector2(1220, 150), Vector2(16, 10))
	_add_solid(props, "Vacuum", "vacuum", Vector2(1320, 140), Vector2(14, 10))
	_add_solid(props, "XmasBin", "decoration_bin", Vector2(1360, 150), Vector2(18, 10))
	_add_solid(props, "StorageMop", "mop_bucket", Vector2(1140, 150), Vector2(12, 10))
	_add_solid(props, "StorageLadder", "storage_ladder", Vector2(1380, 180), Vector2(10, 16))
	_add_solid(props, "StorageBinA", "labeled_bin", Vector2(1180, 200), Vector2(16, 10))
	_add_solid(props, "StorageBinB", "labeled_bin", Vector2(1220, 210), Vector2(16, 10))
	_add_solid(props, "StorageChairs", "stacked_chairs", Vector2(1320, 210), Vector2(18, 12))
	_add_lamp_light("StorageGlow", Vector2(1240, 140), Color(1, 0.86, 0.62), 0.4)


func _add_hallway_clutter(props: Node) -> void:
	_add_wall_deco(props, "HallPhotoA", "photo", Vector2(200, InteriorLayout.sanct_hallway_wall_foot_y()))
	_add_wall_deco(props, "HallPhotoB", "photo", Vector2(400, InteriorLayout.sanct_hallway_wall_foot_y()))
	_add_wall_deco(props, "HallPhotoC", "photo", Vector2(1000, InteriorLayout.sanct_hallway_wall_foot_y()))
	_add_deco(props, "HallCoatRack", "coat_rack", Vector2(1320, 312), 0)
	_add_deco(props, "HallExtinguisher", "fire_extinguisher", Vector2(1280, 292), 0)
	_add_deco(props, "HallPlant", "plant", Vector2(960, 312), 0)
	_add_deco(props, "HallFountain", "water_fountain", Vector2(80, 312), 0)
	_add_lamp_light("HallwayGlow", Vector2(736, 320), Color(1, 0.86, 0.62), 0.4)


func _add_aisle_color(props: Node) -> void:
	_add_stain_pool(props, "AisleStain1", Vector2(736, 494), "stain_pool_aisle")
	_add_stain_pool(props, "AisleStain2", Vector2(736, 594), "stain_pool_aisle")
	_add_stain_pool(props, "AisleStain3", Vector2(736, 704), "stain_pool_aisle")
	_add_stain_pool(props, "AisleStain4", Vector2(736, 804), "stain_pool_aisle")
	_add_stained_light("AisleStain1Light", Vector2(736, 494), InteriorLayout.aisle_stain_color(0), true)
	_add_stained_light("AisleStain2Light", Vector2(736, 594), InteriorLayout.aisle_stain_color(1), true)
	_add_stained_light("AisleStain3Light", Vector2(736, 704), InteriorLayout.aisle_stain_color(2), true)
	_add_stained_light("AisleStain4Light", Vector2(736, 804), InteriorLayout.aisle_stain_color(0), true)


func _add_flavor_props() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_flavor(props, "BulletinBoard", "bulletin", Vector2(900, 994), Vector2i(40, 48), "Board", "Read", "A potluck flyer, a lost glove, and a bake-sale date.")
	_add_flavor(props, "GuestBook", "guest_book", Vector2(640, 1024), Vector2i(32, 24), "Guest book", "Read", "Last week someone wrote 'glad we came.' The ink is still shiny.")
	_add_flavor(props, "SanctuaryPiano", "piano", InteriorLayout.POS_SANCT_PIANO, Vector2i(72, 40), "Piano", "Look", "The hymn is still open to the third verse.", Vector2(56, 14))
	_add_flavor(props, "StainedGlassLook", "stained_glass", Vector2(1220, 504), Vector2i(32, 56), "Window", "Look", "Morning color pools on the carpet. It makes the room feel kept.")
	_add_flavor(props, "HymnBoardLook", "hymn_board", Vector2(260, 464), Vector2i(28, 40), "Hymn board", "Read", "Today's numbers are in Margaret's careful hand.", Vector2(16, 10))
	_add_flavor(props, "VisionSketch", "vision_sketch", Vector2(80, 140), Vector2i(28, 24), "Sketch", "Look", "A pencil drawing of extra wings and a taller roof. Somebody was dreaming on scrap paper.")
	_add_flavor(props, "OfficePhoto", "photo", Vector2(280, 60), Vector2i(20, 24), "Photo", "Look", "A faded picnic. Nobody wrote names on the back.")
	_add_flavor(props, "RestroomLook", "restroom_door", Vector2(1420, 320), Vector2i(24, 48), "Door", "Look", "The lock works. That's enough.", Vector2(16, 20))
	_add_flavor(props, "PrayerBoxLook", "prayer_box", Vector2(820, 1104), Vector2i(22, 22), "Box", "Look", "Folded notes wait for Sunday. Nobody signed them.")
	_add_flavor(props, "PrayerJournal", "journal_stand", Vector2(620, 188), Vector2i(20, 24), "Journal", "Read", "The last line is only 'still here.' The page is not dated.")
	_add_flavor(props, "ChoirSchedule", "practice_board", Vector2(1000, 55), Vector2i(28, 32), "Board", "Read", "Thursday rehearsal. Bring folders. Coffee after.")
	_add_flavor(props, "OfferingLook", "offering_plates", Vector2(400, 848), Vector2i(28, 16), "Plates", "Look", "The plates are empty and polished. Sunday will fill them.")


func _add_ambients() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	_add_ambient(
		props,
		"PrayerNeighbor",
		"prayer_neighbor",
		0,
		Vector2(528, 130),
		[Vector2(520, 128), Vector2(548, 136)],
		PackedStringArray(["Day", "Evening"]),
		InteriorLayout.weekdays(),
		8,
		18,
		true
	)
	_add_ambient(
		props,
		"ChoirHelper",
		"choir_helper",
		1,
		Vector2(864, 120),
		[Vector2(840, 118), Vector2(900, 130)],
		PackedStringArray(["Day"]),
		PackedStringArray(["Monday", "Tuesday", "Wednesday", "Friday"]),
		9,
		16,
		true
	)


func _paint_ground() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	var tex := InteriorArt.atlas()
	if layer == null or tex == null:
		push_error("Sanctuary ground is missing")
		return
	layer.tile_set = _make_tileset(tex)
	for y in InteriorLayout.SANCTUARY_SIZE.y:
		for x in InteriorLayout.SANCTUARY_SIZE.x:
			layer.set_cell(Vector2i(x, y), 0, InteriorLayout.TILE_WALL)
	_fill_rect(layer, InteriorLayout.SANCT_OFFICE, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_PRAYER, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_CHOIR, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_STORAGE, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_HALLWAY, InteriorLayout.TILE_WOOD)
	_fill_rect(layer, InteriorLayout.SANCT_WORSHIP, InteriorLayout.TILE_CARPET)
	_fill_rect(layer, InteriorLayout.SANCT_NARTHEX, InteriorLayout.TILE_STONE)
	for y in range(InteriorLayout.SANCT_NARTHEX.position.y, InteriorLayout.SANCT_NARTHEX.end.y):
		layer.set_cell(Vector2i(22, y), 0, InteriorLayout.TILE_RUNNER)
		layer.set_cell(Vector2i(23, y), 0, InteriorLayout.TILE_RUNNER)
	for cell in InteriorLayout.sanctuary_doorways():
		layer.set_cell(cell, 0, InteriorLayout.TILE_WOOD)
	for y in range(InteriorLayout.SANCT_WORSHIP.position.y, InteriorLayout.SANCT_WORSHIP.end.y):
		layer.set_cell(Vector2i(22, y), 0, InteriorLayout.TILE_RUNNER)
		layer.set_cell(Vector2i(23, y), 0, InteriorLayout.TILE_RUNNER)
	for y in InteriorLayout.sanctuary_stain_rows():
		layer.set_cell(Vector2i(6, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(7, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(38, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(39, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(22, y), 0, InteriorLayout.TILE_STAIN)
		layer.set_cell(Vector2i(23, y), 0, InteriorLayout.TILE_STAIN)


func _add_walls() -> void:
	var layer := get_node_or_null("Ground") as TileMapLayer
	if layer == null:
		return
	for y in InteriorLayout.SANCTUARY_SIZE.y:
		for x in InteriorLayout.SANCTUARY_SIZE.x:
			if layer.get_cell_atlas_coords(Vector2i(x, y)) == InteriorLayout.TILE_WALL:
				_add_rect(Vector2(x * 32 + 16, y * 32 + 16), Vector2(32, 32))


func _fill_rect(layer: TileMapLayer, rect: Rect2i, tile: Vector2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			layer.set_cell(Vector2i(x, y), 0, tile)


func _make_tileset(tex: Texture2D) -> TileSet:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(32, 32)
	for i in 8:
		atlas.create_tile(Vector2i(i, 0))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_source(atlas, 0)
	return tileset


func _ensure_pews() -> void:
	var props := get_node_or_null("Props")
	if props == null:
		return
	var rows := InteriorLayout.pew_rows()
	for i in rows.size():
		_ensure_pew(props, "PewL%d" % (i + 1), Vector2(InteriorLayout.PEW_LEFT_X, rows[i]))
		_ensure_pew(props, "PewR%d" % (i + 1), Vector2(InteriorLayout.PEW_RIGHT_X, rows[i]))


func _ensure_pew(props: Node, node_name: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var pew := SolidProp.new()
	pew.name = node_name
	pew.position = pos
	pew.block_size = InteriorLayout.PEW_BLOCK
	pew.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(pew)
	props.add_child(pew)


func _add_solid(props: Node, node_name: String, frame_id: String, pos: Vector2, block: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := SolidProp.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.block_size = block
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_deco(props: Node, node_name: String, frame_id: String, pos: Vector2, z: int) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.z_index = z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_wall_deco(props: Node, node_name: String, frame_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.z_index = InteriorLayout.WALL_DECO_Z
	sprite.z_as_relative = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not sprite.is_in_group("interior_wall_deco"):
		sprite.add_to_group("interior_wall_deco")
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_rug(props: Node, node_name: String, frame_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	sprite.z_index = -2
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _mark_prop(node: Node) -> void:
	if node != null and not node.is_in_group("interior_prop"):
		node.add_to_group("interior_prop")


func _add_glass(props: Node, node_name: String, frame_id: String, pos: Vector2) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)
	_add_stained_light(node_name + "Light", pos + Vector2(0, 36), _glass_color(frame_id))
	var inward := -80.0 if pos.x > 736.0 else 80.0
	_add_stained_light(node_name + "FloorLight", pos + Vector2(inward, 70), _glass_color(frame_id))


func _add_stain_pool(props: Node, node_name: String, pos: Vector2, frame_id: String = "stain_pool") -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = InteriorArt.texture(frame_id)
	sprite.centered = true
	sprite.z_index = -1
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mark_prop(sprite)
	props.add_child(sprite)


func _add_office_window(props: Node) -> void:
	if props.get_node_or_null("OfficeWindow") != null:
		return
	var sprite := Sprite2D.new()
	sprite.name = "OfficeWindow"
	sprite.texture = InteriorArt.texture("stained_glass_c")
	sprite.centered = true
	if sprite.texture != null:
		sprite.offset = Vector2(0, -sprite.texture.get_height() * 0.5)
	sprite.position = Vector2(192, 40)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	props.add_child(sprite)
	_add_lamp_light("OfficeGlow", Vector2(140, 110), Color(1, 0.86, 0.62), 0.7)


func _add_flavor(
	props: Node,
	node_name: String,
	frame_id: String,
	pos: Vector2,
	frame: Vector2i,
	speaker: String,
	prompt: String,
	line: String,
	block: Vector2 = Vector2.ZERO
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var sheet := InteriorArt.texture(frame_id)
	if sheet == null:
		return
	var prop := SpeechProp.new()
	prop.name = node_name
	prop.position = pos
	prop.sheet = sheet
	prop.frame_size = frame
	prop.frame_count = 1
	prop.speaker_name = speaker
	prop.prompt_text = prompt
	prop.line = line
	prop.radius = 36.0
	if block != Vector2.ZERO:
		prop.blocks_movement = true
		prop.block_size = block
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	prop.add_child(sprite)
	_mark_prop(prop)
	props.add_child(prop)


func _add_ambient(
	props: Node,
	node_name: String,
	person_id: String,
	variant: int,
	pos: Vector2,
	route_points: Array,
	phases: PackedStringArray,
	days: PackedStringArray,
	from_hour: int,
	until_hour: int,
	hide_service: bool
) -> void:
	if props.get_node_or_null(node_name) != null:
		return
	var person := InteriorAmbient.new()
	person.name = node_name
	person.person_id = person_id
	person.crowd_index = 0
	person.art_variant = variant
	person.appear_phases = phases
	person.days = days
	person.from_hour = from_hour
	person.until_hour = until_hour
	person.hide_during_service = hide_service
	person.position = pos
	person.prompt_text = "Say hello"
	person.radius = 36.0
	person.blocks_movement = false
	if person_id == "choir_helper":
		person.idle_line = "Just stacking the music. Don't mind me."
	else:
		person.idle_line = "The room is quiet. That feels right."
	var route: Array[Vector2] = []
	for point in route_points:
		if point is Vector2:
			route.append(point)
	person.set_route(route)
	props.add_child(person)


func _add_stained_light(light_name: String, pos: Vector2, color: Color, aisle: bool = false) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = light_name
	lamp.position = pos
	lamp.color = color
	lamp.energy = TimeOfDay.stained_aisle_energy() if aisle else 0.7
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = InteriorLayout.AISLE_STAIN_LIGHT_SCALE if aisle else 2.8
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_stained_aisle" if aisle else "tod_stained")
	lighting.add_child(lamp)


func _add_lamp_light(light_name: String, pos: Vector2, color: Color, energy: float) -> void:
	var lighting := get_node_or_null("Lighting")
	if lighting == null or lighting.get_node_or_null(light_name) != null:
		return
	var lamp := PointLight2D.new()
	lamp.name = light_name
	lamp.position = pos
	lamp.color = color
	lamp.energy = energy
	lamp.texture = PlaceholderArt.glow()
	lamp.texture_scale = 2.4
	lamp.shadow_enabled = false
	lamp.add_to_group("tod_lamp")
	lighting.add_child(lamp)


func _glass_color(frame_id: String) -> Color:
	if frame_id.ends_with("_b"):
		return Color(0.42, 0.52, 0.92)
	if frame_id.ends_with("_c"):
		return Color(0.95, 0.74, 0.36)
	return Color(0.86, 0.38, 0.42)
