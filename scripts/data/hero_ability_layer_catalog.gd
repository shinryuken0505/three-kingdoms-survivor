class_name HeroAbilityLayerCatalog
extends RefCounted

## 將名將既有資料整理成三層能力展示資料。
## 不修改 GameData.heroes()，避免舊存檔與戰鬥技能 ID 受到影響。

const LAYER_SPECIALIZATION: StringName = &"specialization"
const LAYER_RESERVE_PASSIVE: StringName = &"reserve_passive"
const LAYER_LEGACY_ART: StringName = &"legacy_art"


static func build(hero_id: String, hero_def: Dictionary) -> Dictionary:
	var role: String = str(hero_def.get("combat_role", "utility"))
	var role_tags: Array[StringName] = _role_tags(role)
	return {
		"hero_id": hero_id,
		"role": role,
		"role_tags": role_tags,
		"specialization": {
			"layer": LAYER_SPECIALIZATION,
			"name": "%s專精" % str(hero_def.get("name", hero_id)),
			"description": str(hero_def.get("active", "強化目前主戰名將的主動技能。")),
			"source": &"active",
			"build_tags": role_tags.duplicate(),
		},
		"reserve_passive": {
			"layer": LAYER_RESERVE_PASSIVE,
			"name": "%s後援" % str(hero_def.get("name", hero_id)),
			"description": str(hero_def.get("passive", "在後備位置提供較弱的角色特色效果。")),
			"source": &"reserve",
			"build_tags": role_tags.duplicate(),
		},
		"legacy_art": {
			"layer": LAYER_LEGACY_ART,
			"name": str(hero_def.get("legendary", "%s傳承戰法" % str(hero_def.get("name", hero_id)))),
			"description": str(hero_def.get("identity", "完成羈絆或專屬事件後解鎖的通用戰法。")),
			"source": &"unlock",
			"build_tags": role_tags.duplicate(),
			"locked": true,
		},
	}


static func build_all(hero_defs: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for hero_value in hero_defs.keys():
		var hero_id: String = str(hero_value)
		result[hero_id] = build(hero_id, hero_defs.get(hero_id, {}) as Dictionary)
	return result


static func layer_for_position(hero_id: String, position: StringName, hero_defs: Dictionary) -> Dictionary:
	if not hero_defs.has(hero_id):
		return {}
	var layers: Dictionary = build(hero_id, hero_defs.get(hero_id, {}) as Dictionary)
	if position == &"active":
		return (layers.get("specialization", {}) as Dictionary).duplicate(true)
	if position == &"reserve":
		return (layers.get("reserve_passive", {}) as Dictionary).duplicate(true)
	return (layers.get("legacy_art", {}) as Dictionary).duplicate(true)


static func _role_tags(role: String) -> Array[StringName]:
	if role in ["melee", "revenge", "mobility"]:
		return [&"melee"]
	if role in ["ranged", "projectile"]:
		return [&"ranged", &"projectile"]
	if role == "ailment":
		return [&"ailment", &"poison"]
	if role == "control":
		return [&"control"]
	if role in ["support", "command", "utility"]:
		return [&"shared", &"support"]
	return [&"shared"]
