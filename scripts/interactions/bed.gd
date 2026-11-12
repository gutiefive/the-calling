class_name Bed
extends Interactable
## Sleeps until the next morning. The day card is what you wake up to.


func interact(actor: Node) -> void:
	super.interact(actor)
	var card := _day_card()
	if card == null:
		return
	if card.has_method("is_blocking") and bool(card.call("is_blocking")):
		return
	if NarrativeState.ending_open or NarrativeState.dialogue_open:
		return
	if card.has_method("begin_sleep"):
		card.call("begin_sleep")


func _day_card() -> Node:
	var node: Node = self
	while node != null:
		var card := node.get_node_or_null("HUD/DayCard")
		if card != null:
			return card
		node = node.get_parent()
	return null
