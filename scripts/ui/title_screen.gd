extends Control
## Launch menu. New Game starts Thursday. Continue opens the one save slot.

var _choices: PackedStringArray = PackedStringArray()
var _index: int = 0
var _labels: Array[Label] = []
var _box: VBoxContainer
var _hint: Label
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false


func _ready() -> void:
	DayClock.held = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	refresh()


func choices() -> PackedStringArray:
	return _choices


func current_choice() -> String:
	if _index < 0 or _index >= _choices.size():
		return ""
	return _choices[_index]


func refresh() -> void:
	_choices = PackedStringArray(["New Game"])
	if FileAccess.file_exists(SaveGame.SAVE_PATH):
		_choices.append("Continue")
	_choices.append("Quit")
	_index = mini(_index, _choices.size() - 1)
	_rebuild_labels()


func start_new_game() -> void:
	DayClock.held = false
	SaveGame.begin_new_game(get_tree())


func continue_game() -> void:
	if not FileAccess.file_exists(SaveGame.SAVE_PATH):
		_set_hint("No save to continue.")
		return
	DayClock.held = false
	var tree := get_tree()
	if tree == null or not SaveGame.load_from_disk(tree):
		DayClock.held = true
		_set_hint("Couldn't continue.")


func _build() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.16, 0.14, 0.18, 1.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_box = VBoxContainer.new()
	add_child(_box)
	_box.set_anchors_preset(Control.PRESET_CENTER)
	_box.offset_left = -180.0
	_box.offset_top = -110.0
	_box.offset_right = 180.0
	_box.offset_bottom = 110.0
	_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_theme_constant_override("separation", 6)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title := Label.new()
	title.text = "The Calling"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	_box.add_child(title)
	var sub := Label.new()
	sub.text = "A first week in Oakridge"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	_box.add_child(sub)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	_set_hint("Up and Down choose. E confirms.")


func _rebuild_labels() -> void:
	for label in _labels:
		label.queue_free()
	_labels.clear()
	if _box == null:
		return
	for choice in _choices:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_box.add_child(label)
		_labels.append(label)
	if _hint != null:
		if _hint.get_parent() != _box:
			_box.add_child(_hint)
		_box.move_child(_hint, -1)
	_sync_held()
	_paint()


func _physics_process(_delta: float) -> void:
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_index = maxi(_index - 1, 0)
		_paint()
	if down and not _down_was:
		_index = mini(_index + 1, _choices.size() - 1)
		_paint()
	if confirm and not _confirm_was:
		_confirm()
	_up_was = up
	_down_was = down
	_confirm_was = confirm


func _confirm() -> void:
	match current_choice():
		"New Game":
			start_new_game()
		"Continue":
			continue_game()
		"Quit":
			var tree := get_tree()
			if tree != null:
				tree.quit()


func _paint() -> void:
	for i in _labels.size():
		var mark := "> " if i == _index else "  "
		_labels[i].text = mark + _choices[i]


func _set_hint(text: String) -> void:
	if _hint != null:
		_hint.text = text


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
