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
const CREDIT := "res://assets/environments/credit_union.png"
const PHARMACY := "res://assets/environments/pharmacy.png"
const THRIFT := "res://assets/environments/thrift_shop.png"
const FEED := "res://assets/environments/feed_store.png"
const TOWN_HALL := "res://assets/environments/town_hall.png"
const BOARDED := "res://assets/environments/boarded_shop.png"
const PAPER_BOX := "res://assets/environments/newspaper_box.png"
const BIKE_RACK := "res://assets/environments/bike_rack.png"
const FLOWER_BOX := "res://assets/environments/flower_box.png"
const SWING := "res://assets/environments/swing_set.png"
const KIDS_BIKE := "res://assets/environments/kids_bike.png"
const HOSE := "res://assets/environments/garden_hose.png"
const DOG_HOUSE := "res://assets/environments/dog_house.png"
const ROCKER := "res://assets/environments/rocking_chair.png"
const PICKET := "res://assets/environments/picket_fence.png"


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


static func credit_union() -> Texture2D:
	return _load(CREDIT)


static func pharmacy() -> Texture2D:
	return _load(PHARMACY)


static func thrift() -> Texture2D:
	return _load(THRIFT)


static func feed_store() -> Texture2D:
	return _load(FEED)


static func town_hall() -> Texture2D:
	return _load(TOWN_HALL)


static func boarded_shop() -> Texture2D:
	return _load(BOARDED)


static func newspaper_box() -> Texture2D:
	return _load(PAPER_BOX)


static func bike_rack() -> Texture2D:
	return _load(BIKE_RACK)


static func flower_box() -> Texture2D:
	return _load(FLOWER_BOX)


static func swing_set() -> Texture2D:
	return _load(SWING)


static func kids_bike() -> Texture2D:
	return _load(KIDS_BIKE)


static func garden_hose() -> Texture2D:
	return _load(HOSE)


static func dog_house() -> Texture2D:
	return _load(DOG_HOUSE)


static func rocking_chair() -> Texture2D:
	return _load(ROCKER)


static func picket_fence() -> Texture2D:
	return _load(PICKET)


static func house(variant: int, door_east: bool) -> Texture2D:
	var side := "east" if door_east else "west"
	var clamped := clampi(variant, 0, 5)
	return _load("res://assets/environments/house_%d_%s.png" % [clamped, side])


static func hanging_sign(sign_id: String) -> Texture2D:
	if sign_id.is_empty():
		return null
	return _load("res://assets/environments/sign_%s.png" % sign_id)


static func _load(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
