class_name ActionToast
extends PanelContainer
## Compact one-line feedback for till, water, harvest, repairs, and pickups.
## Never covers the player or the worked tile. Never captures input.

const HOLD_SECONDS := 1.2
const FADE_SECONDS := 0.25
const FONT_SIZE := 11
## Left gutter, above the hotbar and fully left of the centered prompt bar.
const SLOT_LEFT := 8.0
const SLOT_RIGHT := 164.0
const SLOT_TOP := -62.0
const SLOT_BOTTOM := -40.0

var _left: float = 0.0
var _label: Label


func _enter_tree() -> void:
	add_to_group("action_toast")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	anchor_top = 1.0
	anchor_bottom = 1.0
	anchor_left = 0.0
	anchor_right = 0.0
	_apply_slot()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.82)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(1)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.name = "Line"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_label.clip_text = true
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	add_child(_label)


func _process(delta: float) -> void:
	if _left <= 0.0:
		return
	_left -= delta
	if _left <= 0.0:
		visible = false
		modulate.a = 1.0
		return
	if _left < FADE_SECONDS:
		modulate.a = clampf(_left / FADE_SECONDS, 0.0, 1.0)


func show_message(text: String) -> void:
	if _label == null or text.is_empty():
		return
	_label.text = text
	visible = true
	modulate.a = 1.0
	_left = HOLD_SECONDS + FADE_SECONDS


func is_showing() -> bool:
	return visible and _left > 0.0


func current_text() -> String:
	if _label == null:
		return ""
	return _label.text


func remaining() -> float:
	return _left


func captures_input() -> bool:
	return mouse_filter != Control.MOUSE_FILTER_IGNORE


func overlaps_control(other: Control) -> bool:
	if other == null or not visible or not other.visible:
		return false
	return get_global_rect().intersects(other.get_global_rect())


func _apply_slot() -> void:
	offset_left = SLOT_LEFT
	offset_right = SLOT_RIGHT
	offset_top = SLOT_TOP
	offset_bottom = SLOT_BOTTOM


static func say(tree: SceneTree, text: String) -> void:
	if tree == null or text.is_empty():
		return
	var node := tree.get_first_node_in_group("action_toast")
	if node != null and node.has_method("show_message"):
		node.call("show_message", text)
