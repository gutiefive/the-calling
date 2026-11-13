class_name Interactable
extends Node2D
## Something the player can use with E while standing close.
## Doors and speech props share the prompt and the single-target rule.

signal interacted

@export var prompt_text: String = "Interact"
@export var radius: float = 36.0
@export var enabled: bool = true
@export var blocks_movement: bool = false
@export var block_size: Vector2 = Vector2(14, 10)
@export var block_offset: Vector2 = Vector2(0, -4)


func _enter_tree() -> void:
	add_to_group("interactable")
	if blocks_movement:
		add_to_group("solid_prop")


func prompt_label() -> String:
	var who := ""
	var named: Variant = get("speaker_name")
	if named != null:
		who = str(named)
	if who.is_empty() or prompt_text.findn(who) != -1:
		return prompt_text
	return "%s — %s" % [who, prompt_text]


func interact(_actor: Node) -> void:
	interacted.emit()
