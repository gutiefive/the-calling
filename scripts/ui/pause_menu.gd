extends Control
## Esc pauses the game. This is not a settings menu.

@onready var _title: Label = $Center/Title
@onready var _hint: Label = $Center/Hint


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _title != null:
		_title.text = "Paused"
	if _hint != null:
		_hint.text = "Esc to resume.  J journal"
	var center := get_node_or_null("Center") as Control
	if center != null:
		center.offset_left = -150.0
		center.offset_right = 150.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("pause"):
		return
	toggle_pause()
	get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.paused = not tree.paused
	visible = tree.paused
