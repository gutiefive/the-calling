class_name CropArt
extends RefCounted
## Loads authored garden PNGs. Falls back to CropFrames if a file is missing.

const DIR := "res://assets/garden"

static var _cache: Dictionary = {}


static func plot_texture(row: Dictionary) -> Texture2D:
	var stage := str(row.get("stage", "untouched"))
	var crop_id := str(row.get("crop", ""))
	var watered := bool(row.get("watered", false))
	var key := "%s|%s|%s" % [stage, crop_id, "w" if watered else "d"]
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var image := _compose(row)
	if image == null:
		return null
	var tex := ImageTexture.create_from_image(image)
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


static func _compose(row: Dictionary) -> Image:
	var stage := str(row.get("stage", "untouched"))
	var watered := bool(row.get("watered", false))
	var soil_id := "soil_untouched"
	match stage:
		"tilled":
			soil_id = "soil_tilled_wet" if watered else "soil_tilled"
		"harvested":
			soil_id = "soil_harvested"
		"seeded":
			soil_id = "soil_seeded_wet" if watered else "soil_seeded"
		"sprout", "growing", "mature":
			soil_id = "soil_tilled_wet" if watered else "soil_tilled"
		_:
			soil_id = "soil_untouched"
	var soil := _image(soil_id)
	if soil == null:
		return null
	var composed := soil.duplicate()
	if stage == "sprout" or stage == "growing" or stage == "mature":
		var crop_id := str(row.get("crop", ""))
		if not crop_id.is_empty():
			var plant := _image("%s_%s" % [crop_id, stage])
			if plant != null:
				PixelDraw.blit(composed, plant, 0, 0)
	return composed


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
