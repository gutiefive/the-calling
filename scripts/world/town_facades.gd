class_name TownFacades
extends RefCounted
## Data-driven storefronts and houses. destination_scene is optional so a
## later milestone can turn any facade into an enterable interior.

const OAK_PATH := "res://data/world/oak_storefronts.json"
const MAPLE_PATH := "res://data/world/maple_houses.json"


static func oak_storefronts() -> Array[Dictionary]:
	return _rows(OAK_PATH, "storefronts")


static func maple_houses() -> Array[Dictionary]:
	return _rows(MAPLE_PATH, "houses")


static func _rows(path: String, key: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		return out
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return out
	var data: Dictionary = parsed
	var raw: Variant = data.get(key, [])
	if typeof(raw) != TYPE_ARRAY:
		return out
	var rows: Array = raw
	for row in rows:
		if typeof(row) == TYPE_DICTIONARY:
			out.append(row)
	return out
