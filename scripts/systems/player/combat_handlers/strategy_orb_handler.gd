class_name StrategyOrbHandler
extends RefCounted

static func execute(host: Object, damage: float) -> bool:
	if host == null or not host.has_method("nearest_enemy_position") or not host.has_method("spawn_player_projectile"):
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
	player["facing"] = direction
	host.set("player", player)

	if host.has_method("play_combat_motif"):
		host.call("play_combat_motif", "poison", 0.95)
	var projectile_count: int = 1 + int(int(player.get("multishot", 0)) / 2)
	for index in range(projectile_count):
		var spread: float = (float(index) - float(projectile_count - 1) * 0.5) * 0.14
		host.call("spawn_player_projectile", "fire_arrow", direction.rotated(spread), damage * 1.08, 390.0, 1.75, 10.0, int(player.get("pierce", 0)), 0.0)

	var zones_value: Variant = host.get("zones")
	if zones_value is Array:
		var zones: Array = zones_value as Array
		zones.append({
			"kind":"strategy_cast_visual", "pos":origin + direction * 42.0,
			"angle":direction.angle(), "r":56.0,
			"life":0.42, "max_life":0.42, "color":Color8(172, 139, 255)
		})
		host.set("zones", zones)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", origin + direction * 36.0, Color8(177, 145, 255), 42.0, 0.28)
	return true
