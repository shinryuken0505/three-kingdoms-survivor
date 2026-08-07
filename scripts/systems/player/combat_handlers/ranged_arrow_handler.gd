class_name RangedArrowHandler
extends RefCounted

const PlayerSignaturePassiveService = preload("res://scripts/systems/player/player_signature_passive_service.gd")

static func upgrade_level(host: Object, skill_id: String) -> int:
	if host != null and host.has_method("skill_level"):
		return int(host.call("skill_level", skill_id))
	return 0

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
	var level: int = max(1, int(player.get("level", 1)))
	var eagle_lv: int = upgrade_level(host, "sig_eagle_eye")
	var split_lv: int = upgrade_level(host, "sig_split_arrow")
	var pierce_lv: int = upgrade_level(host, "sig_piercing_focus")
	var distance: float = origin.distance_to(target_pos)
	var eagle_eye_mult: float = PlayerSignaturePassiveService.eagle_eye_damage_multiplier(distance, level, eagle_lv)
	player["facing"] = direction
	player["alpha51_eagle_eye_mult"] = eagle_eye_mult
	host.set("player", player)

	if host.has_method("play_combat_motif"):
		host.call("play_combat_motif", "arrow", 0.98)
	var count: int = max(1, 1 + int(player.get("multishot", 0))) + split_lv
	if level >= 5:
		count += 1
	if level >= 8:
		count += 1
	var pierce: int = int(player.get("pierce", 0)) + 1 + pierce_lv + (1 if level >= 8 else 0)
	var spread_step: float = max(0.068, (0.105 if level < 8 else 0.088) - float(eagle_lv) * 0.006)
	for index in range(count):
		var spread: float = (float(index) - float(count - 1) * 0.5) * spread_step
		host.call("spawn_player_projectile", "arrow", direction.rotated(spread), damage * 1.20 * eagle_eye_mult, 545.0 + float(level) * 4.0 + float(eagle_lv) * 10.0, 1.85, 6.5, pierce, 0.0)
	if host.has_method("spawn_ring"):
		host.call("spawn_ring", origin + direction * 20.0, Color8(186, 226, 255), 25.0 + (8.0 if level >= 5 else 0.0) + float(split_lv) * 3.0, 0.18)
	return true
