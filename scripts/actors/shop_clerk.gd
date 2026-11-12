class_name ShopClerk
extends DialogueNpc
## The same person, behind the counter, during the hours they already keep on the street.

@export var hours_id: String = ""


func _enter_tree() -> void:
	# Leave npc_id empty so the street schedule is not pulled indoors.
	npc_id = ""
	super._enter_tree()
	add_to_group("shop_clerk")


func _ready() -> void:
	super._ready()
	apply_clock()


func apply_clock() -> void:
	var open := ShopHours.is_open(hours_id)
	visible = open
	enabled = open
