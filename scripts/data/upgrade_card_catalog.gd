class_name UpgradeCardCatalog
extends RefCounted

## 將既有 GameData.skills() 補上穩定的卡池分類資料。
## 不修改舊技能定義與存檔 ID，僅在產生候選時附加 metadata。

const DEFINITIONS: Dictionary = {
	"damage": {
		"category": &"shared",
		"build_tags": [&"shared"],
		"priority": 90,
	},
	"attack_speed": {
		"category": &"shared",
		"build_tags": [&"shared"],
		"priority": 88,
	},
	"move_speed": {
		"category": &"passive",
		"build_tags": [&"shared", &"mobility"],
		"priority": 72,
	},
	"max_hp": {
		"category": &"passive",
		"build_tags": [&"shared", &"survival"],
		"priority": 78,
	},
	"armor": {
		"category": &"passive",
		"build_tags": [&"shared", &"survival"],
		"priority": 76,
	},
	"crit": {
		"category": &"shared",
		"build_tags": [&"shared", &"crit"],
		"priority": 82,
	},
	"magnet": {
		"category": &"passive",
		"build_tags": [&"shared", &"economy"],
		"priority": 58,
	},
	"dash": {
		"category": &"passive",
		"build_tags": [&"shared", &"mobility", &"survival"],
		"priority": 70,
	},
	"hero_cd": {
		"category": &"passive",
		"build_tags": [&"shared", &"hero"],
		"priority": 66,
	},
	"projectile": {
		"category": &"player_skill",
		"build_tags": [&"ranged", &"projectile"],
		"blocked_tags": [&"melee"],
		"priority": 96,
	},
	"pierce": {
		"category": &"player_skill",
		"build_tags": [&"ranged", &"projectile"],
		"required_tags": [&"ranged"],
		"blocked_tags": [&"melee"],
		"priority": 92,
	},
	"poison": {
		"category": &"player_skill",
		"build_tags": [&"poison"],
		"entry_tags": [&"poison"],
		"priority": 80,
	},
	"multishot": {
		"category": &"player_skill",
		"build_tags": [&"ranged", &"projectile"],
		"required_tags": [&"ranged"],
		"blocked_tags": [&"melee"],
		"priority": 94,
	},
	"heal": {
		"category": &"passive",
		"build_tags": [&"shared", &"recovery"],
		"priority": 68,
	},
}


static func metadata(skill_id: String) -> Dictionary:
	return (DEFINITIONS.get(skill_id, _fallback_metadata()) as Dictionary).duplicate(true)


static func decorate(skill_id: String, card: Dictionary) -> Dictionary:
	var result: Dictionary = card.duplicate(true)
	result["id"] = skill_id
	for key in metadata(skill_id):
		if not result.has(key):
			result[key] = metadata(skill_id)[key]
	return result


static func decorate_pool(skill_defs: Dictionary, skill_levels: Dictionary = {}) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for skill_value in skill_defs.keys():
		var skill_id: String = str(skill_value)
		var definition: Dictionary = skill_defs.get(skill_id, {}) as Dictionary
		var current_level: int = int(skill_levels.get(skill_id, 0))
		var max_level: int = int(definition.get("max", 1))
		if current_level >= max_level:
			continue
		var card: Dictionary = decorate(skill_id, definition)
		card["current_level"] = current_level
		card["max_level"] = max_level
		result.append(card)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("priority", 0)) > int(b.get("priority", 0))
	)
	return result


static func infer_id(card: Dictionary, skill_defs: Dictionary) -> String:
	for key in ["id", "skill_id", "key"]:
		var explicit_id: String = str(card.get(key, ""))
		if skill_defs.has(explicit_id):
			return explicit_id
	var card_name: String = str(card.get("name", ""))
	for skill_value in skill_defs.keys():
		var skill_id: String = str(skill_value)
		var definition: Dictionary = skill_defs.get(skill_id, {}) as Dictionary
		if str(definition.get("name", "")) == card_name:
			return skill_id
	return ""


static func _fallback_metadata() -> Dictionary:
	return {
		"category": &"shared",
		"build_tags": [&"shared"],
		"priority": 50,
	}
