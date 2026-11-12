extends SceneTree
## Writes the input map and launch scene into project.godot.
## Includes the Milestone 2 journal and dialogue keys so a rerun does not drop them.
## Run: godot --headless --path . --script res://tools/configure_input.gd

func _init() -> void:
	_bind("move_up", [KEY_W, KEY_UP])
	_bind("move_down", [KEY_S, KEY_DOWN])
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("interact", [KEY_E])
	_bind("pause", [KEY_ESCAPE])
	_bind("cycle_time", [KEY_T])
	_bind("journal", [KEY_J])
	_bind("advance_dialogue", [KEY_SPACE, KEY_ENTER])
	_bind("dialogue_up", [KEY_W, KEY_UP])
	_bind("dialogue_down", [KEY_S, KEY_DOWN])
	ProjectSettings.set_setting("application/run/main_scene", "res://scenes/main.tscn")
	ProjectSettings.set_setting(
		"application/config/description",
		"Story-driven top-down pixel-art RPG. Milestone 4: a first Sunday, a sermon theme, and the end of chapter one."
	)
	var err := ProjectSettings.save()
	print("PROJECT_SETTINGS_SAVE ", err)
	quit(0 if err == OK else 1)


func _bind(action: String, keys: Array) -> void:
	var events: Array[InputEvent] = []
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key as Key
		events.append(ev)
	ProjectSettings.set_setting("input/" + action, {"deadzone": 0.5, "events": events})
