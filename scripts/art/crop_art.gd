class_name CropArt
extends RefCounted
## Loads authored garden PNGs. Falls back to CropFrames if a file is missing.

const DIR := "res://assets/garden"

static var _cache: Dictionary = {}


static func plot_texture(row: Dictionary) -> Texture2D:
	return tile_texture(row, 0)


static func tile_texture(row: Dictionary, neighbor_mask: int = 0) -> Texture2D:
	var stage := str(row.get("stage", "untouched"))
	var crop_id := str(row.get("crop", ""))
	var watered := bool(row.get("watered", false))
	var cell := _cell_of(row)
	var key := "%s|%s|%s|%d|%d,%d" % [stage, crop_id, "w" if watered else "d", neighbor_mask, cell.x, cell.y]
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var image := _compose(row, neighbor_mask, cell)
	if image == null:
		return null
	var tex := ImageTexture.create_from_image(image)
	_cache[key] = tex
	return tex


static func crop_texture(crop_id: String, stage: String) -> Texture2D:
	if crop_id.is_empty() or stage.is_empty():
		return null
	var key := "crop|%s|%s" % [crop_id, stage]
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var image := _image("%s_%s" % [crop_id, stage])
	if image == null:
		return null
	var tex := ImageTexture.create_from_image(image)
	_cache[key] = tex
	return tex


static func target_texture() -> Texture2D:
	var key := "fx|target"
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var tex := _load_or_build("fx_target")
	if tex != null:
		_cache[key] = tex
	return tex


static func fx_texture(kind: String) -> Texture2D:
	var frame_id := "fx_%s" % kind
	var cache_key := "fx|%s" % frame_id
	if _cache.has(cache_key):
		var cached: Variant = _cache[cache_key]
		if cached is Texture2D:
			return cached
	var tex := _load_or_build(frame_id)
	if tex != null:
		_cache[cache_key] = tex
	return tex


static func prop_texture(prop_id: String) -> Texture2D:
	if prop_id.is_empty():
		return null
	var key := "prop|%s" % prop_id
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var tex := _load_or_build(prop_id)
	if tex != null:
		_cache[key] = tex
	return tex


static func _compose(row: Dictionary, neighbor_mask: int = 0, cell: Vector2i = Vector2i.ZERO) -> Image:
	var stage := str(row.get("stage", "untouched"))
	var watered := bool(row.get("watered", false))
	var soil := CropFrames.ground(watered, neighbor_mask, stage, cell)
	if soil == null:
		return null
	return soil.duplicate()


static func _cell_of(row: Dictionary) -> Vector2i:
	var id := str(row.get("id", ""))
	if id.is_empty():
		return Vector2i.ZERO
	var parts := id.split(",")
	if parts.size() < 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))


static func _load_or_build(frame_id: String) -> Texture2D:
	var path := "%s/%s.png" % [DIR, frame_id]
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			return tex
	return CropFrames.texture(frame_id)


static func _image(frame_id: String) -> Image:
	var path := "%s/%s.png" % [DIR, frame_id]
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			var loaded := tex.get_image()
			if loaded != null:
				return loaded
	return CropFrames.build(frame_id)
