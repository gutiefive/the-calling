class_name ExpansionPlot
extends Interactable
## A staked, empty lot. A later milestone can attach a funded project and swap the built art.

var plot_id: String = ""
var display_name: String = "Future Building Site"
var speaker_name: String = "Future Building Site"
var inspect_line: String = "Margaret says this was meant for something, once."
var project_id: String = ""
var built_scene: String = ""
var tile_rect: Rect2i = Rect2i()


func _enter_tree() -> void:
	blocks_movement = false
	super._enter_tree()
	add_to_group("expansion_plot")


func _ready() -> void:
	prompt_text = "Look at the lot"
	if not display_name.is_empty():
		speaker_name = display_name
	radius = 42.0
	_add_markers()


func interact(actor: Node) -> void:
	interacted.emit()
	var banner := _banner()
	if banner != null and banner.has_method("show_line"):
		banner.call("show_line", speaker_name, inspect_line)


func _add_markers() -> void:
	if tile_rect.size.x <= 0 or tile_rect.size.y <= 0:
		return
	var corners: Array[Vector2] = [
		_corner(0, 0),
		_corner(tile_rect.size.x - 1, tile_rect.size.y - 1),
	]
	for i in corners.size():
		var stake := Sprite2D.new()
		stake.name = "Stake%d" % i
		stake.texture = PlaceholderArt.survey_stakes()
		stake.centered = true
		stake.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if stake.texture != null:
			stake.offset = Vector2(0, -stake.texture.get_height() * 0.5)
		stake.position = corners[i] - position
		add_child(stake)
	var sign := Sprite2D.new()
	sign.name = "SiteSign"
	sign.texture = PlaceholderArt.future_site_sign()
	sign.centered = true
	sign.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if sign.texture != null:
		sign.offset = Vector2(0, -sign.texture.get_height() * 0.5)
	sign.position = Vector2(0, tile_rect.size.y * GroundsLayout.TILE * 0.35)
	add_child(sign)


func _corner(local_x: int, local_y: int) -> Vector2:
	return GroundsLayout.tile_center(Vector2i(tile_rect.position.x + local_x, tile_rect.position.y + local_y))


func _banner() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("speech_banner")
