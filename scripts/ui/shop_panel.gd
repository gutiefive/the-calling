extends Control
## Hardware-store transaction UI. Dollars live here. Dialogue never names them.

const Catalog := preload("res://scripts/systems/item_catalog.gd")

const PANEL_POS := Vector2(90, 32)
const PANEL_SIZE := Vector2(460, 296)

var _open: bool = false
var _index: int = 0
var _was_pause: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _confirm_was: bool = false
var _status: String = ""
var _dim: ColorRect
var _panel: PanelContainer
var _label: Label


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
	style.set_content_margin_all(12)
	_panel.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(436, 272)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	add_child(_panel)


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
	if _label != null:
		_label.text = _body_text()
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
	if is_open:
		var inv := get_tree().get_first_node_in_group("inventory_panel") if get_tree() != null else null
		if inv != null and inv.has_method("close"):
			inv.call("close")
		_sync_held()
		if _label != null:
			_label.text = _body_text()


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
		return
	if pack.has_method("can_afford") and not bool(pack.call("can_afford", Catalog.shop_price(item_id))):
		_status = "Not enough in the wallet."
		return
	if pack.has_method("can_add") and not bool(pack.call("can_add", item_id, 1)):
		_status = "No room in the pack."
		return
	if bool(pack.call("buy", item_id, 1)):
		_status = "Bought %s." % Catalog.display_name(item_id)
	else:
		_status = "Not enough in the wallet."


func _body_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(Catalog.shop_title())
	var pack := _pack()
	var cash := 0
	if pack != null and pack.has_method("cash"):
		cash = int(pack.call("cash"))
	lines.append("Wallet $%d" % cash)
	lines.append("")
	var stock := Catalog.shop_stock()
	if stock.is_empty():
		lines.append("The shelves are empty.")
	else:
		for i in stock.size():
			var mark := "> " if i == _index else "  "
			var row: Dictionary = stock[i]
			var item_id := str(row.get("id", ""))
			var price := int(row.get("price", 0))
			lines.append("%s%-18s $%d" % [mark, Catalog.display_name(item_id), price])
		lines.append("")
		if _index >= 0 and _index < stock.size():
			var selected: Dictionary = stock[_index]
			var sid := str(selected.get("id", ""))
			lines.append(Catalog.description(sid))
	if not _status.is_empty():
		lines.append("")
		lines.append(_status)
	lines.append("")
	lines.append("E  buy    Esc  close")
	return "\n".join(lines)


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")


func _sync_held() -> void:
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
	_confirm_was = Input.is_action_pressed("interact") or Input.is_action_pressed("advance_dialogue")
