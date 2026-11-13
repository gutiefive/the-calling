extends CanvasLayer
## Shown after the ledger. Continue stays in Oakridge. Restart clears the story. Quit leaves.

const CHOICES: PackedStringArray = ["Continue in Oakridge", "Restart from the beginning", "Quit"]

var _index: int = 0
var _shown: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false
var _title: Label
var _body: Label
var _options: Array[Label] = []


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_showing() -> bool:
	return _shown


func body_text() -> String:
	if _body == null:
		return ""
	return _body.text


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.08, 0.07, 0.1, 0.82)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := VBoxContainer.new()
	add_child(center)
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 36.0
	center.offset_top = 28.0
	center.offset_right = -36.0
	center.offset_bottom = -24.0
	center.add_theme_constant_override("separation", 8)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title = Label.new()
	_title.text = "End of Chapter 1"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 22)
	_title.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	center.add_child(_title)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size", 14)
	_body.add_theme_color_override("font_color", Color(0.89, 0.82, 0.72))
	center.add_child(_body)
	for choice in CHOICES:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
		center.add_child(label)
		_options.append(label)
	var hint := Label.new()
	hint.text = "Up and Down choose. E confirms."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	center.add_child(hint)
	_refresh()


func _process(_delta: float) -> void:
	if _shown:
		return
	if NarrativeState.flag_is_true("week_continues"):
		return
	if not NarrativeState.flag_is_true("ledger_revealed"):
		return
	if NarrativeState.dialogue_open:
		return
	_show()


func _physics_process(_delta: float) -> void:
	if not _shown:
		_sync_held()
		return
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_index = maxi(_index - 1, 0)
		_refresh()
	if down and not _down_was:
		_index = mini(_index + 1, CHOICES.size() - 1)
		_refresh()
	if confirm and not _confirm_was:
		_confirm()
	_up_was = up
	_down_was = down
	_confirm_was = confirm


func _show() -> void:
	_shown = true
	visible = true
	_index = 0
	NarrativeState.ending_open = true
	if _body != null:
		_body.text = ChapterSummary.text()
	_sync_held()
	_refresh()


func _confirm() -> void:
	if _index == 0:
		continue_story()
		return
	if _index == 1:
		restart_story()
		return
	var tree := get_tree()
	if tree != null:
		tree.quit()


func continue_story() -> void:
	NarrativeState.set_flag("week_continues", true)
	NarrativeState.ending_open = false
	_shown = false
	visible = false


func restart_story() -> void:
	SaveGame.delete_save()
	SaveGame.begin_new_game(get_tree())


func _refresh() -> void:
	for i in _options.size():
		var mark := "> " if i == _index else "  "
		_options[i].text = mark + CHOICES[i]


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
