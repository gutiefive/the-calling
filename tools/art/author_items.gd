extends SceneTree
## Writes 16×16 item icons. Also called from author_environment.gd.
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_items.gd

const Items := preload("res://scripts/art/item_frames.gd")

const IDS: PackedStringArray = [
	"watering_can",
	"hoe",
	"hand_tools",
	"lettuce_seeds",
	"carrot_seeds",
	"tomato_seeds",
	"flower_seeds",
	"lettuce",
	"carrots",
	"tomatoes",
	"flowers",
	"wood",
	"nails",
	"scrap",
]


func _init() -> void:
	quit(0 if _write_items() else 1)


func _write_items() -> bool:
	var dir := DirAccess.open("res://assets")
	if dir == null:
		print("AUTHOR FAIL items dir")
		return false
	if not dir.dir_exists("items"):
		var err := dir.make_dir("items")
		if err != OK:
			print("AUTHOR FAIL items mkdir ", err)
			return false
	var ok := true
	for item_id in IDS:
		var image: Image = Items.build(item_id)
		if image == null or image.get_width() != 16 or image.get_height() != 16:
			print("AUTHOR FAIL ", item_id, " bad size")
			ok = false
			continue
		var rel := "res://assets/items/%s.png" % item_id
		var abs_path := ProjectSettings.globalize_path(rel)
		var err := image.save_png(abs_path)
		if err != OK:
			print("AUTHOR FAIL ", rel, " save ", err)
			ok = false
			continue
		print("WROTE ", rel, " 16x16")
	return ok
