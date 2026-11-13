class_name ScheduledDoor
extends Door
## Opens only while the named person is inside, on the week schedule.
## A shut door says when to come back and does not change rooms.

@export var hours_id: String = ""


func interact(actor: Node) -> void:
	if ShopHours.is_open(hours_id):
		super.interact(actor)
		return
	interacted.emit()
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line("", ShopHours.closed_line(hours_id))
