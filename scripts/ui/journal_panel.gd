extends PanelContainer
## Lists active and completed quests. J toggles it. Walking waits until it closes.

@onready var _label: Label = $Body

var _open: bool = false
var _was_down: bool = false


func _ready() -> void:
	add_to_group("journal_panel")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _label != null:
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.94)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	add_theme_stylebox_override("panel", style)


func _physics_process(_delta: float) -> void:
	var down := Input.is_action_pressed("journal")
	if NarrativeState.ending_open or NarrativeState.day_card_open or NarrativeState.inventory_open or NarrativeState.shop_open or NarrativeState.dialogue_open or NarrativeState.ledger_open:
		_was_down = down
		return
	if down and not _was_down:
		_set_open(not _open)
	_was_down = down
	if _open and _label != null:
		_label.text = _body_text()


func _exit_tree() -> void:
	if not _open:
		return
	_open = false
	var story := get_node_or_null("/root/NarrativeState")
	if story != null:
		story.set("journal_open", false)


func is_open() -> bool:
	return _open


func close() -> void:
	if not _open:
		return
	_set_open(false)
	_was_down = Input.is_action_pressed("journal")


func _set_open(is_open: bool) -> void:
	_open = is_open
	visible = is_open
	NarrativeState.set_journal_open(is_open)
	if is_open:
		var threads := get_node_or_null("/root/StoryThreads")
		if threads != null and threads.has_method("inspect_reece_key"):
			threads.call("inspect_reece_key")
		if _label != null:
			_label.text = _body_text()


func _body_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Journal")
	lines.append("")
	lines.append("Active")
	var active := NarrativeState.active_quests()
	if active.is_empty():
		lines.append("No active quests.")
	else:
		for quest in active:
			lines.append(str(quest.get("title", "")))
			var objective := str(quest.get("objective", ""))
			if not objective.is_empty():
				lines.append(objective)
	lines.append("")
	lines.append("Requests")
	var ask_lines := PackedStringArray()
	var asks := get_node_or_null("/root/RequestState")
	if asks != null and asks.has_method("journal_lines"):
		var ask_raw: Variant = asks.call("journal_lines")
		if ask_raw is PackedStringArray:
			ask_lines = ask_raw
	if ask_lines.is_empty():
		lines.append("No open asks.")
	else:
		for line in ask_lines:
			lines.append(line)
	lines.append("")
	lines.append("Completed")
	var done := NarrativeState.completed_quests()
	if done.is_empty():
		lines.append("Nothing completed yet.")
	else:
		for quest in done:
			lines.append(str(quest.get("title", "")))
			var objective := str(quest.get("objective", ""))
			if not objective.is_empty():
				lines.append(objective)
	lines.append("")
	lines.append("The church")
	for measure in NarrativeState.growth_lines():
		lines.append(measure)
	lines.append("")
	lines.append("Threads")
	var thread_lines := PackedStringArray()
	var threads := get_node_or_null("/root/StoryThreads")
	if threads != null and threads.has_method("journal_lines"):
		var raw: Variant = threads.call("journal_lines")
		if raw is PackedStringArray:
			thread_lines = raw
	if thread_lines.is_empty():
		lines.append("Nothing unfolding yet.")
	else:
		for line in thread_lines:
			lines.append(line)
	lines.append("")
	lines.append("Notes")
	var notes := NarrativeState.journal_notes()
	if notes.is_empty():
		lines.append("Nothing written down.")
	else:
		for note in notes:
			lines.append(note)
	if NarrativeState.flag_is_true("weekly_loop"):
		lines.append("")
		lines.append("L  church ledger")
	lines.append("")
	lines.append("J or Esc  close")
	return "\n".join(lines)
