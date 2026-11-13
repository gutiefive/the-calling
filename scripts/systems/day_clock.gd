extends Node
## Opening week: Thursday 2:00 p.m. through this Sunday night, until the chapter lets the week continue.
## Exploring advances time at MINUTES_PER_REAL_SECOND. Dialogue, the journal, pause, and the ending hold it.
## One frame never moves more than one in-game minute, so a hitch cannot skip a schedule.
## This Sunday is stored as weekday 7. Calendar weekday 0 is the same morning, accepted by set_time.
## After Continue, weekday keeps climbing. Names repeat every seven days. Later Sundays are weekday 14, 21, and so on.

signal time_changed

const MINUTES_PER_REAL_SECOND := 4.0
const MAX_REAL_STEP := 0.25
const WEEKDAYS: PackedStringArray = [
	"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday",
]
const START_WEEKDAY := 4
const START_HOUR := 14
const START_MINUTE := 0
const LAST_WEEKDAY := 7
const LAST_HOUR := 23
const LAST_MINUTE := 59
const LATER_SUNDAY_NOTE := "The room is quiet this morning. The next chapter is still being written."

var weekday: int = START_WEEKDAY
var hour: int = START_HOUR
var minute: int = START_MINUTE
## Title screen holds the clock. Gameplay rooms clear it.
var held: bool = false

var _carry: float = 0.0


func _ready() -> void:
	_commit(true)


func _process(delta: float) -> void:
	if not is_exploring():
		return
	tick(minf(delta, MAX_REAL_STEP))


func is_exploring() -> bool:
	if held:
		return false
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
	if not week_continues():
		var cap := LAST_WEEKDAY * 24 * 60 + LAST_HOUR * 60 + LAST_MINUTE
		if total > cap:
			total = cap
	weekday = int(total / (24 * 60))
	var rem := total % (24 * 60)
	hour = int(rem / 60)
	minute = rem % 60
	_commit(false)


func set_time(day: int, h: int, m: int) -> void:
	var resolved: int = day
	# Callers say Sunday as 0. The opening week stores that morning as the day after Saturday.
	if resolved == 0:
		resolved = 7
	if week_continues():
		weekday = maxi(resolved, 1)
	else:
		weekday = clampi(resolved, 1, LAST_WEEKDAY)
	hour = clampi(h, 0, 23)
	minute = clampi(m, 0, 59)
	_carry = 0.0
	_commit(true)


func sleep_until_morning() -> void:
	# Before the chapter continues, Sunday after dawn stays put. The day card still shows.
	if not week_continues() and weekday >= LAST_WEEKDAY and hour >= 6:
		return
	var day := weekday
	if hour >= 6:
		day += 1
	set_time(day, 6, 0)


func skip_ahead() -> void:
	if at_cap():
		return
	# The first Sunday morning lands on the service. Later Sundays have no sermon to catch.
	if is_opening_sunday() and hour < 10:
		set_time(weekday, 10, 0)
		return
	var phase := phase_for_hour(hour)
	var day := weekday
	var h := 6
	if phase == TimeOfDay.Phase.DAY:
		h = 17
	elif phase == TimeOfDay.Phase.EVENING:
		h = 20
	elif hour >= 6:
		day += 1
	if not week_continues() and day > LAST_WEEKDAY:
		set_time(LAST_WEEKDAY, LAST_HOUR, LAST_MINUTE)
		return
	set_time(day, h, 0)


func at_cap() -> bool:
	if week_continues():
		return false
	return weekday == LAST_WEEKDAY and hour == LAST_HOUR and minute == LAST_MINUTE


func week_continues() -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	return bool(story.call("flag_is_true", "week_continues"))


func is_opening_sunday() -> bool:
	return weekday_name() == "Sunday" and weekday <= LAST_WEEKDAY


func is_later_sunday() -> bool:
	return weekday_name() == "Sunday" and weekday > LAST_WEEKDAY


func weekday_name() -> String:
	var index: int = weekday % 7
	if index < 0 or index >= WEEKDAYS.size():
		return ""
	return WEEKDAYS[index]


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
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("reconcile_calendar"):
		story.call("reconcile_calendar")
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
