class_name ItemPickup
extends Interactable
## One-time starter crate. The catalog names the items and the narrative flag.

@export var starter_id: String = "tools"
@export var speaker_name: String = "Crate"
@export_multiline var take_line: String = ""
@export_multiline var empty_line: String = "Nothing left in here."
@export var sheet: Texture2D
@export var frame_size: Vector2i = Vector2i(32, 32)


func _ready() -> void:
	_apply_sprite()
	_refresh_prompt()


func interact(actor: Node) -> void:
	super.interact(actor)
	var pack := _pack()
	var line := empty_line
	if pack != null and pack.has_method("starter_taken") and not bool(pack.call("starter_taken", starter_id)):
		if pack.has_method("grant_starter") and bool(pack.call("grant_starter", starter_id)):
			line = take_line
		else:
			line = "The pack is too full for what's in here."
	_refresh_prompt()
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.call("show_line", speaker_name, line)


func _refresh_prompt() -> void:
	var pack := _pack()
	if pack != null and pack.has_method("starter_taken") and bool(pack.call("starter_taken", starter_id)):
		prompt_text = "Look"
	else:
		prompt_text = "Take"


func _apply_sprite() -> void:
	var sprite := get_node_or_null("Sprite") as Sprite2D
	if sprite == null or sheet == null:
		return
	sprite.texture = sheet
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.offset = Vector2(0, -sheet.get_height() * 0.5)
	if sheet.get_width() > frame_size.x:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(0, 0, frame_size.x, frame_size.y)
		sprite.texture = atlas


func _pack() -> Node:
	return get_node_or_null("/root/Inventory")
