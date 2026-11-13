extends SceneTree
## Writes the six authored character sheets under assets/characters/.
## Run from the repo root:
## C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/art/author_sprites.gd

const Frames := preload("res://scripts/art/character_frames.gd")


func _init() -> void:
	var failed := false
	for who in Frames.NAMES:
		var image: Image = Frames.build_sheet(who)
		if image == null or image.get_width() != 192 or image.get_height() != 192:
			print("AUTHOR FAIL ", who, " bad size")
			failed = true
			continue
		var rel: String = Frames.output_path(who)
		var abs_path := ProjectSettings.globalize_path(rel)
		var err := image.save_png(abs_path)
		if err != OK:
			print("AUTHOR FAIL ", rel, " save ", err)
			failed = true
			continue
		print("WROTE ", rel, " ", image.get_width(), "x", image.get_height())
	quit(1 if failed else 0)
