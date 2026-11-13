class_name FarmField
extends Node2D
## Church garden overlay: in-ground soil, crops, and the facing-tile cursor.

var soil_root: Node2D

var _soil_sprites: Dictionary = {}
var _crop_sprites: Dictionary = {}
var _fx: Sprite2D
var _fx_time: float = 0.0
var _pickup: Label
var _pickup_time: float = 0.0
var _cursor: FarmCursor


func _ready() -> void:
	add_to_group("farm_field")
	y_sort_enabled = true
	z_as_relative = true
	_ensure_cursor()
	_ensure_fx()
	rebuild()
	var garden := _garden()
	if garden != null and garden.has_signal("plots_changed"):
		if not garden.plots_changed.is_connected(rebuild):
			garden.plots_changed.connect(rebuild)
	if garden != null and garden.has_signal("garden_action"):
		if not garden.garden_action.is_connected(_on_action):
			garden.garden_action.connect(_on_action)


func _exit_tree() -> void:
	var garden := _garden()
	if garden != null and garden.has_signal("plots_changed"):
		if garden.plots_changed.is_connected(rebuild):
			garden.plots_changed.disconnect(rebuild)
	if garden != null and garden.has_signal("garden_action"):
		if garden.garden_action.is_connected(_on_action):
			garden.garden_action.disconnect(_on_action)


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


func rebuild() -> void:
	var garden := _garden()
	var live: Dictionary = {}
	if garden != null and garden.has_method("plot_ids"):
		var ids_v: Variant = garden.call("plot_ids")
		if ids_v is PackedStringArray:
			for plot_id in ids_v:
				live[str(plot_id)] = true
				_refresh_tile(str(plot_id))
	var stale: Array = []
	for key_v in _soil_sprites.keys():
		var key := str(key_v)
		if not live.has(key):
			stale.append(key)
	for key in stale:
		_free_tile(str(key))


func target_id() -> String:
	if _cursor == null:
		return ""
	return _cursor.target_id()


func _refresh_tile(plot_id: String) -> void:
	var garden := _garden()
	if garden == null or not garden.has_method("plot_of"):
		return
	var row_v: Variant = garden.call("plot_of", plot_id)
	var row: Dictionary = row_v if row_v is Dictionary else {}
	if row.is_empty() or str(row.get("soil", "untouched")) == "untouched":
		_free_tile(plot_id)
		return
	var cell := GroundsLayout.parse_cell_id(plot_id)
	var center := GroundsLayout.tile_center(cell)
	var mask := 0
	if garden.has_method("neighbor_mask"):
		mask = int(garden.call("neighbor_mask", cell))
	var soil := _soil_sprite(plot_id, center)
	var soil_tex := CropArt.tile_texture(row, mask)
	if soil != null and soil_tex != null:
		soil.texture = soil_tex
		soil.position = center
		soil.centered = true
	var crop := _crop_sprite(plot_id, center)
	var stage := str(row.get("stage", ""))
	if stage == "sprout" or stage == "growing" or stage == "mature":
		var plant_tex := CropArt.crop_texture(str(row.get("crop", "")), stage)
		if crop != null:
			crop.texture = plant_tex
			crop.visible = plant_tex != null
			crop.position = center
	elif crop != null:
		crop.visible = false


func _soil_sprite(plot_id: String, center: Vector2) -> Sprite2D:
	if _soil_sprites.has(plot_id):
		var existing_v: Variant = _soil_sprites[plot_id]
		if existing_v is Sprite2D:
			return existing_v
	var sprite := Sprite2D.new()
	sprite.name = "Soil_%s" % plot_id.replace(",", "_")
	sprite.centered = true
	sprite.position = center
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.z_as_relative = false
	sprite.z_index = -9
	var parent := soil_root if soil_root != null else self
	parent.add_child(sprite)
	_soil_sprites[plot_id] = sprite
	return sprite


func _crop_sprite(plot_id: String, center: Vector2) -> Sprite2D:
	if _crop_sprites.has(plot_id):
		var existing_v: Variant = _crop_sprites[plot_id]
		if existing_v is Sprite2D:
			return existing_v
	var sprite := Sprite2D.new()
	sprite.name = "Crop_%s" % plot_id.replace(",", "_")
	sprite.centered = true
	sprite.position = center
	sprite.offset = Vector2(0, -4)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_crop_sprites[plot_id] = sprite
	return sprite


func _free_tile(plot_id: String) -> void:
	if _soil_sprites.has(plot_id):
		var soil_v: Variant = _soil_sprites[plot_id]
		if soil_v is Node:
			(soil_v as Node).queue_free()
		_soil_sprites.erase(plot_id)
	if _crop_sprites.has(plot_id):
		var crop_v: Variant = _crop_sprites[plot_id]
		if crop_v is Node:
			(crop_v as Node).queue_free()
		_crop_sprites.erase(plot_id)


func _on_action(kind: String) -> void:
	if _cursor == null:
		return
	var cell := _cursor.target_cell()
	_flash(kind, GroundsLayout.tile_center(cell))
	if kind == "harvest":
		var garden := _garden()
		if garden != null and garden.has_method("plot_of"):
			pass
		_show_pickup("Harvested.")


func flash_at(kind: String, world_pos: Vector2, message: String) -> void:
	_flash(kind, world_pos)
	if kind == "harvest" and not message.is_empty():
		_show_pickup(message)


func _flash(kind: String, world_pos: Vector2) -> void:
	_ensure_fx()
	if _fx == null:
		return
	var tex := CropArt.fx_texture(kind)
	if tex == null:
		return
	_fx.global_position = world_pos + Vector2(0, -8)
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
	if _cursor != null:
		_pickup.global_position = _cursor.global_position + Vector2(-40, -28)
	_pickup.modulate.a = 1.0
	_pickup_time = 0.8


func _ensure_cursor() -> void:
	if _cursor != null:
		return
	_cursor = FarmCursor.new()
	_cursor.name = "FarmCursor"
	add_child(_cursor)


func _ensure_fx() -> void:
	if _fx == null:
		_fx = Sprite2D.new()
		_fx.name = "Fx"
		_fx.centered = true
		_fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_fx.z_index = 8
		_fx.visible = false
		add_child(_fx)
	if _pickup == null:
		_pickup = Label.new()
		_pickup.name = "Pickup"
		_pickup.visible = false
		_pickup.add_theme_font_size_override("font_size", 12)
		_pickup.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78))
		_pickup.z_index = 8
		add_child(_pickup)


func _garden() -> Node:
	return get_node_or_null("/root/GardenState")
