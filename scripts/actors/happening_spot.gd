class_name HappeningSpot
extends DialogueNpc
## A discoverable moment that is only present on its day and hours.

@export var happening_id: String = ""


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("ambient_happening")


func _ready() -> void:
	super._ready()
	apply_clock()


func apply_clock() -> void:
	var clock := get_node_or_null("/root/DayClock")
	var here := false
	if clock != null and not happening_id.is_empty():
		var day := str(clock.call("weekday_name"))
		var hour := int(clock.get("hour"))
		var minute := int(clock.get("minute"))
		var scene_ok := true
		var wanted := HappeningSchedule.scene_for(happening_id)
		if not wanted.is_empty():
			var room := _room()
			scene_ok = room != null and NpcSchedule.scene_id(room) == wanted
		here = scene_ok and HappeningSchedule.is_active(happening_id, day, hour, minute)
	visible = here
	enabled = here


func _room() -> Node:
	var node := get_parent()
	while node != null:
		if node.scene_file_path.begins_with("res://scenes/world/"):
			return node
		node = node.get_parent()
	return null
