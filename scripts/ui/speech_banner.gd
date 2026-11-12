class_name SpeechBanner
extends PanelContainer
## One-line banner for props. DialogueBox uses the same panel for conversations.

@onready var _label: RichTextLabel = $Label

var _left: float = 0.0


func _enter_tree() -> void:
	add_to_group("speech_banner")


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _label != null:
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.bbcode_enabled = true
		if "fit_content" in _label:
			_label.set("fit_content", true)
		if "scroll_active" in _label:
			_label.set("scroll_active", false)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.16, 0.92)
	style.border_color = Color(0.45, 0.36, 0.28, 1.0)
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	add_theme_stylebox_override("panel", style)


func _process(delta: float) -> void:
	if _left <= 0.0:
		return
	_left -= delta
	if _left <= 0.0:
		visible = false


func show_line(speaker: String, line: String) -> void:
	if _label == null or line.is_empty():
		return
	if speaker.is_empty():
		_label.text = line
	else:
		_label.text = "[color=#d7b48a]%s[/color]\n%s" % [speaker, line]
	visible = true
	_left = 5.5
