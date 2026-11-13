extends PanelContainer
## Shows "E  …" while the player is in range of one interactable.
## Doors are walk-in, so they show only the place name, with no E.

@onready var _label: Label = $Label


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.88)
	style.border_color = Color(0.55, 0.44, 0.32, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(6)
	add_theme_stylebox_override("panel", style)


func _process(_delta: float) -> void:
	var tree := get_tree()
	if tree == null or _label == null:
		visible = false
		return
	var player := tree.get_first_node_in_group("player")
	if player == null or not player.has_method("get_focus"):
		visible = false
		return
	var item: Interactable = player.get_focus()
	if item != null:
		visible = true
		_label.text = "E  %s" % item.prompt_label()
		return
	if player is Player:
		var door := (player as Player).get_door_focus()
		if door != null:
			visible = true
			_label.text = door.place_label()
			return
	visible = false
