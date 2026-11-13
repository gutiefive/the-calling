class_name GroundsPlots
extends RefCounted
## Loads the empty expansion lots on the church campus.

const DATA_PATH := "res://data/grounds/plots.json"


static func all_plots() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if not FileAccess.file_exists(DATA_PATH):
		return rows
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not (parsed is Dictionary):
		return rows
	var data: Dictionary = parsed
	var raw: Variant = data.get("plots", [])
	if not (raw is Array):
		return rows
	for item in raw:
		if item is Dictionary:
			rows.append(item)
	return rows


static func plot_rect(row: Dictionary) -> Rect2i:
	var nums: Variant = row.get("rect", [])
	if not (nums is Array) or nums.size() < 4:
		return Rect2i()
	var values: Array = nums
	return Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))


static func inspect_line(row: Dictionary) -> String:
	return str(row.get("inspect", "Margaret says this was meant for something, once."))


static func display_name(row: Dictionary) -> String:
	return str(row.get("name", "Future Building Site"))
