class_name BuildingDoor
extends Door
## A facade door. Empty destination_scene keeps the building closed with a
## one-line flavor message. A later milestone can set destination_scene to
## make the interior enterable without changing the trigger.

@export var flavor_line: String = "Nobody seems to be home."
@export var building_id: String = ""


func is_open() -> bool:
	return not destination_scene.is_empty()


func closed_line() -> String:
	if flavor_line.is_empty():
		return "It's locked."
	return flavor_line


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if _ui_blocks():
		return
	var player := _player()
	if player == null or not is_hovering(player):
		return
	if is_open():
		return
	_closed_shown = false
	_show_closed_once()
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
