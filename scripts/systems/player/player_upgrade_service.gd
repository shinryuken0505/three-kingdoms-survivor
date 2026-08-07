class_name PlayerUpgradeService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")

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

static func weight_for(archetype_id: String, skill_id: String, definition: Dictionary) -> float:
	var archetype: Dictionary = PlayerArchetypeRegistry.get_definition(archetype_id)
	var weights: Dictionary = archetype.get("upgrade_weights", {}) as Dictionary
	return max(0.10, float(weights.get(skill_category(skill_id, definition), 1.0)))

static func weighted_pool(pool: Array, skill_defs: Dictionary, archetype_id: String, rng: RandomNumberGenerator) -> Array:
	if pool.size() <= 1:
		return pool.duplicate()
	var remaining: Array = pool.duplicate()
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
		result[sid] = weight_for(archetype_id, sid, skill_defs[sid] as Dictionary)
	return result
