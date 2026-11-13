class_name ShopClerk
extends DialogueNpc
## The same person, behind the counter, during the hours they already keep on the street.

@export var hours_id: String = ""


func _enter_tree() -> void:
	# The week schedule is the only copy of this person. The sidewalk node hides while they are here.
	if npc_id.is_empty():
		npc_id = hours_id
	super._enter_tree()
	add_to_group("shop_clerk")


func _ready() -> void:
	super._ready()
	apply_clock()


func apply_clock() -> void:
	# NpcSchedule already showed or hid this node. Do not turn the sidewalk hours back on.
	if not npc_id.is_empty():
		return
	var open := ShopHours.is_open(hours_id)
	visible = open
	enabled = open
