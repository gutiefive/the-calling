class_name IntroData
extends RefCounted
## Loads data/intro.json. Beats, goals, and the primer live there so lines can change without code.

const PATH := "res://data/intro.json"
const MIN_BOXES := 12
const MAX_BOXES := 20
const FORBIDDEN := ["cult", "ledger", "debt", "money"]
const PANEL_IDS := [
	"letter",
	"drive",
	"town_sign",
	"oak_street",
	"church_reveal",
	"overgrown_garden",
	"locked_door",
	"vignette_margaret",
	"vignette_harold",
	"vignette_thomas",
	"vignette_frank",
	"vignette_sarah",
	"porch_close",
	"closing",
]


static func load_data() -> Dictionary:
	var parsed: Variant = JsonFile.read(PATH)
	if parsed is Dictionary:
		return parsed
	return {}


static func beats(data: Dictionary = {}) -> Array:
	var source: Dictionary = data if not data.is_empty() else load_data()
	var raw: Variant = source.get("beats", [])
	if raw is Array:
		return raw
	return []


static func goals(data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else load_data()
	var raw: Variant = source.get("goals", {})
	if raw is Dictionary:
		return raw
	return {}


static func primer(data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else load_data()
	var raw: Variant = source.get("primer", {})
	if raw is Dictionary:
		return raw
	return {}


static func skip_hint(data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else load_data()
	return str(source.get("skip_hint", "Hold Esc to skip"))


static func skip_hold_seconds(data: Dictionary = {}) -> float:
	var source: Dictionary = data if not data.is_empty() else load_data()
	return float(source.get("skip_hold_seconds", 0.85))


static func beat_text(beat: Dictionary) -> String:
	return str(beat.get("text", "")).strip_edges()


static func beat_panel(beat: Dictionary) -> String:
	return str(beat.get("panel", "")).strip_edges()


static func beat_id(beat: Dictionary) -> String:
	return str(beat.get("id", "")).strip_edges()


static func beat_motion(beat: Dictionary) -> String:
	return str(beat.get("motion", "fade")).strip_edges()


static func beat_voice(beat: Dictionary) -> String:
	return str(beat.get("voice", "narration")).strip_edges()


static func all_story_text(data: Dictionary = {}) -> PackedStringArray:
	var lines := PackedStringArray()
	for beat_v in beats(data):
		if not beat_v is Dictionary:
			continue
		var text := beat_text(beat_v)
		if not text.is_empty():
			lines.append(text)
	_append_block(lines, goals(data))
	_append_block(lines, primer(data))
	return lines


static func issues(data: Dictionary = {}) -> PackedStringArray:
	var source: Dictionary = data if not data.is_empty() else load_data()
	var found := PackedStringArray()
	if source.is_empty():
		found.append("intro data did not load")
		return found
	var rows := beats(source)
	if rows.size() < MIN_BOXES or rows.size() > MAX_BOXES:
		found.append("text box count %d is outside %d-%d" % [rows.size(), MIN_BOXES, MAX_BOXES])
	for beat_v in rows:
		if not beat_v is Dictionary:
			found.append("a beat is not an object")
			continue
		var beat: Dictionary = beat_v
		var panel := beat_panel(beat)
		if not PANEL_IDS.has(panel) or not IntroFrames.has_panel(panel):
			found.append("beat %s uses unknown panel %s" % [beat_id(beat), panel])
		var text := beat_text(beat)
		if text.is_empty():
			found.append("beat %s has empty text" % beat_id(beat))
		var sentences := _sentence_count(text)
		if sentences < 1 or sentences > 2:
			found.append("beat %s is not 1-2 sentences (%d)" % [beat_id(beat), sentences])
		if text.length() > 180:
			found.append("beat %s is longer than 180 characters" % beat_id(beat))
	for line in all_story_text(source):
		if line.find("$") >= 0:
			found.append("a dollar sign appears in intro text")
		var lowered := line.to_lower()
		for word in FORBIDDEN:
			if lowered.find(word) >= 0:
				found.append("forbidden word %s appears in intro text" % word)
		if _has_digit(line) and not _is_primer_line(source, line):
			found.append("a digit appears in intro narration")
	return found


static func _append_block(lines: PackedStringArray, block: Dictionary) -> void:
	var title := str(block.get("title", "")).strip_edges()
	if not title.is_empty():
		lines.append(title)
	var raw: Variant = block.get("lines", [])
	if raw is Array:
		for item in raw:
			var line := str(item).strip_edges()
			if not line.is_empty():
				lines.append(line)
	var dismiss := str(block.get("dismiss", "")).strip_edges()
	if not dismiss.is_empty():
		lines.append(dismiss)


static func _sentence_count(text: String) -> int:
	var trimmed := text.strip_edges()
	if trimmed.is_empty():
		return 0
	var count := 0
	for ch in ["!", "?"]:
		trimmed = trimmed.replace(ch, ".")
	var parts := trimmed.split(".", false)
	for part in parts:
		if not str(part).strip_edges().is_empty():
			count += 1
	return count


static func _has_digit(text: String) -> bool:
	for i in text.length():
		var code := text.unicode_at(i)
		if code >= 48 and code <= 57:
			return true
	return false


static func _is_primer_line(data: Dictionary, line: String) -> bool:
	var block := primer(data)
	if str(block.get("title", "")) == line or str(block.get("dismiss", "")) == line:
		return true
	var raw: Variant = block.get("lines", [])
	if raw is Array:
		for item in raw:
			if str(item) == line:
				return true
	return false
