class_name GroundsChore
extends Interactable
## One small piece of the church-grounds cleanup. Optional.

@export var chore_id: String = ""
@export var done_line: String = "That's enough for this spot."
@export var work_line: String = "You clear a little of it."


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")


func apply_clock() -> void:
	var done := _is_done()
	if chore_id.begins_with("litter"):
		visible = not done
		enabled = not done


func interact(actor: Node) -> void:
	super.interact(actor)
	if chore_id.is_empty():
		return
	var already := _is_done()
	if not already:
		NarrativeState.set_flag(_flag(), true)
		_try_finish()
		_refresh()
	_say(done_line if _is_done() else work_line)


func _is_done() -> bool:
	return NarrativeState.flag_is_true(_flag())


func _flag() -> String:
	return "grounds_" + chore_id


func _try_finish() -> void:
	if NarrativeState.flag_is_true("grounds_tidy"):
		return
	if not NarrativeState.flag_is_true("grounds_litter_a"):
		return
	if not NarrativeState.flag_is_true("grounds_litter_b"):
		return
	if not NarrativeState.flag_is_true("grounds_bed"):
		return
	NarrativeState.set_flag("grounds_tidy", true)
	NarrativeState.add_growth("facility_condition", 1)
	NarrativeState.add_note("The church walk looks looked-after.")


func _refresh() -> void:
	var node: Node = self
	while node != null:
		if node.has_method("_apply_grounds_look"):
			node.call("_apply_grounds_look")
			return
		node = node.get_parent()


func _say(text: String) -> void:
	ActionToast.say(get_tree(), text)
