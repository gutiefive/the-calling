class_name GardenPlot
extends Interactable
## Maple Lane Chapter 1 plot when plot_id is empty. Church garden beds set plot_id.

@export var plot_id: String = ""

var shown_stage: int = 0

var _fx: Sprite2D
var _fx_time: float = 0.0
var _pickup: Label
var _pickup_time: float = 0.0


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")
	if not plot_id.is_empty():
		add_to_group("farm_plot")


func _ready() -> void:
	_ensure_fx()
	apply_clock()
	var garden := _garden()
	if garden != null and garden.has_signal("plots_changed"):
		if not garden.plots_changed.is_connected(apply_clock):
			garden.plots_changed.connect(apply_clock)


func _exit_tree() -> void:
	var garden := _garden()
	if garden != null and garden.has_signal("plots_changed"):
		if garden.plots_changed.is_connected(apply_clock):
			garden.plots_changed.disconnect(apply_clock)


func _process(delta: float) -> void:
	if _fx_time > 0.0:
		_fx_time = maxf(0.0, _fx_time - delta)
		if _fx != null:
			_fx.visible = _fx_time > 0.0
			_fx.modulate.a = clampf(_fx_time / 0.35, 0.0, 1.0)
	if _pickup_time > 0.0:
		_pickup_time = maxf(0.0, _pickup_time - delta)
		if _pickup != null:
			_pickup.visible = _pickup_time > 0.0
			_pickup.position.y = -28.0 - (0.4 - _pickup_time) * 18.0
			_pickup.modulate.a = clampf(_pickup_time / 0.4, 0.0, 1.0)


func is_farm() -> bool:
	return not plot_id.is_empty()


func prompt_label() -> String:
	if is_farm():
		var garden := _garden()
		if garden != null and garden.has_method("prompt_for"):
			return str(garden.call("prompt_for", plot_id))
	return super.prompt_label()


func apply_clock() -> void:
	if is_farm():
		_apply_farm()
		return
	shown_stage = NarrativeState.garden_stage()
	var sprite := get_node_or_null("Sprite") as Sprite2D
	var texture := PlaceholderArt.garden_plot(shown_stage)
	if sprite != null and texture != null:
		sprite.texture = texture
		sprite.centered = true
		sprite.offset = Vector2(0, -texture.get_height() * 0.5)


func interact(actor: Node) -> void:
	super.interact(actor)
	if is_farm():
		_interact_farm(actor)
		return
	var line := "The plot is a mat of weeds. You could pull them."
	if NarrativeState.flag_is_true("garden_planted"):
		line = "It's in the ground. A few mornings will show whether it takes."
	elif NarrativeState.flag_is_true("garden_cleared"):
		line = "The soil is clear. It wants seed, and another pair of hands."
	else:
		NarrativeState.set_flag("garden_cleared", true)
		line = "You pull the weeds back. It still needs seed."
		apply_clock()
	_say("Garden", line)


func _interact_farm(actor: Node) -> void:
	var garden := _garden()
	if garden == null or not garden.has_method("interact_plot"):
		return
	var raw: Variant = garden.call("interact_plot", plot_id)
	var result: Dictionary = raw if raw is Dictionary else {}
	var kind := str(result.get("kind", "noop"))
	var message := str(result.get("message", ""))
	apply_clock()
	if kind != "noop":
		_flash(kind)
		if actor != null and actor.has_method("set_interact_lock"):
			actor.call("set_interact_lock", 0.35)
		if kind == "harvest":
			_show_pickup(message)
	if not message.is_empty():
		_say("Garden", message)


func _apply_farm() -> void:
	var garden := _garden()
	if garden == null or not garden.has_method("plot_of"):
		return
	var row_v: Variant = garden.call("plot_of", plot_id)
	var row: Dictionary = row_v if row_v is Dictionary else {}
	var sprite := get_node_or_null("Sprite") as Sprite2D
	var texture := CropArt.plot_texture(row)
	if sprite != null and texture != null:
		sprite.texture = texture
		sprite.centered = true
		sprite.offset = Vector2(0, -texture.get_height() * 0.5)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _flash(kind: String) -> void:
	_ensure_fx()
	if _fx == null:
		return
	var tex := CropArt.fx_texture(kind)
	if tex == null:
		return
	_fx.texture = tex
	_fx.visible = true
	_fx.modulate.a = 1.0
	_fx_time = 0.35


func _show_pickup(message: String) -> void:
	_ensure_fx()
	if _pickup == null:
		return
	_pickup.text = message
	_pickup.visible = true
	_pickup.position = Vector2(-40, -28)
	_pickup.modulate.a = 1.0
	_pickup_time = 0.8


func _ensure_fx() -> void:
	if _fx == null:
		_fx = get_node_or_null("Fx") as Sprite2D
		if _fx == null:
			_fx = Sprite2D.new()
			_fx.name = "Fx"
			_fx.centered = true
			_fx.position = Vector2(0, -16)
			_fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_fx.visible = false
			add_child(_fx)
	if _pickup == null:
		_pickup = get_node_or_null("Pickup") as Label
		if _pickup == null:
			_pickup = Label.new()
			_pickup.name = "Pickup"
			_pickup.visible = false
			_pickup.add_theme_font_size_override("font_size", 12)
			_pickup.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
			_pickup.z_index = 8
			add_child(_pickup)


func _say(speaker: String, line: String) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line(speaker, line)


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")
