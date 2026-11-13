extends CanvasLayer
## A short fade across a room change. The router starts it; the new room is already loading.


var _alpha: float = 0.0
var _rect: ColorRect


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0.05, 0.04, 0.07, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func play() -> void:
	_alpha = 1.0
	_paint()


func is_fading() -> bool:
	return _alpha > 0.01


func _process(delta: float) -> void:
	if _alpha <= 0.0:
		return
	_alpha = maxf(0.0, _alpha - delta / 0.22)
	_paint()


func _paint() -> void:
	if _rect == null:
		return
	_rect.color = Color(0.05, 0.04, 0.07, _alpha)
