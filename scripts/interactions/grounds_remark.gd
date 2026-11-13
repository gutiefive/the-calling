class_name GroundsRemark
extends SpeechProp
## A light aside when the church grounds look tended. No numbers.

const QUIET := "The picnic lawn is the same as last week."
const CARED := "The grounds look cared for. Someone has been out with tools."


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")


func apply_clock() -> void:
	var repairs := get_node_or_null("/root/RepairState")
	if repairs != null and repairs.has_method("looks_cared_for") and bool(repairs.call("looks_cared_for")):
		line = CARED
	else:
		line = QUIET
