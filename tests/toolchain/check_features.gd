extends SceneTree
## Toolchain smoke test (environment only, not gameplay).
## Run: godot --headless --path . --script res://tests/toolchain/check_features.gd
## Verifies the engine build exposes the 2D classes The Calling depends on,
## and that the project default texture filter is Nearest.

const REQUIRED_CLASSES: Array[String] = [
	"GDScript", "Node2D", "Sprite2D", "AnimatedSprite2D", "CharacterBody2D", "Camera2D",
	"TileMapLayer", "TileSet", "PointLight2D", "DirectionalLight2D", "CanvasModulate",
	"LightOccluder2D", "OccluderPolygon2D", "NavigationAgent2D", "NavigationRegion2D",
]

func _init() -> void:
	var all_ok: bool = true
	for cls: String in REQUIRED_CLASSES:
		var ok: bool = ClassDB.class_exists(cls)
		print("FEATURE %-20s %s" % [cls, "OK" if ok else "MISSING"])
		all_ok = all_ok and ok
	var filter: int = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1)
	print("SETTING default_texture_filter = %d (0 = Nearest)" % filter)
	all_ok = all_ok and filter == 0
	print("ENGINE ", Engine.get_version_info().string)
	print("FEATURES_ALL_OK" if all_ok else "FEATURES_FAIL")
	quit(0 if all_ok else 1)
