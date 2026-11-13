class_name SpeechProp
extends Interactable
## One stationary line for a prop. Conversations are DialogueNpc plus JSON.

@export var speaker_name: String = ""
@export_multiline var line: String = ""
@export var art_id: String = ""
@export var sheet: Texture2D
@export var frame_size: Vector2i = Vector2i(32, 48)
@export var frame_count: int = 2
@export var fps: float = 1.5

var _uses_character_sheet: bool = false
var _npc_facing: StringName = &"down"
var _last_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	if CharacterSheets.is_named(art_id):
		_setup_character()
		return
	if sheet == null and not art_id.is_empty():
		sheet = PlaceholderArt.by_id(art_id)
	var sprite := get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite == null or sheet == null:
		push_error("SpeechProp %s is missing a sprite sheet" % name)
		return
	var frames := SpriteFrames.new()
	var anim := &"idle"
	frames.add_animation(anim)
	frames.set_animation_loop(anim, true)
	frames.set_animation_speed(anim, fps)
	var count := maxi(frame_count, 1)
	for i in count:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(anim, atlas)
	if frames.has_animation("default"):
		frames.remove_animation("default")
	sprite.sprite_frames = frames
	sprite.centered = true
	sprite.offset = Vector2(0.0, -float(frame_size.y) * 0.5)
	sprite.play("idle")


func _physics_process(_delta: float) -> void:
	if not _uses_character_sheet:
		return
	var walking := _is_walking()
	var moved := position - _last_pos
	if walking and moved.length_squared() > 0.01:
		_npc_facing = _facing_from(moved)
		_play_character(true)
	else:
		_play_character(false)
	_last_pos = position


func _setup_character() -> void:
	var sprite := get_node_or_null("Sprite") as AnimatedSprite2D
	var frames := CharacterSheets.sprite_frames(art_id)
	if sprite == null or frames == null:
		push_error("SpeechProp %s is missing a character sheet" % name)
		return
	_uses_character_sheet = true
	_last_pos = position
	sprite.sprite_frames = frames
	sprite.centered = true
	sprite.offset = Vector2(0.0, -float(frame_size.y) * 0.5)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_play_character(false)


func _is_walking() -> bool:
	var agent := get_node_or_null("ScheduleAgent") as ScheduleAgent
	if agent != null and agent.is_walking():
		return true
	return bool(get_meta("schedule_walking", false))


func _facing_from(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	return &"down" if direction.y > 0.0 else &"up"


func _play_character(moving: bool) -> void:
	var sprite := get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return
	var anim := String(_npc_facing) + ("_walk" if moving else "_idle")
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)


func interact(actor: Node) -> void:
	super.interact(actor)
	if line.is_empty():
		return
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line(speaker_name, line)
