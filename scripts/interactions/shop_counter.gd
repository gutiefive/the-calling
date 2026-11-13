class_name ShopCounter
extends Interactable
## Opens the hardware shop UI. Thomas still talks from his own node.

@export var speaker_name: String = "Shelves"
@export var sheet: Texture2D
@export var frame_size: Vector2i = Vector2i(64, 48)


func _ready() -> void:
	prompt_text = "Browse"
	_apply_sprite()


func interact(actor: Node) -> void:
	super.interact(actor)
	var tree := get_tree()
	if tree == null:
		return
	var panel := tree.get_first_node_in_group("shop_panel")
	if panel == null:
		return
	if panel.has_method("is_open") and bool(panel.call("is_open")):
		return
	if panel.has_method("open"):
		panel.call("open")


func _apply_sprite() -> void:
	var sprite := get_node_or_null("Sprite") as Sprite2D
	if sprite == null or sheet == null:
		return
	sprite.texture = sheet
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.offset = Vector2(0, -sheet.get_height() * 0.5)
