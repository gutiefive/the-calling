class_name EnvironmentArt
extends RefCounted
## Loads authored environment PNGs written by tools/art/author_environment.gd.

const CHURCH := "res://assets/environments/church_front.png"
const TREE := "res://assets/environments/tree.png"
const BENCH := "res://assets/environments/bench.png"
const LAMP := "res://assets/environments/lamp_post.png"
const NOTICE := "res://assets/environments/notice_board.png"
const MAILBOX := "res://assets/environments/mailbox.png"
const HALL_WORN := "res://assets/environments/fellowship_hall_worn.png"
const HALL_REPAIRED := "res://assets/environments/fellowship_hall_repaired.png"


static func church_front() -> Texture2D:
	return _load(CHURCH)


static func tree() -> Texture2D:
	return _load(TREE)


static func bench() -> Texture2D:
	return _load(BENCH)


static func lamp_post() -> Texture2D:
	return _load(LAMP)


static func notice_board() -> Texture2D:
	return _load(NOTICE)


static func mailbox() -> Texture2D:
	return _load(MAILBOX)


static func fellowship_hall(repaired: bool) -> Texture2D:
	return _load(HALL_REPAIRED if repaired else HALL_WORN)


static func _load(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
