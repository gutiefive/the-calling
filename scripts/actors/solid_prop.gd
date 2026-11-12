class_name SolidProp
extends Sprite2D
## A y-sorted prop with a small foot collision. WorldRoom reads these at startup.

@export var block_size: Vector2 = Vector2(16, 10)
@export var block_offset: Vector2 = Vector2(0, -4)


func _enter_tree() -> void:
	add_to_group("solid_prop")
