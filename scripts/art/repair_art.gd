class_name RepairArt
extends RefCounted
## Loads authored repair PNGs. Falls back to RepairFrames if a file is missing.

const DIR := "res://assets/repairs"

static var _cache: Dictionary = {}


static func texture(frame_id: String) -> Texture2D:
	if frame_id.is_empty() or frame_id == "litter_gone":
		return null
	if _cache.has(frame_id):
		var cached: Variant = _cache[frame_id]
		if cached is Texture2D:
			return cached
	var tex := _load_or_build(frame_id)
	if tex != null:
		_cache[frame_id] = tex
	return tex


static func fx_texture() -> Texture2D:
	return texture("fx_repair")


static func _load_or_build(frame_id: String) -> Texture2D:
	var path := "%s/%s.png" % [DIR, frame_id]
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			return tex
	return RepairFrames.texture(frame_id)
