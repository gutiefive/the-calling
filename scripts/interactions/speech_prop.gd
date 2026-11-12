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


func _ready() -> void:
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
