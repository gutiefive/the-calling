class_name PixelDraw
extends RefCounted
## Shared pixel helpers for authored tiles and props. Palette colors only.

static var _palette_colors: Dictionary = {}


static func pal(color_name: String) -> Color:
	var colors := _palette()
	if colors.has(color_name):
		return colors[color_name]
	push_error("Missing palette color %s" % color_name)
	return Color(42.0 / 255.0, 36.0 / 255.0, 48.0 / 255.0, 1.0)


static func canvas(w: int, h: int) -> Image:
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


static func px(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)


static func fill(image: Image, color: Color) -> void:
	image.fill(color)


static func fill_empty(image: Image, color: Color) -> void:
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a == 0.0:
				image.set_pixel(x, y, color)


static func rect(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			px(image, xx, yy, color)


static func ellipse(image: Image, cx: int, cy: int, rx: int, ry: int, color: Color) -> void:
	if rx <= 0 or ry <= 0:
		return
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var nx := float(x - cx) / float(rx)
			var ny := float(y - cy) / float(ry)
			if nx * nx + ny * ny <= 1.0:
				px(image, x, y, color)


static func blit(dst: Image, src: Image, ox: int, oy: int) -> void:
	for y in src.get_height():
		for x in src.get_width():
			var pixel: Color = src.get_pixel(x, y)
			if pixel.a == 0.0:
				continue
			px(dst, ox + x, oy + y, pixel)


static func stamp(image: Image, rows: PackedStringArray, colors: Dictionary, ox: int, oy: int) -> void:
	for y in rows.size():
		var row := rows[y]
		for x in row.length():
			var ch := row.substr(x, 1)
			if ch == "." or not colors.has(ch):
				continue
			var color: Color = colors[ch]
			px(image, ox + x, oy + y, color)


static func noise(x: int, y: int, seed: int = 0) -> int:
	return ((x * 73 + y * 151 + seed * 19) ^ (x * 17 + y * 31 + seed * 47)) & 255


static func speckle(
		image: Image,
		seed: int,
		min_n: int,
		max_n: int,
		color: Color,
		only_opaque: bool = true
) -> void:
	for y in image.get_height():
		for x in image.get_width():
			if only_opaque and image.get_pixel(x, y).a < 0.5:
				continue
			var n := noise(x, y, seed)
			if n >= min_n and n <= max_n:
				px(image, x, y, color)


static func speckle_rect(
		image: Image,
		area: Rect2i,
		seed: int,
		min_n: int,
		max_n: int,
		color: Color,
		only_opaque: bool = true
) -> void:
	for y in range(area.position.y, area.position.y + area.size.y):
		for x in range(area.position.x, area.position.x + area.size.x):
			if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
				continue
			if only_opaque and image.get_pixel(x, y).a < 0.5:
				continue
			var n := noise(x, y, seed)
			if n >= min_n and n <= max_n:
				px(image, x, y, color)


static func shade(image: Image, area: Rect2i, seed: int, light: Color, shadow: Color) -> void:
	var w := maxi(area.size.x, 1)
	var h := maxi(area.size.y, 1)
	for y in range(area.position.y, area.position.y + area.size.y):
		for x in range(area.position.x, area.position.x + area.size.x):
			if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
				continue
			if image.get_pixel(x, y).a < 0.5:
				continue
			var nx := float(x - area.position.x) / float(w)
			var ny := float(y - area.position.y) / float(h)
			var n := noise(x, y, seed)
			# Light from the top-left: warm highlights, cool-leaning shadow swatches.
			if nx + ny < 0.72 and n > 198:
				px(image, x, y, light)
			elif nx + ny > 1.28 and n < 72:
				px(image, x, y, shadow)


static func crack(image: Image, x0: int, y0: int, length: int, color: Color, down_right: bool = true) -> void:
	var x := x0
	var y := y0
	for i in length:
		px(image, x, y, color)
		if down_right:
			if (i & 1) == 0:
				x += 1
			else:
				y += 1
		else:
			if (i & 1) == 0:
				x -= 1
			else:
				y += 1


static func outline(image: Image) -> Image:
	var w := image.get_width()
	var h := image.get_height()
	var copy := image.duplicate()
	var ink := pal("outline")
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
