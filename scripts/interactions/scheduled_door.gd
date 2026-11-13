class_name ScheduledDoor
extends Door
## Opens only while the named person is inside, on the week schedule.
## A shut door says when to come back and does not change rooms.

@export var hours_id: String = ""


func is_open() -> bool:
	return ShopHours.is_open(hours_id)


func closed_line() -> String:
	return ShopHours.closed_line(hours_id)
