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
const HARDWARE := "res://assets/environments/hardware_store.png"
const AUTO_SHOP := "res://assets/environments/auto_shop.png"
const COTTAGE := "res://assets/environments/cottage.png"
const DINER := "res://assets/environments/brights_diner.png"
const POST_OFFICE := "res://assets/environments/post_office.png"
const BARBER := "res://assets/environments/barber_shop.png"
const VACANT := "res://assets/environments/vacant_shop.png"
const CAR_A := "res://assets/environments/parked_car_a.png"
const CAR_B := "res://assets/environments/parked_car_b.png"
const TRASH := "res://assets/environments/trash_can.png"
const HYDRANT := "res://assets/environments/fire_hydrant.png"


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


static func hardware_store() -> Texture2D:
	return _load(HARDWARE)


static func auto_shop() -> Texture2D:
	return _load(AUTO_SHOP)


static func cottage() -> Texture2D:
	return _load(COTTAGE)


static func diner() -> Texture2D:
	return _load(DINER)


static func post_office() -> Texture2D:
	return _load(POST_OFFICE)


static func barber() -> Texture2D:
	return _load(BARBER)


static func vacant_shop() -> Texture2D:
	return _load(VACANT)


static func parked_car(variant: int) -> Texture2D:
	return _load(CAR_B if variant == 1 else CAR_A)


static func trash_can() -> Texture2D:
	return _load(TRASH)


static func hydrant() -> Texture2D:
	return _load(HYDRANT)


static func _load(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
