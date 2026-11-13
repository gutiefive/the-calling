class_name InteriorArt
extends RefCounted
## Cached interior furniture. Draws from InteriorFrames when a PNG is missing.

static var _cache: Dictionary = {}


static func texture(frame_id: String) -> Texture2D:
	if frame_id.is_empty():
		return null
	if _cache.has(frame_id):
		var cached: Variant = _cache[frame_id]
		if cached is Texture2D:
			return cached
	var image: Image = InteriorFrames.build(frame_id)
	if image == null:
		return null
	var tex := ImageTexture.create_from_image(image)
	_cache[frame_id] = tex
	return tex


static func atlas() -> Texture2D:
	return texture("atlas")
