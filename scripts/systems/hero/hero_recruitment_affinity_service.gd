class_name HeroRecruitmentAffinityService
extends RefCounted

const HeroContentRegistry = preload("res://scripts/systems/hero/hero_content_registry.gd")

const RELIC_TAGS: Dictionary = {
	"scarlet_flame_talisman": ["fire", "burn", "reaction"],
	"five_venom_satchel": ["poison", "reaction"],
	"mystic_ice_jade": ["frost", "freeze", "stun", "control"],
	"thunder_command": ["lightning", "shock", "chain"],
	"army_break_seal": ["physical", "armor_break"],
	"yin_yang_furnace": ["burn", "poison", "reaction"],
}

const ELEMENT_LABELS: Dictionary = {
	"fire": "[火] 火焰",
	"lightning": "[雷] 雷電",
	"frost": "[冰] 冰霜",
	"support": "[輔] 輔助",
	"strategy": "[策] 謀略",
	"control": "[控] 控場",
}

static func profile_tags(hero_id: String) -> Array[String]:
	var definition: Dictionary = HeroContentRegistry.get_hero(hero_id)
	var result: Array[String] = []
	var element: String = str(definition.get("element", "")).to_lower()
	if element != "":
		result.append(element)
	for key in ["status_tags", "synergy_tags"]:
		var values: Variant = definition.get(key, [])
		if values is Array:
			for value in values:
				var tag: String = str(value).to_lower()
				if tag != "" and not result.has(tag):
					result.append(tag)
	return result

static func current_build_tags(host: Object) -> Array[String]:
	var result: Array[String] = []
	if host == null:
		return result
	var relic_value: Variant = host.get("relics")
	if relic_value is Array:
		for relic_value_id in relic_value as Array:
			var relic_id: String = str(relic_value_id)
			for value in RELIC_TAGS.get(relic_id, []):
				var tag: String = str(value)
				if not result.has(tag):
					result.append(tag)
	for roster_key in ["active_heroes", "reserve_heroes"]:
		var roster_value: Variant = host.get(roster_key)
		if not roster_value is Array:
			continue
		for hero_value in roster_value as Array:
			for tag in profile_tags(str(hero_value)):
				if not result.has(tag):
					result.append(tag)
	return result

static func affinity_score(host: Object, hero_id: String) -> int:
	var candidate_tags: Array[String] = profile_tags(hero_id)
	if candidate_tags.is_empty():
		return 0
	var build_tags: Array[String] = current_build_tags(host)
	var matches: int = 0
	for tag in candidate_tags:
		if build_tags.has(tag):
			matches += 1
	return clampi(matches, 0, 2)

static func adjusted_weight(host: Object, hero_id: String, base_weight: int) -> int:
	if base_weight <= 0:
		return 0
	# 相性只提供輕量加成，歷史、陣營、分支與傳奇條件仍是主要來源。
	return clampi(base_weight + affinity_score(host, hero_id), 1, 12)

static func affinity_hint(host: Object, hero_id: String) -> String:
	var score: int = affinity_score(host, hero_id)
	if score >= 2:
		return "與目前戰術搭配良好"
	if score == 1:
		return "可補強目前戰術"
	return ""

static func element_label(hero_id: String) -> String:
	var definition: Dictionary = HeroContentRegistry.get_hero(hero_id)
	var element: String = str(definition.get("element", "")).to_lower()
	return str(ELEMENT_LABELS.get(element, "[將] 名將"))

static func synergy_description(hero_id: String) -> String:
	match HeroContentRegistry.canonical_id(hero_id):
		"zhouyu": return "強化燃燒與範圍反應"
		"zhangjiao": return "強化感電與雷電連鎖"
		"zhenji": return "強化緩速與冰封控場"
		"sunshangxiang": return "遠程連射可持續引燃敵群"
		"huatuo": return "提供治療、淨化與護盾"
		"zhugeliang": return "延長控制並支援元素反應"
		"diaochan": return "擅長魅惑、混亂與控場"
	return ""
