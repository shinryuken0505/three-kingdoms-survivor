class_name PlayerSignaturePassiveService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")
const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")

static func passive_for(archetype_id: String) -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("passive", ""))

static func player_level(host: Object) -> int:
	if host == null:
		return 1
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return 1
	return max(1, int((player_value as Dictionary).get("level", 1)))

static func upgrade_level(host: Object, skill_id: String) -> int:
	if host != null and host.has_method("skill_level"):
		return int(host.call("skill_level", skill_id))
	return 0

static func incoming_damage_multiplier(host: Object, archetype_id: String, source: String) -> float:
	if passive_for(archetype_id) != "blade_guard":
		return 1.0
	var level: int = player_level(host)
	var mastery: int = upgrade_level(host, "sig_blade_guard")
	var reduction: float = 0.08 + min(0.08, float(level - 1) * 0.012) + float(mastery) * 0.025
	if source in ["contact", "boss"]:
		reduction += 0.04 + float(mastery) * 0.008
	return clamp(1.0 - reduction, 0.72, 0.94)

static func eagle_eye_damage_multiplier(distance: float, level: int, mastery: int = 0) -> float:
	var normalized: float = clamp((distance - 150.0) / 480.0, 0.0, 1.0)
	var max_bonus: float = 0.18 + min(0.12, float(max(0, level - 1)) * 0.018) + float(mastery) * 0.06
	return 1.0 + normalized * min(max_bonus, 0.48)

static func arcane_burst_profile(level: int, base_damage: float, burst_mastery: int = 0, resonance_mastery: int = 0, frost_mastery: int = 0) -> Dictionary:
	var second_pulse: bool = level >= 8 or resonance_mastery >= 2
	return {
		"radius": 78.0 + min(42.0, float(max(0, level - 1)) * 6.0) + float(burst_mastery) * 13.0,
		"damage": base_damage * (0.36 + min(0.22, float(max(0, level - 1)) * 0.035) + float(burst_mastery) * 0.08),
		"slow": (0.0 if level < 4 and frost_mastery <= 0 else (0.9 + min(1.3, float(max(0, level - 4)) * 0.28) + float(frost_mastery) * 0.55)),
		"slow_potency": clamp(0.18 + float(frost_mastery) * 0.06, 0.18, 0.42),
		"burn_duration": 2.8 + min(2.4, float(level - 1) * 0.22) + float(burst_mastery) * 0.45,
		"burn_potency": 0.75 + float(level) * 0.08 + float(burst_mastery) * 0.28,
		"burn_stacks": 1 + int(resonance_mastery >= 2),
		"second_pulse": second_pulse,
		"second_pulse_mult": 0.52 + float(resonance_mastery) * 0.12,
		"second_pulse_radius_mult": 0.74 + float(resonance_mastery) * 0.06,
	}

static func apply_arcane_statuses_to_enemy(host: Object, index: int, profile: Dictionary) -> void:
	if index < 0:
		return
	StatusEffectService.apply_enemy(
		host,
		index,
		"burn",
		float(profile.get("burn_duration", 3.0)),
		float(profile.get("burn_potency", 1.0)),
		int(profile.get("burn_stacks", 1))
	)
	var slow_duration: float = float(profile.get("slow", 0.0))
	if slow_duration > 0.0:
		StatusEffectService.apply_enemy(
			host,
			index,
			"slow",
			slow_duration,
			float(profile.get("slow_potency", 0.20)),
			1
		)

static func on_projectile_enemy_hit(host: Object, shot: Dictionary, direct_enemy_index: int) -> void:
	if host == null or not bool(shot.get("alpha51_arcane_orb", false)):
		return
	var level: int = max(1, int(shot.get("alpha51_level", 1)))
	var burst_mastery: int = int(shot.get("alpha52_burst_level", 0))
	var resonance_mastery: int = int(shot.get("alpha52_resonance_level", 0))
	var frost_mastery: int = int(shot.get("alpha52_frost_level", 0))
	var profile: Dictionary = arcane_burst_profile(level, float(shot.get("damage", 0.0)), burst_mastery, resonance_mastery, frost_mastery)
	apply_arcane_statuses_to_enemy(host, direct_enemy_index, profile)
	var center: Vector2 = shot.get("pos", Vector2.ZERO) as Vector2
	var radius: float = float(profile.get("radius", 80.0))
	var burst_damage: float = float(profile.get("damage", 0.0))
	var enemies_value: Variant = host.get("enemies")
	if enemies_value is Array:
		var enemies: Array = enemies_value as Array
		for index in range(enemies.size() - 1, -1, -1):
			if index == direct_enemy_index or index >= enemies.size():
				continue
			var enemy: Dictionary = enemies[index] as Dictionary
			var pos: Vector2 = enemy.get("pos", Vector2.ZERO) as Vector2
			if center.distance_squared_to(pos) > radius * radius:
				continue
			if host.has_method("damage_enemy"):
				var live_index: int = int(host.call("damage_enemy", index, burst_damage, "arcane_burst", false))
				if live_index >= 0:
					apply_arcane_statuses_to_enemy(host, live_index, profile)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", center, Color8(176, 142, 255), radius, 0.34)
	if bool(profile.get("second_pulse", false)) and host.has_method("damage_arc"):
		host.call("damage_arc", center, 0.0, radius * float(profile.get("second_pulse_radius_mult", 0.74)), TAU, burst_damage * float(profile.get("second_pulse_mult", 0.52)), 0.0)

static func on_projectile_boss_hit(host: Object, shot: Dictionary) -> void:
	if host == null or not bool(shot.get("alpha51_arcane_orb", false)):
		return
	var level: int = max(1, int(shot.get("alpha51_level", 1)))
	var burst_mastery: int = int(shot.get("alpha52_burst_level", 0))
	var resonance_mastery: int = int(shot.get("alpha52_resonance_level", 0))
	var frost_mastery: int = int(shot.get("alpha52_frost_level", 0))
	var profile: Dictionary = arcane_burst_profile(level, float(shot.get("damage", 0.0)), burst_mastery, resonance_mastery, frost_mastery)
	var extra_damage: float = float(profile.get("damage", 0.0)) * (0.70 + float(resonance_mastery) * 0.06)
	if extra_damage > 0.0 and host.has_method("damage_boss"):
		host.call("damage_boss", extra_damage, "arcane_burst", false)
	StatusEffectService.apply_boss(
		host,
		"burn",
		float(profile.get("burn_duration", 3.0)),
		float(profile.get("burn_potency", 1.0)),
		int(profile.get("burn_stacks", 1))
	)
	var slow_duration: float = float(profile.get("slow", 0.0))
	if slow_duration > 0.0:
		StatusEffectService.apply_boss(host, "slow", slow_duration, float(profile.get("slow_potency", 0.20)), 1)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", shot.get("pos", Vector2.ZERO), Color8(176, 142, 255), float(profile.get("radius", 80.0)), 0.34)

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var expected: Dictionary = {
		"swordsman":"blade_guard",
		"archer":"eagle_eye",
		"strategist":"arcane_flow",
	}
	for archetype_id in expected.keys():
		if passive_for(str(archetype_id)) != str(expected[archetype_id]):
			errors.append("%s passive mismatch" % archetype_id)
	if arcane_burst_profile(6, 20.0, 1, 1, 1).get("burn_duration", 0.0) <= 0.0:
		errors.append("strategist burn profile missing")
	return errors
