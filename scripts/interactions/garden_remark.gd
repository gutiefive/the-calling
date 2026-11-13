class_name GardenRemark
extends SpeechProp
## A light, non-numeric aside. Only sounds pleased when the beds are tended.

const QUIET := "Open ground inside the fence. Quiet, for now."
const TENDED := "The ground looks tended. Someone's been out here."


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")


func apply_clock() -> void:
	var garden := get_node_or_null("/root/GardenState")
	if garden != null and garden.has_method("looks_cared_for") and bool(garden.call("looks_cared_for")):
		line = TENDED
	else:
		line = QUIET
