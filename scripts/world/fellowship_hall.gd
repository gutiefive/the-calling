class_name FellowshipHall
extends Interactable
## Worn hall until the project is funded and Harold finishes the week of repair.

var speaker_name: String = "Fellowship Hall"
var _sprite: Sprite2D


func _enter_tree() -> void:
	blocks_movement = true
	block_size = Vector2(168, 36)
	block_offset = Vector2(0, -8)
	super._enter_tree()
	add_to_group("day_world")


func _ready() -> void:
	prompt_text = "Look at the hall"
	speaker_name = "Fellowship Hall"
	radius = 52.0
	blocks_movement = true
	block_size = Vector2(168, 36)
	block_offset = Vector2(0, -8)
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	apply_clock()


func apply_clock() -> void:
	var repaired := NarrativeState.flag_is_true("hall_repaired")
	if _sprite != null:
		_sprite.texture = PlaceholderArt.fellowship_hall(repaired)
		if _sprite.texture != null:
			_sprite.offset = Vector2(0, -_sprite.texture.get_height() * 0.5)
	if repaired and not NarrativeState.flag_is_true("hall_celebrated"):
		prompt_text = "Talk"
		speaker_name = "Harold"
		enabled = true
	elif repaired:
		prompt_text = "Look in"
		speaker_name = "Fellowship Hall"
		enabled = false
	else:
		prompt_text = "Look at the hall"
		speaker_name = "Fellowship Hall"
		enabled = true


func interact(actor: Node) -> void:
	interacted.emit()
	if NarrativeState.flag_is_true("hall_repaired") and not NarrativeState.flag_is_true("hall_celebrated"):
		_open_dialogue("hall_celebration", actor)
		return
	var banner := _banner()
	if banner != null and banner.has_method("show_line"):
		banner.call("show_line", speaker_name, _look_line())


func is_repaired_look() -> bool:
	if _sprite == null or _sprite.texture == null:
		return false
	var path := _sprite.texture.resource_path
	return path.ends_with("fellowship_hall_repaired.png") or NarrativeState.flag_is_true("hall_repaired")


func _look_line() -> String:
	if NarrativeState.flag_is_true("hall_repaired"):
		return "The hall smells like coffee and floor wax. Wednesday dishes still sit in the washbasin."
	if NarrativeState.flag_is_true("hall_repairing"):
		return "Harold left a saw and a promise. The boards are half down."
	return "The Fellowship Hall is boarded. The roof still holds."


func _open_dialogue(conversation_id: String, source: Node) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var box := tree.get_first_node_in_group("dialogue_box")
	if box != null and box.has_method("open_conversation"):
		box.call("open_conversation", conversation_id, source)


func _banner() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("speech_banner")
