extends Node
## Weekday clock for the opening week. Thursday 2:00 p.m. through Saturday night.
## Exploring advances time at MINUTES_PER_REAL_SECOND. Dialogue, the journal, and pause hold it.
## One frame never moves more than one in-game minute, so a hitch cannot skip a schedule.
## Sunday services are Milestone 4. The clock stops at Saturday 11:59 p.m.

signal time_changed

const MINUTES_PER_REAL_SECOND := 4.0
const MAX_REAL_STEP := 0.25
const WEEKDAYS: PackedStringArray = [
	"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday",
]
const START_WEEKDAY := 4
const START_HOUR := 14
const START_MINUTE := 0
const LAST_WEEKDAY := 6
const LAST_HOUR := 23
const LAST_MINUTE := 59

var weekday: int = START_WEEKDAY
var hour: int = START_HOUR
var minute: int = START_MINUTE

var _carry: float = 0.0


func _ready() -> void:
	_commit(true)


func _process(delta: float) -> void:
	if not is_exploring():
		return
	tick(minf(delta, MAX_REAL_STEP))


func is_exploring() -> bool:
	var tree := get_tree()
	if tree == null or tree.paused:
		return false
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("movement_locked") and bool(story.call("movement_locked")):
		return false
	return true


func tick(seconds: float) -> void:
	if seconds <= 0.0 or at_cap():
		return
	_carry += seconds * MINUTES_PER_REAL_SECOND
	var whole := int(_carry)
	if whole <= 0:
		return
	_carry -= float(whole)
	advance_minutes(whole)


func advance_minutes(amount: int) -> void:
	if amount <= 0 or at_cap():
		return
	var total := weekday * 24 * 60 + hour * 60 + minute + amount
	var cap := LAST_WEEKDAY * 24 * 60 + LAST_HOUR * 60 + LAST_MINUTE
	if total > cap:
		total = cap
	weekday = int(total / (24 * 60))
	var rem := total % (24 * 60)
	hour = int(rem / 60)
	minute = rem % 60
	_commit(false)


func set_time(day: int, h: int, m: int) -> void:
	weekday = clampi(day, 0, 6)
	hour = clampi(h, 0, 23)
	minute = clampi(m, 0, 59)
	# Sunday is not playable yet. A set or a load that asks for it stays on Saturday night.
	if weekday == 0 or weekday > LAST_WEEKDAY:
		weekday = LAST_WEEKDAY
		hour = LAST_HOUR
		minute = LAST_MINUTE
	_carry = 0.0
	_commit(true)


func skip_ahead() -> void:
	var phase := phase_for_hour(hour)
	var day := weekday
	var h := 6
	if phase == TimeOfDay.Phase.DAY:
		h = 17
	elif phase == TimeOfDay.Phase.EVENING:
		h = 20
	elif hour >= 6:
		day += 1
	if day > LAST_WEEKDAY:
		set_time(LAST_WEEKDAY, LAST_HOUR, LAST_MINUTE)
		return
	set_time(day, h, 0)


func at_cap() -> bool:
	return weekday == LAST_WEEKDAY and hour == LAST_HOUR and minute == LAST_MINUTE


func weekday_name() -> String:
	if weekday < 0 or weekday >= WEEKDAYS.size():
		return ""
	return WEEKDAYS[weekday]


func clock_text() -> String:
	var suffix := "AM" if hour < 12 else "PM"
	var h12 := hour % 12
	if h12 == 0:
		h12 = 12
	return "%s %d:%02d %s" % [weekday_name(), h12, minute, suffix]


func phase_for_hour(h: int) -> TimeOfDay.Phase:
	if h >= 6 and h < 17:
		return TimeOfDay.Phase.DAY
	if h >= 17 and h < 20:
		return TimeOfDay.Phase.EVENING
	return TimeOfDay.Phase.NIGHT


func to_dictionary() -> Dictionary:
	return {"weekday": weekday, "hour": hour, "minute": minute}


func from_dictionary(data: Dictionary) -> void:
	set_time(
		int(data.get("weekday", START_WEEKDAY)),
		int(data.get("hour", START_HOUR)),
		int(data.get("minute", START_MINUTE))
	)


func reset() -> void:
	set_time(START_WEEKDAY, START_HOUR, START_MINUTE)


func _commit(force_lights: bool) -> void:
	var next := phase_for_hour(hour)
	var changed := TimeOfDay.phase != next
	if changed:
		TimeOfDay.set_phase(next)
	if changed or force_lights:
		_refresh_lights()
	_refresh_clock_labels()
	time_changed.emit()


func _refresh_lights() -> void:
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("time_of_day_view"):
		if node.has_method("apply"):
			node.call("apply")


func _refresh_clock_labels() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var text := clock_text()
	for node in tree.get_nodes_in_group("clock_label"):
		if node is Label:
			(node as Label).text = text
