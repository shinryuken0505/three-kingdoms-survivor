class_name Alpha21CombatIdentity
extends RefCounted

const PROFILES := {
	"swordsman": {
		"title": "破陣刀客",
		"damage_mult": 1.08,
		"close_range_mult": 1.18,
		"dash_bonus": 0.20,
		"crit_bonus": 0.02,
		"description": "近身連斬、閃避後強化下一擊。",
	},
	"archer": {
		"title": "百步弓手",
		"damage_mult": 1.00,
		"far_range_mult": 1.22,
		"dash_bonus": 0.08,
		"crit_bonus": 0.08,
		"description": "距離越遠越致命，擅長穿透與暴擊。",
	},
	"poisoner": {
		"title": "百蠱毒師",
		"damage_mult": 0.94,
		"dot_mult": 1.32,
		"dash_bonus": 0.10,
		"crit_bonus": 0.01,
		"description": "以中毒、毒爆與區域控制累積優勢。",
	},
	"ring_blade": {
		"title": "迴刃女俠",
		"damage_mult": 1.02,
		"return_hit_mult": 1.24,
		"dash_bonus": 0.16,
		"crit_bonus": 0.04,
		"description": "環刃往返皆可造成傷害，節奏快速。",
	},
}

static func profile(identity_id: String) -> Dictionary:
	return PROFILES.get(identity_id, PROFILES["swordsman"]).duplicate(true)


static func base_damage_multiplier(identity_id: String) -> float:
	return float(profile(identity_id).get("damage_mult", 1.0))


static func contextual_damage_multiplier(identity_id: String, distance: float, is_dot: bool = false, is_return_hit: bool = false) -> float:
	var data: Dictionary = profile(identity_id)
	var result: float = float(data.get("damage_mult", 1.0))
	match identity_id:
		"swordsman":
			if distance <= 145.0:
				result *= float(data.get("close_range_mult", 1.0))
		"archer":
			if distance >= 360.0:
				result *= float(data.get("far_range_mult", 1.0))
		"poisoner":
			if is_dot:
				result *= float(data.get("dot_mult", 1.0))
		"ring_blade":
			if is_return_hit:
				result *= float(data.get("return_hit_mult", 1.0))
	return clamp(result, 0.75, 1.65)


static func dash_cooldown_multiplier(identity_id: String) -> float:
	var bonus: float = float(profile(identity_id).get("dash_bonus", 0.0))
	return clamp(1.0 - bonus, 0.65, 1.0)


static func crit_bonus(identity_id: String) -> float:
	return float(profile(identity_id).get("crit_bonus", 0.0))


static func summary(identity_id: String) -> String:
	var data: Dictionary = profile(identity_id)
	return "%s｜%s" % [str(data.get("title", "亂世武者")), str(data.get("description", ""))]
