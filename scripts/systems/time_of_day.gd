class_name TimeOfDay
extends RefCounted
## Session-only day / evening / night. Restarting the game returns to day.
## Night colors stay bright enough that paths and the player remain readable.

enum Phase { DAY, EVENING, NIGHT }

static var phase: Phase = Phase.DAY


static func cycle() -> void:
	match phase:
		Phase.DAY:
			phase = Phase.EVENING
		Phase.EVENING:
			phase = Phase.NIGHT
		_:
			phase = Phase.DAY


static func set_phase(value: Phase) -> void:
	phase = value


static func phase_name() -> String:
	match phase:
		Phase.DAY:
			return "Day"
		Phase.EVENING:
			return "Evening"
		_:
			return "Night"


static func ambient(interior: bool) -> Color:
	match phase:
		Phase.DAY:
			return Color(1.0, 0.95, 0.88) if interior else Color(1.0, 0.97, 0.92)
		Phase.EVENING:
			return Color(0.90, 0.70, 0.55) if interior else Color(0.98, 0.70, 0.52)
		_:
			# Interior night is a dim warm room. Exterior night is blue, not black.
			return Color(0.64, 0.58, 0.50) if interior else Color(0.52, 0.58, 0.78)


static func lamp_energy(interior: bool) -> float:
	match phase:
		Phase.DAY:
			return 0.45 if interior else 0.08
		Phase.EVENING:
			return 0.95 if interior else 0.75
		_:
			return 1.2 if interior else 1.35


static func window_energy() -> float:
	match phase:
		Phase.DAY:
			return 0.0
		Phase.EVENING:
			return 0.5
		_:
			return 0.9


static func stained_energy() -> float:
	match phase:
		Phase.DAY:
			return 0.9
		Phase.EVENING:
			return 0.55
		_:
			return 0.16


static func sun_energy() -> float:
	match phase:
		Phase.DAY:
			return 0.1
		Phase.EVENING:
			return 0.04
		_:
			return 0.0


static func sun_color() -> Color:
	if phase == Phase.EVENING:
		return Color(1.0, 0.72, 0.45)
	return Color(1.0, 0.96, 0.88)
