class_name ChapterBranchRegistry
extends RefCounted

const BRANCHES: Dictionary = {
	"yellow_turban_mercy": {
		"name":"安民路線", "description":"先安百姓、再定亂軍。你留下的仁義名聲，會讓醫者與義士更願意靠近。", "chapter":"yellow_turban_zhuo", "fallback":false,
		"requirements":{"flags_any":["protected_civilians","spared_yellow_turban"],"heroes_any":["liubei","huatuo"]},
		"effects":{"next_chapter":"luoyang_turmoil","merchant_override":"healer","hero_weight_bonus":{"liubei":1.25,"huatuo":1.20},"set_flags":["people_support"]}
	},
	"yellow_turban_history": {
		"name":"隨軍入洛", "description":"黃巾之亂暫平，你隨著時局向帝都前進，踏入更深的亂世。", "chapter":"yellow_turban_zhuo", "fallback":true,
		"requirements":{}, "effects":{"next_chapter":"luoyang_turmoil","set_flags":["yellow_turban_resolved"]}
	},
	"luoyang_escape": {
		"name":"護送出京", "description":"在洛陽陷入混亂前護送百姓與重要人物出城，留下可在後續戰局呼應的人脈。", "chapter":"luoyang_turmoil", "fallback":false,
		"requirements":{"flags_any":["people_support","saved_refugees"],"heroes_any":["caocao","diaochan"]},
		"effects":{"next_chapter":"hulao_coalition","merchant_override":"antiquarian","reinforcement":"refugee_guard","set_flags":["luoyang_survivors"]}
	},
	"luoyang_history": {
		"name":"追隨討董軍", "description":"董卓西遷，關東諸侯會盟。你順著大勢前往虎牢關。", "chapter":"luoyang_turmoil", "fallback":true,
		"requirements":{}, "effects":{"next_chapter":"hulao_coalition","set_flags":["joined_coalition_route"]}
	},
	"hulao_alliance": {
		"name":"諸侯同盟", "description":"擊退飛將後與諸侯保持聯繫，後續可獲得軍需與特殊盟軍支援。", "chapter":"hulao_coalition", "fallback":false,
		"requirements":{"bosses_all":["lvbu"],"heroes_any":["liubei","caocao","sunjian"]},
		"effects":{"next_chapter":"xuzhou_flames","boss_variant":"alliance_aftermath","merchant_override":"quartermaster","set_flags":["coalition_contact"]}
	},
	"hulao_history": {
		"name":"各自歸途", "description":"諸侯聯軍漸散，你離開虎牢關，下一場風暴將在徐州聚集。", "chapter":"hulao_coalition", "fallback":true,
		"requirements":{}, "effects":{"next_chapter":"xuzhou_flames","set_flags":["coalition_disbanded"]}
	},
	"xuzhou_rescue": {
		"name":"徐州救援", "description":"優先保住百姓與糧道，讓徐州地方力量成為後續可用的援軍。", "chapter":"xuzhou_flames", "fallback":false,
		"requirements":{"flags_any":["people_support","luoyang_survivors"],"heroes_any":["liubei","guanyu","zhangfei"]},
		"effects":{"next_chapter":"guandu_showdown","reinforcement":"xuzhou_volunteers","merchant_override":"blacksmith","hero_weight_bonus":{"liubei":1.18,"guanyu":1.12,"zhangfei":1.12},"set_flags":["xuzhou_saved"]}
	},
	"xuzhou_history": {
		"name":"北上官渡", "description":"徐州局勢告一段落，北方兩大勢力的決戰已無可避免。", "chapter":"xuzhou_flames", "fallback":true,
		"requirements":{}, "effects":{"next_chapter":"guandu_showdown","set_flags":["xuzhou_resolved"]}
	},
	"guandu_supply": {
		"name":"奇襲糧道", "description":"將勝負押在情報與糧道上，後續更容易遇到軍需型商人與策略型名將。", "chapter":"guandu_showdown", "fallback":false,
		"requirements":{"heroes_any":["caocao","guojia","simayi"]},
		"effects":{"merchant_override":"quartermaster","reinforcement":"guandu_scouts","hero_weight_bonus":{"caocao":1.20,"guojia":1.25},"set_flags":["guandu_supply_strike"]}
	},
	"guandu_history": {
		"name":"決戰之後", "description":"官渡勝負已定，你沿著歷史洪流繼續前進。", "chapter":"guandu_showdown", "fallback":true,
		"requirements":{}, "effects":{"set_flags":["guandu_resolved"]}
	}
}

static func normalize_id(value: String) -> String:
	return value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")

static func get_definition(branch_id: String) -> Dictionary:
	return (BRANCHES.get(normalize_id(branch_id), {}) as Dictionary).duplicate(true)

static func available_for(chapter_id: String, context: Dictionary) -> Array[String]:
	var regular: Array[String] = []
	var fallback: Array[String] = []
	for branch_value in BRANCHES.keys():
		var branch_id: String = str(branch_value)
		var definition: Dictionary = BRANCHES[branch_id] as Dictionary
		if str(definition.get("chapter", "")) != chapter_id:
			continue
		if not requirements_met(definition.get("requirements", {}) as Dictionary, context):
			continue
		if bool(definition.get("fallback", false)):
			fallback.append(branch_id)
		else:
			regular.append(branch_id)
	# 有特殊歷史條件時仍保留一條穩定歷史路線，讓玩家有真正的選擇；若沒有特殊條件則只顯示預設路線。
	if not regular.is_empty():
		regular.append_array(fallback)
		return regular
	return fallback

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

static func effect_summary(branch_id: String) -> Array[String]:
	var definition: Dictionary = get_definition(branch_id)
	var effects: Dictionary = definition.get("effects", {}) as Dictionary
	var lines: Array[String] = []
	if str(effects.get("reinforcement", "")) != "": lines.append("可能獲得援軍")
	if str(effects.get("boss_variant", "")) != "": lines.append("後續敵將狀態可能改變")
	if str(effects.get("merchant_override", "")) != "": lines.append("影響下一階段可遇商人")
	if not (effects.get("hero_weight_bonus", {}) as Dictionary).is_empty(): lines.append("影響名將相遇傾向")
	if lines.is_empty(): lines.append("沿著歷史主線繼續前進")
	return lines

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for branch_value in BRANCHES.keys():
		var branch_id: String = str(branch_value)
		var definition: Dictionary = BRANCHES[branch_id] as Dictionary
		for key in ["name", "description", "chapter", "requirements", "effects"]:
			if not definition.has(key):
				errors.append("%s missing %s" % [branch_id, key])
	return errors
