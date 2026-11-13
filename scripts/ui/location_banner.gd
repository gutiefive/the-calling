class_name LocationBanner
extends Label
## Area name, shown for a moment when a room starts.

var _left: float = 0.0


func _ready() -> void:
	add_to_group("location_banner")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 16)
	add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	add_theme_color_override("font_shadow_color", Color(0.12, 0.1, 0.14, 0.85))
	add_theme_constant_override("shadow_offset_x", 1)
	add_theme_constant_override("shadow_offset_y", 1)


func show_place(place_name: String) -> void:
	text = place_name
	visible = not place_name.is_empty()
	_left = 2.8


func _process(delta: float) -> void:
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and bool(story.get("journal_open")):
		visible = false
		return
	if _left <= 0.0:
		visible = false
		return
	_left -= delta
	visible = _left > 0.0
