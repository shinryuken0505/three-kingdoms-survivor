class_name Alpha22Codex
extends RefCounted

const CATEGORIES := ["heroes", "bosses", "relics", "endings"]

static func normalize(raw: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for category in CATEGORIES:
		var value: Variant = raw.get(category, {})
		result[category] = value.duplicate(true) if value is Dictionary else {}
	return result

static func discover(codex: Dictionary, category: String, id: String, details: Dictionary = {}) -> Dictionary:
	var next: Dictionary = normalize(codex)
	if not category in CATEGORIES or id == "":
		return next
	var entries: Dictionary = next.get(category, {})
	var previous: Dictionary = entries.get(id, {}) if entries.get(id, {}) is Dictionary else {}
	var entry: Dictionary = previous.duplicate(true)
	entry["discovered"] = true
	entry["encounters"] = int(entry.get("encounters", 0)) + 1
	for key in details.keys():
		entry[key] = details[key]
	entries[id] = entry
	next[category] = entries
	return next

static func completion(codex: Dictionary, totals: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize(codex)
	var found: int = 0
	var total: int = 0
	for category in CATEGORIES:
		found += normalized.get(category, {}).size()
		total += max(0, int(totals.get(category, 0)))
	return {
		"found": found,
		"total": total,
		"ratio": float(found) / max(1.0, float(total)),
	}

static func is_discovered(codex: Dictionary, category: String, id: String) -> bool:
	return bool(normalize(codex).get(category, {}).get(id, {}).get("discovered", false))
