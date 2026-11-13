class_name ItemCatalog
extends RefCounted
## Data-driven item definitions. Inventory, the shop, and the UI read this; they do not duplicate lists.

const DATA_PATH := "res://data/items/catalog.json"
const CATEGORY_TOOLS := "Tools"
const CATEGORY_SEEDS := "Seeds"
const CATEGORY_CROPS := "Crops"
const CATEGORY_MATERIALS := "Materials"
const CATEGORY_QUEST := "Quest"

const EXPECTED_IDS: PackedStringArray = [
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

static var _loaded: bool = false
static var _capacity: int = 16
static var _starting_cash: int = 20
static var _items: Dictionary = {}
static var _order: PackedStringArray = PackedStringArray()
static var _shop_title: String = "Oak Street Hardware"
static var _shop_stock: Array[Dictionary] = []
static var _starters: Dictionary = {}


static func ensure() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed: Variant = JsonFile.read(DATA_PATH)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	_capacity = maxi(1, int(data.get("capacity", 16)))
	_starting_cash = maxi(0, int(data.get("starting_cash", 20)))
	_items.clear()
	_order = PackedStringArray()
	var rows_v: Variant = data.get("items", [])
	if rows_v is Array:
		for row_v in rows_v as Array:
			if not row_v is Dictionary:
				continue
			var row: Dictionary = (row_v as Dictionary).duplicate(true)
			var item_id := str(row.get("id", ""))
			if item_id.is_empty():
				continue
			_items[item_id] = row
			_order.append(item_id)
	_shop_stock.clear()
	var shop_v: Variant = data.get("shop", {})
	if shop_v is Dictionary:
		var shop: Dictionary = shop_v
		_shop_title = str(shop.get("title", "Oak Street Hardware"))
		var stock_v: Variant = shop.get("stock", [])
		if stock_v is Array:
			for stock_row in stock_v as Array:
				if stock_row is Dictionary:
					_shop_stock.append((stock_row as Dictionary).duplicate(true))
	var starters_v: Variant = data.get("starters", {})
	if starters_v is Dictionary:
		_starters = (starters_v as Dictionary).duplicate(true)


static func capacity() -> int:
	ensure()
	return _capacity


static func starting_cash() -> int:
	ensure()
	return _starting_cash


static func has_item(item_id: String) -> bool:
	ensure()
	return _items.has(item_id)


static func item(item_id: String) -> Dictionary:
	ensure()
	if not _items.has(item_id):
		return {}
	var row_v: Variant = _items[item_id]
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


static func display_name(item_id: String) -> String:
	var row := item(item_id)
	if row.is_empty():
		return item_id
	return str(row.get("name", item_id))


static func description(item_id: String) -> String:
	return str(item(item_id).get("description", ""))


static func category(item_id: String) -> String:
	return str(item(item_id).get("category", ""))


static func max_stack(item_id: String) -> int:
	return maxi(1, int(item(item_id).get("max_stack", 1)))


static func icon_id(item_id: String) -> String:
	var icon := str(item(item_id).get("icon", item_id))
	if icon.is_empty():
		return item_id
	return icon


static func item_is_tool(item_id: String) -> bool:
	return category(item_id) == CATEGORY_TOOLS


static func item_is_seed(item_id: String) -> bool:
	return category(item_id) == CATEGORY_SEEDS


static func is_consumable(item_id: String) -> bool:
	if not has_item(item_id):
		return false
	return not item_is_tool(item_id)


static func ids() -> PackedStringArray:
	ensure()
	return _order.duplicate()


static func shop_title() -> String:
	ensure()
	return _shop_title


static func shop_stock() -> Array[Dictionary]:
	ensure()
	var rows: Array[Dictionary] = []
	for row in _shop_stock:
		rows.append(row.duplicate(true))
	return rows


static func shop_price(item_id: String) -> int:
	ensure()
	for row in _shop_stock:
		if str(row.get("id", "")) == item_id:
			return maxi(0, int(row.get("price", 0)))
	return 0


static func is_sold(item_id: String) -> bool:
	return shop_price(item_id) > 0


static func starter(kind: String) -> Dictionary:
	ensure()
	var row_v: Variant = _starters.get(kind, {})
	if row_v is Dictionary:
		return (row_v as Dictionary).duplicate(true)
	return {}


static func starter_flag(kind: String) -> String:
	return str(starter(kind).get("flag", ""))


static func starter_items(kind: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var items_v: Variant = starter(kind).get("items", [])
	if items_v is Array:
		for row_v in items_v as Array:
			if row_v is Dictionary:
				rows.append((row_v as Dictionary).duplicate(true))
	return rows
