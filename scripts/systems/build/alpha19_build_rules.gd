class_name Alpha19BuildRules
extends RefCounted

const ARCHETYPES := {
	"melee": {"name":"無雙近戰", "skills":["damage","attack_speed","armor","dash","range"], "weapons":["blade"]},
	"ranged": {"name":"百步弓道", "skills":["projectile","multishot","pierce","crit","attack_speed"], "weapons":["bow","rings"]},
	"poison": {"name":"百毒奇術", "skills":["poison","projectile","multishot","damage"], "weapons":["poison"]},
	"fire": {"name":"烈焰軍略", "skills":["fire","element","zone","hero_cd"], "weapons":[]},
	"summon": {"name":"名將號令", "skills":["hero_cd","hero_damage","bond","summon"], "weapons":[]},
}

static func evaluate(identity_id: String, weapon: String, skill_levels: Dictionary, relics: Array) -> Dictionary:
	var scores: Dictionary = {"melee":0, "ranged":0, "poison":0, "fire":0, "summon":0}
	for archetype in ARCHETYPES:
		var data: Dictionary = ARCHETYPES[archetype]
		if weapon in data.get("weapons", []):
			scores[archetype] = int(scores[archetype]) + 3
		for skill_id in data.get("skills", []):
			scores[archetype] = int(scores[archetype]) + int(skill_levels.get(skill_id, 0))
	if identity_id == "hunter": scores["ranged"] += 2
	elif identity_id == "poisoner": scores["poison"] += 2
	elif identity_id == "swordsman": scores["melee"] += 2
	elif identity_id == "heroine": scores["summon"] += 1
	for relic_id in relics:
		var rid := str(relic_id)
		if rid in ["crossbow", "arrowhead", "redhare"]: scores["ranged"] += 1
		elif rid in ["yellowwater", "poisonmanual"]: scores["poison"] += 1
		elif rid in ["formationseal", "artofwar", "moonbell"]: scores["summon"] += 1
	var primary := "melee"
	for key in scores:
		if int(scores[key]) > int(scores[primary]): primary = key
	var score := int(scores[primary])
	var stage := clampi(1 + score / 4, 1, 5)
	return {
		"id": primary,
		"name": str(ARCHETYPES[primary]["name"]),
		"score": score,
		"stage": stage,
		"stage_name": ["","成形","精進","共鳴","宗師","大成"][stage],
		"damage_mult": 1.0 + float(stage - 1) * 0.065,
		"hero_cd_mult": 1.0 - (0.035 * float(stage - 1) if primary == "summon" else 0.0),
	}

static func skill_allowed(weapon: String, skill_id: String, skill_levels: Dictionary) -> bool:
	if skill_id == "" or int(skill_levels.get(skill_id, 0)) > 0:
		return true
	if weapon == "blade" and skill_id in ["poison", "multishot", "pierce"]:
		return false
	if weapon == "poison" and skill_id in ["range", "armor"]:
		return false
	if weapon in ["bow", "rings"] and skill_id == "poison":
		return false
	return true
