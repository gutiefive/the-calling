class_name InteriorAmbient
extends AmbientTownsfolk
## Unnamed interior neighbor with a weekday window. Stays in a small idle loop.

@export var days: PackedStringArray = PackedStringArray()
@export var from_hour: int = 8
@export var until_hour: int = 17
@export var hide_during_service: bool = false
@export var idle_line: String = ""


func bark_text() -> String:
	if not idle_line.is_empty():
		return idle_line
	return super.bark_text()


func apply_clock() -> void:
	if hide_during_service and _service_hour():
		visible = false
		enabled = false
		return
	if not _window_now():
		visible = false
		enabled = false
		return
	super.apply_clock()


func _window_now() -> bool:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return true
	if days.size() > 0:
		var day := str(clock.call("weekday_name"))
		var listed := false
		for item in days:
			if str(item) == day:
				listed = true
				break
		if not listed:
			return false
	var hour := int(clock.get("hour"))
	return hour >= from_hour and hour < until_hour


func _service_hour() -> bool:
	var clock := get_node_or_null("/root/DayClock")
	if clock == null:
		return false
	if str(clock.call("weekday_name")) != "Sunday":
		return false
	return int(clock.get("hour")) >= 10
