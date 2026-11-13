class_name ItemArt
extends RefCounted
## Loads authored item PNGs. Falls back to ItemFrames if a file is missing.

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const DIR := "res://assets/items"

static var _cache: Dictionary = {}


static func icon(item_id: String) -> Texture2D:
	var key := Catalog.icon_id(item_id)
	if key.is_empty():
		key = item_id
	if _cache.has(key):
		var cached: Variant = _cache[key]
		if cached is Texture2D:
			return cached
	var path := "%s/%s.png" % [DIR, key]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		tex = ItemFrames.texture(key)
	if tex != null:
		_cache[key] = tex
	return tex
