class_name CharacterFrames
extends RefCounted
## Shared 32x48 character template plus small overlays. Original pixels only.
## Walk frames reuse one pose and offset the marked limbs. Palette comes from
## assets/source/palette/the_calling_master.gpl.

const CELL_W := 32
const CELL_H := 48
const SHEET_COLS := 6
const SHEET_ROWS := 4
const MAP_W := 16
const MAP_X := 8
const MAP_Y := 7

const FACINGS: PackedStringArray = ["down", "up", "left", "right"]
const NAMES: PackedStringArray = [
	"player", "margaret", "harold", "thomas", "frank", "sarah"
]


static var _palette_colors: Dictionary = {}


static func output_path(who: String) -> String:
	if who == "player":
		return "res://assets/characters/player_sheet.png"
	return "res://assets/characters/npc_%s_sheet.png" % who


static func build_sheet(who: String) -> Image:
	var sheet := _new(CELL_W * SHEET_COLS, CELL_H * SHEET_ROWS)
	for row in FACINGS.size():
		var facing := FACINGS[row]
		for col in SHEET_COLS:
			_blit(sheet, _frame(who, facing, col), col * CELL_W, row * CELL_H)
	return sheet


static func _frame(who: String, facing: String, col: int) -> Image:
	var draw_facing := facing
	var mirror := false
	if facing == "right":
		draw_facing = "left"
		mirror = true
	var bob := 0
	var left_dx := 0
	var right_dx := 0
	if col == 1:
		bob = 1
	elif col == 2:
		bob = -1
		left_dx = -2
		right_dx = 2
	elif col == 4:
		bob = -1
		left_dx = 2
		right_dx = -2
	if mirror:
		var swap := left_dx
		left_dx = -right_dx
		right_dx = -swap
	var kit := _kit(who)
	var image := _new(CELL_W, CELL_H)
	_shadow(image)
	_stamp(image, _body(str(kit["body"]), draw_facing), MAP_X, MAP_Y + bob, kit, left_dx, right_dx)
	_stamp(image, _hair(who, draw_facing), MAP_X, MAP_Y + bob - 2, kit, 0, 0)
	_stamp(image, _extra(who, draw_facing), MAP_X, MAP_Y + bob - 2, kit, 0, 0)
	var framed := _outline(image)
	if mirror:
		framed = _mirror(framed)
	return framed


static func _kit(who: String) -> Dictionary:
	match who:
		"player":
			return _colors("slim", "hair", "hair_l", "shirt", "shirt_l", "shirt_d", "pants", "pants_d", "paper", "gold")
		"margaret":
			return _colors("skirt", "bun", "bun_d", "cardigan", "moss", "cardigan_d", "skirt", "skirt_d", "grey_d", "paper")
		"harold":
			return _colors("stocky", "grey", "grey_d", "wood", "wood_l", "wood_d", "pants", "pants_d", "gold", "cream")
		"thomas":
			return _colors("slim", "hair_l", "wood_l", "wood", "wood_l", "wood_d", "pants", "pants_d", "cream", "path_c")
		"frank":
			return _colors("stocky", "grey_d", "grey", "grey", "grey_d", "gravel_d", "pants", "pants_d", "grey_d", "path_c")
		"sarah":
			return _colors("skirt", "hair", "hair_l", "flower", "flower2", "brick_d", "skirt", "skirt_d", "wood", "cream")
		_:
			return _colors("slim", "hair", "hair_l", "shirt", "shirt_l", "shirt_d", "pants", "pants_d", "paper", "gold")


static func _colors(
		body: String,
		hair: String,
		hair_l: String,
		shirt: String,
		shirt_l: String,
		shirt_d: String,
		legs: String,
		legs_d: String,
		acc: String,
		acc2: String
) -> Dictionary:
	return {
		"body": body,
		"s": _swatch("skin"),
		"d": _swatch("skin_d"),
		"n": _swatch("skin_d"),
		"i": _swatch("outline"),
		"h": _swatch(hair),
		"H": _swatch(hair_l),
		"t": _swatch(shirt),
		"T": _swatch(shirt_l),
		"u": _swatch(shirt_d),
		"a": _swatch(shirt_d),
		"b": _swatch(shirt_d),
		"l": _swatch(legs),
		"r": _swatch(legs_d),
		"f": _swatch("shoe"),
		"g": _swatch("shoe"),
		"k": _swatch(legs),
		"K": _swatch(legs_d),
		"x": _swatch(acc),
		"y": _swatch(acc2),
		"z": _swatch("gold"),
	}


static func _body(kind: String, facing: String) -> PackedStringArray:
	if facing == "up":
		return _BODY_UP_SKIRT if kind == "skirt" else (_BODY_UP_STOCKY if kind == "stocky" else _BODY_UP_SLIM)
	if facing == "left":
		return _BODY_SIDE_SKIRT if kind == "skirt" else (_BODY_SIDE_STOCKY if kind == "stocky" else _BODY_SIDE_SLIM)
	if kind == "skirt":
		return _BODY_DOWN_SKIRT
	if kind == "stocky":
		return _BODY_DOWN_STOCKY
	return _BODY_DOWN_SLIM


static func _hair(who: String, facing: String) -> PackedStringArray:
	match who:
		"margaret":
			return _HAIR_MARGARET_SIDE if facing == "left" else (_HAIR_MARGARET_UP if facing == "up" else _HAIR_MARGARET_DOWN)
		"harold":
			return _HAIR_HAROLD_SIDE if facing == "left" else (_HAIR_HAROLD_UP if facing == "up" else _HAIR_HAROLD_DOWN)
		"thomas":
			return _HAIR_THOMAS_SIDE if facing == "left" else (_HAIR_THOMAS_UP if facing == "up" else _HAIR_THOMAS_DOWN)
		"frank":
			return _HAIR_FRANK_SIDE if facing == "left" else (_HAIR_FRANK_UP if facing == "up" else _HAIR_FRANK_DOWN)
		"sarah":
			return _HAIR_SARAH_SIDE if facing == "left" else (_HAIR_SARAH_UP if facing == "up" else _HAIR_SARAH_DOWN)
		_:
			return _HAIR_PLAYER_SIDE if facing == "left" else (_HAIR_PLAYER_UP if facing == "up" else _HAIR_PLAYER_DOWN)


static func _extra(who: String, facing: String) -> PackedStringArray:
	match who:
		"player":
			return _EXTRA_COLLAR_SIDE if facing == "left" else (_EMPTY if facing == "up" else _EXTRA_COLLAR_DOWN)
		"margaret":
			return _EXTRA_GLASSES_SIDE if facing == "left" else (_EMPTY if facing == "up" else _EXTRA_GLASSES_DOWN)
		"harold":
			return _EXTRA_HAROLD_SIDE if facing == "left" else (_EMPTY if facing == "up" else _EXTRA_HAROLD_DOWN)
		"thomas":
			return _EXTRA_APRON_SIDE if facing == "left" else (_EXTRA_APRON_UP if facing == "up" else _EXTRA_APRON_DOWN)
		"frank":
			return _EMPTY
		"sarah":
			return _EXTRA_BAG_SIDE if facing == "left" else (_EMPTY if facing == "up" else _EXTRA_BAG_DOWN)
		_:
			return _EMPTY


static func _stamp(
		image: Image,
		rows: PackedStringArray,
		ox: int,
		oy: int,
		kit: Dictionary,
		left_dx: int,
		right_dx: int
) -> void:
	for y in rows.size():
		var row := rows[y]
		if row.length() != MAP_W:
			push_error("CharacterFrames row length %d (need %d): %s" % [row.length(), MAP_W, row])
			continue
		for x in row.length():
			var ch := row.substr(x, 1)
			if ch == "." or not kit.has(ch):
				continue
			var color: Color = kit[ch]
			var dx := 0
			if ch == "l" or ch == "f" or ch == "a":
				dx = left_dx
			elif ch == "r" or ch == "g" or ch == "b":
				dx = right_dx
			_px(image, ox + x + dx, oy + y, color)


static func _shadow(image: Image) -> void:
	var ink := _swatch("outline")
	ink.a = 90.0 / 255.0
	_ellipse(image, 16, 45, 6, 2, ink)


static func _outline(image: Image) -> Image:
	var w := image.get_width()
	var h := image.get_height()
	var copy := image.duplicate()
	var ink := _swatch("outline")
	for y in h:
		for x in w:
			if image.get_pixel(x, y).a > 0.78:
				continue
			var touch := false
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + offset.x
				var ny: int = y + offset.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and image.get_pixel(nx, ny).a > 0.78:
					touch = true
					break
			if touch:
				copy.set_pixel(x, y, ink)
	return copy


static func _mirror(image: Image) -> Image:
	var copy := _new(image.get_width(), image.get_height())
	var w := image.get_width()
	for y in image.get_height():
		for x in w:
			copy.set_pixel(w - 1 - x, y, image.get_pixel(x, y))
	return copy


static func _blit(dst: Image, src: Image, ox: int, oy: int) -> void:
	for y in src.get_height():
		for x in src.get_width():
			var pixel: Color = src.get_pixel(x, y)
			if pixel.a == 0.0:
				continue
			_px(dst, ox + x, oy + y, pixel)


static func _ellipse(image: Image, cx: int, cy: int, rx: int, ry: int, color: Color) -> void:
	if rx <= 0 or ry <= 0:
		return
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var nx := float(x - cx) / float(rx)
			var ny := float(y - cy) / float(ry)
			if nx * nx + ny * ny <= 1.0:
				_px(image, x, y, color)


static func _px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)


static func _new(w: int, h: int) -> Image:
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


static func _swatch(name: String) -> Color:
	var colors := _palette()
	if colors.has(name):
		return colors[name]
	push_error("Missing palette color %s" % name)
	return Color(42.0 / 255.0, 36.0 / 255.0, 48.0 / 255.0, 1.0)


static func _palette() -> Dictionary:
	if not _palette_colors.is_empty():
		return _palette_colors
	var text := FileAccess.get_file_as_string("res://assets/source/palette/the_calling_master.gpl")
	for line in text.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.is_empty() or trimmed.begins_with("#") or trimmed.begins_with("GIMP") or trimmed.begins_with("Name:") or trimmed.begins_with("Columns:"):
			continue
		var parts := trimmed.split(" ", false)
		if parts.size() < 4:
			continue
		_palette_colors[parts[3]] = Color8(int(parts[0]), int(parts[1]), int(parts[2]), 255)
	return _palette_colors


# 16-wide maps. Dots are empty. Limb letters (a/l/f left, b/r/g right) shift on walk.

const _EMPTY: PackedStringArray = [
	"................",
]

const _BODY_DOWN_SLIM: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...sssississs...",
	"...ssssssssss...",
	"....ssddddss....",
	".....sddddds....",
	"......nnnn......",
	"...TTttttttTT...",
	"..aattttttttbb..",
	"..aaTttttttTbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..uauttttttuub..",
	"...uuttttttuu...",
	"....tttttttt....",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
]

const _BODY_DOWN_STOCKY: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...sssississs...",
	"...ssssssssss...",
	"....ssddddss....",
	".....sddddds....",
	"......nnnn......",
	"..TTTttttttTTT..",
	".aaattttttttbbb.",
	".aaaTttttttTbbb.",
	".aaattttttttbbb.",
	".aaattttttttbbb.",
	".uuauttttttuuub.",
	"..uuuttttttuuu..",
	"...tttttttttt...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
	"................",
]

const _BODY_DOWN_SKIRT: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...sssississs...",
	"...ssssssssss...",
	"....ssddddss....",
	".....sddddds....",
	"......nnnn......",
	"...TTttttttTT...",
	"..aattttttttbb..",
	"..aaTttttttTbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"...uttttttttu...",
	"...KKKKKKKKKK...",
	"..kkkkkkkkkkkk..",
	"..kkkkkkkkkkkk..",
	"...kkkkkkkkkk...",
	"....kkkkkkkk....",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
	"................",
]

const _BODY_UP_SLIM: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...ssssssssss...",
	"...ssssssssss...",
	"....ssssssss....",
	".....sddddds....",
	"......nnnn......",
	"...TTttttttTT...",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..uauttttttuub..",
	"...uuttttttuu...",
	"....tttttttt....",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
]

const _BODY_UP_STOCKY: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...ssssssssss...",
	"...ssssssssss...",
	"....ssssssss....",
	".....sddddds....",
	"......nnnn......",
	"..TTTttttttTTT..",
	".aaattttttttbbb.",
	".aaattttttttbbb.",
	".aaattttttttbbb.",
	".aaattttttttbbb.",
	".uuauttttttuuub.",
	"..uuuttttttuuu..",
	"...tttttttttt...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
	"................",
]

const _BODY_UP_SKIRT: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"....ssssssss....",
	"...ssssssssss...",
	"...ssssssssss...",
	"...ssssssssss...",
	"....ssssssss....",
	".....sddddds....",
	"......nnnn......",
	"...TTttttttTT...",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"..aattttttttbb..",
	"...uttttttttu...",
	"...KKKKKKKKKK...",
	"..kkkkkkkkkkkk..",
	"..kkkkkkkkkkkk..",
	"...kkkkkkkkkk...",
	"....kkkkkkkk....",
	"...llll..rrrr...",
	"...ffff..gggg...",
	"...ffff..gggg...",
	"................",
	"................",
]

const _BODY_SIDE_SLIM: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	".....ssssss.....",
	"....ssssssss....",
	"....ssisssss....",
	"....ssssssss....",
	".....sddddds....",
	"......dddd......",
	"......nnnn......",
	"....Tttttttu....",
	"...aattttttbb...",
	"...aaTtttttbb...",
	"...aattttttbb...",
	"...aattttttbb...",
	"....uttttttu....",
	".....tttttt.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....fff.ggg.....",
	"....fff.ggg.....",
	"................",
	"................",
]

const _BODY_SIDE_STOCKY: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	".....ssssss.....",
	"....ssssssss....",
	"....ssisssss....",
	"....ssssssss....",
	".....sddddds....",
	"......dddd......",
	"......nnnn......",
	"...TTttttttuu...",
	"..aaattttttbbb..",
	"..aaaTtttttbbb..",
	"..aaattttttbbb..",
	"..aaattttttbbb..",
	"...uuttttttuu...",
	"....tttttttt....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....lll.rrr.....",
	"....fff.ggg.....",
	"....fff.ggg.....",
	"................",
	"................",
	"................",
]

const _BODY_SIDE_SKIRT: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	".....ssssss.....",
	"....ssssssss....",
	"....ssisssss....",
	"....ssssssss....",
	".....sddddds....",
	"......dddd......",
	"......nnnn......",
	"....Tttttttu....",
	"...aattttttbb...",
	"...aaTtttttbb...",
	"...aattttttbb...",
	"...aattttttbb...",
	"....uttttttu....",
	"....KKKKKKKK....",
	"...kkkkkkkkkk...",
	"...kkkkkkkkkk...",
	"....kkkkkkkk....",
	".....kkkkkk.....",
	"....lll.rrr.....",
	"....fff.ggg.....",
	"....fff.ggg.....",
	"................",
	"................",
]

const _HAIR_PLAYER_DOWN: PackedStringArray = [
	"................",
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...hhsssssshh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_PLAYER_UP: PackedStringArray = [
	"................",
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"....hhhhhhhh....",
	"................",
	"................",
	"................",
]

const _HAIR_PLAYER_SIDE: PackedStringArray = [
	"................",
	".....hhhhhhh....",
	"....hhhhhhhhh...",
	"....hhHHHHHhh...",
	"....h....hhhh...",
	".........hhh....",
	"..........hh....",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_MARGARET_DOWN: PackedStringArray = [
	"...hhhhhhhhhh...",
	"..hhhhhhhhhhhh..",
	"..hhhHHHHHHhhh..",
	".hhhhhhhhhhhhhh.",
	"..hhhhsssshhhh..",
	"...hh......hh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_MARGARET_UP: PackedStringArray = [
	"...hhhhhhhhhh...",
	"..hhhhhhhhhhhh..",
	"..hhhhhhhhhhhh..",
	".hhhhhhhhhhhhhh.",
	"..hhhhHHHHHhhh..",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"....hhhhhhhh....",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_MARGARET_SIDE: PackedStringArray = [
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhhHHHHHhh...",
	"..hh....hhhhh...",
	"..h......hhhh...",
	"..........hhh...",
	"...........hh...",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_HAROLD_DOWN: PackedStringArray = [
	"................",
	"................",
	"...hh......hh...",
	"...hH......Hh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_HAROLD_UP: PackedStringArray = [
	"................",
	"....hh....hh....",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...hhhhhhhhhh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_HAROLD_SIDE: PackedStringArray = [
	"................",
	"................",
	".........hhhh...",
	"........hHHHh...",
	".........hhh....",
	"..........hh....",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_THOMAS_DOWN: PackedStringArray = [
	"................",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhhh..",
	"...hhHHHHHHhh...",
	"...hhsssssshh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_THOMAS_UP: PackedStringArray = [
	"................",
	"...hhhhhhhhhh...",
	"..hhhhhhhhhhhh..",
	"...hhHHHHHHhh...",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"....hhhhhhhh....",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_THOMAS_SIDE: PackedStringArray = [
	"................",
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhHHHHhhhh...",
	"....h....hhhh...",
	".........hhhh...",
	"..........hh....",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_FRANK_DOWN: PackedStringArray = [
	"..xxxxxxxxxxxx..",
	".xxxxxxxxxxxxxx.",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_FRANK_UP: PackedStringArray = [
	"..xxxxxxxxxxxx..",
	".xxxxxxxxxxxxxx.",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...h........h...",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_FRANK_SIDE: PackedStringArray = [
	".xxxxxxxxxxxxx..",
	"xxxxxxxxxxxxxx..",
	"....hhhhhhhh....",
	".....hHHHhhh....",
	".........hhh....",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
]

const _HAIR_SARAH_DOWN: PackedStringArray = [
	"................",
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...hhsssssshh...",
	"...h........hh..",
	".............hh.",
	"..............h.",
	"..............h.",
	"................",
	"................",
	"................",
]

const _HAIR_SARAH_UP: PackedStringArray = [
	"................",
	"....hhhhhhhh....",
	"...hhhhhhhhhh...",
	"...hhhhhhhhhh...",
	"...hhHHHHHHhh...",
	"...hhhhhhhhhh...",
	"....hhhhhhhh....",
	"......hhhh......",
	"......hhhh......",
	".......hh.......",
	"................",
	"................",
]

const _HAIR_SARAH_SIDE: PackedStringArray = [
	"................",
	".....hhhhhhh....",
	"....hhhhhhhhh...",
	"....hhHHHHHhh...",
	"....h....hhhhh..",
	".........hhhhh..",
	"..........hhhh..",
	"...........hhh..",
	"............hh..",
	"................",
	"................",
	"................",
]

const _EXTRA_COLLAR_DOWN: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"......yyyy......",
	"......y..y......",
]

const _EXTRA_COLLAR_SIDE: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"......yy........",
	"......y.........",
]

const _EXTRA_GLASSES_DOWN: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"...xx.xx.xx.....",
]

const _EXTRA_GLASSES_SIDE: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"....xxx.........",
]

const _EXTRA_HAROLD_DOWN: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"...zz.zz.zz.....",
	"................",
	"................",
	"................",
	"................",
	"......yyyy......",
]

const _EXTRA_HAROLD_SIDE: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"....zzz.........",
	"................",
	"................",
	"................",
	"................",
	"......yy........",
]

const _EXTRA_APRON_DOWN: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	".....yyyyyy.....",
	".....yyyyyy.....",
	".....yyyyyy.....",
	".....yyyyyy.....",
]

const _EXTRA_APRON_UP: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	".....yyyyyy.....",
	".....y....y.....",
	".....y....y.....",
]

const _EXTRA_APRON_SIDE: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"......yyyyy.....",
	"......yyyyy.....",
	"......yyyyy.....",
]

const _EXTRA_BAG_DOWN: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"..............xx",
	".............xxx",
	".............xxx",
]

const _EXTRA_BAG_SIDE: PackedStringArray = [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"...........xx...",
	"..........xxx...",
	"..........xxx...",
]
