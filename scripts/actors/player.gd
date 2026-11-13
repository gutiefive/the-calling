class_name Player
extends CharacterBody2D
## Top-down movement: 8 directions, normalized so diagonals are not faster.
## Animation uses the nearest of four facings (down, up, left, right).

const FRAME_SIZE := Vector2i(32, 48)

@export var speed: float = 100.0

var _facing: StringName = &"down"
var _lock: float = 0.35
var _interact_was_down: bool = false


static func velocity_from_input(direction: Vector2, move_speed: float) -> Vector2:
	if direction.length_squared() <= 0.000001:
		return Vector2.ZERO
	return direction.normalized() * move_speed


func _enter_tree() -> void:
	add_to_group("player")


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	collision_layer = 2
	collision_mask = 1
	_build_frames()
	_play(false)


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _story_locks_movement():
		direction = Vector2.ZERO
	velocity = velocity_from_input(direction, speed)
	move_and_slide()
	if direction.length_squared() > 0.0001:
		_facing = _facing_from(direction)
		_play(true)
	else:
		_play(false)
	_poll_interact()
	if _lock > 0.0:
		_lock = maxf(0.0, _lock - delta)


func get_focus() -> Interactable:
	var best: Interactable = null
	var best_dist := 100000.0
	var tree := get_tree()
	if tree == null:
		return null
	for node in tree.get_nodes_in_group("interactable"):
		if not node is Interactable:
			continue
		var item := node as Interactable
		if not item.enabled:
			continue
		var dist := global_position.distance_to(item.global_position)
		if dist <= item.radius and dist < best_dist:
			best = item
			best_dist = dist
	return best


func get_door_focus() -> Door:
	var best: Door = null
	var best_dist := 100000.0
	var tree := get_tree()
	if tree == null:
		return null
	for node in tree.get_nodes_in_group("scene_door"):
		if not node is Door:
			continue
		var door := node as Door
		if not door.is_hovering(self):
			continue
		var dist := global_position.distance_to(door.global_position)
		if dist < best_dist:
			best = door
			best_dist = dist
	return best


func get_facing() -> StringName:
	return _facing


func set_facing(facing: StringName) -> void:
	_facing = facing
	_play(false)


func set_interact_lock(seconds: float) -> void:
	_lock = seconds


func clear_interact_lock() -> void:
	_lock = 0.0


func interact_lock_active() -> bool:
	return _lock > 0.0


func _story_locks_movement() -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("movement_locked"):
		return false
	return bool(story.call("movement_locked"))


func _poll_interact() -> void:
	# Edge-triggered so a held key cannot fire again on the next physics tick.
	var down := Input.is_action_pressed("interact")
	if down and not _interact_was_down and _lock <= 0.0:
		var target := get_focus()
		if target != null:
			target.interact(self)
	_interact_was_down = down


func _facing_from(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	return &"down" if direction.y > 0.0 else &"up"


func _play(moving: bool) -> void:
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return
	var anim := String(_facing) + ("_walk" if moving else "_idle")
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)


func _build_frames() -> void:
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		push_error("Player sprite missing")
		return
	var frames := CharacterSheets.sprite_frames("player")
	if frames == null:
		push_error("Player sprite sheet missing")
		return
	sprite.sprite_frames = frames
	sprite.centered = true
	sprite.offset = Vector2(0.0, -float(FRAME_SIZE.y) * 0.5)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
