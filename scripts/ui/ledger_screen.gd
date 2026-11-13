class_name LedgerScreen
extends Control
## Church ledger. Dollars live here. L opens it after Chapter 1. Esc or L closes it.

const CHOICES: PackedStringArray = ["None of the surplus", "Half of the surplus", "All of the surplus"]
const CHOICE_IDS: PackedStringArray = ["none", "half", "all"]

var _open: bool = false
var _index: int = 2
var _was_ledger: bool = false
var _was_pause: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false
var _dim: ColorRect
var _panel: PanelContainer
var _label: Label


func _ready() -> void:
	add_to_group("ledger_screen")
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.05, 0.04, 0.07, 0.55)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.position = Vector2(70, 24)
	_panel.custom_minimum_size = Vector2(500, 312)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.96)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(12)
	_panel.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(476, 288)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	add_child(_panel)


func is_open() -> bool:
	return _open


func open_from_service() -> void:
	if not _can_open():
		return
	_index = 2
	_set_open(true)


func close() -> void:
	if not _open:
		return
	_set_open(false)
	_was_ledger = Input.is_action_pressed("ledger")
	_was_pause = Input.is_action_pressed("pause")


func _physics_process(_delta: float) -> void:
	var ledger_down := Input.is_action_pressed("ledger")
	var pause_down := Input.is_action_pressed("pause")
	if NarrativeState.ending_open or NarrativeState.day_card_open or NarrativeState.dialogue_open:
		_was_ledger = ledger_down
		_was_pause = pause_down
		return
	if ledger_down and not _was_ledger:
		if _open:
			close()
		elif _can_open():
			_set_open(true)
	_was_ledger = ledger_down
	if _open and pause_down and not _was_pause:
		close()
		_was_pause = pause_down
		return
	_was_pause = pause_down
	if not _open:
		_sync_held()
		return
	if _label != null:
		_label.text = _body_text()
	if not _can_choose():
		_sync_held()
		return
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_index = maxi(_index - 1, 0)
	if down and not _down_was:
		_index = mini(_index + 1, CHOICES.size() - 1)
	if confirm and not _confirm_was:
		_confirm()
	_up_was = up
	_down_was = down
	_confirm_was = confirm


func _set_open(is_open: bool) -> void:
	_open = is_open
	visible = is_open
	NarrativeState.ledger_open = is_open
	if is_open:
		var journal := get_tree().get_first_node_in_group("journal_panel") if get_tree() != null else null
		if journal != null and journal.has_method("close"):
			journal.call("close")
		_sync_held()
		if _label != null:
			_label.text = _body_text()


func _can_open() -> bool:
	return NarrativeState.flag_is_true("weekly_loop") or NarrativeState.flag_is_true("chapter_one_complete")


func _can_choose() -> bool:
	var funds := _funds()
	if funds == null or not bool(funds.call("has_pending")):
		return false
	return str(funds.get("project_state")) == "active"


func _confirm() -> void:
	var funds := _funds()
	if funds == null:
		return
	var choice := CHOICE_IDS[_index]
	funds.call("apply_contribution", choice)
	if _label != null:
		_label.text = _body_text()


func _body_text() -> String:
	var funds := _funds()
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Church ledger")
	var week := DayClock.week_number()
	if funds != null:
		var pending: Dictionary = funds.call("pending_snapshot")
		if int(pending.get("week", 0)) > 0:
			week = int(pending.get("week", week))
	lines.append("Week %d" % week)
	lines.append("")
	if funds == null:
		lines.append("The books are not open yet.")
		lines.append("L or Esc  close")
		return "\n".join(lines)
	var pending: Dictionary = funds.call("pending_snapshot")
	var last: Dictionary = funds.call("last_entry")
	var offering := int(pending.get("offering", 0))
	var expenses := int(pending.get("expenses", 0))
	var contribution := 0
	if int(pending.get("week", 0)) > 0:
		if str(pending.get("choice", "")).is_empty() and bool(funds.call("has_pending")):
			contribution = 0
		else:
			contribution = int(last.get("contribution", 0))
	elif not last.is_empty():
		offering = int(last.get("offering", 0))
		expenses = int(last.get("expenses", 0))
		contribution = int(last.get("contribution", 0))
	lines.append("This week")
	lines.append("  Offering            $%d" % offering)
	for row in funds.call("expense_rows"):
		if row is Dictionary:
			var item: Dictionary = row
			lines.append("  %-18s $%d" % [str(item.get("label", "Expense")), int(item.get("amount", 0))])
	lines.append("  To the hall         $%d" % contribution)
	lines.append("  Balance             $%d" % int(funds.get("balance")))
	lines.append("")
	var state := str(funds.get("project_state"))
	if state == "none":
		lines.append("No project is on the books yet.")
	else:
		lines.append(str(funds.call("project_name")))
		lines.append("  $%d of $%d" % [int(funds.get("project_progress")), int(funds.call("project_cost"))])
		if state == "repairing":
			lines.append("  Harold is on the boards this week.")
		elif state == "repaired":
			lines.append("  The hall is open.")
	lines.append("")
	lines.append("Recent weeks")
	var recent: Array = funds.call("recent_history", 4)
	if recent.is_empty():
		lines.append("  None yet.")
	else:
		for row_v in recent:
			if not row_v is Dictionary:
				continue
			var row: Dictionary = row_v
			lines.append("  Week %d   in $%d   out $%d   hall $%d" % [
				int(row.get("week", 0)),
				int(row.get("offering", 0)),
				int(row.get("expenses", 0)),
				int(row.get("contribution", 0)),
			])
	lines.append("")
	lines.append(str(funds.call("flavor_line")))
	if _can_choose():
		lines.append("")
		lines.append("This week's surplus toward the hall?")
		for i in CHOICES.size():
			var mark := "> " if i == _index else "  "
			lines.append(mark + CHOICES[i])
		lines.append("E  confirm")
	lines.append("L or Esc  close")
	return "\n".join(lines)


func _funds() -> Node:
	return get_node_or_null("/root/ChurchFunds")


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
