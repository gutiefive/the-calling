extends Control
## Hardware-store transaction UI. Dollars live here. Dialogue never names them.

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const Icons := preload("res://scripts/art/item_art.gd")

const PANEL_POS := Vector2(88, 16)
const PANEL_SIZE := Vector2(464, 328)

var _open: bool = false
var _index: int = 0
var _was_pause: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false
var _status: String = ""
var _dim: ColorRect
var _panel: PanelContainer
var _title: Label
var _wallet: Label
var _rows: Array[HBoxContainer] = []
var _name_labels: Array[Label] = []
var _price_labels: Array[Label] = []
var _icon: TextureRect
var _detail: Label
var _status_label: Label
var _hint: Label


func _ready() -> void:
	add_to_group("shop_panel")
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
	body.add_theme_constant_override("separation", 4)
	_panel.add_child(body)
	_title = _make_label(Catalog.shop_title(), 16, Color(0.93, 0.88, 0.78))
	body.add_child(_title)
	_wallet = _make_label("", 14, Color(0.78, 0.72, 0.62))
	body.add_child(_wallet)
	var list := VBoxContainer.new()
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_theme_constant_override("separation", 2)
	body.add_child(list)
	for _i in 8:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.custom_minimum_size = Vector2(430, 18)
		var name_label := _make_label("", 14, Color(0.93, 0.88, 0.78))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var price_label := _make_label("", 14, Color(0.93, 0.88, 0.78))
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_label.custom_minimum_size = Vector2(48, 0)
		row.add_child(name_label)
		row.add_child(price_label)
		list.add_child(row)
		_rows.append(row)
		_name_labels.append(name_label)
		_price_labels.append(price_label)
	var detail_row := HBoxContainer.new()
	detail_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_row.add_theme_constant_override("separation", 8)
	body.add_child(detail_row)
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.custom_minimum_size = Vector2(32, 32)
	_icon.size = Vector2(32, 32)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail_row.add_child(_icon)
	_detail = _make_label("", 13, Color(0.89, 0.82, 0.72))
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.custom_minimum_size = Vector2(380, 40)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_row.add_child(_detail)
	_status_label = _make_label("", 13, Color(0.86, 0.74, 0.52))
	body.add_child(_status_label)
	_hint = _make_label("E  buy    Esc  close", 13, Color(0.78, 0.72, 0.62))
	body.add_child(_hint)


func is_open() -> bool:
	return _open


func open() -> void:
	if _open:
		return
	_index = 0
	_status = ""
	_set_open(true)


func close() -> void:
	if not _open:
		return
	_set_open(false)
	_was_pause = Input.is_action_pressed("pause")


func _physics_process(_delta: float) -> void:
	var pause_down := Input.is_action_pressed("pause")
	if NarrativeState.ending_open or NarrativeState.day_card_open or NarrativeState.dialogue_open:
		_was_pause = pause_down
		return
	if not _open:
		_was_pause = pause_down
		_sync_held()
		return
	if pause_down and not _was_pause:
		close()
		_was_pause = pause_down
		return
	_was_pause = pause_down
	_refresh()
	var stock := Catalog.shop_stock()
	if stock.is_empty():
		_sync_held()
		return
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	var confirm := Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
	if up and not _up_was:
		_index = maxi(_index - 1, 0)
		_status = ""
	if down and not _down_was:
		_index = mini(_index + 1, stock.size() - 1)
		_status = ""
	if confirm and not _confirm_was:
		_buy_selected()
	_up_was = up
	_down_was = down
	_confirm_was = confirm


func _set_open(is_open: bool) -> void:
	_open = is_open
	visible = is_open
	var story := get_node_or_null("/root/NarrativeState")
	if story != null:
		if story.has_method("set_shop_open"):
			story.call("set_shop_open", is_open)
		else:
			story.set("shop_open", is_open)
	_sync_clock_chrome()
	if is_open:
		var inv := get_tree().get_first_node_in_group("inventory_panel") if get_tree() != null else null
		if inv != null and inv.has_method("close"):
			inv.call("close")
		_sync_held()
		_refresh()


func _buy_selected() -> void:
	var stock := Catalog.shop_stock()
	if _index < 0 or _index >= stock.size():
		return
	var row: Dictionary = stock[_index]
	var item_id := str(row.get("id", ""))
	var pack := _pack()
	if pack == null or not pack.has_method("buy"):
		return
	if not Catalog.has_item(item_id):
		_status = "Thomas doesn't stock that."
		_refresh()
		return
	if pack.has_method("can_afford") and not bool(pack.call("can_afford", Catalog.shop_price(item_id))):
		_status = "Not enough in the wallet."
		_refresh()
		return
	if pack.has_method("can_add") and not bool(pack.call("can_add", item_id, 1)):
		_status = "No room in the pack."
		_refresh()
		return
	if bool(pack.call("buy", item_id, 1)):
		_status = "Bought %s." % Catalog.display_name(item_id)
	else:
		_status = "Not enough in the wallet."
	_refresh()


func _refresh() -> void:
	if not _open:
		return
	if _title != null:
		_title.text = Catalog.shop_title()
	var pack := _pack()
	var cash := 0
	if pack != null and pack.has_method("cash"):
		cash = int(pack.call("cash"))
	if _wallet != null:
		_wallet.text = "Wallet $%d" % cash
	var stock := Catalog.shop_stock()
	for i in _rows.size():
		var shown := i < stock.size()
		_rows[i].visible = shown
		if not shown:
			continue
		var row: Dictionary = stock[i]
		var item_id := str(row.get("id", ""))
		var price := int(row.get("price", 0))
		var selected := i == _index
		var mark := "> " if selected else "  "
		_name_labels[i].text = "%s%s" % [mark, Catalog.display_name(item_id)]
		_price_labels[i].text = "$%d" % price
		var color := Color(0.97, 0.86, 0.52) if selected else Color(0.93, 0.88, 0.78)
		_name_labels[i].add_theme_color_override("font_color", color)
		_price_labels[i].add_theme_color_override("font_color", color)
	if _index >= 0 and _index < stock.size():
		var selected_row: Dictionary = stock[_index]
		var sid := str(selected_row.get("id", ""))
		if _icon != null:
			_icon.texture = Icons.icon(sid)
			_icon.visible = true
		if _detail != null:
			_detail.text = Catalog.description(sid)
	else:
		if _icon != null:
			_icon.texture = null
			_icon.visible = false
		if _detail != null:
			_detail.text = "The shelves are empty."
	if _status_label != null:
		_status_label.text = _status
	if _hint != null:
		_hint.text = "E  buy    Esc  close"


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
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
