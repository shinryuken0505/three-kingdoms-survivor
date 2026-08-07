class_name MeleeArcHandler
extends RefCounted

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
	var chain: int = int(player.get("alpha51_blade_chain", 0)) + 1
	player["alpha51_blade_chain"] = chain
	player["facing"] = direction
	host.set("player", player)

	if host.has_method("play_combat_motif"):
		host.call("play_combat_motif", "slash", 0.98)
	var radius: float = 126.0 + min(32.0, float(level - 1) * 4.0)
	var arc_width: float = 1.56 + (0.16 if level >= 5 else 0.0) + (0.12 if level >= 8 else 0.0)
	var attack_origin: Vector2 = origin + direction * 34.0
	host.call("damage_arc", attack_origin, direction.angle(), radius, arc_width, damage * 1.14, 62.0 + float(level) * 2.0)

	# 刀客進化：連斬第三擊自 Lv4 起會放出短程劍氣；Lv8 劍氣更強且可多穿透一名敵人。
	if level >= 4 and chain % 3 == 0 and host.has_method("spawn_player_projectile"):
		host.call("spawn_player_projectile", "blade_wave", direction, damage * (0.62 if level < 8 else 0.78), 455.0, 0.72, 9.0, 1 if level < 8 else 2, 0.0)
		if host.has_method("spawn_ring"):
			host.call("spawn_ring", attack_origin + direction * 34.0, Color8(132, 232, 177), 58.0, 0.22)

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
		host.call("spawn_ring", attack_origin + direction * 24.0, Color8(255, 226, 145), 48.0, 0.24)
	host.set("screen_shake", max(float(host.get("screen_shake")), 3.2))
	return true
