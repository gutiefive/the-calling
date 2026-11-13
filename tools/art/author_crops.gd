extends SceneTree
## Writes 32×32 garden soil, crop, and effect frames.
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_crops.gd

const Frames := preload("res://scripts/art/crop_frames.gd")

const IDS: PackedStringArray = [
	"soil_untouched",
	"soil_tilled",
	"soil_tilled_wet",
	"soil_seeded",
	"soil_seeded_wet",
	"soil_harvested",
	"lettuce_sprout",
	"lettuce_growing",
	"lettuce_mature",
	"carrots_sprout",
	"carrots_growing",
	"carrots_mature",
	"tomatoes_sprout",
	"tomatoes_growing",
	"tomatoes_mature",
	"flowers_sprout",
	"flowers_growing",
	"flowers_mature",
	"fx_hoe",
	"fx_water",
	"fx_plant",
	"fx_harvest",
	"fx_target",
	"fence_patch",
]


func _init() -> void:
	quit(0 if _write_crops() else 1)


func _write_crops() -> bool:
	var dir := DirAccess.open("res://assets")
	if dir == null:
		print("AUTHOR FAIL garden dir")
		return false
	if not dir.dir_exists("garden"):
		var err := dir.make_dir("garden")
		if err != OK:
			print("AUTHOR FAIL garden mkdir ", err)
			return false
	var ok := true
	for frame_id in IDS:
		var image: Image = Frames.build(frame_id)
		if image == null or image.get_width() != 32 or image.get_height() != 32:
			print("AUTHOR FAIL ", frame_id, " bad size")
			ok = false
			continue
		var rel := "res://assets/garden/%s.png" % frame_id
		var abs_path := ProjectSettings.globalize_path(rel)
		var err := image.save_png(abs_path)
		if err != OK:
			print("AUTHOR FAIL ", rel, " save ", err)
			ok = false
			continue
		print("WROTE ", rel, " 32x32")
	return ok
