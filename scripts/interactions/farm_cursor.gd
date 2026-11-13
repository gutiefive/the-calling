class_name FarmCursor
extends Interactable
## Facing-tile marker for the church garden. E acts on the highlighted cell.

var _indicator: Sprite2D
var _cell: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	prompt_text = "Till"
	radius = 44.0
	blocks_movement = false
	enabled = false
	z_index = 6
	_indicator = Sprite2D.new()
	_indicator.name = "Indicator"
	_indicator.centered = true
	_indicator.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_indicator.texture = CropArt.target_texture()
	_indicator.visible = false
	add_child(_indicator)


func _process(_delta: float) -> void:
	_follow_player()


func target_cell() -> Vector2i:
	return _cell


func target_id() -> String:
	if _cell.x < 0:
		return ""
	return GroundsLayout.cell_id(_cell)


func prompt_label() -> String:
	var garden := _garden()
	if garden != null and garden.has_method("prompt_for"):
		var line := str(garden.call("prompt_for", target_id()))
		if not line.is_empty():
			return line
	return super.prompt_label()


func interact(actor: Node) -> void:
	super.interact(actor)
	var garden := _garden()
	if garden == null or not garden.has_method("interact_plot"):
		return
	var plot_id := target_id()
	if plot_id.is_empty():
		return
	var raw: Variant = garden.call("interact_plot", plot_id)
	var result: Dictionary = raw if raw is Dictionary else {}
	var kind := str(result.get("kind", "noop"))
	var message := str(result.get("message", ""))
	if kind != "noop" and actor != null and actor.has_method("set_interact_lock"):
		actor.call("set_interact_lock", 0.35)
	var field := get_parent()
	if kind != "noop" and field != null and field.has_method("flash_at"):
		field.call("flash_at", kind, global_position, message)
	if not message.is_empty():
		ActionToast.say(get_tree(), message)


func _follow_player() -> void:
	var player := _player()
	if player == null:
		_hide()
		return
	var facing := &"down"
	if player.has_method("get_facing"):
		facing = StringName(str(player.call("get_facing")))
	var cell := GroundsLayout.facing_cell(player.global_position, facing)
	var garden := _garden()
	var farmable := false
	if garden != null and garden.has_method("is_farmable"):
		farmable = bool(garden.call("is_farmable", cell))
	elif GroundsLayout.is_veg_tillable(cell):
		farmable = true
	if not farmable:
		_hide()
		return
	_cell = cell
	global_position = GroundsLayout.tile_center(cell)
	enabled = true
	if _indicator != null:
		_indicator.visible = true
	prompt_text = prompt_label()


func _hide() -> void:
	_cell = Vector2i(-1, -1)
	enabled = false
	if _indicator != null:
		_indicator.visible = false
	global_position = Vector2(-1000, -1000)


func _player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("player") as Node2D


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")
