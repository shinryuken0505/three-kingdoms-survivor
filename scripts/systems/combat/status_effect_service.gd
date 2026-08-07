class_name StatusEffectService
extends RefCounted

const EFFECT_ORDER: Array[String] = ["burn", "poison", "slow", "stun", "confuse", "charm", "armor_break"]
const DISPLAY_NAMES: Dictionary = {
	"burn":"燃燒",
	"poison":"中毒",
	"slow":"緩速",
	"stun":"暈眩",
	"confuse":"混亂",
	"charm":"魅惑",
	"armor_break":"破甲",
}
const EFFECT_COLORS: Dictionary = {
	"burn": Color8(242, 126, 62),
	"poison": Color8(116, 205, 103),
	"slow": Color8(111, 190, 235),
	"stun": Color8(244, 214, 94),
	"confuse": Color8(188, 125, 232),
	"charm": Color8(235, 128, 180),
	"armor_break": Color8(222, 163, 91),
}

static func canonical_effect(effect_id: String) -> String:
	var key: String = effect_id.strip_edges().to_lower().replace("-", "_")
	match key:
		"frost", "freeze", "chill":
			return "slow"
		"bind", "root":
			return "stun"
		"confusion":
			return "confuse"
		"armorbreak", "break_armor", "def_down":
			return "armor_break"
	return key

static func display_name(effect_id: String) -> String:
	var key: String = canonical_effect(effect_id)
	return str(DISPLAY_NAMES.get(key, key))

static func effect_color(effect_id: String) -> Color:
	var key: String = canonical_effect(effect_id)
	return EFFECT_COLORS.get(key, Color8(205, 205, 205)) as Color

static func _status_map(entity: Dictionary) -> Dictionary:
	var value: Variant = entity.get("status_effects", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func _write_status(statuses: Dictionary, effect_id: String, duration: float, potency: float, stacks: int, tick: float = 0.0) -> void:
	statuses[effect_id] = {
		"duration": max(0.0, duration),
		"potency": max(0.0, potency),
		"stacks": max(1, stacks),
		"tick": max(0.0, tick),
	}

static func _hydrate_legacy(entity: Dictionary, statuses: Dictionary) -> void:
	for effect_id in ["slow", "stun", "charm", "armor_break"]:
		var duration: float = max(0.0, float(entity.get(effect_id, 0.0)))
		if duration <= 0.0:
			continue
		var old: Dictionary = statuses.get(effect_id, {}) as Dictionary
		_write_status(statuses, effect_id, max(duration, float(old.get("duration", 0.0))), max(1.0, float(old.get("potency", 1.0))), int(old.get("stacks", 1)))
	var confuse_duration: float = max(0.0, float(entity.get("confuse", 0.0)))
	if confuse_duration > 0.0:
		var old_confuse: Dictionary = statuses.get("confuse", {}) as Dictionary
		_write_status(statuses, "confuse", max(confuse_duration, float(old_confuse.get("duration", 0.0))), max(1.0, float(old_confuse.get("potency", 1.0))), int(old_confuse.get("stacks", 1)))
	var poison_time: float = max(0.0, float(entity.get("poison_time", 0.0)))
	var poison_power: float = max(0.0, float(entity.get("poison", 0.0)))
	if poison_time > 0.0 and poison_power > 0.0:
		var old_poison: Dictionary = statuses.get("poison", {}) as Dictionary
		_write_status(
			statuses,
			"poison",
			max(poison_time, float(old_poison.get("duration", 0.0))),
			max(poison_power, float(old_poison.get("potency", 0.0))),
			max(int(ceil(poison_power)), int(old_poison.get("stacks", 1))),
			min(float(entity.get("poison_tick", 0.2)), float(old_poison.get("tick", 0.2)))
		)
	var burn_time: float = max(0.0, float(entity.get("burn_time", 0.0)))
	var burn_power: float = max(0.0, float(entity.get("burn", 0.0)))
	if burn_time > 0.0 and burn_power > 0.0:
		var old_burn: Dictionary = statuses.get("burn", {}) as Dictionary
		_write_status(
			statuses,
			"burn",
			max(burn_time, float(old_burn.get("duration", 0.0))),
			max(burn_power, float(old_burn.get("potency", 0.0))),
			max(int(entity.get("burn_stacks", 1)), int(old_burn.get("stacks", 1))),
			min(float(entity.get("burn_tick", 0.3)), float(old_burn.get("tick", 0.3)))
		)

static func _sync_legacy(entity: Dictionary, statuses: Dictionary) -> void:
	for effect_id in ["slow", "stun", "charm", "armor_break", "confuse"]:
		var status: Dictionary = statuses.get(effect_id, {}) as Dictionary
		entity[effect_id] = max(0.0, float(status.get("duration", 0.0)))
	if statuses.has("confuse"):
		entity["charm"] = max(float(entity.get("charm", 0.0)), float((statuses["confuse"] as Dictionary).get("duration", 0.0)))
	var poison: Dictionary = statuses.get("poison", {}) as Dictionary
	entity["poison"] = max(0.0, float(poison.get("potency", 0.0)))
	entity["poison_time"] = max(0.0, float(poison.get("duration", 0.0)))
	entity["poison_tick"] = max(0.0, float(poison.get("tick", 0.0)))
	var burn: Dictionary = statuses.get("burn", {}) as Dictionary
	entity["burn"] = max(0.0, float(burn.get("potency", 0.0)))
	entity["burn_time"] = max(0.0, float(burn.get("duration", 0.0)))
	entity["burn_tick"] = max(0.0, float(burn.get("tick", 0.0)))
	entity["burn_stacks"] = max(0, int(burn.get("stacks", 0)))
	entity["status_effects"] = statuses

static func _enemy_duration_multiplier(enemy: Dictionary, effect_id: String) -> float:
	if not bool(enemy.get("elite", false)):
		return 1.0
	match effect_id:
		"stun", "confuse", "charm":
			return 0.72
		"slow":
			return 0.82
	return 1.0

static func apply_enemy(host: Object, index: int, effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:
	if host == null:
		return false
	var enemies_value: Variant = host.get("enemies")
	if not enemies_value is Array:
		return false
	var enemies: Array = enemies_value as Array
	if index < 0 or index >= enemies.size():
		return false
	var enemy: Dictionary = (enemies[index] as Dictionary).duplicate(true)
	var key: String = canonical_effect(effect_id)
	if not DISPLAY_NAMES.has(key):
		return false
	var statuses: Dictionary = _status_map(enemy)
	_hydrate_legacy(enemy, statuses)
	var current: Dictionary = statuses.get(key, {}) as Dictionary
	var adjusted_duration: float = max(0.0, duration) * _enemy_duration_multiplier(enemy, key)
	var new_duration: float = max(float(current.get("duration", 0.0)), adjusted_duration)
	var new_potency: float = max(float(current.get("potency", 0.0)), potency)
	var new_stacks: int = max(1, int(current.get("stacks", 1)))
	var tick: float = float(current.get("tick", 0.0))
	match key:
		"poison":
			new_stacks = min(8, max(0, int(current.get("stacks", 0))) + max(1, stacks))
			new_potency = min(8.0, max(0.0, float(current.get("potency", 0.0))) + max(0.15, potency))
			tick = min(0.2, tick if tick > 0.0 else 0.2)
		"burn":
			new_stacks = min(5, max(0, int(current.get("stacks", 0))) + max(1, stacks))
			new_potency = min(6.0, max(potency, float(current.get("potency", 0.0)) + potency * 0.35))
			tick = min(0.3, tick if tick > 0.0 else 0.3)
		"slow":
			new_potency = clamp(max(float(current.get("potency", 0.0)), potency), 0.12, 0.55)
		"armor_break":
			new_potency = clamp(max(float(current.get("potency", 0.0)), potency), 0.08, 0.45)
	_write_status(statuses, key, new_duration, new_potency, new_stacks, tick)
	_sync_legacy(enemy, statuses)
	enemies[index] = enemy
	host.set("enemies", enemies)
	return true

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
	var statuses: Dictionary = _status_map(enemy)
	_hydrate_legacy(enemy, statuses)
	var pending_hits: Array[Dictionary] = []
	for effect_value in statuses.keys():
		var effect_id: String = str(effect_value)
		var status: Dictionary = statuses[effect_id] as Dictionary
		var remaining: float = max(0.0, float(status.get("duration", 0.0)) - delta)
		status["duration"] = remaining
		if effect_id in ["poison", "burn"] and remaining > 0.0:
			var tick_left: float = float(status.get("tick", 0.0)) - delta
			if tick_left <= 0.0:
				var stacks: int = max(1, int(status.get("stacks", 1)))
				var potency: float = max(0.0, float(status.get("potency", 0.0)))
				if effect_id == "poison":
					var player_value: Variant = host.get("player")
					var poison_mult: float = 1.0
					if player_value is Dictionary:
						poison_mult = max(0.1, float((player_value as Dictionary).get("poison_power", 1.0)))
					pending_hits.append({"damage":(2.8 + potency * 1.35) * poison_mult, "source":"poison"})
					tick_left = 0.65
				else:
					pending_hits.append({"damage":3.4 + potency * 1.75 + float(stacks - 1) * 1.15, "source":"burn"})
					tick_left = 0.55
			status["tick"] = tick_left
		if remaining <= 0.0:
			statuses.erase(effect_id)
		else:
			statuses[effect_id] = status
	_sync_legacy(enemy, statuses)
	enemies[index] = enemy
	host.set("enemies", enemies)
	var live_index: int = index
	for hit in pending_hits:
		if not host.has_method("damage_enemy"):
			break
		live_index = int(host.call("damage_enemy", live_index, float(hit.get("damage", 0.0)), str(hit.get("source", "status")), false))
		if live_index < 0:
			return -1
	return live_index

static func boss_resistance(boss_id: String, effect_id: String) -> float:
	var key: String = canonical_effect(effect_id)
	var base: Dictionary = {
		"burn":0.78,
		"poison":0.62,
		"slow":0.58,
		"stun":0.28,
		"confuse":0.20,
		"charm":0.16,
		"armor_break":0.60,
	}
	var value: float = float(base.get(key, 1.0))
	match boss_id.to_lower():
		"lvbu":
			if key in ["stun", "confuse", "charm"]: value *= 0.45
			if key == "slow": value *= 0.72
		"zhangliang", "zhangjiao":
			if key == "poison": value *= 0.55
		"yuanshao":
			if key == "armor_break": value *= 0.78
	return clamp(value, 0.05, 1.0)

static func apply_boss(host: Object, effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:
	if host == null:
		return false
	var boss_value: Variant = host.get("boss")
	if not boss_value is Dictionary or (boss_value as Dictionary).is_empty():
		return false
	var boss: Dictionary = (boss_value as Dictionary).duplicate(true)
	var key: String = canonical_effect(effect_id)
	if not DISPLAY_NAMES.has(key):
		return false
	var resist: float = boss_resistance(str(boss.get("id", "")), key)
	var statuses: Dictionary = _status_map(boss)
	var current: Dictionary = statuses.get(key, {}) as Dictionary
	var adjusted_duration: float = max(0.0, duration) * resist
	var new_duration: float = max(float(current.get("duration", 0.0)), adjusted_duration)
	var new_potency: float = max(float(current.get("potency", 0.0)), potency)
	var new_stacks: int = max(1, int(current.get("stacks", 1)))
	var tick: float = float(current.get("tick", 0.0))
	if key == "burn":
		new_stacks = min(4, max(0, int(current.get("stacks", 0))) + max(1, stacks))
		new_potency = min(5.0, max(potency, float(current.get("potency", 0.0)) + potency * 0.25))
		tick = min(0.35, tick if tick > 0.0 else 0.35)
	elif key == "poison":
		new_stacks = min(6, max(0, int(current.get("stacks", 0))) + max(1, stacks))
		new_potency = min(6.0, max(potency, float(current.get("potency", 0.0)) + potency * 0.25))
		tick = min(0.3, tick if tick > 0.0 else 0.3)
	elif key == "slow":
		new_potency = clamp(max(float(current.get("potency", 0.0)), potency), 0.08, 0.42)
	elif key == "armor_break":
		new_potency = clamp(max(float(current.get("potency", 0.0)), potency), 0.05, 0.30)
	_write_status(statuses, key, new_duration, new_potency, new_stacks, tick)
	boss["status_effects"] = statuses
	host.set("boss", boss)
	return true

static func tick_boss(host: Object, delta: float) -> void:
	if host == null:
		return
	var boss_value: Variant = host.get("boss")
	if not boss_value is Dictionary or (boss_value as Dictionary).is_empty():
		return
	var boss: Dictionary = (boss_value as Dictionary).duplicate(true)
	var statuses: Dictionary = _status_map(boss)
	var pending_hits: Array[Dictionary] = []
	for effect_value in statuses.keys():
		var effect_id: String = str(effect_value)
		var status: Dictionary = statuses[effect_id] as Dictionary
		var remaining: float = max(0.0, float(status.get("duration", 0.0)) - delta)
		status["duration"] = remaining
		if effect_id in ["burn", "poison"] and remaining > 0.0:
			var tick_left: float = float(status.get("tick", 0.0)) - delta
			if tick_left <= 0.0:
				var potency: float = max(0.0, float(status.get("potency", 0.0)))
				var stacks: int = max(1, int(status.get("stacks", 1)))
				var damage: float = (3.0 + potency * 1.45 + float(stacks - 1) * 0.8) if effect_id == "burn" else (2.1 + potency * 1.05)
				pending_hits.append({"damage":damage, "source":effect_id})
				tick_left = 0.60 if effect_id == "burn" else 0.72
			status["tick"] = tick_left
		if remaining <= 0.0:
			statuses.erase(effect_id)
		else:
			statuses[effect_id] = status
	boss["status_effects"] = statuses
	var slow: Dictionary = statuses.get("slow", {}) as Dictionary
	if not boss.has("_status_base_speed"):
		boss["_status_base_speed"] = float(boss.get("speed", 0.0))
	var base_speed: float = float(boss.get("_status_base_speed", boss.get("speed", 0.0)))
	if not slow.is_empty():
		boss["speed"] = base_speed * (1.0 - clamp(float(slow.get("potency", 0.2)), 0.08, 0.42))
	else:
		boss["speed"] = base_speed
	boss["status_stunned"] = statuses.has("stun")
	host.set("boss", boss)
	for hit in pending_hits:
		if host.has_method("damage_boss") and not (host.get("boss") as Dictionary).is_empty():
			host.call("damage_boss", float(hit.get("damage", 0.0)), str(hit.get("source", "status")), false)

static func boss_stunned(boss: Dictionary) -> bool:
	return bool(boss.get("status_stunned", false))

static func status_summary(entity: Dictionary, max_items: int = 4) -> String:
	var statuses: Dictionary = _status_map(entity)
	if statuses.is_empty():
		return ""
	var parts: Array[String] = []
	for effect_id in EFFECT_ORDER:
		if not statuses.has(effect_id):
			continue
		var status: Dictionary = statuses[effect_id] as Dictionary
		var duration: float = max(0.0, float(status.get("duration", 0.0)))
		if duration <= 0.0:
			continue
		var stacks: int = max(1, int(status.get("stacks", 1)))
		var suffix: String = "×%d" % stacks if stacks > 1 else ""
		parts.append("%s%s %.1fs" % [display_name(effect_id), suffix, duration])
		if parts.size() >= max_items:
			break
	return "　".join(parts)

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for effect_id in EFFECT_ORDER:
		if not DISPLAY_NAMES.has(effect_id):
			errors.append("missing display name: %s" % effect_id)
		if not EFFECT_COLORS.has(effect_id):
			errors.append("missing color: %s" % effect_id)
	for alias_value in ["frost", "bind", "armorbreak"]:
		if canonical_effect(str(alias_value)) == str(alias_value):
			errors.append("alias did not canonicalize: %s" % str(alias_value))
	return errors
