extends Node2D
## Letterboxed opening. Data lives in data/intro.json. Hold Esc to skip.

const VIEW := Vector2(640, 360)
const LETTERBOX_TOP := 32.0
const LETTERBOX_BOTTOM := 100.0
const REVEAL_PER_TICK := 1

var _data: Dictionary = {}
var _beats: Array = []
var _index: int = 0
var _reveal: int = 0
var _skip_hold: float = 0.0
var _skip_needed: float = 0.85
var _motion: String = "fade"
var _elapsed: float = 0.0
var _fade: float = 1.0
var _panel_id: String = ""
var _advance_was: bool = false
var _finished: bool = false
var _car: Sprite2D
var _leaf_a: Sprite2D
var _leaf_b: Sprite2D
var _bird: Sprite2D
var _glow: Sprite2D
var _far: Sprite2D
var _mid: Sprite2D
var _body: Label
var _skip_label: Label
var _skip_bar: ColorRect
var _voice_tint: Color = Color(0.93, 0.88, 0.78, 1.0)


func _ready() -> void:
	DayClock.held = true
	_data = IntroData.load_data()
	_beats = IntroData.beats(_data)
	_skip_needed = IntroData.skip_hold_seconds(_data)
	_build()
	if _beats.is_empty():
		_finish()
		return
	_show_beat(0, true)
	_sync_held()


func beat_count() -> int:
	return _beats.size()


func beat_index() -> int:
	return _index


func current_beat_id() -> String:
	if _index < 0 or _index >= _beats.size() or not _beats[_index] is Dictionary:
		return ""
	return IntroData.beat_id(_beats[_index])


func current_panel_id() -> String:
	return _panel_id


func current_text() -> String:
	if _body == null:
		return ""
	return _body.text


func revealed_text() -> String:
	var full := _full_text()
	if _reveal >= full.length():
		return full
	return full.substr(0, _reveal)


func is_revealing() -> bool:
	return _reveal < _full_text().length()


func is_finished() -> bool:
	return _finished


func skip_to_end() -> void:
	_finish()


func jump_to_beat(beat_id: String) -> void:
	for i in _beats.size():
		if not _beats[i] is Dictionary:
			continue
		if IntroData.beat_id(_beats[i]) == beat_id:
			_show_beat(i, true)
			_reveal = _full_text().length()
			_refresh_text()
			return


func advance() -> void:
	if _finished:
		return
	if is_revealing():
		_reveal = _full_text().length()
		_refresh_text()
		return
	if _index >= _beats.size() - 1:
		_finish()
		return
	_show_beat(_index + 1, false)


func _build() -> void:
	var camera := Camera2D.new()
	camera.enabled = true
	camera.position = VIEW * 0.5
	add_child(camera)
	_far = _sprite(Vector2(VIEW.x * 0.5, VIEW.y * 0.5))
	_mid = _sprite(Vector2(VIEW.x * 0.5, VIEW.y * 0.5))
	_car = _sprite(Vector2(220, 236))
	_car.texture = IntroFrames.overlay_texture("car")
	_car.visible = false
	_leaf_a = _sprite(Vector2(480, 120))
	_leaf_a.texture = IntroFrames.overlay_texture("leaf")
	_leaf_a.visible = false
	_leaf_b = _sprite(Vector2(560, 160))
	_leaf_b.texture = IntroFrames.overlay_texture("leaf")
	_leaf_b.visible = false
	_bird = _sprite(Vector2(80, 70))
	_bird.texture = IntroFrames.overlay_texture("bird")
	_bird.visible = false
	_glow = _sprite(Vector2(456, 160))
	_glow.texture = IntroFrames.overlay_texture("window_glow")
	_glow.visible = false
	var ui := CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	var top := ColorRect.new()
	top.color = Color(0.05, 0.04, 0.07, 1.0)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.position = Vector2.ZERO
	top.size = Vector2(VIEW.x, LETTERBOX_TOP)
	ui.add_child(top)
	var bottom := ColorRect.new()
	bottom.color = Color(0.05, 0.04, 0.07, 1.0)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.position = Vector2(0.0, VIEW.y - LETTERBOX_BOTTOM)
	bottom.size = Vector2(VIEW.x, LETTERBOX_BOTTOM)
	ui.add_child(bottom)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(16.0, 266.0)
	panel.size = Vector2(608.0, 86.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.92)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)
	ui.add_child(panel)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(576, 72)
	_body.add_theme_font_size_override("font_size", 15)
	_body.add_theme_color_override("font_color", _voice_tint)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_body)
	_skip_label = Label.new()
	_skip_label.text = IntroData.skip_hint(_data)
	_skip_label.position = Vector2(24.0, 8.0)
	_skip_label.add_theme_font_size_override("font_size", 13)
	_skip_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62, 0.9))
	_skip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_skip_label)
	var meter_bg := ColorRect.new()
	meter_bg.color = Color(0.22, 0.18, 0.2, 0.8)
	meter_bg.position = Vector2(24.0, 28.0)
	meter_bg.size = Vector2(120.0, 4.0)
	meter_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(meter_bg)
	_skip_bar = ColorRect.new()
	_skip_bar.color = Color(0.93, 0.88, 0.78, 0.9)
	_skip_bar.position = Vector2(24.0, 28.0)
	_skip_bar.size = Vector2(0.0, 4.0)
	_skip_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_skip_bar)


func _sprite(pos: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.position = pos
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	return sprite


func _process(delta: float) -> void:
	if _finished:
		return
	DayClock.held = true
	_elapsed += delta
	_animate(delta)
	if Input.is_action_pressed("pause"):
		_skip_hold += delta
		if _skip_bar != null:
			_skip_bar.size.x = 120.0 * clampf(_skip_hold / _skip_needed, 0.0, 1.0)
		if _skip_hold >= _skip_needed:
			_finish()
		return
	_skip_hold = 0.0
	if _skip_bar != null:
		_skip_bar.size.x = 0.0


func _physics_process(_delta: float) -> void:
	if _finished:
		return
	if is_revealing():
		_reveal = mini(_reveal + REVEAL_PER_TICK, _full_text().length())
		_refresh_text()
	var advance_down := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if advance_down and not _advance_was:
		advance()
	_advance_was = advance_down


func _show_beat(index: int, instant: bool) -> void:
	if index < 0 or index >= _beats.size() or not _beats[index] is Dictionary:
		_finish()
		return
	_index = index
	var beat: Dictionary = _beats[index]
	_motion = IntroData.beat_motion(beat)
	_elapsed = 0.0
	_reveal = 0
	var next_panel := IntroData.beat_panel(beat)
	if next_panel != _panel_id:
		_panel_id = next_panel
		_set_panel(_panel_id)
		_fade = 0.0 if not instant else 1.0
	else:
		_fade = 1.0
	var inner := IntroData.beat_voice(beat) == "inner"
	_voice_tint = Color(0.86, 0.82, 0.74, 1.0) if inner else Color(0.93, 0.88, 0.78, 1.0)
	if _body != null:
		_body.add_theme_color_override("font_color", _voice_tint)
	_refresh_text()
	_sync_held()


func _set_panel(panel_id: String) -> void:
	var tex := IntroFrames.texture(panel_id)
	if _mid != null:
		_mid.texture = tex
		_mid.position = Vector2(VIEW.x * 0.5, VIEW.y * 0.5)
		_mid.modulate = Color(1, 1, 1, 1)
	if _far != null:
		_far.texture = tex
		_far.modulate = Color(1, 1, 1, 0.35)
		_far.position = Vector2(VIEW.x * 0.5 + 12.0, VIEW.y * 0.5)
	_car.visible = _motion == "drive"
	_leaf_a.visible = _motion == "leaves"
	_leaf_b.visible = _motion == "leaves"
	_bird.visible = _motion == "birds"
	_glow.visible = _motion == "flicker"
	if _car.visible:
		_car.position = Vector2(180, 236)
	if _glow.visible:
		_glow.position = Vector2(456, 148)


func _animate(delta: float) -> void:
	if _fade < 1.0:
		_fade = minf(1.0, _fade + delta / 0.45)
		if _mid != null:
			_mid.modulate.a = _fade
	var pan := sin(_elapsed * 0.22) * 18.0
	if _motion == "pan_right" and _mid != null:
		_mid.position.x = VIEW.x * 0.5 - 20.0 + _elapsed * 6.0
		if _far != null:
			_far.position.x = VIEW.x * 0.5 - 8.0 + _elapsed * 3.0
	elif _motion == "pan_up" and _mid != null:
		_mid.position.y = VIEW.y * 0.5 + 10.0 - _elapsed * 3.0
	elif _motion == "drive":
		if _mid != null:
			_mid.position.x = VIEW.x * 0.5 + pan * 0.4
		if _car != null:
			_car.position.x = 160.0 + fmod(_elapsed * 28.0, 360.0)
			_car.position.y = 236.0 + sin(_elapsed * 8.0) * 1.5
	elif _motion == "leaves":
		if _leaf_a != null:
			_leaf_a.position = Vector2(480.0 + sin(_elapsed) * 30.0, 120.0 + fmod(_elapsed * 18.0, 80.0))
		if _leaf_b != null:
			_leaf_b.position = Vector2(560.0 + cos(_elapsed * 0.8) * 24.0, 90.0 + fmod(_elapsed * 14.0 + 20.0, 90.0))
	elif _motion == "birds":
		if _bird != null:
			_bird.position = Vector2(fmod(_elapsed * 36.0, 700.0) - 20.0, 64.0 + sin(_elapsed * 2.0) * 10.0)
	elif _motion == "flicker":
		if _glow != null:
			var lit := fmod(_elapsed, 2.6) < 1.8
			_glow.visible = lit
			_glow.modulate.a = 0.7 if lit else 0.0
			if _elapsed > 3.4:
				_glow.visible = false


func _full_text() -> String:
	if _index < 0 or _index >= _beats.size() or not _beats[_index] is Dictionary:
		return ""
	return IntroData.beat_text(_beats[_index])


func _refresh_text() -> void:
	if _body == null:
		return
	_body.text = revealed_text()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	SaveGame.finish_intro(get_tree())


func _sync_held() -> void:
	_advance_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
