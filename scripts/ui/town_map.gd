class_name TownMap
extends Control
## A sketch of the places you can walk: church grounds, sanctuary, and Oak Street.

const CHURCH := Rect2(48, 96, 200, 160)
const SANCTUARY := Rect2(88, 48, 120, 36)
const STREET := Rect2(268, 96, 250, 150)
const PARSONAGE := Rect2(16, 268, 110, 64)
const MAPLE := Rect2(400, 262, 210, 72)
const STORE := Rect2(268, 16, 110, 36)
const BAY := Rect2(388, 16, 110, 36)

var _open: bool = false
var _was_down: bool = false
var _marker: ColorRect
var _dim: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("town_map")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim = ColorRect.new()
	_dim.color = Color(0.08, 0.07, 0.1, 0.72)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_add_region(CHURCH, Color(0.36, 0.48, 0.32, 1.0), "Church grounds")
	_add_region(SANCTUARY, Color(0.45, 0.38, 0.32, 1.0), "Sanctuary")
	_add_region(STREET, Color(0.48, 0.42, 0.34, 1.0), "Oak Street")
	_add_region(PARSONAGE, Color(0.55, 0.42, 0.32, 1.0), "Parsonage")
	_add_region(MAPLE, Color(0.40, 0.50, 0.34, 1.0), "Maple Lane")
	_add_region(STORE, Color(0.52, 0.40, 0.30, 1.0), "Hardware store")
	_add_region(BAY, Color(0.42, 0.40, 0.38, 1.0), "Frank's bay")
	var hint := Label.new()
	hint.name = "Hint"
	hint.text = "M or Esc  close"
	hint.position = Vector2(16, 338)
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	_marker = ColorRect.new()
	_marker.name = "Marker"
	_marker.color = Color(0.93, 0.82, 0.45, 1.0)
	_marker.size = Vector2(8, 8)
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_marker)


func _physics_process(_delta: float) -> void:
	# Polled, like the journal, so a test can press the action without a window event.
	var down := Input.is_action_pressed("town_map")
	if down and not _was_down:
		if not NarrativeState.ending_open and not NarrativeState.dialogue_open and not NarrativeState.journal_open and not NarrativeState.day_card_open:
			toggle()
	_was_down = down
	if _open:
		_place_marker()


func place_names() -> PackedStringArray:
	var names := PackedStringArray()
	for child in get_children():
		if not child is Label:
			continue
		var label := child as Label
		if label.name == "Hint":
			continue
		names.append(label.text)
	return names


func is_open() -> bool:
	return _open


func toggle() -> void:
	if _open:
		close()
	else:
		open()


func open() -> void:
	_open = true
	visible = true
	NarrativeState.set_map_open(true)
	_place_marker()


func close() -> void:
	_open = false
	visible = false
	NarrativeState.set_map_open(false)


func region_rect(region_id: String) -> Rect2:
	match region_id:
		"church":
			return CHURCH
		"sanctuary":
			return SANCTUARY
		"street":
			return STREET
		"parsonage":
			return PARSONAGE
		"maple":
			return MAPLE
		"store":
			return STORE
		"bay":
			return BAY
		_:
			return Rect2()


func marker_region() -> String:
	return _region_id(_current_room())


func marker_position() -> Vector2:
	var room := _current_room()
	var rect := region_rect(_region_id(room))
	if room == null or rect.size == Vector2.ZERO:
		return rect.position
	var player := _player()
	if player == null:
		return rect.position + rect.size * 0.5
	var bounds := room.bounds
	var span := bounds.size
	if span.x <= 1.0 or span.y <= 1.0:
		return rect.position + rect.size * 0.5
	var nx := clampf((player.global_position.x - bounds.position.x) / span.x, 0.0, 1.0)
	var ny := clampf((player.global_position.y - bounds.position.y) / span.y, 0.0, 1.0)
	return rect.position + Vector2(nx * rect.size.x, ny * rect.size.y)


func _place_marker() -> void:
	if _marker == null:
		return
	var point := marker_position()
	_marker.position = point - _marker.size * 0.5


func _add_region(rect: Rect2, color: Color, title: String) -> void:
	var box := ColorRect.new()
	box.position = rect.position
	box.size = rect.size
	box.color = color
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var label := Label.new()
	label.text = title
	label.position = rect.position + Vector2(8, 6)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)


func _region_id(room: WorldRoom) -> String:
	if room == null:
		return ""
	var base := room.scene_file_path.get_file().get_basename()
	if base == "sanctuary":
		return "sanctuary"
	if base == "hardware_street":
		return "street"
	if base == "church_exterior":
		return "church"
	if base == "parsonage":
		return "parsonage"
	if base == "maple_lane":
		return "maple"
	if base == "hardware_interior":
		return "store"
	if base == "bay_interior":
		return "bay"
	return ""


func _current_room() -> WorldRoom:
	var player := _player()
	var node: Node = player
	while node != null:
		if node is WorldRoom:
			return node as WorldRoom
		node = node.get_parent()
	return null


func _player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("player") as Node2D
