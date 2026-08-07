class_name RangedArrowHandler
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
		host.call("play_combat_motif", "arrow", 0.98)
	var count: int = max(1, 1 + int(player.get("multishot", 0)))
	var pierce: int = int(player.get("pierce", 0)) + 1
	for index in range(count):
		var spread: float = (float(index) - float(count - 1) * 0.5) * 0.105
		host.call("spawn_player_projectile", "arrow", direction.rotated(spread), damage * 1.20, 545.0, 1.85, 6.5, pierce, 0.0)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", origin + direction * 20.0, Color8(186, 226, 255), 25.0, 0.18)
	return true
