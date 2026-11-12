class_name DayCard
extends Control
## A short fade, then the morning, then a few things you might do. None of them are required.

var _phase: String = ""
var _fade: float = 0.0
var _card_open: bool = false
var _hold_release: bool = false
var _confirm_was: bool = false
var _dim: ColorRect
var _panel: PanelContainer
var _label: Label


func _ready() -> void:
	add_to_group("day_card")
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.05, 0.04, 0.07, 0.0)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.position = Vector2(70, 70)
	_panel.custom_minimum_size = Vector2(500, 180)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.94)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(12)
	_panel.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(476, 156)
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	add_child(_panel)


func is_blocking() -> bool:
	return _phase != "" or _card_open or _hold_release


func card_text() -> String:
	if _label == null:
		return ""
	return _label.text


func is_card_visible() -> bool:
	return _card_open and _panel != null and _panel.visible


func begin_sleep() -> void:
	if is_blocking():
		return
	_phase = "out"
	_fade = 0.0
	_card_open = false
	_hold_release = true
	_confirm_was = true
	visible = true
	if _panel != null:
		_panel.visible = false
	NarrativeState.day_card_open = true
	_paint_dim()


func _process(delta: float) -> void:
	if _phase == "out":
		_fade = minf(1.0, _fade + delta / 0.28)
		_paint_dim()
		if _fade >= 1.0:
			DayClock.sleep_until_morning()
			_phase = "in"
	elif _phase == "in":
		_fade = maxf(0.0, _fade - delta / 0.28)
		_paint_dim()
		if _fade <= 0.0:
			_phase = ""
			_show_card()


func _physics_process(_delta: float) -> void:
	var held := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if _hold_release:
		if not held:
			_hold_release = false
			_confirm_was = false
		return
	if not _card_open:
		_confirm_was = held
		return
	if held and not _confirm_was:
		_close_card()
	_confirm_was = held


func _show_card() -> void:
	_card_open = true
	visible = true
	if _panel != null:
		_panel.visible = true
	if _label != null:
		_label.text = _body()
	NarrativeState.day_card_open = true


func _close_card() -> void:
	_card_open = false
	_hold_release = true
	if _panel != null:
		_panel.visible = false
	visible = false
	NarrativeState.day_card_open = false


func _body() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(DayClock.weekday_name())
	lines.append("Morning. A few things you might do, if you feel like it.")
	for suggestion in NarrativeState.day_suggestions():
		lines.append(suggestion)
	lines.append("E  continue")
	return "\n".join(lines)


func _paint_dim() -> void:
	if _dim == null:
		return
	_dim.color = Color(0.05, 0.04, 0.07, _fade)
