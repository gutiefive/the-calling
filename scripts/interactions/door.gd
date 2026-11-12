class_name Door
extends Interactable
## Sends the player to another room and a named spawn marker.
## Interaction is explicit (E), so loading the destination cannot immediately bounce back.

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn: StringName = &"default"


func interact(actor: Node) -> void:
	super.interact(actor)
	SceneRouter.travel(get_tree(), destination_scene, destination_spawn)
