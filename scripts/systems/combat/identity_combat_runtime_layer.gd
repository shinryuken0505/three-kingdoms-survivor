extends Node

## Alpha.19 主角戰鬥身份執行層。
## 透過既有 player／skill_levels／enemies／player_shots 欄位實際生效，
## 不接管輸入，也不改變存檔格式。

const ProfileScript = preload("res://scripts/systems/combat/identity_combat_profile.gd")

var _main: Node = null
var _last_shot_count: int = 0
var _ring_combo: int = 0
var _ring_combo_timer: float = 0.0
var _blade_counter_timer: float = 0.0
var _last_dash_active: float = 0.0


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		_reset_transient(delta)
		return
	var player_value: Variant = _main.get("player")
	var levels_value: Variant = _main.get("skill_levels")
	if not (player_value is Dictionary) or not (levels_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	var levels: Dictionary = levels_value as Dictionary
	_update_transient_state(player, delta)
	_apply_profile(player, levels)
	_main.set("player", player)
	if str(player.get("weapon", "")) == "poison":
		_update_poison_spread(player, delta)


func _reset_transient(delta: float) -> void:
	_ring_combo_timer = maxf(0.0, _ring_combo_timer - delta)
	_blade_counter_timer = maxf(0.0, _blade_counter_timer - delta)
	if _ring_combo_timer <= 0.0:
		_ring_combo = 0


func _update_transient_state(player: Dictionary, delta: float) -> void:
	var weapon: String = str(player.get("weapon", ""))
	var dash_active: float = float(player.get("dash_active", 0.0))
	if weapon == "blade" and dash_active > 0.0 and _last_dash_active <= 0.0:
		_blade_counter_timer = 1.15
	_last_dash_active = dash_active
	_blade_counter_timer = maxf(0.0, _blade_counter_timer - delta)

	var shots_value: Variant = _main.get("player_shots")
	var shot_count: int = 0
	if shots_value is Array:
		shot_count = (shots_value as Array).size()
	if weapon == "rings" and shot_count > _last_shot_count:
		_ring_combo = mini(6, _ring_combo + 1)
		_ring_combo_timer = 1.2
	_ring_combo_timer = maxf(0.0, _ring_combo_timer - delta)
	if _ring_combo_timer <= 0.0:
		_ring_combo = 0
	_last_shot_count = shot_count


func _apply_profile(player: Dictionary, skill_levels: Dictionary) -> void:
	_remove_previous_adjustments(player)
	var weapon: String = str(player.get("weapon", ""))
	var profile: Dictionary = ProfileScript.for_player(player)
	if profile.is_empty():
		return
	var core: int = ProfileScript.core_level(weapon, skill_levels)
	var applied: Dictionary = {
		"damage_mult": 1.0,
		"projectile_mult": 1.0,
		"speed_mult": 1.0,
		"armor_add": 0.0,
		"crit_add": 0.0,
		"pierce_add": 0,
		"multishot_add": 0,
		"poison_mult": 1.0,
		"heal_mult": 1.0,
	}

	if weapon == "blade":
		applied["damage_mult"] = 1.0 + minf(0.22, core * float(profile.get("damage_per_core", 0.0)))
		if _blade_counter_timer > 0.0:
			applied["damage_mult"] = float(applied["damage_mult"]) + float(profile.get("dash_damage_bonus", 0.0))
		applied["armor_add"] = minf(3.0, core * float(profile.get("armor_per_core", 0.0)))
		applied["crit_add"] = minf(0.06, core * float(profile.get("crit_per_core", 0.0)))
	elif weapon == "bow":
		applied["projectile_mult"] = 1.0 + minf(0.30, core * float(profile.get("projectile_per_core", 0.0)))
		applied["crit_add"] = minf(0.05, core * float(profile.get("crit_per_core", 0.0)))
		applied["pierce_add"] = ProfileScript.threshold_bonus(core, profile.get("pierce_thresholds", []) as Array)
		applied["multishot_add"] = ProfileScript.threshold_bonus(core, profile.get("multishot_thresholds", []) as Array)
	elif weapon == "poison":
		applied["poison_mult"] = 1.0 + minf(0.55, core * float(profile.get("poison_per_core", 0.0)))
		applied["heal_mult"] = 1.0 + minf(0.24, core * float(profile.get("heal_per_core", 0.0)))
	elif weapon == "rings":
		applied["damage_mult"] = 1.0 + minf(0.18, core * float(profile.get("damage_per_core", 0.0))) + float(_ring_combo) * 0.018
		applied["crit_add"] = minf(0.09, core * float(profile.get("crit_per_core", 0.0)))
		applied["speed_mult"] = 1.0 + minf(0.16, core * float(profile.get("speed_per_core", 0.0)))
		applied["multishot_add"] = ProfileScript.threshold_bonus(core, profile.get("multishot_thresholds", []) as Array)

	_apply_adjustments(player, applied)
	player["alpha19_identity_state"] = applied
	player["alpha19_identity_state"]["weapon"] = weapon
	player["alpha19_identity_state"]["core_level"] = core
	player["alpha19_identity_state"]["blade_counter"] = _blade_counter_timer
	player["alpha19_identity_state"]["ring_combo"] = _ring_combo


func _remove_previous_adjustments(player: Dictionary) -> void:
	var previous_value: Variant = player.get("alpha19_identity_state", {})
	if not (previous_value is Dictionary):
		return
	var previous: Dictionary = previous_value as Dictionary
	player["damage"] = float(player.get("damage", 1.0)) / maxf(0.01, float(previous.get("damage_mult", 1.0)))
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) / maxf(0.01, float(previous.get("projectile_mult", 1.0)))
	player["speed"] = float(player.get("speed", 1.0)) / maxf(0.01, float(previous.get("speed_mult", 1.0)))
	player["armor"] = float(player.get("armor", 0.0)) - float(previous.get("armor_add", 0.0))
	player["crit"] = float(player.get("crit", 0.0)) - float(previous.get("crit_add", 0.0))
	player["pierce"] = int(player.get("pierce", 0)) - int(previous.get("pierce_add", 0))
	player["multishot"] = int(player.get("multishot", 0)) - int(previous.get("multishot_add", 0))
	player["poison_power"] = float(player.get("poison_power", 1.0)) / maxf(0.01, float(previous.get("poison_mult", 1.0)))
	player["heal_power"] = float(player.get("heal_power", 1.0)) / maxf(0.01, float(previous.get("heal_mult", 1.0)))


func _apply_adjustments(player: Dictionary, applied: Dictionary) -> void:
	player["damage"] = float(player.get("damage", 1.0)) * float(applied.get("damage_mult", 1.0))
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) * float(applied.get("projectile_mult", 1.0))
	player["speed"] = float(player.get("speed", 1.0)) * float(applied.get("speed_mult", 1.0))
	player["armor"] = maxf(0.0, float(player.get("armor", 0.0)) + float(applied.get("armor_add", 0.0)))
	player["crit"] = clampf(float(player.get("crit", 0.0)) + float(applied.get("crit_add", 0.0)), 0.0, 0.75)
	player["pierce"] = maxi(0, int(player.get("pierce", 0)) + int(applied.get("pierce_add", 0)))
	player["multishot"] = maxi(0, int(player.get("multishot", 0)) + int(applied.get("multishot_add", 0)))
	player["poison_power"] = float(player.get("poison_power", 1.0)) * float(applied.get("poison_mult", 1.0))
	player["heal_power"] = float(player.get("heal_power", 1.0)) * float(applied.get("heal_mult", 1.0))


func _update_poison_spread(player: Dictionary, delta: float) -> void:
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	var profile: Dictionary = ProfileScript.for_player(player)
	var threshold: int = int(profile.get("spread_stack_threshold", 3))
	var radius: float = float(profile.get("spread_radius", 150.0))
	var interval: float = float(profile.get("spread_interval", 1.15))
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		enemy["alpha19_spread_cd"] = maxf(0.0, float(enemy.get("alpha19_spread_cd", 0.0)) - delta)
		if float(enemy.get("poison", 0.0)) < float(threshold) or float(enemy.get("alpha19_spread_cd", 0.0)) > 0.0:
			enemies[index] = enemy
			continue
		var target_index: int = _nearest_spread_target(enemies, index, radius)
		if target_index >= 0:
			var target: Dictionary = enemies[target_index] as Dictionary
			target["poison"] = minf(8.0, float(target.get("poison", 0.0)) + 1.0)
			target["poison_time"] = maxf(float(target.get("poison_time", 0.0)), 3.8)
			target["poison_tick"] = minf(float(target.get("poison_tick", 0.65)), 0.35)
			enemies[target_index] = target
			enemy["alpha19_spread_cd"] = interval
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _nearest_spread_target(enemies: Array, source_index: int, radius: float) -> int:
	var source: Dictionary = enemies[source_index] as Dictionary
	var source_pos: Vector2 = source.get("pos", Vector2.ZERO) as Vector2
	var best_index: int = -1
	var best_distance: float = radius * radius
	for index in range(enemies.size()):
		if index == source_index or not (enemies[index] is Dictionary):
			continue
		var target: Dictionary = enemies[index] as Dictionary
		if float(target.get("hp", 0.0)) <= 0.0:
			continue
		var target_pos: Vector2 = target.get("pos", Vector2.ZERO) as Vector2
		var distance: float = source_pos.distance_squared_to(target_pos)
		if distance <= best_distance:
			best_distance = distance
			best_index = index
	return best_index
