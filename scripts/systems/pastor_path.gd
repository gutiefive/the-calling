extends Node
## Hidden pastor leanings. Three small integer tracks. Never shown as numbers.
## Separate from InfluenceState (Pull). D45.

const SHEPHERD := "shepherd"
const BUILDER := "builder"
const SKEPTIC := "skeptic"
const LEANINGS: PackedStringArray = [SHEPHERD, BUILDER, SKEPTIC]
const DEFAULT_SEED := 8


var _shepherd: int = 0
var _builder: int = 0
var _skeptic: int = 0
var _history: Array[String] = []
var _run_seed: int = DEFAULT_SEED


func reset() -> void:
	_shepherd = 0
	_builder = 0
	_skeptic = 0
	_history.clear()
	_run_seed = DEFAULT_SEED


func nudge(leaning: String, amount: int, reason_id: String) -> void:
	if amount == 0:
		if not reason_id.is_empty() and not _history.has(reason_id):
			_history.append(reason_id)
		return
	if not reason_id.is_empty() and _history.has(reason_id):
		return
	_add(leaning, amount)
	if not reason_id.is_empty():
		_history.append(reason_id)


func lean_at_least(leaning: String, amount: int) -> bool:
	return _value(leaning) >= amount


func dominant() -> String:
	var shepherd_v := _shepherd
	var builder_v := _builder
	var skeptic_v := _skeptic
	var high := shepherd_v
	if builder_v > high:
		high = builder_v
	if skeptic_v > high:
		high = skeptic_v
	if high <= 0:
		return ""
	var lead := ""
	var ties := 0
	if shepherd_v == high:
		lead = SHEPHERD
		ties += 1
	if builder_v == high:
		lead = BUILDER
		ties += 1
	if skeptic_v == high:
		lead = SKEPTIC
		ties += 1
	if ties != 1:
		return ""
	return lead


func has_reason(reason_id: String) -> bool:
	return _history.has(reason_id)


func reason_history() -> PackedStringArray:
	var rows := PackedStringArray()
	for item in _history:
		rows.append(item)
	return rows


func run_seed() -> int:
	return _run_seed


func set_seed(value: int) -> void:
	_run_seed = value


func roll_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_run_seed = int(rng.randi_range(1, 2147483646))
	return _run_seed


func crowd_shift() -> int:
	return posmod(_run_seed, 3)


func pick_index(modulus: int, salt: int = 0) -> int:
	if modulus <= 0:
		return 0
	return posmod(_run_seed * 31 + salt * 17, modulus)


func to_dictionary() -> Dictionary:
	return {
		"shepherd": _shepherd,
		"builder": _builder,
		"skeptic": _skeptic,
		"history": _history_values(),
		"seed": _run_seed,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	_shepherd = int(data.get("shepherd", 0))
	_builder = int(data.get("builder", 0))
	_skeptic = int(data.get("skeptic", 0))
	_history.clear()
	var history_v: Variant = data.get("history", [])
	if history_v is Array:
		for item in history_v as Array:
			var reason := str(item)
			if not reason.is_empty() and not _history.has(reason):
				_history.append(reason)
	if data.has("seed"):
		_run_seed = int(data.get("seed", DEFAULT_SEED))


func _add(leaning: String, amount: int) -> void:
	match leaning:
		SHEPHERD:
			_shepherd += amount
		BUILDER:
			_builder += amount
		SKEPTIC:
			_skeptic += amount


func _value(leaning: String) -> int:
	match leaning:
		SHEPHERD:
			return _shepherd
		BUILDER:
			return _builder
		SKEPTIC:
			return _skeptic
		_:
			return 0


func _history_values() -> Array:
	var rows: Array = []
	for item in _history:
		rows.append(item)
	return rows
