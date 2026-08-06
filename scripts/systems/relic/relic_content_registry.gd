class_name RelicContentRegistry
extends RefCounted

const RARITY_ORDER: Dictionary = {
	"common": 0,
	"rare": 1,
	"epic": 2,
	"legendary": 3,
	"mythic": 4,
}

const REQUIRED_FIELDS: Array[String] = ["id", "name", "rarity", "max_level", "effect_id"]

static func normalize_id(value: String) -> String:
	return value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")

static func adapt_legacy(relic_id: String, legacy: Dictionary) -> Dictionary:
	var id: String = normalize_id(relic_id)
	var definition: Dictionary = legacy.duplicate(true)
	definition["id"] = id
	definition["name"] = str(definition.get("name", id))
	definition["rarity"] = str(definition.get("rarity", "common")).to_lower()
	definition["max_level"] = clampi(int(definition.get("max_level", 3)), 1, 8)
	definition["effect_id"] = str(definition.get("effect_id", id))
	definition["sources"] = definition.get("sources", definition.get("source", ["battle"]))
	definition["event_hooks"] = definition.get("event_hooks", infer_hooks(definition))
	return definition

static func infer_hooks(definition: Dictionary) -> Array[String]:
	var tags: Array = definition.get("tags", []) as Array
	var hooks: Array[String] = ["on_acquired"]
	for tag_value in tags:
		var tag: String = str(tag_value)
		if tag in ["閃避", "移動"] and not hooks.has("on_dodge"):
			hooks.append("on_dodge")
		elif tag in ["Boss", "名將"] and not hooks.has("on_boss_spawned"):
			hooks.append("on_boss_spawned")
		elif tag in ["治療", "護盾", "防禦"] and not hooks.has("on_damage_taken"):
			hooks.append("on_damage_taken")
		elif tag in ["毒", "範圍", "投射物", "穿透"] and not hooks.has("on_attack"):
			hooks.append("on_attack")
	return hooks

static func build_from_legacy(legacy_defs: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for raw_id in legacy_defs.keys():
		var definition: Dictionary = adapt_legacy(str(raw_id), legacy_defs[raw_id] as Dictionary)
		result[definition["id"]] = definition
	return result

static func validate(definitions: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var icon_owners: Dictionary = {}
	for relic_id in definitions.keys():
		var definition: Dictionary = definitions[relic_id] as Dictionary
		for field in REQUIRED_FIELDS:
			if not definition.has(field) or str(definition[field]) == "":
				errors.append("遺物 %s 缺少欄位：%s" % [relic_id, field])
		var rarity: String = str(definition.get("rarity", "common"))
		if not RARITY_ORDER.has(rarity):
			errors.append("遺物 %s 使用未知稀有度：%s" % [relic_id, rarity])
		var icon_path: String = str(definition.get("icon", ""))
		if icon_path != "":
			if not ResourceLoader.exists(icon_path):
				errors.append("遺物 %s 圖示不存在：%s" % [relic_id, icon_path])
			if icon_owners.has(icon_path):
				errors.append("遺物圖示重複使用：%s（%s／%s）" % [icon_path, icon_owners[icon_path], relic_id])
			else:
				icon_owners[icon_path] = relic_id
	return errors
