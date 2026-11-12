class_name NpcRoute
extends RefCounted
## Short axis-aligned routes between two schedule points.
## A blocked segment is a failed plan. The caller teleports instead of trapping the NPC.


static func plan(from: Vector2, to: Vector2, blocks: Array[Rect2]) -> Dictionary:
	if from.distance_to(to) <= 1.0:
		return {"ok": true, "points": []}
	if _clear(from, to, blocks):
		var direct: Array[Vector2] = [to]
		return {"ok": true, "points": direct}
	var corner_h := Vector2(to.x, from.y)
	if corner_h.distance_to(from) > 1.0 and corner_h.distance_to(to) > 1.0:
		if _clear(from, corner_h, blocks) and _clear(corner_h, to, blocks):
			var elbow_h: Array[Vector2] = [corner_h, to]
			return {"ok": true, "points": elbow_h}
	var corner_v := Vector2(from.x, to.y)
	if corner_v.distance_to(from) > 1.0 and corner_v.distance_to(to) > 1.0:
		if _clear(from, corner_v, blocks) and _clear(corner_v, to, blocks):
			var elbow_v: Array[Vector2] = [corner_v, to]
			return {"ok": true, "points": elbow_v}
	return {"ok": false, "points": []}


static func _clear(a: Vector2, b: Vector2, blocks: Array[Rect2]) -> bool:
	var dist := a.distance_to(b)
	var steps := maxi(int(dist / 12.0), 1)
	for i in steps + 1:
		var point := a.lerp(b, float(i) / float(steps))
		for rect in blocks:
			if rect.grow(6.0).has_point(point):
				return false
	return true
