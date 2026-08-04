class_name IdentityCombatProfile
extends RefCounted

## Alpha.19 四位主角的實際戰鬥差異資料。
## 僅回傳倍率與門檻，不直接修改 main.gd 或存檔。

const PROFILES = {
	"blade": {
		"id": "swordsman",
		"damage_per_core": 0.025,
		"armor_per_core": 0.22,
		"crit_per_core": 0.004,
		"dash_damage_bonus": 0.18,
		"tags": ["melee", "counter", "survival"],
	},
	"bow": {
		"id": "hunter",
		"projectile_per_core": 0.035,
		"pierce_thresholds": [2, 5],
		"multishot_thresholds": [3, 6],
		"crit_per_core": 0.003,
		"tags": ["ranged", "projectile", "pierce"],
	},
	"poison": {
		"id": "poisoner",
		"poison_per_core": 0.055,
		"heal_per_core": 0.025,
		"spread_stack_threshold": 3,
		"spread_radius": 150.0,
		"spread_interval": 1.15,
		"tags": ["ranged", "poison", "recovery"],
	},
	"rings": {
		"id": "heroine",
		"damage_per_core": 0.018,
		"crit_per_core": 0.006,
		"speed_per_core": 0.012,
		"multishot_thresholds": [3, 7],
		"combo_window": 1.2,
		"tags": ["ranged", "returning", "mobility"],
	},
}


static func for_player(player: Dictionary) -> Dictionary:
	var weapon: String = str(player.get("weapon", ""))
	return (PROFILES.get(weapon, {}) as Dictionary).duplicate(true)


static func core_level(weapon: String, skill_levels: Dictionary) -> int:
	var ids: Array = []
	if weapon == "blade":
		ids = ["damage", "attack_speed", "crit", "armor", "dash"]
	elif weapon == "bow":
		ids = ["projectile", "pierce", "multishot", "crit", "attack_speed"]
	elif weapon == "poison":
		ids = ["poison", "attack_speed", "heal", "move_speed", "damage"]
	elif weapon == "rings":
		ids = ["multishot", "projectile", "crit", "dash", "attack_speed"]
	var total: int = 0
	for skill_id in ids:
		total += maxi(0, int(skill_levels.get(skill_id, 0)))
	return total


static func threshold_bonus(level: int, thresholds: Array) -> int:
	var bonus: int = 0
	for value in thresholds:
		if level >= int(value):
			bonus += 1
	return bonus
