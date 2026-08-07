class_name PlayerUpgradeService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")

const SIGNATURE_UPGRADES: Dictionary = {
	"sig_blade_wave": {
		"id":"sig_blade_wave", "name":"劍氣熟練", "desc":"縮短劍氣觸發節奏並提高劍氣傷害與穿透。",
		"max":3, "category":"melee", "archetype":"swordsman", "weight":1.62
	},
	"sig_wide_arc": {
		"id":"sig_wide_arc", "name":"橫掃千軍", "desc":"擴大刀客斬擊半徑與扇形角度。",
		"max":3, "category":"melee", "archetype":"swordsman", "weight":1.50
	},
	"sig_blade_guard": {
		"id":"sig_blade_guard", "name":"刃守精進", "desc":"強化刃守減傷，近身受擊時效果更明顯。",
		"max":3, "category":"defense", "archetype":"swordsman", "weight":1.42
	},
	"sig_eagle_eye": {
		"id":"sig_eagle_eye", "name":"鷹眼專注", "desc":"提高遠距離射擊的最高增傷。",
		"max":3, "category":"ranged", "archetype":"archer", "weight":1.62
	},
	"sig_split_arrow": {
		"id":"sig_split_arrow", "name":"分裂箭", "desc":"普通射擊追加箭矢，形成更完整的遠程扇面。",
		"max":2, "category":"ranged", "archetype":"archer", "weight":1.50
	},
	"sig_piercing_focus": {
		"id":"sig_piercing_focus", "name":"破甲貫穿", "desc":"提高箭矢穿透層數，強化直線清怪能力。",
		"max":3, "category":"ranged", "archetype":"archer", "weight":1.46
	},
	"sig_orb_burst": {
		"id":"sig_orb_burst", "name":"術法爆裂", "desc":"提高術法球爆炸半徑與爆發傷害。",
		"max":3, "category":"strategy", "archetype":"strategist", "weight":1.62
	},
	"sig_arcane_resonance": {
		"id":"sig_arcane_resonance", "name":"術式共鳴", "desc":"強化二次脈衝；高階時提早啟動第二段爆發。",
		"max":3, "category":"strategy", "archetype":"strategist", "weight":1.50
	},
	"sig_frost_seal": {
		"id":"sig_frost_seal", "name":"寒印", "desc":"延長術法爆裂造成的緩速時間。",
		"max":3, "category":"strategy", "archetype":"strategist", "weight":1.42
	},
}

const PASSIVE_NAMES: Dictionary = {
	"swordsman":"刃守｜近身承傷降低",
	"archer":"鷹眼｜距離越遠傷害越高",
	"strategist":"法脈｜術法球命中觸發範圍爆裂",
}

static func install_signature_definitions(base_defs: Dictionary) -> Dictionary:
	var result: Dictionary = base_defs.duplicate(true)
	for sid_value in SIGNATURE_UPGRADES.keys():
		var sid: String = str(sid_value)
		result[sid] = (SIGNATURE_UPGRADES[sid] as Dictionary).duplicate(true)
	return result

static func is_signature_skill(skill_id: String) -> bool:
	return SIGNATURE_UPGRADES.has(skill_id)

static func signature_ids_for(archetype_id: String) -> Array[String]:
	var result: Array[String] = []
	for sid_value in SIGNATURE_UPGRADES.keys():
		var sid: String = str(sid_value)
		if str((SIGNATURE_UPGRADES[sid] as Dictionary).get("archetype", "")) == archetype_id:
			result.append(sid)
	return result

static func passive_name(archetype_id: String) -> String:
	return str(PASSIVE_NAMES.get(archetype_id, "專屬能力"))

static func signature_preview(archetype_id: String) -> String:
	var names: Array[String] = []
	for sid in signature_ids_for(archetype_id):
		names.append(str((SIGNATURE_UPGRADES[sid] as Dictionary).get("name", sid)))
	return "、".join(names)

static func signature_summary(archetype_id: String, levels: Dictionary) -> String:
	var parts: Array[String] = []
	for sid in signature_ids_for(archetype_id):
		var lv: int = int(levels.get(sid, 0))
		if lv > 0:
			parts.append("%s Lv.%d" % [str((SIGNATURE_UPGRADES[sid] as Dictionary).get("name", sid)), lv])
	return "尚未取得專屬進化" if parts.is_empty() else "｜".join(parts)

static func skill_category(skill_id: String, definition: Dictionary) -> String:
	var explicit: String = str(definition.get("category", definition.get("group", ""))).to_lower()
	if explicit in ["melee", "defense", "ranged", "strategy"]:
		return explicit
	var sid: String = skill_id.to_lower()
	if sid.contains("slash") or sid.contains("blade") or sid.contains("melee") or sid.contains("spin"):
		return "melee"
	if sid.contains("shield") or sid.contains("armor") or sid.contains("hp") or sid.contains("guard") or sid.contains("heal"):
		return "defense"
	if sid.contains("arrow") or sid.contains("bow") or sid.contains("shot") or sid.contains("pierce"):
		return "ranged"
	if sid.contains("fire") or sid.contains("poison") or sid.contains("orb") or sid.contains("cooldown") or sid.contains("zone"):
		return "strategy"
	return "strategy"

static func available_for_archetype(archetype_id: String, skill_id: String) -> bool:
	if not is_signature_skill(skill_id):
		return true
	return str((SIGNATURE_UPGRADES[skill_id] as Dictionary).get("archetype", "")) == archetype_id

static func weight_for(archetype_id: String, skill_id: String, definition: Dictionary) -> float:
	if is_signature_skill(skill_id):
		if not available_for_archetype(archetype_id, skill_id):
			return 0.0
		return max(0.10, float((SIGNATURE_UPGRADES[skill_id] as Dictionary).get("weight", 1.45)))
	var archetype: Dictionary = PlayerArchetypeRegistry.get_definition(archetype_id)
	var weights: Dictionary = archetype.get("upgrade_weights", {}) as Dictionary
	return max(0.10, float(weights.get(skill_category(skill_id, definition), 1.0)))

static func weighted_pool(pool: Array, skill_defs: Dictionary, archetype_id: String, rng: RandomNumberGenerator) -> Array:
	var remaining: Array = []
	for value in pool:
		var sid: String = str(value)
		if available_for_archetype(archetype_id, sid):
			remaining.append(sid)
	if remaining.size() <= 1:
		return remaining.duplicate()
	var result: Array = []
	while not remaining.is_empty():
		var total: float = 0.0
		for value in remaining:
			var sid: String = str(value)
			total += weight_for(archetype_id, sid, skill_defs.get(sid, {}) as Dictionary)
		var roll: float = rng.randf() * max(total, 0.001)
		var chosen_index: int = 0
		for index in range(remaining.size()):
			var sid: String = str(remaining[index])
			roll -= weight_for(archetype_id, sid, skill_defs.get(sid, {}) as Dictionary)
			if roll <= 0.0:
				chosen_index = index
				break
		result.append(remaining[chosen_index])
		remaining.remove_at(chosen_index)
	return result

static func debug_weights(archetype_id: String, skill_defs: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for sid_value in skill_defs.keys():
		var sid: String = str(sid_value)
		if available_for_archetype(archetype_id, sid):
			result[sid] = weight_for(archetype_id, sid, skill_defs[sid] as Dictionary)
	return result
