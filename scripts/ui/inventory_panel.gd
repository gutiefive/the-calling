extends Control
## Personal pack. I toggles it. Keyboard moves the highlight; E equips a tool.

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const Icons := preload("res://scripts/art/item_art.gd")

const COLS := 4
const CELL := 42
const ICON := 32
const PANEL_POS := Vector2(64, 12)
const PANEL_SIZE := Vector2(512, 336)

var _open: bool = false
var _index: int = 0
var _was_inv: bool = false
var _was_pause: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _left_was: bool = false
var _right_was: bool = false
var _confirm_was: bool = false
var _dim: ColorRect
var _panel: PanelContainer
var _title: Label
var _meta: Label
var _grid: Control
var _cells: Array[PanelContainer] = []
var _icons: Array[TextureRect] = []
var _qty_labels: Array[Label] = []
var _detail: Label
var _hint: Label


func _ready() -> void:
	add_to_group("inventory_panel")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_dim = ColorRect.new()
	_dim.color = Color(0.05, 0.04, 0.07, 0.45)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.position = PANEL_POS
	_panel.custom_minimum_size = PANEL_SIZE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.96)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(10)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var body := VBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_constant_override("separation", 6)
	_panel.add_child(body)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(header)
	_title = _make_label("Inventory", 16, Color(0.93, 0.88, 0.78))
	header.add_child(_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	_meta = _make_label("", 14, Color(0.78, 0.72, 0.62))
	_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(_meta)
	_grid = Control.new()
	_grid.custom_minimum_size = Vector2(COLS * CELL + 8, 4 * CELL + 8)
	_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(_grid)
	_build_cells()
	_detail = _make_label("", 14, Color(0.89, 0.82, 0.72))
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.custom_minimum_size = Vector2(480, 36)
	_detail.size_flags_vertical = Control.SIZE_SHRINK_END
	body.add_child(_detail)
	_hint = _make_label("I or Esc  close    E  equip tool or seed", 13, Color(0.78, 0.72, 0.62))
	body.add_child(_hint)
	var pack := _pack()
	if pack != null:
		if pack.has_signal("inventory_changed") and not pack.inventory_changed.is_connected(_refresh):
			pack.inventory_changed.connect(_refresh)
		if pack.has_signal("wallet_changed") and not pack.wallet_changed.is_connected(_refresh):
			pack.wallet_changed.connect(_refresh)
		if pack.has_signal("equipped_changed") and not pack.equipped_changed.is_connected(_refresh):
			pack.equipped_changed.connect(_refresh)


func is_open() -> bool:
	return _open


func close() -> void:
	if not _open:
		return
	_set_open(false)
	_was_inv = Input.is_action_pressed("inventory")
	_was_pause = Input.is_action_pressed("pause")


func open() -> void:
	if _open or not _can_toggle():
		return
	_set_open(true)


func _physics_process(_delta: float) -> void:
	var inv_down := Input.is_action_pressed("inventory")
	var pause_down := Input.is_action_pressed("pause")
	if not _can_toggle() and not _open:
		_was_inv = inv_down
		_was_pause = pause_down
		return
	if inv_down and not _was_inv:
		if _open:
			close()
		elif _can_toggle():
			_set_open(true)
	_was_inv = inv_down
	if _open and pause_down and not _was_pause:
		close()
		_was_pause = pause_down
		return
	_was_pause = pause_down
	if not _open:
		_sync_held()
		return
	_refresh()
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var left := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_move(0, -1)
	if down and not _down_was:
		_move(0, 1)
	if left and not _left_was:
		_move(-1, 0)
	if right and not _right_was:
		_move(1, 0)
	if confirm and not _confirm_was:
		_equip_selected()
	_up_was = up
	_down_was = down
	_left_was = left
	_right_was = right
	_confirm_was = confirm


func _set_open(is_open: bool) -> void:
	_open = is_open
	visible = is_open
	var story := get_node_or_null("/root/NarrativeState")
	if story != null:
		if story.has_method("set_inventory_open"):
			story.call("set_inventory_open", is_open)
		else:
			story.set("inventory_open", is_open)
	_sync_clock_chrome()
	if is_open:
		_close_other_panels()
		_index = 0
		_sync_held()
		_refresh()


func _can_toggle() -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null:
		return true
	if bool(story.get("ending_open")) or bool(story.get("day_card_open")) or bool(story.get("dialogue_open")) or bool(story.get("primer_open")):
		return false
	if bool(story.get("journal_open")) or bool(story.get("map_open")) or bool(story.get("ledger_open")):
		return false
	if bool(story.get("shop_open")):
		return false
	return true


func _close_other_panels() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var journal := tree.get_first_node_in_group("journal_panel")
	if journal != null and journal.has_method("close"):
		journal.call("close")


func _move(dx: int, dy: int) -> void:
	var cap := 0
	var pack := _pack()
	if pack != null and pack.has_method("capacity"):
		cap = int(pack.call("capacity"))
	if cap <= 0:
		return
	var col := _index % COLS
	var row := int(_index / COLS)
	var rows := int(ceil(float(cap) / float(COLS)))
	col = clampi(col + dx, 0, COLS - 1)
	row = clampi(row + dy, 0, rows - 1)
	_index = clampi(row * COLS + col, 0, cap - 1)
	_refresh()


func _equip_selected() -> void:
	var pack := _pack()
	if pack == null or not pack.has_method("slots"):
		return
	var rows: Array = pack.call("slots")
	if _index < 0 or _index >= rows.size():
		return
	var row_v: Variant = rows[_index]
	if not row_v is Dictionary:
		return
	var item_id := str((row_v as Dictionary).get("id", ""))
	if Catalog.item_is_tool(item_id) and pack.has_method("equip"):
		pack.call("equip", item_id)
	elif Catalog.item_is_seed(item_id) and pack.has_method("equip_seed"):
		pack.call("equip_seed", item_id)
	_refresh()


func _refresh() -> void:
	if not _open:
		return
	var pack := _pack()
	var cap := 16
	var used := 0
	var cash := 0
	var equipped := ""
	var rows: Array = []
	if pack != null:
		if pack.has_method("capacity"):
			cap = int(pack.call("capacity"))
		if pack.has_method("occupied_slots"):
			used = int(pack.call("occupied_slots"))
		if pack.has_method("cash"):
			cash = int(pack.call("cash"))
		if pack.has_method("equipped_tool"):
			equipped = str(pack.call("equipped_tool"))
		if pack.has_method("slots"):
			rows = pack.call("slots")
	if _meta != null:
		_meta.text = "%d/%d    Wallet $%d" % [used, cap, cash]
	for i in _cells.size():
		var filled := i < rows.size()
		var selected := i == _index
		_tint_cell(i, filled, selected)
		if filled:
			var row_v: Variant = rows[i]
			var row: Dictionary = row_v if row_v is Dictionary else {}
			var item_id := str(row.get("id", ""))
			if i < _icons.size() and _icons[i] != null:
				_icons[i].texture = Icons.icon(item_id)
				_icons[i].visible = true
			if i < _qty_labels.size() and _qty_labels[i] != null:
				var qty := int(row.get("qty", 0))
				_qty_labels[i].text = "" if qty <= 1 else str(qty)
		else:
			if i < _icons.size() and _icons[i] != null:
				_icons[i].texture = null
				_icons[i].visible = false
			if i < _qty_labels.size() and _qty_labels[i] != null:
				_qty_labels[i].text = ""
	if _detail != null:
		_detail.text = _detail_text(rows, equipped)
	if _hint != null:
		_hint.text = "I or Esc  close    E  equip tool or seed    arrows move"


func _detail_text(rows: Array, equipped: String) -> String:
	if _index < 0 or _index >= rows.size():
		return "Empty slot."
	var row_v: Variant = rows[_index]
	if not row_v is Dictionary:
		return "Empty slot."
	var row: Dictionary = row_v
	var item_id := str(row.get("id", ""))
	var qty := int(row.get("qty", 0))
	var kind := "Tool" if Catalog.item_is_tool(item_id) else Catalog.category(item_id)
	if kind.is_empty():
		kind = "Item"
	var lines: PackedStringArray = PackedStringArray()
	lines.append("%s  ×%d" % [Catalog.display_name(item_id), qty])
	lines.append(kind)
	lines.append(Catalog.description(item_id))
	if Catalog.item_is_tool(item_id):
		if equipped == item_id:
			lines.append("Equipped.")
		else:
			lines.append("E equips this tool.")
	elif Catalog.item_is_seed(item_id):
		var prepared := ""
		var pack := _pack()
		if pack != null and pack.has_method("equipped_seed"):
			prepared = str(pack.call("equipped_seed"))
		if prepared == item_id:
			lines.append("Ready to plant.")
		else:
			lines.append("E prepares this seed for planting.")
	else:
		lines.append("Consumable.")
	return "\n".join(lines)


func _build_cells() -> void:
	_cells.clear()
	_icons.clear()
	_qty_labels.clear()
	for i in 16:
		var cell := PanelContainer.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.position = Vector2((i % COLS) * CELL, int(i / COLS) * CELL)
		cell.custom_minimum_size = Vector2(CELL - 4, CELL - 4)
		cell.size = Vector2(CELL - 4, CELL - 4)
		var inner := Control.new()
		inner.custom_minimum_size = Vector2(CELL - 8, CELL - 8)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(inner)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.position = Vector2(6, 4)
		icon.custom_minimum_size = Vector2(ICON, ICON)
		icon.size = Vector2(ICON, ICON)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		inner.add_child(icon)
		var qty := Label.new()
		qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		qty.position = Vector2(20, 22)
		qty.add_theme_font_size_override("font_size", 11)
		qty.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
		inner.add_child(qty)
		_grid.add_child(cell)
		_cells.append(cell)
		_icons.append(icon)
		_qty_labels.append(qty)
		_tint_cell(i, false, false)


func _tint_cell(index: int, filled: bool, selected: bool) -> void:
	if index < 0 or index >= _cells.size():
		return
	var style := StyleBoxFlat.new()
	if selected:
		style.bg_color = Color(0.22, 0.18, 0.16, 1.0)
		style.border_color = Color(0.77, 0.61, 0.31, 1.0)
	elif filled:
		style.bg_color = Color(0.18, 0.14, 0.18, 1.0)
		style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	else:
		style.bg_color = Color(0.10, 0.08, 0.12, 1.0)
		style.border_color = Color(0.28, 0.22, 0.20, 1.0)
	style.set_border_width_all(1)
	style.set_content_margin_all(2)
	_cells[index].add_theme_stylebox_override("panel", style)


func _make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _sync_clock_chrome() -> void:
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_method("sync_chrome"):
		clock.call("sync_chrome")


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_left_was = Input.is_action_pressed("move_left")
	_right_was = Input.is_action_pressed("move_right")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
