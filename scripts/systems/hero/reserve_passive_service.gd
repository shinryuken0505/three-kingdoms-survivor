class_name ReservePassiveService
extends RefCounted

## Alpha.19 後備名將被動統一計算。
## 回傳已套用疊加上限的聚合值，避免每位名將各自在戰鬥流程修改玩家。

const PASSIVES = {
	"liubei": {"heal_mult": 0.05},
	"guanyu": {"damage_mult": 0.035},
	"zhangfei": {"armor_add": 0.55},
	"zhaoyun": {"speed_mult": 0.035},
	"huangzhong": {"projectile_mult": 0.055},
	"huatuo": {"heal_mult": 0.09},
	"caocao": {"hero_cd_reduction": 0.055},
	"sunjian": {"damage_mult": 0.025, "speed_mult": 0.02},
	"taishici": {"projectile_mult": 0.04, "crit_add": 0.012},
	"zhangjiao": {"poison_mult": 0.07},
	"diaochan": {"control_resist_add": 0.06},
	"sunshangxiang": {"attack_speed_reduction": 0.035},
	"zhenji": {"armor_add": 0.35, "control_resist_add": 0.04},
	"lvlingqi": {"crit_add": 0.016},
	"wangyi": {"crit_add": 0.012, "speed_mult": 0.018},
	"caiwenji": {"heal_mult": 0.06, "control_resist_add": 0.03},
	"daqiao": {"armor_add": 0.45},
}

const CAPS = {
	"damage_mult": 0.12,
	"projectile_mult": 0.16,
	"poison_mult": 0.18,
	"heal_mult": 0.22,
	"speed_mult": 0.12,
	"crit_add": 0.06,
	"armor_add": 2.0,
	"hero_cd_reduction": 0.18,
	"attack_speed_reduction": 0.14,
	"control_resist_add": 0.18,
}


static func aggregate(reserve_heroes: Array) -> Dictionary:
	var result: Dictionary = {
		"damage_mult": 0.0,
		"projectile_mult": 0.0,
		"poison_mult": 0.0,
		"heal_mult": 0.0,
		"speed_mult": 0.0,
		"crit_add": 0.0,
		"armor_add": 0.0,
		"hero_cd_reduction": 0.0,
		"attack_speed_reduction": 0.0,
		"control_resist_add": 0.0,
		"sources": [],
	}
	var seen: Dictionary = {}
	for value in reserve_heroes:
		var hero_id: String = str(value)
		if seen.has(hero_id) or not PASSIVES.has(hero_id):
			continue
		seen[hero_id] = true
		var passive: Dictionary = PASSIVES.get(hero_id, {}) as Dictionary
		(result["sources"] as Array).append(hero_id)
		for key in passive.keys():
			result[key] = float(result.get(key, 0.0)) + float(passive.get(key, 0.0))
	for key in CAPS.keys():
		result[key] = minf(float(result.get(key, 0.0)), float(CAPS.get(key, 0.0)))
	return result
