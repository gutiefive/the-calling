class_name WorldRoom
extends Node2D
## Shared room startup: collision helpers, spawn placement, camera bounds, lighting.

@export var bounds: Rect2 = Rect2(0, 0, 1152, 832)

var _presence: String = ""


func _ready() -> void:
	_build()
	_presence = NpcSchedule.signature(self)
	_spawn_player()
	_apply_camera()
	_apply_time()
	_bind_clock()


func _exit_tree() -> void:
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.time_changed.is_connected(_on_time_changed):
		clock.time_changed.disconnect(_on_time_changed)


func _bind_clock() -> void:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return
	if not clock.time_changed.is_connected(_on_time_changed):
		clock.time_changed.connect(_on_time_changed)


func _on_time_changed() -> void:
	if not is_inside_tree():
		return
	var next := NpcSchedule.signature(self)
	if next == _presence:
		return
	_presence = next
	if has_method("rebuild_collision"):
		call("rebuild_collision")
	else:
		NpcSchedule.apply_room(self)


func _build() -> void:
	pass


func _clear_solids() -> void:
	var solids := get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		push_error("%s is missing Solids" % name)
		return
	while solids.get_child_count() > 0:
		var child := solids.get_child(0)
		solids.remove_child(child)
		child.free()


func _add_rect(center: Vector2, size: Vector2) -> void:
	var solids := get_node_or_null("Solids") as StaticBody2D
	if solids == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = center
	solids.add_child(shape)


func _add_prop_blocks() -> void:
	var solids := get_node_or_null("Solids") as StaticBody2D
	if solids == null:
		return
	NpcSchedule.apply_room(self)
	for node in get_tree().get_nodes_in_group("solid_prop"):
		if not node is Node2D or not is_ancestor_of(node):
			continue
		if bool(node.get_meta("scheduled_away", false)):
			continue
		var body := node as Node2D
		var size: Vector2 = body.get("block_size")
		var block_offset: Vector2 = body.get("block_offset")
		if size == Vector2.ZERO:
			size = Vector2(16, 10)
		_add_rect(solids.to_local(body.global_position) + block_offset, size)


func _add_map_border(map_size: Vector2i) -> void:
	var width := float(map_size.x * 32)
	var height := float(map_size.y * 32)
	_add_rect(Vector2(width * 0.5, 8.0), Vector2(width, 16.0))
	_add_rect(Vector2(width * 0.5, height - 8.0), Vector2(width, 16.0))
	_add_rect(Vector2(8.0, height * 0.5), Vector2(16.0, height))
	_add_rect(Vector2(width - 8.0, height * 0.5), Vector2(16.0, height))


func _place(node_path: String, pos: Vector2) -> Node2D:
	var node := get_node_or_null(node_path) as Node2D
	if node == null:
		push_error("%s missing %s" % [name, node_path])
		return null
	node.position = pos
	return node


func _set_sprite(node_path: String, texture: Texture2D) -> void:
	var sprite := get_node_or_null(node_path) as Sprite2D
	if sprite == null or texture == null:
		push_error("%s missing sprite %s" % [name, node_path])
		return
	sprite.texture = texture


func _set_light_texture(node_path: String) -> void:
	var light := get_node_or_null(node_path) as PointLight2D
	if light == null:
		push_error("%s missing light %s" % [name, node_path])
		return
	light.texture = PlaceholderArt.glow()


func _feet_offset(node_path: String) -> void:
	var sprite := get_node_or_null(node_path) as Sprite2D
	if sprite == null or sprite.texture == null:
		return
	sprite.centered = true
	sprite.offset = Vector2(0.0, -sprite.texture.get_height() * 0.5)


func _spawn_player() -> void:
	var player := get_node_or_null("Props/Player") as Node2D
	if player == null:
		push_error("%s is missing Props/Player" % name)
		return
	if SceneRouter.apply_exact(player):
		return
	var spawn_id := SceneRouter.consume_spawn()
	var marker := get_node_or_null("Spawns/" + String(spawn_id)) as Node2D
	if marker == null:
		marker = get_node_or_null("Spawns/default") as Node2D
	if marker == null:
		push_error("%s is missing a spawn marker" % name)
		return
	player.global_position = marker.global_position
	if marker.has_meta("facing") and player.has_method("set_facing"):
		player.set_facing(StringName(str(marker.get_meta("facing"))))


func _apply_camera() -> void:
	var camera := get_node_or_null("Props/Player/Camera2D") as Camera2D
	if camera == null:
		push_error("%s is missing the player camera" % name)
		return
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	camera.limit_smoothed = false
	camera.position_smoothing_enabled = false


func _apply_time() -> void:
	var view := get_node_or_null("Lighting")
	if view != null and view.has_method("apply"):
		view.apply()
