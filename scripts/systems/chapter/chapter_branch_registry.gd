class_name ChapterBranchRegistry
extends RefCounted

const BRANCHES: Dictionary = {
	"yellow_turban_mercy": {
		"name":"安民路線",
		"chapter":"yellow_turban_zhuo",
		"requirements":{"flags_any":["protected_civilians","spared_yellow_turban"],"heroes_any":["liubei","huatuo"]},
		"effects":{"next_chapter":"luoyang_turmoil","merchant_override":"healer","hero_weight_bonus":{"liubei":1.25,"huatuo":1.20},"set_flags":["people_support"]}
	},
	"luoyang_escape": {
		"name":"護送出京",
		"chapter":"luoyang_turmoil",
		"requirements":{"flags_any":["people_support","saved_refugees"],"heroes_any":["caocao","diaochan"]},
		"effects":{"next_chapter":"hulao_coalition","merchant_override":"antiquarian","reinforcement":"refugee_guard","set_flags":["luoyang_survivors"]}
	},
	"hulao_alliance": {
		"name":"諸侯同盟",
		"chapter":"hulao_coalition",
		"requirements":{"bosses_all":["lvbu"],"heroes_any":["liubei","caocao","sunjian"]},
		"effects":{"next_chapter":"xuzhou_flames","boss_variant":"alliance_aftermath","merchant_override":"quartermaster","set_flags":["coalition_contact"]}
	},
	"xuzhou_rescue": {
		"name":"徐州救援",
		"chapter":"xuzhou_flames",
		"requirements":{"flags_any":["people_support","luoyang_survivors"],"heroes_any":["liubei","guanyu","zhangfei"]},
		"effects":{"next_chapter":"guandu_showdown","reinforcement":"xuzhou_volunteers","merchant_override":"blacksmith","set_flags":["xuzhou_saved"]}
	}
}

static func normalize_id(value: String) -> String:
	return value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")

static func get_definition(branch_id: String) -> Dictionary:
	return (BRANCHES.get(normalize_id(branch_id), {}) as Dictionary).duplicate(true)

static func available_for(chapter_id: String, context: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for branch_value in BRANCHES.keys():
		var branch_id: String = str(branch_value)
		var definition: Dictionary = BRANCHES[branch_id] as Dictionary
		if str(definition.get("chapter", "")) != chapter_id:
			continue
		if requirements_met(definition.get("requirements", {}) as Dictionary, context):
			result.append(branch_id)
	return result

static func requirements_met(requirements: Dictionary, context: Dictionary) -> bool:
	var flags: Dictionary = context.get("flags", {}) as Dictionary
	var heroes: Array = context.get("heroes", []) as Array
	var bosses: Dictionary = context.get("bosses", {}) as Dictionary
	var relics: Array = context.get("relics", []) as Array
	var flags_any: Array = requirements.get("flags_any", []) as Array
	if not flags_any.is_empty() and not flags_any.any(func(v: Variant) -> bool: return bool(flags.get(str(v), false))):
		return false
	var heroes_any: Array = requirements.get("heroes_any", []) as Array
	if not heroes_any.is_empty() and not heroes_any.any(func(v: Variant) -> bool: return heroes.has(str(v))):
		return false
	for boss_value in requirements.get("bosses_all", []):
		if int(bosses.get(str(boss_value), 0)) <= 0:
			return false
	for relic_value in requirements.get("relics_all", []):
		if not relics.has(str(relic_value)):
			return false
	return true

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for branch_value in BRANCHES.keys():
		var branch_id: String = str(branch_value)
		var definition: Dictionary = BRANCHES[branch_id] as Dictionary
		for key in ["name", "chapter", "requirements", "effects"]:
			if not definition.has(key):
				errors.append("%s missing %s" % [branch_id, key])
	return errors
