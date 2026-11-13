class_name CharacterSheets
extends RefCounted
## Loads authored 32x48 character sheets and builds SpriteFrames.
## One cell is 32x48. Rows are down, up, left, right. Columns are idle, idle,
## then four walk frames.

const CELL := Vector2i(32, 48)
const WALK_FPS := 8.0
const IDLE_FPS := 2.0
const FACINGS: PackedStringArray = ["down", "up", "left", "right"]
const NAMED: PackedStringArray = [
	"player", "margaret", "harold", "thomas", "frank", "sarah", "ostrow", "dale", "ruth"
]


static func is_named(who: String) -> bool:
	return who in NAMED


static func path_for(who: String) -> String:
	return CharacterFrames.output_path(who)


static func texture(who: String) -> Texture2D:
	var path := path_for(who)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


static func sprite_frames(who: String) -> SpriteFrames:
	var tex := texture(who)
	if tex == null:
		return null
	var frames := SpriteFrames.new()
	for row in FACINGS.size():
		var idle_name := FACINGS[row] + "_idle"
		var walk_name := FACINGS[row] + "_walk"
		frames.add_animation(idle_name)
		frames.add_animation(walk_name)
		frames.set_animation_loop(idle_name, true)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(idle_name, IDLE_FPS)
		frames.set_animation_speed(walk_name, WALK_FPS)
		frames.add_frame(idle_name, _atlas(tex, 0, row))
		frames.add_frame(idle_name, _atlas(tex, 1, row))
		for col in range(2, 6):
			frames.add_frame(walk_name, _atlas(tex, col, row))
	if frames.has_animation("default"):
		frames.remove_animation("default")
	return frames


static func _atlas(tex: Texture2D, column: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(column * CELL.x, row * CELL.y, CELL.x, CELL.y)
	return atlas
