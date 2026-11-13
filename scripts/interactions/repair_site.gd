class_name RepairSite
extends Interactable
## One church-grounds worksite. Short E press. No hold.

@export var site_id: String = ""

var _sprite: Sprite2D
var _fx: Sprite2D
var _fx_time: float = 0.0


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")
	add_to_group("repair_site")


func _ready() -> void:
	radius = 52.0
	blocks_movement = false
	_ensure_sprite()
	_refresh()
	var repairs := _repairs()
	if repairs != null and repairs.has_signal("sites_changed"):
		if not repairs.sites_changed.is_connected(_refresh):
			repairs.sites_changed.connect(_refresh)


func _exit_tree() -> void:
	var repairs := _repairs()
	if repairs != null and repairs.has_signal("sites_changed"):
		if repairs.sites_changed.is_connected(_refresh):
			repairs.sites_changed.disconnect(_refresh)


func _process(delta: float) -> void:
	_update_hint()
	if _fx_time <= 0.0:
		return
	_fx_time = maxf(0.0, _fx_time - delta)
	if _fx != null:
		_fx.visible = _fx_time > 0.0
		_fx.modulate.a = clampf(_fx_time / 0.35, 0.0, 1.0)


func apply_clock() -> void:
	_refresh()


func prompt_label() -> String:
	var repairs := _repairs()
	if repairs != null and repairs.has_method("prompt_for"):
		var line := str(repairs.call("prompt_for", site_id))
		if not line.is_empty():
			return line
	return prompt_text


func interact(actor: Node) -> void:
	super.interact(actor)
	var repairs := _repairs()
	if repairs == null or not repairs.has_method("interact"):
		return
	var raw: Variant = repairs.call("interact", site_id)
	var result: Dictionary = raw if raw is Dictionary else {}
	var kind := str(result.get("kind", "noop"))
	var message := str(result.get("message", ""))
	if kind != "noop" and actor != null and actor.has_method("set_interact_lock"):
		actor.call("set_interact_lock", 0.35)
	if kind != "noop":
		_flash()
	if not message.is_empty():
		_say(message)
	_refresh()


func current_art() -> String:
	var repairs := _repairs()
	if repairs != null and repairs.has_method("art_id"):
		return str(repairs.call("art_id", site_id))
	return ""


func _refresh() -> void:
	_ensure_sprite()
	var repairs := _repairs()
	var hidden := false
	if repairs != null and repairs.has_method("is_hidden"):
		hidden = bool(repairs.call("is_hidden", site_id))
	visible = not hidden
	enabled = not hidden
	if _sprite == null:
		return
	var art := current_art()
	var tex := RepairArt.texture(art)
	_sprite.texture = tex
	_sprite.visible = tex != null
	if tex != null:
		_sprite.offset = Vector2(0, -tex.get_height() * 0.5)
	prompt_text = prompt_label()


func _flash() -> void:
	_ensure_fx()
	if _fx == null:
		return
	var tex := RepairArt.fx_texture()
	if tex == null:
		return
	_fx.texture = tex
	_fx.visible = true
	_fx.modulate.a = 1.0
	_fx_time = 0.35


func _update_hint() -> void:
	if _sprite == null:
		return
	if not visible or not enabled:
		_sprite.modulate = Color.WHITE
		return
	var tree := get_tree()
	if tree == null:
		_sprite.modulate = Color.WHITE
		return
	var player := tree.get_first_node_in_group("player") as Node2D
	if player == null:
		_sprite.modulate = Color.WHITE
		return
	if player.global_position.distance_to(global_position) > radius:
		_sprite.modulate = Color.WHITE
		return
	if not _player_faces_site(player):
		_sprite.modulate = Color.WHITE
		return
	_sprite.modulate = Color(1.14, 1.08, 0.92, 1.0)


func _player_faces_site(player: Node2D) -> bool:
	var facing := &"down"
	if player.has_method("get_facing"):
		facing = StringName(str(player.call("get_facing")))
	var delta := global_position - player.global_position
	match facing:
		&"up":
			return delta.y <= 8.0
		&"down":
			return delta.y >= -8.0
		&"left":
			return delta.x <= 8.0
		&"right":
			return delta.x >= -8.0
		_:
			return true


func _ensure_sprite() -> void:
	if _sprite != null:
		return
	var existing := get_node_or_null("Sprite") as Sprite2D
	if existing != null:
		_sprite = existing
		return
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)


func _ensure_fx() -> void:
	if _fx != null:
		return
	_fx = Sprite2D.new()
	_fx.name = "Fx"
	_fx.centered = true
	_fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fx.position = Vector2(0, -12)
	_fx.z_index = 8
	_fx.visible = false
	add_child(_fx)


func _say(text: String) -> void:
	ActionToast.say(get_tree(), text)


func _repairs() -> Node:
	return get_node_or_null("/root/RepairState")
