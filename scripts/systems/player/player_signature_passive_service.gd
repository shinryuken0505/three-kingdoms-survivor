class_name PlayerSignaturePassiveService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")

static func passive_for(archetype_id: String) -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("passive", ""))

static func player_level(host: Object) -> int:
	if host == null:
		return 1
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return 1
	return max(1, int((player_value as Dictionary).get("level", 1)))

static func incoming_damage_multiplier(host: Object, archetype_id: String, source: String) -> float:
	if passive_for(archetype_id) != "blade_guard":
		return 1.0
	var level: int = player_level(host)
	var reduction: float = 0.08 + min(0.08, float(level - 1) * 0.012)
	if source in ["contact", "boss"]:
		reduction += 0.04
	return clamp(1.0 - reduction, 0.80, 0.94)

static func eagle_eye_damage_multiplier(distance: float, level: int) -> float:
	var normalized: float = clamp((distance - 150.0) / 480.0, 0.0, 1.0)
	var max_bonus: float = 0.18 + min(0.12, float(max(0, level - 1)) * 0.018)
	return 1.0 + normalized * max_bonus

static func arcane_burst_profile(level: int, base_damage: float) -> Dictionary:
	return {
		"radius": 78.0 + min(42.0, float(max(0, level - 1)) * 6.0),
		"damage": base_damage * (0.36 + min(0.22, float(max(0, level - 1)) * 0.035)),
		"slow": 0.0 if level < 4 else (0.9 + min(1.3, float(level - 4) * 0.28)),
		"second_pulse": level >= 8,
	}

static func on_projectile_enemy_hit(host: Object, shot: Dictionary, direct_enemy_index: int) -> void:
	if host == null or not bool(shot.get("alpha51_arcane_orb", false)):
		return
	var level: int = max(1, int(shot.get("alpha51_level", 1)))
	var profile: Dictionary = arcane_burst_profile(level, float(shot.get("damage", 0.0)))
	var center: Vector2 = shot.get("pos", Vector2.ZERO) as Vector2
	var radius: float = float(profile.get("radius", 80.0))
	var burst_damage: float = float(profile.get("damage", 0.0))
	var slow_duration: float = float(profile.get("slow", 0.0))
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
				if slow_duration > 0.0 and live_index >= 0:
					var live_enemies: Array = host.get("enemies") as Array
					if live_index < live_enemies.size():
						live_enemies[live_index]["slow"] = max(float(live_enemies[live_index].get("slow", 0.0)), slow_duration)
						host.set("enemies", live_enemies)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", center, Color8(176, 142, 255), radius, 0.34)
	if bool(profile.get("second_pulse", false)) and host.has_method("damage_arc"):
		host.call("damage_arc", center, 0.0, radius * 0.74, TAU, burst_damage * 0.52, 0.0)

static func on_projectile_boss_hit(host: Object, shot: Dictionary) -> void:
	if host == null or not bool(shot.get("alpha51_arcane_orb", false)):
		return
	var level: int = max(1, int(shot.get("alpha51_level", 1)))
	var profile: Dictionary = arcane_burst_profile(level, float(shot.get("damage", 0.0)))
	var extra_damage: float = float(profile.get("damage", 0.0)) * 0.70
	if extra_damage > 0.0 and host.has_method("damage_boss"):
		host.call("damage_boss", extra_damage, "arcane_burst", false)
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
	return errors
