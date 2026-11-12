class_name JsonFile
extends RefCounted
## Reads a project JSON file. Imported JSON resources and plain text both work.

static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("Missing data file %s" % path)
		return null
	var resource: Resource = load(path)
	if resource is JSON:
		return (resource as JSON).data
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Empty data file %s" % path)
		return null
	return JSON.parse_string(text)
