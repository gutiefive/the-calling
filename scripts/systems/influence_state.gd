extends Node
## Hidden Pull. Three parts plus a general total. Never shown as a number.
## Ladder stage 1 is person-by-person trust. Chapter stays empty until M8.

const STAGE_TRUST := 1
const PARTS: PackedStringArray = ["seats", "storefronts", "dependents"]

var _seats: int = 0
var _storefronts: int = 0
var _dependents: int = 0
var _total: int = 0
var _stage: int = STAGE_TRUST
var _chapter: String = ""


func reset() -> void:
	_seats = 0
	_storefronts = 0
	_dependents = 0
	_total = 0
	_stage = STAGE_TRUST
	_chapter = ""


func add_pull(amount: int, part: String = "") -> void:
	_total += amount
	match part:
		"seats":
			_seats += amount
		"storefronts":
			_storefronts += amount
		"dependents":
			_dependents += amount


func pull_total() -> int:
	return _total


func pull_part(part: String) -> int:
	match part:
		"seats":
			return _seats
		"storefronts":
			return _storefronts
		"dependents":
			return _dependents
		_:
			return 0


func pull_at_least(amount: int) -> bool:
	return _total >= amount


func influence_stage() -> int:
	return _stage


func influence_stage_at_least(amount: int) -> bool:
	return _stage >= amount


func chapter() -> String:
	return _chapter


func set_chapter(value: String) -> void:
	_chapter = value


func to_dictionary() -> Dictionary:
	return {
		"seats": _seats,
		"storefronts": _storefronts,
		"dependents": _dependents,
		"total": _total,
		"stage": _stage,
		"chapter": _chapter,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	_seats = int(data.get("seats", 0))
	_storefronts = int(data.get("storefronts", 0))
	_dependents = int(data.get("dependents", 0))
	if data.has("total"):
		_total = int(data.get("total", 0))
	else:
		_total = _seats + _storefronts + _dependents
	_stage = int(data.get("stage", STAGE_TRUST))
	if _stage < 1:
		_stage = STAGE_TRUST
	_chapter = str(data.get("chapter", ""))
