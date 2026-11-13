extends Node
## Church plate, weekly expenses, and the first building project.
## Dollar amounts stay in this autoload and the ledger UI. Dialogue never names them.

const DATA_PATH := "res://data/economy/economy.json"
const PROJECT_NONE := "none"
const PROJECT_ACTIVE := "active"
const PROJECT_REPAIRING := "repairing"
const PROJECT_REPAIRED := "repaired"
const CHOICE_NONE := "none"
const CHOICE_HALF := "half"
const CHOICE_ALL := "all"

var balance: int = 0
var last_service_week: int = 0
var project_id: String = ""
var project_progress: int = 0
var project_state: String = PROJECT_NONE
var repair_week: int = 0
var pending_week: int = 0
var pending_offering: int = 0
var pending_expenses: int = 0
var pending_attendance: int = 0
var pending_theme: String = ""
var pending_choice: String = ""
var history: Array[Dictionary] = []

var _config: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_ensure_config()
	reset()
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_signal("time_changed"):
		if not clock.time_changed.is_connected(_on_time_changed):
			clock.time_changed.connect(_on_time_changed)


func reset() -> void:
	_ensure_config()
	balance = _starting_balance()
	last_service_week = 0
	project_id = str(_project().get("id", "fellowship_hall"))
	project_progress = 0
	project_state = PROJECT_NONE
	repair_week = 0
	_clear_pending()
	history.clear()
	_sync_hall_flags()


func week_number() -> int:
	var clock := get_node_or_null("/root/DayClock")
	if clock != null and clock.has_method("week_number"):
		return int(clock.call("week_number"))
	return 1


func weekly_loop_active() -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	return bool(story.call("flag_is_true", "weekly_loop"))


func has_pending() -> bool:
	return pending_week > 0 and pending_choice.is_empty()


func project_cost() -> int:
	return int(_project().get("cost", 2500))


func project_name() -> String:
	return str(_project().get("name", "Fellowship Hall repair"))


func project_remaining() -> int:
	return maxi(0, project_cost() - project_progress)


func is_hall_repaired() -> bool:
	return project_state == PROJECT_REPAIRED


func is_hall_repairing() -> bool:
	return project_state == PROJECT_REPAIRING


func expense_total() -> int:
	var total := 0
	for row in _expenses():
		total += int(row.get("amount", 0))
	return total


func expense_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for row in _expenses():
		rows.append(row.duplicate(true))
	return rows


func recent_history(limit: int = 4) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var start := maxi(0, history.size() - limit)
	for i in range(start, history.size()):
		out.append(history[i].duplicate(true))
	return out


func preview_week(week: int, theme: String) -> Dictionary:
	return _compute(week, theme)


func settle_sunday(theme: String = "") -> Dictionary:
	_ensure_config()
	var week := week_number()
	if last_service_week == week and pending_week != week:
		return last_entry()
	if pending_week > 0 and pending_week != week:
		_archive_pending(CHOICE_NONE)
	if last_service_week == week and pending_week == week:
		return pending_snapshot()
	var used_theme := theme
	if used_theme.is_empty():
		used_theme = _current_theme()
	var row := _compute(week, used_theme)
	pending_week = week
	pending_offering = int(row.get("offering", 0))
	pending_expenses = int(row.get("expenses", 0))
	pending_attendance = int(row.get("attendance", 0))
	pending_theme = used_theme
	pending_choice = ""
	balance += pending_offering
	balance -= pending_expenses
	last_service_week = week
	_maybe_activate_project()
	return pending_snapshot()


func apply_contribution(choice: String) -> int:
	if pending_week <= 0:
		return 0
	var kind := choice
	if kind != CHOICE_NONE and kind != CHOICE_HALF and kind != CHOICE_ALL:
		kind = CHOICE_NONE
	if project_state != PROJECT_ACTIVE:
		kind = CHOICE_NONE
	var contributed := _contribution_amount(kind)
	if contributed > 0 and project_state == PROJECT_ACTIVE:
		var capped := mini(contributed, project_remaining())
		capped = mini(capped, maxi(0, balance))
		balance -= capped
		project_progress += capped
		contributed = capped
		if project_progress >= project_cost():
			project_progress = project_cost()
			project_state = PROJECT_REPAIRING
			repair_week = pending_week
			_set_flag("hall_repairing", true)
	pending_choice = kind
	_archive_pending(kind, contributed)
	_sync_hall_flags()
	return contributed


func last_entry() -> Dictionary:
	if history.is_empty():
		return {}
	return history[history.size() - 1].duplicate(true)


func pending_snapshot() -> Dictionary:
	return {
		"week": pending_week,
		"offering": pending_offering,
		"expenses": pending_expenses,
		"attendance": pending_attendance,
		"theme": pending_theme,
		"surplus": pending_surplus(),
		"choice": pending_choice,
		"balance": balance,
	}


func pending_surplus() -> int:
	return maxi(0, pending_offering - pending_expenses)


func flavor_line() -> String:
	return "Margaret still notes a deposit she does not recognize."


func to_dictionary() -> Dictionary:
	return {
		"balance": balance,
		"last_service_week": last_service_week,
		"project_id": project_id,
		"project_progress": project_progress,
		"project_state": project_state,
		"repair_week": repair_week,
		"pending_week": pending_week,
		"pending_offering": pending_offering,
		"pending_expenses": pending_expenses,
		"pending_attendance": pending_attendance,
		"pending_theme": pending_theme,
		"pending_choice": pending_choice,
		"history": _history_copies(),
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	balance = int(data.get("balance", _starting_balance()))
	last_service_week = int(data.get("last_service_week", 0))
	project_id = str(data.get("project_id", str(_project().get("id", "fellowship_hall"))))
	project_progress = int(data.get("project_progress", 0))
	project_state = str(data.get("project_state", PROJECT_NONE))
	if project_state.is_empty():
		project_state = PROJECT_NONE
	repair_week = int(data.get("repair_week", 0))
	pending_week = int(data.get("pending_week", 0))
	pending_offering = int(data.get("pending_offering", 0))
	pending_expenses = int(data.get("pending_expenses", 0))
	pending_attendance = int(data.get("pending_attendance", 0))
	pending_theme = str(data.get("pending_theme", ""))
	pending_choice = str(data.get("pending_choice", ""))
	history.clear()
	var rows_v: Variant = data.get("history", [])
	if rows_v is Array:
		for item in rows_v as Array:
			if item is Dictionary:
				history.append((item as Dictionary).duplicate(true))
	_sync_hall_flags()
	_advance_repair()


func _on_time_changed() -> void:
	_maybe_activate_project()
	_advance_repair()


func _advance_repair() -> void:
	if project_state != PROJECT_REPAIRING:
		return
	var week := week_number()
	# Harold works the following week, then the boards come down.
	if week < repair_week + 2:
		return
	project_state = PROJECT_REPAIRED
	_set_flag("hall_repairing", false)
	_set_flag("hall_repaired", true)
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("add_growth"):
		if not bool(story.call("flag_is_true", "hall_growth_applied")):
			story.call("add_growth", "facility_condition", 1)
			story.call("set_flag", "hall_growth_applied", true)
	_sync_hall_flags()
	if story != null and story.has_signal("story_changed"):
		story.story_changed.emit()


func _maybe_activate_project() -> void:
	if project_state != PROJECT_NONE:
		return
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return
	if not bool(story.call("flag_is_true", "hall_proposed")):
		return
	project_state = PROJECT_ACTIVE
	project_progress = 0
	_sync_hall_flags()


func _compute(week: int, theme: String) -> Dictionary:
	_ensure_config()
	var att_cfg: Dictionary = _attendance_cfg()
	var give_cfg: Dictionary = _giving_cfg()
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng_seed() + week * 17
	var attendance := int(att_cfg.get("core_regulars", 15))
	attendance += _named_turnout()
	attendance += _influence_nudge()
	var variance := int(att_cfg.get("variance", 2))
	attendance += rng.randi_range(-variance, variance)
	attendance = maxi(int(att_cfg.get("min_attendance", 8)), attendance)
	var offering := 0
	var per_min := int(give_cfg.get("per_person_min", 24))
	var per_max := int(give_cfg.get("per_person_max", 34))
	if per_max < per_min:
		per_max = per_min
	for _i in attendance:
		offering += rng.randi_range(per_min, per_max)
	if _sermon_fits(theme):
		offering += int(give_cfg.get("sermon_fit_bonus", 0))
	var expenses := expense_total()
	return {
		"week": week,
		"attendance": attendance,
		"offering": offering,
		"expenses": expenses,
		"surplus": maxi(0, offering - expenses),
		"theme": theme,
		"fits": _sermon_fits(theme),
	}


func _named_turnout() -> int:
	var extra := 0
	if _person_comes("frank"):
		extra += 1
	if _person_comes("sarah"):
		extra += 1
	if _flag("garden_planted"):
		extra += 1
	if _flag("grounds_tidy"):
		extra += 1
	return extra


func _person_comes(npc_id: String) -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null:
		return false
	if story.has_method("relationship") and int(story.call("relationship", npc_id)) >= 1:
		return true
	if npc_id == "frank":
		return _flag("frank_listened") or _flag("frank_invited")
	if npc_id == "sarah":
		return _flag("sarah_heard")
	return false


func _influence_nudge() -> int:
	var att_cfg: Dictionary = _attendance_cfg()
	var amount := int(att_cfg.get("influence_nudge", 1))
	if amount == 0:
		return 0
	var inf := get_node_or_null("/root/InfluenceState")
	if inf == null or not inf.has_method("pull_total"):
		return 0
	var pull := int(inf.call("pull_total"))
	if pull >= 2:
		return amount
	if pull <= -2:
		return -amount
	return 0


func _sermon_fits(theme: String) -> bool:
	match theme:
		"hope":
			return _flag("sarah_heard") or _growth("congregation_health") >= 1
		"forgiveness":
			return _flag("frank_listened")
		"service":
			return _flag("grounds_tidy") or _flag("garden_planted")
		_:
			return false


func _current_theme() -> String:
	var weekly := str(_flag_value("weekly_sermon_theme", ""))
	if not weekly.is_empty():
		return weekly
	return str(_flag_value("sermon_theme", ""))


func _contribution_amount(choice: String) -> int:
	var surplus := pending_surplus()
	if choice == CHOICE_ALL:
		return surplus
	if choice == CHOICE_HALF:
		return surplus / 2
	return 0


func _archive_pending(choice: String, contributed: int = -1) -> void:
	if pending_week <= 0:
		return
	var amount := contributed
	if amount < 0:
		amount = _contribution_amount(choice)
		if amount > 0 and project_state == PROJECT_ACTIVE:
			amount = mini(amount, mini(project_remaining(), maxi(0, balance)))
			balance -= amount
			project_progress += amount
	var entry := {
		"week": pending_week,
		"offering": pending_offering,
		"expenses": pending_expenses,
		"contribution": maxi(0, amount),
		"attendance": pending_attendance,
		"theme": pending_theme,
		"choice": choice,
		"balance": balance,
	}
	history.append(entry)
	_clear_pending()


func _clear_pending() -> void:
	pending_week = 0
	pending_offering = 0
	pending_expenses = 0
	pending_attendance = 0
	pending_theme = ""
	pending_choice = ""


func _history_copies() -> Array:
	var rows: Array = []
	for row in history:
		rows.append(row.duplicate(true))
	return rows


func _sync_hall_flags() -> void:
	_set_flag("hall_repairing", project_state == PROJECT_REPAIRING)
	_set_flag("hall_repaired", project_state == PROJECT_REPAIRED)


func _set_flag(key: String, value: bool) -> void:
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("set_flag"):
		story.call("set_flag", key, value)


func _flag(key: String) -> bool:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	return bool(story.call("flag_is_true", key))


func _flag_value(key: String, fallback: Variant) -> Variant:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("get_flag"):
		return fallback
	return story.call("get_flag", key, fallback)


func _growth(key: String) -> int:
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("growth_value"):
		return 0
	return int(story.call("growth_value", key))


func _ensure_config() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed: Variant = JsonFile.read(DATA_PATH)
	if parsed is Dictionary:
		_config = parsed
	else:
		_config = {}


func _starting_balance() -> int:
	return int(_config.get("starting_balance", 55))


func _rng_seed() -> int:
	return int(_config.get("rng_seed", 8))


func _attendance_cfg() -> Dictionary:
	var raw: Variant = _config.get("attendance", {})
	return raw if raw is Dictionary else {}


func _giving_cfg() -> Dictionary:
	var raw: Variant = _config.get("giving", {})
	return raw if raw is Dictionary else {}


func _project() -> Dictionary:
	var raw: Variant = _config.get("project", {})
	return raw if raw is Dictionary else {}


func _expenses() -> Array:
	var raw: Variant = _config.get("expenses", [])
	return raw if raw is Array else []
