extends SceneTree
## Writes potluck table, dish, flower, light, and chair frames.
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_potluck.gd

const Frames := preload("res://scripts/art/potluck_frames.gd")

const IDS: PackedStringArray = [
	"table_modest",
	"table_full",
	"dishes_simple",
	"dishes_varied",
	"centerpiece",
	"string_lights",
	"banner",
	"chair",
	"chairs_extra",
]


func _init() -> void:
	quit(0 if _write() else 1)


func _write() -> bool:
	var dir := DirAccess.open("res://assets")
	if dir == null:
		print("AUTHOR FAIL potluck dir")
		return false
	if not dir.dir_exists("potluck"):
		var err := dir.make_dir("potluck")
		if err != OK:
			print("AUTHOR FAIL potluck mkdir ", err)
			return false
	var ok := true
	for frame_id in IDS:
		var image: Image = Frames.build(frame_id)
		if image == null or image.get_width() < 8 or image.get_height() < 8:
			print("AUTHOR FAIL ", frame_id, " bad size")
			ok = false
			continue
		var rel := "res://assets/potluck/%s.png" % frame_id
		var abs_path := ProjectSettings.globalize_path(rel)
		var err := image.save_png(abs_path)
		if err != OK:
			print("AUTHOR FAIL ", rel, " save ", err)
			ok = false
			continue
		print("WROTE ", rel, " ", image.get_width(), "x", image.get_height())
	return ok
