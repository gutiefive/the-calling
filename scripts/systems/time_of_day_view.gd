class_name TimeOfDayView
extends Node
## Applies TimeOfDay to this room's modulate, sun, and grouped lights.

@export var interior: bool = false

var _toast: float = 0.0


func _ready() -> void:
	add_to_group("time_of_day_view")


func _process(delta: float) -> void:
	if _toast <= 0.0:
		return
	_toast -= delta
	if _toast <= 0.0:
		_set_phase_text(TimeOfDay.phase_name())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("cycle_time"):
		return
	TimeOfDay.cycle()
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("time_of_day_view"):
		if node.has_method("apply"):
			node.apply()
	_toast = 1.4
	_set_phase_text("%s  (T)" % TimeOfDay.phase_name())
	get_viewport().set_input_as_handled()


func apply() -> void:
	var modulate := get_node_or_null("CanvasModulate") as CanvasModulate
	if modulate != null:
		modulate.color = TimeOfDay.ambient(interior)
	var sun := get_node_or_null("Sun") as DirectionalLight2D
	if sun != null:
		# A low exterior sun reads as daylight. Indoors, lamps carry the light.
		sun.energy = 0.0 if interior else TimeOfDay.sun_energy()
		sun.color = TimeOfDay.sun_color()
	_set_group_energy("tod_lamp", TimeOfDay.lamp_energy(interior))
	_set_group_energy("tod_window", TimeOfDay.window_energy())
	if _toast <= 0.0:
		_set_phase_text(TimeOfDay.phase_name())


func _set_group_energy(group_name: String, energy: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	# One room is loaded at a time, so every light in the group belongs to it.
	for node in tree.get_nodes_in_group(group_name):
		if node is PointLight2D:
			(node as PointLight2D).energy = energy


func _set_phase_text(value: String) -> void:
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("phase_label"):
		if node is Label:
			(node as Label).text = value
