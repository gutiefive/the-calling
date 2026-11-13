extends Control
## Esc pauses. Up and Down choose. E, Space, or Enter confirms Save or Load.

const OPTIONS: PackedStringArray = ["Resume", "Save", "Load", "Map"]

@onready var _title: Label = $Center/Title
@onready var _hint: Label = $Center/Hint

var _index: int = 0
var _labels: Array[Label] = []
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false
var _pause_was: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _title != null:
		_title.text = "Paused"
	var center := get_node_or_null("Center") as Control
	if center != null:
		center.offset_left = -160.0
		center.offset_right = 160.0
		center.offset_top = -110.0
		center.offset_bottom = 110.0
	for option in OPTIONS:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if center != null:
			center.add_child(label)
		_labels.append(label)
	if center != null and _hint != null:
		center.move_child(_hint, center.get_child_count() - 1)
	if _hint != null:
		_hint.add_theme_font_size_override("font_size", 14)
	_refresh()


func _physics_process(_delta: float) -> void:
	var pause_down := Input.is_action_pressed("pause")
	if pause_down and not _pause_was:
		_handle_pause()
	_pause_was = pause_down
	var tree := get_tree()
	if tree == null or not tree.paused:
		_sync_held()
		return
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_index = maxi(_index - 1, 0)
		_refresh()
	if down and not _down_was:
		_index = mini(_index + 1, OPTIONS.size() - 1)
		_refresh()
	if confirm and not _confirm_was:
		_confirm()
	_up_was = up
	_down_was = down
	_confirm_was = confirm


func _handle_pause() -> void:
	if NarrativeState.ending_open:
		return
	var tree := get_tree()
	if tree == null:
		return
	var journal := tree.get_first_node_in_group("journal_panel")
	if journal != null and journal.has_method("is_open") and bool(journal.call("is_open")):
		journal.call("close")
		return
	var map := tree.get_first_node_in_group("town_map")
	if map != null and map.has_method("is_open") and bool(map.call("is_open")):
		map.call("close")
		return
	toggle_pause()


func toggle_pause() -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.paused = not tree.paused
	visible = tree.paused
	if tree.paused:
		_index = 0
		_set_status("Up and Down choose. E confirms.")
		_sync_held()
		_refresh()


func _confirm() -> void:
	match _index:
		0:
			toggle_pause()
		1:
			_do_save()
		2:
			_do_load()
		_:
			_open_map()


func _do_save() -> void:
	var tree := get_tree()
	if tree != null and SaveGame.save_to_disk(tree):
		_set_status("Saved.")
	else:
		_set_status("Couldn't save.")


func _open_map() -> void:
	var map := get_tree().get_first_node_in_group("town_map")
	if map != null and map.has_method("open"):
		map.call("open")


func _do_load() -> void:
	var tree := get_tree()
	if tree == null:
		return
	if not FileAccess.file_exists(SaveGame.SAVE_PATH):
		_set_status("No save to load.")
		return
	visible = false
	if not SaveGame.load_from_disk(tree):
		tree.paused = true
		visible = true
		_set_status("Couldn't load.")


func _refresh() -> void:
	for i in _labels.size():
		var mark := "> " if i == _index else "  "
		_labels[i].text = mark + OPTIONS[i]


func _set_status(text: String) -> void:
	if _hint != null:
		_hint.text = text


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
