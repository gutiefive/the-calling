extends Control
## Goals, then a small controls primer. Shown once after the intro, never on Continue.

var _phase: String = ""
var _hold_release: bool = false
var _confirm_was: bool = false
var _pause_was: bool = false
var _dim: ColorRect
var _panel: PanelContainer
var _label: Label


func _ready() -> void:
	add_to_group("opening_handoff")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.05, 0.04, 0.07, 0.35)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.position = Vector2(70, 34)
	_panel.custom_minimum_size = Vector2(500, 220)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.94)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(12)
	_panel.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(476, 196)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	add_child(_panel)
	call_deferred("_begin_if_pending")


func is_open() -> bool:
	return _phase != ""


func current_phase() -> String:
	return _phase


func body_text() -> String:
	if _label == null:
		return ""
	return _label.text


func show_goals() -> void:
	_set_phase("goals")


func show_primer() -> void:
	_set_phase("primer")


func dismiss() -> void:
	if _phase == "goals":
		_set_phase("primer")
		return
	_close()


func _begin_if_pending() -> void:
	if not SaveGame.pending_opening_handoff:
		return
	if NarrativeState.flag_is_true("primer_seen"):
		SaveGame.pending_opening_handoff = false
		return
	_hold_release = true
	_confirm_was = true
	_pause_was = true
	_set_phase("goals")


func _physics_process(_delta: float) -> void:
	if _phase != "":
		DayClock.held = true
	var pause_down := Input.is_action_pressed("pause")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if _hold_release:
		if not confirm and not pause_down:
			_hold_release = false
			_confirm_was = false
			_pause_was = false
		return
	if _phase == "":
		_confirm_was = confirm
		_pause_was = pause_down
		return
	if (confirm and not _confirm_was) or (pause_down and not _pause_was):
		dismiss()
	_confirm_was = confirm
	_pause_was = pause_down


func _set_phase(phase: String) -> void:
	_phase = phase
	visible = phase != ""
	NarrativeState.primer_open = phase != ""
	if _panel != null:
		_panel.visible = phase != ""
	if phase == "primer":
		_panel.position = Vector2(352, 40)
		_panel.custom_minimum_size = Vector2(280, 232)
		if _label != null:
			_label.custom_minimum_size = Vector2(256, 208)
		if _dim != null:
			_dim.color = Color(0.05, 0.04, 0.07, 0.12)
	elif phase == "goals":
		_panel.position = Vector2(70, 34)
		_panel.custom_minimum_size = Vector2(500, 220)
		if _label != null:
			_label.custom_minimum_size = Vector2(476, 196)
		if _dim != null:
			_dim.color = Color(0.05, 0.04, 0.07, 0.35)
	if _label != null:
		_label.text = _body_for(phase)
	if _panel != null:
		_panel.size = Vector2.ZERO
	_sync_held()


func _close() -> void:
	_phase = ""
	visible = false
	NarrativeState.primer_open = false
	NarrativeState.set_flag("primer_seen", true)
	SaveGame.pending_opening_handoff = false
	DayClock.held = false
	_hold_release = true


func _body_for(phase: String) -> String:
	var block: Dictionary = IntroData.primer() if phase == "primer" else IntroData.goals()
	var lines := PackedStringArray()
	var title := str(block.get("title", "")).strip_edges()
	if not title.is_empty():
		lines.append(title)
		lines.append("")
	var raw: Variant = block.get("lines", [])
	if raw is Array:
		for item in raw:
			var line := str(item).strip_edges()
			if not line.is_empty():
				lines.append(line)
	var dismiss_line := str(block.get("dismiss", "E  continue")).strip_edges()
	if not dismiss_line.is_empty():
		lines.append("")
		lines.append(dismiss_line)
	return "\n".join(lines)


func _sync_held() -> void:
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	_pause_was = Input.is_action_pressed("pause")
	_hold_release = _confirm_was or _pause_was
