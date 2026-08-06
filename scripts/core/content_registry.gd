class_name ContentRegistry
extends RefCounted

const REQUIRED_FIELDS: Dictionary = {
	"player": ["id", "name", "base_stats", "weapon", "starting_skills", "portrait", "sprite"],
	"hero": ["id", "name", "faction", "active_skill", "reserve_passive", "growth_profile", "portrait", "sprite"],
	"relic": ["id", "name", "rarity", "max_level", "effect_id"],
	"merchant": ["id", "name", "inventory_pool", "pricing_profile", "spawn_rules"],
	"chapter": ["id", "name", "index", "phases", "branches"],
}

var entries: Dictionary = {
	"player": {},
	"hero": {},
	"relic": {},
	"merchant": {},
	"chapter": {},
}

func register(kind: String, definition: Dictionary) -> bool:
	if not entries.has(kind):
		push_error("Unsupported registry kind: %s" % kind)
		return false
	var errors: PackedStringArray = validate_definition(kind, definition)
	if not errors.is_empty():
		push_error("Invalid %s definition: %s" % [kind, ", ".join(errors)])
		return false
	var content_id: String = canonical_id(str(definition.get("id", "")))
	if content_id == "":
		return false
	var stored: Dictionary = definition.duplicate(true)
	stored["id"] = content_id
	(entries[kind] as Dictionary)[content_id] = stored
	return true

func register_many(kind: String, definitions: Variant) -> PackedStringArray:
	var failures: PackedStringArray = []
	if definitions is Dictionary:
		for value in (definitions as Dictionary).values():
			if value is Dictionary and not register(kind, value):
				failures.append(str((value as Dictionary).get("id", "unknown")))
	elif definitions is Array:
		for value in definitions:
			if value is Dictionary and not register(kind, value):
				failures.append(str((value as Dictionary).get("id", "unknown")))
	return failures

func get_definition(kind: String, content_id: String) -> Dictionary:
	if not entries.has(kind):
		return {}
	return ((entries[kind] as Dictionary).get(canonical_id(content_id), {}) as Dictionary).duplicate(true)

func validate_definition(kind: String, definition: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	if not REQUIRED_FIELDS.has(kind):
		errors.append("unsupported kind")
		return errors
	for field in REQUIRED_FIELDS[kind]:
		if not definition.has(field):
			errors.append("missing %s" % field)
	if canonical_id(str(definition.get("id", ""))) == "":
		errors.append("empty id")
	return errors

static func canonical_id(value: String) -> String:
	return value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")
