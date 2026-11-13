class_name AmbientTownsfolk
extends Interactable
## Unnamed neighbors who wander Oak Street. Evening keeps one out. Night sends them in.

const SPEED := 28.0

@export var person_id: String = ""
@export var crowd_index: int = 0
@export var art_variant: int = 0
@export var appear_phases: PackedStringArray = PackedStringArray()
@export var leads_dog: bool = false

var _points: Array[Vector2] = []
var _cursor: int = 0


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("ambient_townsfolk")


func _ready() -> void:
	_build_sprite()
	apply_clock()


func set_route(points: Array[Vector2]) -> void:
	_points = points.duplicate()
	_cursor = 0


func apply_clock() -> void:
	var events := get_node_or_null("/root/EventState")
	if events != null and events.has_method("is_present") and bool(events.call("is_present", person_id)):
		visible = false
		enabled = false
		return
	var clock := get_node_or_null("/root/DayClock")
	var phase := "Day"
	if clock != null:
		phase = TimeOfDay.phase_name()
	if appear_phases.size() > 0:
		var listed := false
		for item in appear_phases:
			if str(item) == phase:
				listed = true
				break
		visible = listed
		enabled = listed
		return
	var keep := 3
	if phase == "Evening":
		keep = 1
	elif phase == "Night":
		keep = 0
	var shift := 0
	var path := get_node_or_null("/root/PastorPath")
	if path != null and path.has_method("crowd_shift"):
		shift = int(path.call("crowd_shift"))
	var rotated := posmod(crowd_index + shift, 3)
	var out := rotated < keep
	if crowd_index >= 3:
		out = phase == "Day"
	visible = out
	enabled = out


func bark_text() -> String:
	if person_id == "ruth" and NarrativeState.flag_is_true("garden_planted"):
		return "The garden's actually in the ground. I'll water if I'm walking by."
	if person_id == "dale" and NarrativeState.flag_is_true("grounds_tidy"):
		return "I walked past the church. The front looks looked-after."
	var clock := get_node_or_null("/root/DayClock")
	var day := "Thursday"
	if clock != null:
		day = str(clock.call("weekday_name"))
	return AmbientBarks.line(person_id, day, TimeOfDay.phase_name())


func interact(_actor: Node) -> void:
	super.interact(_actor)
	if person_id == "ruth" and _open_named_talk("ruth"):
		return
	if person_id == "dale" and _open_named_talk("dale"):
		return
	var text := bark_text()
	if text.is_empty():
		return
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line("Neighbor", text)


func _open_named_talk(who: String) -> bool:
	if not _should_open_named(who):
		return false
	var tree := get_tree()
	if tree == null:
		return false
	var box := tree.get_first_node_in_group("dialogue_box")
	if box == null or not box.has_method("open_conversation"):
		return false
	if box.has_method("is_conversation_open") and bool(box.call("is_conversation_open")):
		return true
	if box.has_method("closed_this_frame") and bool(box.call("closed_this_frame")):
		return true
	return bool(box.call("open_conversation", who, self))


func _should_open_named(who: String) -> bool:
	var events := get_node_or_null("/root/EventState")
	if events != null:
		if events.has_method("can_invite") and bool(events.call("can_invite", who)):
			return true
		if events.has_method("is_invited") and bool(events.call("is_invited", who)):
			return true
	if who != "ruth":
		return false
	var asks := get_node_or_null("/root/RequestState")
	if asks == null:
		return false
	if asks.has_method("is_available") and bool(asks.call("is_available", "garden_needs_hands")):
		return true
	if asks.has_method("is_active") and bool(asks.call("is_active", "garden_needs_hands")):
		return true
	return false


func _physics_process(delta: float) -> void:
	if not visible or _points.size() < 2:
		return
	var dest: Vector2 = _points[_cursor]
	var offset := dest - position
	var step := SPEED * delta
	if offset.length() <= step:
		position = dest
		_cursor = (_cursor + 1) % _points.size()
	else:
		position += offset.normalized() * step


func _build_sprite() -> void:
	var existing := get_node_or_null("Sprite") as Sprite2D
	var sprite := existing
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		add_child(sprite)
	var sheet := PlaceholderArt.townsfolk(art_variant)
	if sheet == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0, 0, 32, 48)
	sprite.texture = atlas
	sprite.centered = true
	sprite.offset = Vector2(0, -24)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var dog := get_node_or_null("Dog") as Sprite2D
	if leads_dog:
		if dog == null:
			dog = Sprite2D.new()
			dog.name = "Dog"
			add_child(dog)
		dog.texture = PlaceholderArt.dog()
		dog.centered = true
		dog.offset = Vector2(0, -8)
		dog.position = Vector2(14, 6)
		dog.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		dog.visible = true
	elif dog != null:
		dog.visible = false
