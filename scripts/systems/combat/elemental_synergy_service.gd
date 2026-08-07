class_name ElementalSynergyService
extends RefCounted

const PHYSICAL_SOURCES: Array[String] = [
	"slash", "return_blade", "arrow", "needle", "guanyu", "zhangfei", "zhaoyun",
	"sunjian", "lvlingqi", "taishici", "sunshangxiang", "huangzhong", "lvbu",
	"melee_arc", "ranged_arrow"
]
const LIGHTNING_SOURCES: Array[String] = ["lightning", "zhangjiao", "thunder", "shock"]
const REACTION_NAMES: Dictionary = {
	"toxic_blaze":"劇毒灼燒",
	"frozen":"冰封",
	"shock_chain":"感電連鎖",
}

static func is_lightning_source(source: String) -> bool:
	return source.to_lower() in LIGHTNING_SOURCES

static func is_physical_source(source: String) -> bool:
	return source.to_lower() in PHYSICAL_SOURCES

static func _statuses(entity: Dictionary) -> Dictionary:
	var value: Variant = entity.get("status_effects", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func _reaction_timers(entity: Dictionary) -> Dictionary:
	var value: Variant = entity.get("status_reaction_timers", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func damage_multiplier(entity: Dictionary, source: String) -> float:
	if not is_physical_source(source):
		return 1.0
	var statuses: Dictionary = _statuses(entity)
	var armor_break: Dictionary = statuses.get("armor_break", {}) as Dictionary
	if armor_break.is_empty() or float(armor_break.get("duration", 0.0)) <= 0.0:
		return 1.0
	return 1.0 + clamp(float(armor_break.get("potency", 0.0)), 0.05, 0.45)

static func _ensure_status(statuses: Dictionary, effect_id: String, duration: float, potency: float, stacks: int = 1, tick: float = 0.0) -> void:
	var old: Dictionary = statuses.get(effect_id, {}) as Dictionary
	statuses[effect_id] = {
		"duration": max(duration, float(old.get("duration", 0.0))),
		"potency": max(potency, float(old.get("potency", 0.0))),
		"stacks": max(stacks, int(old.get("stacks", 1))),
		"tick": min(tick, float(old.get("tick", tick))) if tick > 0.0 and float(old.get("tick", 0.0)) > 0.0 else tick,
	}

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
	var statuses: Dictionary = _statuses(enemy)
	var key: String = effect_id.to_lower()

	# 冰霜：緩速重複施加三次後轉為短暫冰封，並清空累積值。
	if key == "slow":
		var frost_charge: int = int(enemy.get("frost_charge", 0)) + 1
		if frost_charge >= 3:
			var freeze_duration: float = 0.52 if bool(enemy.get("elite", false)) else 0.78
			_ensure_status(statuses, "stun", freeze_duration, 1.0)
			enemy["frost_charge"] = 0
			enemy["alpha54_reaction_notice"] = "冰封"
		else:
			enemy["frost_charge"] = frost_charge

	# 燃燒 + 中毒：建立劇毒灼燒，固定節奏追加混合 DOT。
	if statuses.has("burn") and statuses.has("poison"):
		var burn: Dictionary = statuses["burn"] as Dictionary
		var poison: Dictionary = statuses["poison"] as Dictionary
		var potency: float = 0.55 * float(burn.get("potency", 0.0)) + 0.45 * float(poison.get("potency", 0.0))
		_ensure_status(statuses, "toxic_blaze", min(float(burn.get("duration", 0.0)), float(poison.get("duration", 0.0))), potency, 1, 0.35)
		enemy["alpha54_reaction_notice"] = "劇毒灼燒"

	enemy["status_effects"] = statuses
	enemies[index] = enemy
	host.set("enemies", enemies)

	# 感電：只在施加時連鎖一次，避免 DOT 每幀遞迴。
	if key == "shock":
		_chain_enemy_shock(host, index)

static func _chain_enemy_shock(host: Object, source_index: int) -> void:
	var enemies_value: Variant = host.get("enemies")
	if not enemies_value is Array:
		return
	var enemies: Array = enemies_value as Array
	if source_index < 0 or source_index >= enemies.size():
		return
	var source_enemy: Dictionary = enemies[source_index] as Dictionary
	var source_pos: Vector2 = source_enemy.get("pos", Vector2.ZERO) as Vector2
	var candidates: Array[Dictionary] = []
	for index in range(enemies.size()):
		if index == source_index:
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		var pos: Vector2 = enemy.get("pos", Vector2.ZERO) as Vector2
		var distance: float = source_pos.distance_to(pos)
		if distance <= 190.0:
			candidates.append({"index":index, "distance":distance})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["distance"]) < float(b["distance"]))
	var hit_count: int = min(2, candidates.size())
	for i in range(hit_count - 1, -1, -1):
		var target_index: int = int(candidates[i].get("index", -1))
		if target_index < 0 or target_index >= (host.get("enemies") as Array).size():
			continue
		if host.has_method("damage_enemy"):
			host.call("damage_enemy", target_index, 8.0, "shock_chain", false)
	if hit_count > 0 and host.has_method("spawn_ring"):
		host.call("spawn_ring", source_pos, Color8(139, 202, 255), 92.0, 0.24)

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
	var statuses: Dictionary = _statuses(enemy)
	var timers: Dictionary = _reaction_timers(enemy)
	for timer_key in timers.keys():
		timers[timer_key] = max(0.0, float(timers[timer_key]) - delta)
	var toxic: Dictionary = statuses.get("toxic_blaze", {}) as Dictionary
	var pending_damage: float = 0.0
	if not toxic.is_empty() and float(toxic.get("duration", 0.0)) > 0.0:
		var left: float = max(0.0, float(toxic.get("duration", 0.0)) - delta)
		var tick_left: float = float(toxic.get("tick", 0.0)) - delta
		toxic["duration"] = left
		if tick_left <= 0.0:
			pending_damage = 4.0 + float(toxic.get("potency", 0.0)) * 2.2
			tick_left = 0.82
		toxic["tick"] = tick_left
		if left <= 0.0:
			statuses.erase("toxic_blaze")
		else:
			statuses["toxic_blaze"] = toxic
	enemy["status_effects"] = statuses
	enemy["status_reaction_timers"] = timers
	enemies[index] = enemy
	host.set("enemies", enemies)
	if pending_damage > 0.0 and host.has_method("damage_enemy"):
		return int(host.call("damage_enemy", index, pending_damage, "toxic_blaze", false))
	return index

static func on_boss_status_applied(host: Object, effect_id: String) -> void:
	if host == null:
		return
	var boss_value: Variant = host.get("boss")
	if not boss_value is Dictionary or (boss_value as Dictionary).is_empty():
		return
	var boss: Dictionary = (boss_value as Dictionary).duplicate(true)
	var statuses: Dictionary = _statuses(boss)
	if statuses.has("burn") and statuses.has("poison"):
		var burn: Dictionary = statuses["burn"] as Dictionary
		var poison: Dictionary = statuses["poison"] as Dictionary
		var potency: float = 0.55 * float(burn.get("potency", 0.0)) + 0.45 * float(poison.get("potency", 0.0))
		_ensure_status(statuses, "toxic_blaze", min(float(burn.get("duration", 0.0)), float(poison.get("duration", 0.0))), potency * 0.72, 1, 0.4)
	boss["status_effects"] = statuses
	host.set("boss", boss)
	if effect_id.to_lower() == "shock" and host.has_method("damage_boss"):
		host.call("damage_boss", 6.0, "shock_chain", false)

static func tick_boss(host: Object, delta: float) -> void:
	if host == null:
		return
	var boss_value: Variant = host.get("boss")
	if not boss_value is Dictionary or (boss_value as Dictionary).is_empty():
		return
	var boss: Dictionary = (boss_value as Dictionary).duplicate(true)
	var statuses: Dictionary = _statuses(boss)
	var toxic: Dictionary = statuses.get("toxic_blaze", {}) as Dictionary
	var damage: float = 0.0
	if not toxic.is_empty() and float(toxic.get("duration", 0.0)) > 0.0:
		var left: float = max(0.0, float(toxic.get("duration", 0.0)) - delta)
		var tick_left: float = float(toxic.get("tick", 0.0)) - delta
		toxic["duration"] = left
		if tick_left <= 0.0:
			damage = 3.2 + float(toxic.get("potency", 0.0)) * 1.65
			tick_left = 0.92
		toxic["tick"] = tick_left
		if left <= 0.0:
			statuses.erase("toxic_blaze")
		else:
			statuses["toxic_blaze"] = toxic
	boss["status_effects"] = statuses
	host.set("boss", boss)
	if damage > 0.0 and host.has_method("damage_boss"):
		host.call("damage_boss", damage, "toxic_blaze", false)

static func boss_resistance_text(boss_id: String) -> String:
	match boss_id.to_lower():
		"lvbu": return "控制抗性：極高　持續傷害抗性：中"
		"zhangliang", "zhangjiao": return "中毒抗性：高　控制抗性：中"
		"yuanshao": return "破甲抗性：高　元素抗性：中"
		_: return "控制抗性：高　持續傷害抗性：中"

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for source in ["slash", "arrow"]:
		if not is_physical_source(source):
			errors.append("physical source missing: %s" % source)
	if not is_lightning_source("lightning"):
		errors.append("lightning source missing")
	return errors
