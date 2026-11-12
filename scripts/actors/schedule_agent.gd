class_name ScheduleAgent
extends Node
## Moves one scheduled NPC along a planned route. Arrival asks the room to rebuild foot collision.

const SPEED := 56.0

var _points: Array[Vector2] = []
var _active: bool = false


func begin(points: Array) -> void:
	_points.clear()
	for item in points:
		if item is Vector2:
			_points.append(item as Vector2)
	_active = not _points.is_empty()


func stop() -> void:
	_active = false
	_points.clear()


func is_walking() -> bool:
	return _active


func _physics_process(delta: float) -> void:
	if not _active:
		return
	var body := get_parent() as Node2D
	if body == null or _points.is_empty():
		_active = false
		return
	var dest: Vector2 = _points[0]
	var offset := dest - body.position
	var step := SPEED * delta
	if offset.length() <= step:
		body.position = dest
		_points.remove_at(0)
		if _points.is_empty():
			_active = false
			_arrive(body)
	else:
		body.position += offset.normalized() * step


func _arrive(body: Node2D) -> void:
	body.set_meta("schedule_walking", false)
	var room := body
	while room != null:
		if room.has_method("rebuild_collision"):
			room.call("rebuild_collision")
			return
		room = room.get_parent()
