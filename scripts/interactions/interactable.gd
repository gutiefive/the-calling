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


func interact(_actor: Node) -> void:
	interacted.emit()
