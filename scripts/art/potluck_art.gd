class_name PotluckArt
extends RefCounted
## Loads authored potluck PNGs. Falls back to PotluckFrames if a file is missing.

const DIR := "res://assets/potluck"

static var _cache: Dictionary = {}


static func texture(frame_id: String) -> Texture2D:
	if frame_id.is_empty():
		return null
	if _cache.has(frame_id):
		var cached: Variant = _cache[frame_id]
		if cached is Texture2D:
			return cached
	var tex := _load_or_build(frame_id)
	if tex != null:
		_cache[frame_id] = tex
	return tex


static func _load_or_build(frame_id: String) -> Texture2D:
	var path := "%s/%s.png" % [DIR, frame_id]
	if ResourceLoader.exists(path):
		var loaded := load(path) as Texture2D
		if loaded != null:
			return loaded
	return PotluckFrames.texture(frame_id)
