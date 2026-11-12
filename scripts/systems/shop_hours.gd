class_name ShopHours
extends RefCounted
## A shop is open while that person's schedule still puts them on Oak Street.


static func is_open(npc_id: String) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or npc_id.is_empty():
		return false
	var clock := tree.root.get_node_or_null("DayClock")
	if clock == null:
		return false
	var day := str(clock.call("weekday_name"))
	var hour := int(clock.get("hour"))
	var minute := int(clock.get("minute"))
	var place := NpcSchedule.placement(npc_id, day, hour, minute)
	if place.is_empty():
		return false
	return str(place.get("scene", "")) == "hardware_street"


static func closed_line(npc_id: String) -> String:
	if npc_id == "frank":
		return "Closed. Back at 8."
	return "Closed. Back at 9."
