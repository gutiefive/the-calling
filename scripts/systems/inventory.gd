extends Node
## Personal pack and wallet. ChurchFunds is never read or written here.

const Catalog := preload("res://scripts/systems/item_catalog.gd")

signal item_added(item_id: String, quantity: int)
signal item_consumed(item_id: String, quantity: int)
signal inventory_changed
signal wallet_changed
signal equipped_changed

var _slots: Array[Dictionary] = []
var _cash: int = 0
var _equipped: String = ""
var _seed: String = ""


func _ready() -> void:
	reset()


func reset() -> void:
	_slots.clear()
	_cash = Catalog.starting_cash()
	_equipped = ""
	_seed = ""
	inventory_changed.emit()
	wallet_changed.emit()
	equipped_changed.emit()


func capacity() -> int:
	return Catalog.capacity()


func occupied_slots() -> int:
	return _slots.size()


func cash() -> int:
	return _cash


func set_cash(amount: int) -> void:
	var next := maxi(0, amount)
	if next == _cash:
		return
	_cash = next
	wallet_changed.emit()


func gain_cash(amount: int) -> void:
	if amount <= 0:
		return
	set_cash(_cash + amount)


func can_afford(amount: int) -> bool:
	return amount >= 0 and _cash >= amount


func spend_cash(amount: int) -> bool:
	if amount < 0 or _cash < amount:
		return false
	if amount == 0:
		return true
	_cash -= amount
	wallet_changed.emit()
	return true


func quantity(item_id: String) -> int:
	var total := 0
	for slot in _slots:
		if str(slot.get("id", "")) == item_id:
			total += int(slot.get("qty", 0))
	return total


func has(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	return quantity(item_id) >= amount


func can_add(item_id: String, amount: int = 1) -> bool:
	if not Catalog.has_item(item_id) or amount <= 0:
		return false
	var remaining := amount
	var max_stack := Catalog.max_stack(item_id)
	for slot in _slots:
		if str(slot.get("id", "")) != item_id:
			continue
		remaining -= maxi(0, max_stack - int(slot.get("qty", 0)))
		if remaining <= 0:
			return true
	var free := capacity() - _slots.size()
	if remaining <= 0:
		return true
	var stacks_needed := int(ceil(float(remaining) / float(max_stack)))
	return stacks_needed <= free


func add(item_id: String, amount: int = 1) -> int:
	if not Catalog.has_item(item_id) or amount <= 0:
		return 0
	var remaining := amount
	var max_stack := Catalog.max_stack(item_id)
	for slot in _slots:
		if str(slot.get("id", "")) != item_id:
			continue
		var space := max_stack - int(slot.get("qty", 0))
		if space <= 0:
			continue
		var take := mini(space, remaining)
		slot["qty"] = int(slot.get("qty", 0)) + take
		remaining -= take
		if remaining <= 0:
			break
	while remaining > 0 and _slots.size() < capacity():
		var take := mini(max_stack, remaining)
		_slots.append({"id": item_id, "qty": take})
		remaining -= take
	var added := amount - remaining
	if added > 0:
		item_added.emit(item_id, added)
		inventory_changed.emit()
		if _equipped.is_empty() and Catalog.item_is_tool(item_id):
			equip(item_id)
	return added


func remove(item_id: String, amount: int = 1) -> int:
	if amount <= 0 or quantity(item_id) <= 0:
		return 0
	var remaining := amount
	var i := _slots.size() - 1
	while i >= 0 and remaining > 0:
		var slot: Dictionary = _slots[i]
		if str(slot.get("id", "")) != item_id:
			i -= 1
			continue
		var have := int(slot.get("qty", 0))
		var take := mini(have, remaining)
		slot["qty"] = have - take
		remaining -= take
		if int(slot.get("qty", 0)) <= 0:
			_slots.remove_at(i)
		i -= 1
	var removed := amount - remaining
	if removed > 0:
		if _equipped == item_id and quantity(item_id) <= 0:
			_equipped = ""
			equipped_changed.emit()
		if _seed == item_id and quantity(item_id) <= 0:
			_seed = ""
			equipped_changed.emit()
		item_consumed.emit(item_id, removed)
		inventory_changed.emit()
	return removed


func slots() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for slot in _slots:
		rows.append(slot.duplicate(true))
	return rows


func equipped_tool() -> String:
	return _equipped


func equipped_seed() -> String:
	return _seed


func equip(item_id: String) -> bool:
	if item_id.is_empty():
		if _equipped.is_empty():
			return true
		_equipped = ""
		equipped_changed.emit()
		return true
	if not Catalog.item_is_tool(item_id) or quantity(item_id) <= 0:
		return false
	if _equipped == item_id:
		return true
	_equipped = item_id
	equipped_changed.emit()
	return true


func equip_seed(item_id: String) -> bool:
	if item_id.is_empty():
		if _seed.is_empty():
			return true
		_seed = ""
		equipped_changed.emit()
		return true
	if not Catalog.item_is_seed(item_id) or quantity(item_id) <= 0:
		return false
	if _seed == item_id:
		return true
	_seed = item_id
	equipped_changed.emit()
	return true


func tools_owned() -> PackedStringArray:
	var tools := PackedStringArray()
	for item_id in Catalog.ids():
		if Catalog.item_is_tool(item_id) and quantity(item_id) > 0:
			tools.append(item_id)
	return tools


func buy(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not Catalog.is_sold(item_id):
		return false
	var price := Catalog.shop_price(item_id) * amount
	if not can_afford(price):
		return false
	if not can_add(item_id, amount):
		return false
	if not spend_cash(price):
		return false
	var added := add(item_id, amount)
	if added < amount:
		gain_cash(Catalog.shop_price(item_id) * (amount - added))
		return false
	return true


func starter_taken(kind: String) -> bool:
	var flag := Catalog.starter_flag(kind)
	if flag.is_empty():
		return false
	var story := get_node_or_null("/root/NarrativeState")
	if story == null or not story.has_method("flag_is_true"):
		return false
	return bool(story.call("flag_is_true", flag))


func grant_starter(kind: String) -> bool:
	if starter_taken(kind):
		return false
	var rows := Catalog.starter_items(kind)
	if rows.is_empty():
		return false
	for row in rows:
		var item_id := str(row.get("id", ""))
		var qty := int(row.get("qty", 1))
		if not can_add(item_id, qty):
			return false
	for row in rows:
		add(str(row.get("id", "")), int(row.get("qty", 1)))
	if kind == "seeds" and _seed.is_empty():
		for row in rows:
			var seed_id := str(row.get("id", ""))
			if Catalog.item_is_seed(seed_id):
				equip_seed(seed_id)
				break
	var flag := Catalog.starter_flag(kind)
	var story := get_node_or_null("/root/NarrativeState")
	if story != null and story.has_method("set_flag") and not flag.is_empty():
		story.call("set_flag", flag, true)
	return true


func to_dictionary() -> Dictionary:
	var slot_rows: Array = []
	for slot in _slots:
		slot_rows.append(slot.duplicate(true))
	return {
		"slots": slot_rows,
		"equipped": _equipped,
		"seed": _seed,
		"cash": _cash,
	}


func from_dictionary(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	set_cash(int(data.get("cash", Catalog.starting_cash())))
	_slots.clear()
	var rows_v: Variant = data.get("slots", [])
	if rows_v is Array:
		for row_v in rows_v as Array:
			if not row_v is Dictionary:
				continue
			var row: Dictionary = row_v
			var item_id := str(row.get("id", ""))
			var qty := int(row.get("qty", 0))
			if not Catalog.has_item(item_id) or qty <= 0:
				continue
			if _slots.size() >= capacity():
				break
			_slots.append({
				"id": item_id,
				"qty": mini(qty, Catalog.max_stack(item_id)),
			})
	var equipped := str(data.get("equipped", ""))
	if equipped.is_empty() or quantity(equipped) <= 0 or not Catalog.item_is_tool(equipped):
		_equipped = ""
		if not tools_owned().is_empty():
			_equipped = tools_owned()[0]
	else:
		_equipped = equipped
	var seed := str(data.get("seed", ""))
	if seed.is_empty() or quantity(seed) <= 0 or not Catalog.item_is_seed(seed):
		_seed = ""
	else:
		_seed = seed
	inventory_changed.emit()
	wallet_changed.emit()
	equipped_changed.emit()
