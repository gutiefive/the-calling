extends SceneTree
## Writes 32×32 worksite stage frames.
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_repairs.gd

const Frames := preload("res://scripts/art/repair_frames.gd")

const IDS: PackedStringArray = [
	"fence_damaged",
	"fence_cleared",
	"fence_new_wood",
	"fence_finished",
	"weeds_patch",
	"weeds_cleared",
	"litter_pile",
	"litter_gone",
	"bed_overgrown",
	"bed_trimmed",
	"bed_restored",
	"fx_repair",
]


func _init() -> void:
	quit(0 if _write_repairs() else 1)


func _write_repairs() -> bool:
	var dir := DirAccess.open("res://assets")
	if dir == null:
		print("AUTHOR FAIL repairs dir")
		return false
	if not dir.dir_exists("repairs"):
		var err := dir.make_dir("repairs")
		if err != OK:
			print("AUTHOR FAIL repairs mkdir ", err)
			return false
	var ok := true
	for frame_id in IDS:
		var image: Image = Frames.build(frame_id)
		if image == null or image.get_width() < 8 or image.get_height() < 8:
			print("AUTHOR FAIL ", frame_id, " bad size")
			ok = false
			continue
		var rel := "res://assets/repairs/%s.png" % frame_id
		var abs_path := ProjectSettings.globalize_path(rel)
		var err := image.save_png(abs_path)
		if err != OK:
			print("AUTHOR FAIL ", rel, " save ", err)
			ok = false
			continue
		print("WROTE ", rel, " ", image.get_width(), "x", image.get_height())
	return ok
