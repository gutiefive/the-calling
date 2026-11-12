class_name GardenPlot
extends Interactable
## The Maple Lane plot. Clearing it is local. Seed wants another pair of hands.

var shown_stage: int = 0


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group("day_world")


func _ready() -> void:
	apply_clock()


func apply_clock() -> void:
	shown_stage = NarrativeState.garden_stage()
	var sprite := get_node_or_null("Sprite") as Sprite2D
	var texture := PlaceholderArt.garden_plot(shown_stage)
	if sprite != null and texture != null:
		sprite.texture = texture
		sprite.centered = true
		sprite.offset = Vector2(0, -texture.get_height() * 0.5)


func interact(actor: Node) -> void:
	super.interact(actor)
	var line := "The plot is a mat of weeds. You could pull them."
	if NarrativeState.flag_is_true("garden_planted"):
		line = "It's in the ground. A few mornings will show whether it takes."
	elif NarrativeState.flag_is_true("garden_cleared"):
		line = "The soil is clear. It wants seed, and another pair of hands."
	else:
		NarrativeState.set_flag("garden_cleared", true)
		line = "You pull the weeds back. It still needs seed."
		apply_clock()
	var tree := get_tree()
	if tree == null:
		return
	var banner := tree.get_first_node_in_group("speech_banner")
	if banner != null and banner.has_method("show_line"):
		banner.show_line("Garden", line)
