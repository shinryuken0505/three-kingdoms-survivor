class_name MeleeArcHandler
extends RefCounted

static func upgrade_level(host: Object, skill_id: String) -> int:
	if host != null and host.has_method("skill_level"):
		return int(host.call("skill_level", skill_id))
	return 0

static func execute(host: Object, damage: float) -> bool:
	if host == null or not host.has_method("nearest_enemy_position") or not host.has_method("damage_arc"):
		return false
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return false
	var player: Dictionary = player_value as Dictionary
	var origin: Vector2 = player.get("pos", Vector2.ZERO) as Vector2
	var target: Variant = host.call("nearest_enemy_position", origin)
	if not target is Vector2:
		return false
	var target_pos: Vector2 = target as Vector2
	if target_pos.x > 1.0e19:
		return false
	var direction: Vector2 = origin.direction_to(target_pos)
	if direction.length_squared() <= 0.001:
		direction = Vector2.RIGHT
	var level: int = max(1, int(player.get("level", 1)))
	var wave_lv: int = upgrade_level(host, "sig_blade_wave")
	var arc_lv: int = upgrade_level(host, "sig_wide_arc")
	var chain: int = int(player.get("alpha51_blade_chain", 0)) + 1
	player["alpha51_blade_chain"] = chain
	player["facing"] = direction
	host.set("player", player)

	if host.has_method("play_combat_motif"):
		host.call("play_combat_motif", "slash", 0.98)
	var radius: float = 126.0 + min(32.0, float(level - 1) * 4.0) + float(arc_lv) * 12.0
	var arc_width: float = 1.56 + (0.16 if level >= 5 else 0.0) + (0.12 if level >= 8 else 0.0) + float(arc_lv) * 0.10
	var attack_origin: Vector2 = origin + direction * 34.0
	host.call("damage_arc", attack_origin, direction.angle(), radius, arc_width, damage * (1.14 + float(arc_lv) * 0.025), 62.0 + float(level) * 2.0)

	# 專屬進化可提早解鎖劍氣；高階縮短至每兩刀一次，並提高傷害與穿透。
	var wave_unlocked: bool = level >= 4 or wave_lv > 0
	var wave_interval: int = 2 if wave_lv >= 2 else 3
	if wave_unlocked and chain % wave_interval == 0 and host.has_method("spawn_player_projectile"):
		var wave_damage: float = damage * ((0.62 if level < 8 else 0.78) + float(wave_lv) * 0.10)
		var wave_pierce: int = (1 if level < 8 else 2) + (1 if wave_lv >= 3 else 0)
		host.call("spawn_player_projectile", "blade_wave", direction, wave_damage, 455.0 + float(wave_lv) * 18.0, 0.72, 9.0 + float(wave_lv), wave_pierce, 0.0)
		if host.has_method("spawn_ring"):
			host.call("spawn_ring", attack_origin + direction * 34.0, Color8(132, 232, 177), 58.0 + float(wave_lv) * 5.0, 0.22)

	var zones_value: Variant = host.get("zones")
	if zones_value is Array:
		var zones: Array = zones_value as Array
		zones.append({
			"kind":"slash_visual", "pos":attack_origin + direction * 14.0,
			"angle":direction.angle(), "r":radius,
			"life":0.34, "max_life":0.34, "color":Color8(255, 224, 132)
		})
		host.set("zones", zones)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", attack_origin + direction * 24.0, Color8(255, 226, 145), 48.0 + float(arc_lv) * 3.0, 0.24)
	host.set("screen_shake", max(float(host.get("screen_shake")), 3.2))
	return true
