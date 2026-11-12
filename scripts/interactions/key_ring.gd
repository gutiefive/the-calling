class_name KeyRing
extends SpeechProp
## A pickup whose lines and quest effect come from a JSON file.

@export_file("*.json") var data_path: String = "res://data/interactions/spare_key_ring.json"

var _quest_id: String = ""
var _flag: String = ""
var _next_step: String = ""
var _accept: Array[String] = []
var _lines: Dictionary = {}


func _ready() -> void:
	super._ready()
	_load_data()
	if _already_held():
		_retire()


func interact(_actor: Node) -> void:
	interacted.emit()
	if _lines.is_empty():
		return
	if _already_held():
		_say(str(_lines.get("held", "")))
		_retire()
		return
	if _accept.has(NarrativeState.quest_step(_quest_id)):
		NarrativeState.set_flag(_flag, true)
		NarrativeState.set_step(_quest_id, _next_step)
		_say(str(_lines.get("take", "")))
		_retire()
		return
	_say(str(_lines.get("locked", "")))


func _load_data() -> void:
	var parsed: Variant = JsonFile.read(data_path)
	if not parsed is Dictionary:
		push_error("Key ring data %s is not an object" % data_path)
		return
	var data: Dictionary = parsed
	_quest_id = str(data.get("quest_id", ""))
	_flag = str(data.get("flag", ""))
	_next_step = str(data.get("next_step", ""))
	_lines = {
		"locked": str(data.get("locked", "")),
		"take": str(data.get("take", "")),
		"held": str(data.get("held", "")),
	}
	var steps: Variant = data.get("accept_steps", [])
	if steps is Array:
		for step in steps as Array:
			_accept.append(str(step))


func _already_held() -> bool:
	return not _flag.is_empty() and NarrativeState.flag_is_true(_flag)


func _say(text: String) -> void:
	if text.is_empty():
		return
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line("", text)


func _retire() -> void:
	enabled = false
	var sprite := get_node_or_null("Sprite") as CanvasItem
	if sprite != null:
		sprite.visible = false
