class_name PlayerArchetypeRegistry
extends RefCounted

const LEGACY_ALIASES: Dictionary = {
	"hunter":"archer",
	"poisoner":"strategist",
}

const DEFINITIONS: Dictionary = {
	"swordsman": {
		"id":"swordsman", "name":"刀客", "title":"近戰均衡",
		"description":"貼身斬擊、穩定生存，適合熟悉戰場節奏。",
		"legacy_base":"swordsman",
		"weapon":"blade", "attack_mode":"melee_arc",
		"base_stats":{"max_hp":118.0,"speed":205.0,"damage_mult":1.05,"attack_speed_mult":1.0,"dash_cd_mult":1.0},
		"starting_skills":["slash"], "passive":"blade_guard",
		"upgrade_weights":{"melee":1.35,"defense":1.15,"ranged":0.72,"strategy":0.72},
		"portrait":"res://assets/portraits/player_swordsman.png",
		"sprite":"res://assets/player/swordsman.png"
	},
	"archer": {
		"id":"archer", "name":"弓手", "title":"遠程機動",
		"description":"保持距離連續射擊，以穿透與機動清理敵群。",
		"legacy_base":"hunter",
		"weapon":"bow", "attack_mode":"ranged_arrow",
		"base_stats":{"max_hp":92.0,"speed":226.0,"damage_mult":0.96,"attack_speed_mult":1.16,"dash_cd_mult":0.92},
		"starting_skills":["arrow"], "passive":"eagle_eye",
		"upgrade_weights":{"melee":0.58,"defense":0.92,"ranged":1.48,"strategy":0.88},
		"portrait":"res://assets/portraits/player_archer.png",
		"sprite":"res://assets/player/archer.png"
	},
	"strategist": {
		"id":"strategist", "name":"術士", "title":"範圍控場",
		"description":"以術法、爆裂與控制掌握戰場，成形後爆發強。",
		"legacy_base":"poisoner",
		"weapon":"talisman", "attack_mode":"strategy_orb",
		"base_stats":{"max_hp":86.0,"speed":198.0,"damage_mult":1.02,"attack_speed_mult":0.92,"dash_cd_mult":1.05},
		"starting_skills":["fire_orb"], "passive":"arcane_flow",
		"upgrade_weights":{"melee":0.52,"defense":0.90,"ranged":0.92,"strategy":1.55},
		"portrait":"res://assets/portraits/player_strategist.png",
		"sprite":"res://assets/player/strategist.png"
	},
	"heroine": {
		"id":"heroine", "name":"巾幗遊俠", "title":"紅袖環刃",
		"description":"以雙環連射穿梭敵陣，維持距離並快速收割。",
		"legacy_base":"heroine",
		"weapon":"rings", "attack_mode":"legacy_rings",
		"base_stats":{"max_hp":104.0,"speed":228.0,"damage_mult":1.0,"attack_speed_mult":1.10,"dash_cd_mult":0.90},
		"starting_skills":["rings"], "passive":"agile_hunt",
		"upgrade_weights":{"melee":0.65,"defense":0.92,"ranged":1.42,"strategy":0.82},
		"portrait":"res://assets/portraits/heroine_default.png",
		"sprite":"res://assets/sprites/heroine_default.png"
	}
}

static func canonical_id(archetype_id: String) -> String:
	var raw: String = archetype_id.to_lower().strip_edges()
	return str(LEGACY_ALIASES.get(raw, raw))

static func all() -> Dictionary:
	return DEFINITIONS.duplicate(true)

static func get_definition(archetype_id: String) -> Dictionary:
	var canonical: String = canonical_id(archetype_id)
	return (DEFINITIONS.get(canonical, DEFINITIONS["swordsman"]) as Dictionary).duplicate(true)

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var required: Array[String] = ["id","name","base_stats","weapon","attack_mode","starting_skills","passive","portrait","sprite","legacy_base"]
	for key in DEFINITIONS.keys():
		var definition: Dictionary = DEFINITIONS[key] as Dictionary
		for field in required:
			if not definition.has(field):
				errors.append("%s missing %s" % [key, field])
		if str(definition.get("id", "")) != str(key):
			errors.append("archetype id mismatch: %s" % key)
	return errors
