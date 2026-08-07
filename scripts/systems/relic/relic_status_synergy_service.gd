class_name RelicStatusSynergyService
extends RefCounted

const RELIC_DEFINITIONS: Dictionary = {
	"scarlet_flame_talisman": {
		"name":"赤炎符", "rarity":"rare", "max_level":3,
		"effect_id":"burn_mastery", "tags":["火焰", "燃燒"],
		"desc":"燃燒更容易疊高；滿層時引爆敵人。",
		"event_hooks":["on_status_applied"]
	},
	"five_venom_satchel": {
		"name":"五毒囊", "rarity":"rare", "max_level":3,
		"effect_id":"poison_death_spread", "tags":["毒", "擊殺"],
		"desc":"中毒敵人死亡時向附近傳播中毒。",
		"event_hooks":["on_kill"]
	},
	"mystic_ice_jade": {
		"name":"玄冰玉", "rarity":"epic", "max_level":3,
		"effect_id":"frozen_vulnerability", "tags":["冰霜", "控場"],
		"desc":"冰封／暈眩中的敵人受到更多傷害。",
		"event_hooks":["modify_damage"]
	},
	"thunder_command": {
		"name":"雷公令", "rarity":"epic", "max_level":3,
		"effect_id":"shock_chain_plus", "tags":["雷電", "感電"],
		"desc":"感電可額外連鎖更多敵人。",
		"event_hooks":["on_status_applied"]
	},
	"army_break_seal": {
		"name":"破軍印", "rarity":"epic", "max_level":3,
		"effect_id":"armor_break_exploit", "tags":["破甲", "物理"],
		"desc":"攻擊破甲目標時進一步提高物理傷害。",
		"event_hooks":["modify_damage"]
	},
	"yin_yang_furnace": {
		"name":"陰陽爐", "rarity":"legendary", "max_level":3,
		"effect_id":"toxic_blaze_extension", "tags":["燃燒", "毒", "聯動"],
		"desc":"劇毒灼燒持續更久，並提高其傷害。",
		"event_hooks":["on_status_applied", "modify_damage"]
	},
}

static func install_definitions(definitions: Dictionary) -> Dictionary:
	var result: Dictionary = definitions.duplicate(true)
	for relic_id in RELIC_DEFINITIONS.keys():
		if not result.has(relic_id):
			result[relic_id] = (RELIC_DEFINITIONS[relic_id] as Dictionary).duplicate(true)
	return result

static func _has(host: Object, relic_id: String) -> bool:
	return host != null and host.has_method("has_relic") and bool(host.call("has_relic", relic_id))

static func _level(host: Object, relic_id: String) -> int:
	if host != null and host.has_method("relic_level"):
		return max(1, int(host.call("relic_level", relic_id)))
	return 1

static func _status_map(entity: Dictionary) -> Dictionary:
	var value: Variant = entity.get("status_effects", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func on_enemy_status_applied(host: Object, index: int, effect_id: String) -> void:
	if host == null:
		return
	var enemies_value: Variant = host.get("enemies")
	if not enemies_value is Array:
		return
	var enemies: Array = enemies_value as Array
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = (enemies[index] as Dictionary).duplicate(true)
	var statuses: Dictionary = _status_map(enemy)
	var key: String = effect_id.to_lower()

	if key == "burn" and _has(host, "scarlet_flame_talisman") and statuses.has("burn"):
		var burn: Dictionary = (statuses["burn"] as Dictionary).duplicate(true)
		var lv: int = _level(host, "scarlet_flame_talisman")
		burn["stacks"] = min(5, int(burn.get("stacks", 1)) + 1)
		burn["potency"] = min(7.0, float(burn.get("potency", 0.0)) * (1.0 + 0.10 * lv))
		statuses["burn"] = burn
		if int(burn.get("stacks", 1)) >= 5 and float(enemy.get("alpha55_flame_burst_cd", 0.0)) <= 0.0:
			enemy["alpha55_flame_burst_cd"] = 1.2
			enemy["alpha55_flame_burst_pending"] = 18.0 + 6.0 * lv
			burn["stacks"] = 2
			statuses["burn"] = burn

	if statuses.has("toxic_blaze") and _has(host, "yin_yang_furnace"):
		var toxic: Dictionary = (statuses["toxic_blaze"] as Dictionary).duplicate(true)
		var furnace_lv: int = _level(host, "yin_yang_furnace")
		toxic["duration"] = float(toxic.get("duration", 0.0)) * (1.18 + 0.06 * furnace_lv)
		toxic["potency"] = float(toxic.get("potency", 0.0)) * (1.08 + 0.04 * furnace_lv)
		statuses["toxic_blaze"] = toxic

	enemy["status_effects"] = statuses
	enemies[index] = enemy
	host.set("enemies", enemies)

static func on_boss_status_applied(host: Object, effect_id: String) -> void:
	if host == null:
		return
	var boss_value: Variant = host.get("boss")
	if not boss_value is Dictionary or (boss_value as Dictionary).is_empty():
		return
	var boss: Dictionary = (boss_value as Dictionary).duplicate(true)
	var statuses: Dictionary = _status_map(boss)
	if statuses.has("toxic_blaze") and _has(host, "yin_yang_furnace"):
		var toxic: Dictionary = (statuses["toxic_blaze"] as Dictionary).duplicate(true)
		var lv: int = _level(host, "yin_yang_furnace")
		toxic["duration"] = float(toxic.get("duration", 0.0)) * (1.10 + 0.04 * lv)
		toxic["potency"] = float(toxic.get("potency", 0.0)) * (1.05 + 0.03 * lv)
		statuses["toxic_blaze"] = toxic
	boss["status_effects"] = statuses
	host.set("boss", boss)

static func tick_enemy(host: Object, index: int, delta: float) -> int:
	if host == null:
		return index
	var enemies_value: Variant = host.get("enemies")
	if not enemies_value is Array:
		return index
	var enemies: Array = enemies_value as Array
	if index < 0 or index >= enemies.size():
		return -1
	var enemy: Dictionary = (enemies[index] as Dictionary).duplicate(true)
	var burst_cd: float = max(0.0, float(enemy.get("alpha55_flame_burst_cd", 0.0)) - delta)
	enemy["alpha55_flame_burst_cd"] = burst_cd
	var burst_damage: float = float(enemy.get("alpha55_flame_burst_pending", 0.0))
	enemy["alpha55_flame_burst_pending"] = 0.0
	enemies[index] = enemy
	host.set("enemies", enemies)
	if burst_damage > 0.0 and host.has_method("damage_enemy"):
		return int(host.call("damage_enemy", index, burst_damage, "scarlet_flame_burst", false))
	return index

static func on_enemy_killed(host: Object, enemy: Dictionary) -> void:
	if host == null or not _has(host, "five_venom_satchel"):
		return
	var statuses: Dictionary = _status_map(enemy)
	var poison: Dictionary = statuses.get("poison", {}) as Dictionary
	if poison.is_empty() and float(enemy.get("poison", 0.0)) <= 0.0:
		return
	if not host.has_method("spread_poison"):
		return
	var lv: int = _level(host, "five_venom_satchel")
	var radius: float = 105.0 + 20.0 * lv
	var power: float = 0.8 + 0.25 * lv
	host.call("spread_poison", enemy.get("pos", Vector2.ZERO), radius, power)
	if host.has_method("trigger_relic"):
		host.call("trigger_relic", "five_venom_satchel", "五毒傳染")

static func damage_multiplier(host: Object, entity: Dictionary, source: String) -> float:
	if host == null:
		return 1.0
	var result: float = 1.0
	var statuses: Dictionary = _status_map(entity)
	if _has(host, "mystic_ice_jade") and statuses.has("stun"):
		var stun: Dictionary = statuses["stun"] as Dictionary
		if float(stun.get("duration", 0.0)) > 0.0:
			result *= 1.08 + 0.04 * _level(host, "mystic_ice_jade")
	if _has(host, "army_break_seal") and statuses.has("armor_break"):
		var armor_break: Dictionary = statuses["armor_break"] as Dictionary
		if float(armor_break.get("duration", 0.0)) > 0.0 and _is_physical(source):
			result *= 1.06 + 0.035 * _level(host, "army_break_seal")
	if _has(host, "yin_yang_furnace") and source == "toxic_blaze":
		result *= 1.10 + 0.05 * _level(host, "yin_yang_furnace")
	return result

static func shock_chain_bonus(host: Object) -> int:
	if not _has(host, "thunder_command"):
		return 0
	return min(2, _level(host, "thunder_command"))

static func apply_named_hero_status(host: Object, target_kind: String, index: int, source: String) -> void:
	if host == null:
		return
	var key: String = source.to_lower()
	if target_kind == "enemy":
		match key:
			"zhangjiao":
				if host.has_method("apply_enemy_status"): host.call("apply_enemy_status", index, "shock", 2.5, 0.22, 1)
			"zhenji":
				if host.has_method("apply_enemy_status"): host.call("apply_enemy_status", index, "slow", 2.6, 0.28, 1)
			"sunshangxiang":
				if host.has_method("apply_enemy_status"): host.call("apply_enemy_status", index, "burn", 3.2, 0.9, 1)
	elif target_kind == "boss":
		match key:
			"zhangjiao":
				if host.has_method("apply_boss_status"): host.call("apply_boss_status", "shock", 2.0, 0.16, 1)
			"zhenji":
				if host.has_method("apply_boss_status"): host.call("apply_boss_status", "slow", 2.2, 0.20, 1)
			"sunshangxiang":
				if host.has_method("apply_boss_status"): host.call("apply_boss_status", "burn", 2.8, 0.65, 1)

static func _is_physical(source: String) -> bool:
	return source.to_lower() in ["slash", "blade_wave", "return_blade", "arrow", "needle", "guanyu", "zhangfei", "zhaoyun", "sunjian", "lvlingqi", "taishici", "sunshangxiang", "huangzhong", "lvbu", "melee_arc", "ranged_arrow"]

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for relic_id in RELIC_DEFINITIONS.keys():
		var definition: Dictionary = RELIC_DEFINITIONS[relic_id] as Dictionary
		for field in ["name", "rarity", "max_level", "effect_id", "desc"]:
			if not definition.has(field) or str(definition.get(field, "")) == "":
				errors.append("Alpha55 relic missing %s: %s" % [field, relic_id])
	return errors
