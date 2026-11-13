class_name DialogueBox
extends SpeechBanner
## Speaker, revealed line, and choices. One character per physics frame; confirm skips, then advances.

const REVEAL_PER_TICK := 1
const LEAVE_DISTANCE := 110.0
const NAME_COLOR := "d7b48a"
const CHOICE_ON := "f0e2c4"
const CHOICE_OFF := "a89880"

var _runner: DialogueRunner
var _source: Node2D
var _conversation: bool = false
var _pinned: bool = false
var _reveal: int = 0
var _selected: int = 0
var _advance_was: bool = false
var _up_was: bool = false
var _down_was: bool = false
var _closed_physics_frame: int = -100
var _opened_physics_frame: int = -100


func _ready() -> void:
	super._ready()
	add_to_group("dialogue_box")
	offset_left = 16.0
	offset_top = -168.0
	offset_right = -16.0
	offset_bottom = -40.0
	if _label != null:
		_label.fit_content = false
		_label.scroll_active = false
		_label.custom_minimum_size = Vector2(560, 100)


func _process(delta: float) -> void:
	if _conversation:
		_watch_distance()
		return
	super._process(delta)


func _physics_process(_delta: float) -> void:
	if not _conversation:
		return
	_reveal_step()
	_watch_distance()
	_poll_input()


func _exit_tree() -> void:
	var was_open := _conversation
	_conversation = false
	_runner = null
	if not was_open:
		return
	var story := get_node_or_null("/root/NarrativeState")
	if story != null:
		story.set("dialogue_open", false)


func is_conversation_open() -> bool:
	return _conversation


func is_revealing() -> bool:
	return _conversation and _runner != null and _reveal < _runner.body().length()


func closed_this_frame() -> bool:
	return _closed_physics_frame == Engine.get_physics_frames()


func open_conversation(conversation_id: String, source: Node2D, pinned: bool = false) -> bool:
	if _conversation:
		return true
	var data := DialogueRunner.load_conversation(conversation_id)
	if data.is_empty():
		return false
	var runner := DialogueRunner.new()
	if not runner.start(data):
		return false
	_runner = runner
	_source = source
	_pinned = pinned
	_conversation = true
	_reveal = 0
	_selected = 0
	_opened_physics_frame = Engine.get_physics_frames()
	_sync_held_keys()
	_left = 0.0
	NarrativeState.set_dialogue_open(true)
	visible = true
	_refresh_text()
	return true


func close_conversation() -> void:
	if not _conversation and _runner == null:
		return
	_conversation = false
	_pinned = false
	_runner = null
	_source = null
	_closed_physics_frame = Engine.get_physics_frames()
	_left = 0.0
	NarrativeState.set_dialogue_open(false)
	visible = false
	if _label != null:
		_label.text = ""


func show_line(speaker: String, text: String) -> void:
	if _conversation:
		return
	super.show_line(speaker, text)


func _reveal_step() -> void:
	if _runner == null:
		return
	var full := _runner.body()
	if _reveal >= full.length():
		return
	_reveal = mini(_reveal + REVEAL_PER_TICK, full.length())
	_refresh_text()


func _poll_input() -> void:
	if not _conversation or _runner == null:
		return
	var advance := Input.is_action_pressed("advance_dialogue") or Input.is_action_pressed("interact")
	if advance and not _advance_was:
		_on_advance()
	_advance_was = advance
	if not _conversation or _runner == null:
		return
	var up := Input.is_action_pressed("dialogue_up")
	var down := Input.is_action_pressed("dialogue_down")
	if not is_revealing() and _runner.choice_count() > 0:
		if up and not _up_was:
			_selected = maxi(_selected - 1, 0)
			_refresh_text()
		if down and not _down_was:
			_selected = mini(_selected + 1, _runner.choice_count() - 1)
			_refresh_text()
	_up_was = up
	_down_was = down


func _on_advance() -> void:
	if _runner == null:
		return
	if _reveal < _runner.body().length():
		_reveal = _runner.body().length()
		_refresh_text()
		return
	if _runner.choice_count() > 0:
		_runner.choose(_selected)
		_after_move()
		return
	_runner.advance()
	_after_move()


func _after_move() -> void:
	if _runner == null or not _runner.is_open():
		close_conversation()
		return
	_reveal = 0
	_selected = 0
	_refresh_text()


func _refresh_text() -> void:
	if _label == null or _runner == null:
		return
	var full := _runner.body()
	var shown := full.substr(0, mini(_reveal, full.length()))
	if _runner.is_thought():
		shown = "[i]%s[/i]" % shown
	var text := shown
	if not _runner.speaker().is_empty():
		text = "[color=#%s]%s[/color]\n%s" % [NAME_COLOR, _runner.speaker(), shown]
	if _reveal >= full.length() and _runner.choice_count() > 0:
		for index in _runner.choice_count():
			var picked := index == _selected
			var color := CHOICE_ON if picked else CHOICE_OFF
			var mark := "> " if picked else "  "
			text += "\n[color=#%s]%s%s[/color]" % [color, mark, _runner.choice_text(index)]
	_label.text = text


func _watch_distance() -> void:
	if not _conversation or _pinned:
		return
	if Engine.get_physics_frames() == _opened_physics_frame:
		return
	if _source == null or not is_instance_valid(_source):
		close_conversation()
		return
	var tree := get_tree()
	if tree == null:
		return
	var player := tree.get_first_node_in_group("player") as Node2D
	if player == null:
		return
	if player.global_position.distance_to(_source.global_position) > LEAVE_DISTANCE:
		close_conversation()


func _sync_held_keys() -> void:
	_advance_was = Input.is_action_pressed("advance_dialogue") or Input.is_action_pressed("interact")
	_up_was = Input.is_action_pressed("dialogue_up")
	_down_was = Input.is_action_pressed("dialogue_down")
