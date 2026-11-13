class_name Door
extends Area2D
## Walk-in room change. The player's body entering this area while moving toward it
## travels; E is not used. Spawn markers sit outside the circle so arriving cannot bounce.

const REARM_SECONDS := 0.4
const MIN_APPROACH_SPEED := 18.0
const APPROACH_DOT := 0.12
const HOVER_PADDING := 10.0

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn: StringName = &"default"
@export var place_name: String = ""
@export var prompt_text: String = ""
@export var radius: float = 26.0
@export var enabled: bool = true

var _inside: bool = false
var _armed: bool = false
var _busy: bool = false
var _closed_shown: bool = false
var _cooldown: float = 0.0
var _shape: CollisionShape2D


func _enter_tree() -> void:
	add_to_group("scene_door")
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 2
	_ensure_shape()


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	call_deferred("_sync_overlap")


func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = maxf(0.0, _cooldown - delta)
	if not _inside or not _armed or _busy:
		return
	if _cooldown > 0.0:
		return
	_try_enter()


func place_label() -> String:
	if not place_name.is_empty():
		return place_name
	if not prompt_text.is_empty():
		return prompt_text
	return "Door"


func is_open() -> bool:
	return true


func closed_line() -> String:
	return "It's locked."


func is_hovering(player: Node2D) -> bool:
	if not enabled or player == null:
		return false
	if _inside:
		return true
	return global_position.distance_to(player.global_position) <= radius + HOVER_PADDING


func _ensure_shape() -> void:
	_shape = get_node_or_null("Trigger") as CollisionShape2D
	if _shape == null:
		_shape = CollisionShape2D.new()
		_shape.name = "Trigger"
		add_child(_shape)
	var circle := CircleShape2D.new()
	circle.radius = radius
	_shape.shape = circle


func _sync_overlap() -> void:
	_inside = false
	if not is_inside_tree():
		_armed = true
		return
	for body in get_overlapping_bodies():
		if _is_player(body):
			_inside = true
			_armed = false
			return
	_armed = true


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return
	_inside = true
	_try_enter()


func _on_body_exited(body: Node2D) -> void:
	if not _is_player(body):
		return
	_inside = false
	_armed = true
	_busy = false
	_closed_shown = false


func _try_enter() -> void:
	if not enabled or _busy or not _inside:
		return
	if _cooldown > 0.0:
		return
	if _ui_blocks():
		return
	var player := _player()
	if player == null:
		return
	if player.interact_lock_active():
		return
	if not _moving_toward(player):
		return
	if not is_open():
		_show_closed_once()
		return
	_busy = true
	_armed = false
	_cooldown = REARM_SECONDS
	call_deferred("_commit_travel")


func _commit_travel() -> void:
	if not is_inside_tree():
		return
	SceneRouter.travel(get_tree(), destination_scene, destination_spawn)


func _show_closed_once() -> void:
	if _closed_shown:
		return
	_closed_shown = true
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.call("show_line", "", closed_line())


func _ui_blocks() -> bool:
	var tree := get_tree()
	if tree == null or tree.paused:
		return true
	var story := tree.root.get_node_or_null("NarrativeState")
	if story != null and story.has_method("movement_locked") and bool(story.call("movement_locked")):
		return true
	return false


func _moving_toward(player: Player) -> bool:
	var vel := player.velocity
	if vel.length_squared() < MIN_APPROACH_SPEED * MIN_APPROACH_SPEED:
		return false
	var to_door := global_position - player.global_position
	if to_door.length_squared() < 9.0:
		return true
	return vel.normalized().dot(to_door.normalized()) > APPROACH_DOT


func _player() -> Player:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("player") as Player


func _is_player(body: Node) -> bool:
	return body != null and body.is_in_group("player")
