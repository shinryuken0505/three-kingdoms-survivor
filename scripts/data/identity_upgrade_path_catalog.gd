class_name IdentityUpgradePathCatalog
extends RefCounted

## 四位主角的升級路線偏好。
##
## 不新增存檔技能 ID，而是調整既有技能卡的排序、來源標籤與 Build 摘要。
## 這樣可立即改善升級體驗，同時保持 choose_levelup() 與舊存檔相容。

const PATHS = {
	"blade": {
		"id": "melee_vanguard",
		"name": "近戰先鋒",
		"primary": ["damage", "attack_speed", "crit", "armor", "dash"],
		"secondary": ["max_hp", "move_speed", "heal", "hero_cd", "magnet"],
		"blocked": ["projectile", "pierce", "multishot"],
		"tags": ["melee", "crit", "survival"],
	},
	"bow": {
		"id": "ranged_marksman",
		"name": "遠戰神射",
		"primary": ["projectile", "pierce", "multishot", "crit", "attack_speed"],
		"secondary": ["damage", "move_speed", "dash", "hero_cd", "magnet"],
		"blocked": [],
		"tags": ["ranged", "projectile", "crit"],
	},
	"poison": {
		"id": "ailment_alchemist",
		"name": "藥毒流轉",
		"primary": ["poison", "attack_speed", "heal", "move_speed", "damage"],
		"secondary": ["projectile", "multishot", "crit", "dash", "hero_cd"],
		"blocked": ["pierce"],
		"tags": ["ranged", "poison", "recovery"],
	},
	"rings": {
		"id": "mobile_ringblade",
		"name": "環刃遊擊",
		"primary": ["multishot", "projectile", "crit", "dash", "attack_speed"],
		"secondary": ["pierce", "move_speed", "damage", "hero_cd", "heal"],
		"blocked": [],
		"tags": ["ranged", "projectile", "mobility"],
	},
}


static func path_for_player(player: Dictionary) -> Dictionary:
	var weapon: String = str(player.get("weapon", ""))
	return (PATHS.get(weapon, _fallback_path()) as Dictionary).duplicate(true)


static func decorate_card(card: Dictionary, player: Dictionary) -> Dictionary:
	var result: Dictionary = card.duplicate(true)
	var path: Dictionary = path_for_player(player)
	var skill_id: String = str(result.get("id", ""))
	var tier: String = "shared"
	var bonus: int = 0
	if skill_id in (path.get("primary", []) as Array):
		tier = "primary"
		bonus = 80
	elif skill_id in (path.get("secondary", []) as Array):
		tier = "secondary"
		bonus = 35
	elif skill_id in (path.get("blocked", []) as Array):
		tier = "blocked"
		bonus = -500
	result["path_id"] = str(path.get("id", "general"))
	result["path_name"] = str(path.get("name", "通用成長"))
	result["path_tier"] = tier
	result["path_priority"] = int(result.get("priority", 0)) + bonus
	result["source_label"] = _source_label(result, tier)
	return result


static func decorate_pool(cards: Array, player: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in cards:
		if value is Dictionary:
			var decorated: Dictionary = decorate_card(value as Dictionary, player)
			if str(decorated.get("path_tier", "")) != "blocked":
				result.append(decorated)
	_sort_by_path_priority(result)
	return result


static func summary(player: Dictionary, skill_levels: Dictionary) -> Dictionary:
	var path: Dictionary = path_for_player(player)
	var developed: Array[String] = []
	for value in (path.get("primary", []) as Array):
		var skill_id: String = str(value)
		if int(skill_levels.get(skill_id, 0)) > 0:
			developed.append(skill_id)
	return {
		"path_id": str(path.get("id", "general")),
		"path_name": str(path.get("name", "通用成長")),
		"tags": (path.get("tags", []) as Array).duplicate(),
		"developed": developed,
	}


static func _sort_by_path_priority(cards: Array[Dictionary]) -> void:
	for left in range(cards.size()):
		var best: int = left
		for right in range(left + 1, cards.size()):
			if int(cards[right].get("path_priority", 0)) > int(cards[best].get("path_priority", 0)):
				best = right
		if best != left:
			var temporary: Dictionary = cards[left]
			cards[left] = cards[best]
			cards[best] = temporary


static func _source_label(card: Dictionary, tier: String) -> String:
	if tier == "primary":
		return "主角核心"
	if tier == "secondary":
		return "路線支援"
	var category: String = str(card.get("category", "player_skill"))
	if category == "passive" or category == "shared":
		return "共用被動"
	return "流派能力"


static func _fallback_path() -> Dictionary:
	return {
		"id": "general",
		"name": "通用成長",
		"primary": ["damage", "attack_speed", "crit"],
		"secondary": ["move_speed", "max_hp", "armor", "dash", "heal", "hero_cd", "magnet"],
		"blocked": [],
		"tags": ["shared"],
	}
