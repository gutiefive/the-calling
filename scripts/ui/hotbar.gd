extends Control
## Small equipped-tool strip. Hidden while menus are open.

const Catalog := preload("res://scripts/systems/item_catalog.gd")
const Icons := preload("res://scripts/art/item_art.gd")

var _icon: TextureRect
var _label: Label
var _hot_was: Array[bool] = [false, false, false]


func _ready() -> void:
	add_to_group("tool_hotbar")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 8.0
	offset_top = -34.0
	offset_right = 280.0
	offset_bottom = -8.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.86)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(1)
	style.set_content_margin_all(4)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.custom_minimum_size = Vector2(16, 16)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP
	row.add_child(_icon)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	row.add_child(_label)
	var pack := get_node_or_null("/root/Inventory")
	if pack != null and pack.has_signal("equipped_changed"):
		if not pack.equipped_changed.is_connected(_refresh):
			pack.equipped_changed.connect(_refresh)
	_refresh()


func _physics_process(_delta: float) -> void:
	_poll_hotkeys()
	_refresh()


func _poll_hotkeys() -> void:
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("movement_locked") and bool(story.call("movement_locked")):
		return
	var pack := get_node_or_null("/root/Inventory")
	if pack == null or not pack.has_method("tools_owned"):
		return
	var tools: PackedStringArray = pack.call("tools_owned")
	for i in 3:
		var down := Input.is_physical_key_pressed(KEY_1 + i)
		if down and not _hot_was[i] and i < tools.size() and pack.has_method("equip"):
			pack.call("equip", tools[i])
		_hot_was[i] = down


func _refresh() -> void:
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("movement_locked") and bool(story.call("movement_locked")):
		visible = false
		return
	var pack := get_node_or_null("/root/Inventory")
	var equipped := ""
	var seed := ""
	if pack != null and pack.has_method("equipped_tool"):
		equipped = str(pack.call("equipped_tool"))
	if pack != null and pack.has_method("equipped_seed"):
		seed = str(pack.call("equipped_seed"))
	if equipped.is_empty() and seed.is_empty():
		visible = false
		return
	visible = true
	var shown := equipped if not equipped.is_empty() else seed
	if _icon != null:
		_icon.texture = Icons.icon(shown)
	if _label != null:
		var text := Catalog.display_name(equipped) if not equipped.is_empty() else ""
		if not seed.is_empty():
			var seed_name := Catalog.display_name(seed)
			text = seed_name if text.is_empty() else "%s · %s" % [text, seed_name]
		_label.text = text
