class_name HeroSpecializationOfferCatalog
extends RefCounted

## 將目前主戰名將的定位轉成可安全沿用既有技能 ID 的「主將專精」升級卡。
##
## 專精卡不建立新的存檔技能 ID，而是以名將語意包裝既有主角能力；
## 玩家選取後仍由原本 choose_levelup() 提升對應技能，避免破壞舊流程與存檔。

const ROLE_SKILLS: Dictionary = {
	"melee": ["damage", "crit", "armor"],
	"revenge": ["crit", "max_hp", "armor"],
	"mobility": ["dash", "move_speed", "crit"],
	"ranged": ["projectile", "pierce", "multishot"],
	"projectile": ["projectile", "pierce", "multishot"],
	"ailment": ["poison", "attack_speed", "heal"],
	"control": ["hero_cd", "move_speed", "damage"],
	"support": ["hero_cd", "heal", "max_hp"],
	"command": ["hero_cd", "damage", "max_hp"],
	"utility": ["hero_cd", "move_speed", "magnet"],
}


static func build_cards(
	active_heroes: Array,
	hero_defs: Dictionary,
	decorated_pool: Array[Dictionary]
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var used_skill_ids: Dictionary = {}
	for hero_value in active_heroes:
		var hero_id: String = str(hero_value)
		if not hero_defs.has(hero_id):
			continue
		var hero_def: Dictionary = hero_defs.get(hero_id, {}) as Dictionary
		var role: String = str(hero_def.get("combat_role", "utility"))
		var preferred: Array = ROLE_SKILLS.get(role, ROLE_SKILLS["utility"]) as Array
		for skill_value in preferred:
			var skill_id: String = str(skill_value)
			if bool(used_skill_ids.get(skill_id, false)):
				continue
			var base_card: Dictionary = _card_by_id(decorated_pool, skill_id)
			if base_card.is_empty():
				continue
			var card: Dictionary = base_card.duplicate(true)
			card["category"] = "hero_specialization"
			card["source_hero_id"] = hero_id
			card["source_hero_name"] = str(hero_def.get("name", hero_id))
			card["base_name"] = str(base_card.get("name", skill_id))
			card["name"] = "%s專精・%s" % [card["source_hero_name"], card["base_name"]]
			card["desc"] = "%s｜%s" % [str(hero_def.get("active", "強化主戰名將特色。")), str(base_card.get("desc", ""))]
			card["specialization"] = true
			card["path_tier"] = "specialization"
			card["priority"] = int(base_card.get("priority", 50)) + 8
			result.append(card)
			used_skill_ids[skill_id] = true
			break
	return result


static func merge_with_pool(
	base_pool: Array[Dictionary],
	specialization_cards: Array[Dictionary]
) -> Array[Dictionary]:
	var replacements: Dictionary = {}
	for card in specialization_cards:
		replacements[str(card.get("id", ""))] = card
	var result: Array[Dictionary] = []
	for base_card in base_pool:
		var skill_id: String = str(base_card.get("id", ""))
		if replacements.has(skill_id):
			result.append((replacements[skill_id] as Dictionary).duplicate(true))
			replacements.erase(skill_id)
		else:
			result.append(base_card.duplicate(true))
	for remaining in replacements.values():
		result.append((remaining as Dictionary).duplicate(true))
	return result


static func _card_by_id(pool: Array[Dictionary], skill_id: String) -> Dictionary:
	for card in pool:
		if str(card.get("id", "")) == skill_id:
			return card
	return {}
