extends Node

## Alpha.19 武器戰鬥回饋層。
## 刀客閃避後發動近身斬、環刃攻擊產生延遲回擊、毒層提高時補上擴散提示。
## 不接管輸入，不修改存檔格式。

var _main: Node = null
var _last_dash_active: float = 0.0
var _last_shot_count: int = 0
var _ring_returns: Array[Dictionary] = []
var _poison_snapshot: Dictionary = {}
var _ring_serial: int = 0


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		_ring_returns.clear()
		_last_dash_active = 0.0
		_last_shot_count = 0
		_poison_snapshot.clear()
		return
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	var weapon: String = str(player.get("weapon", ""))
	_update_blade_feedback(player, weapon)
	_update_shot_feedback(player, weapon)
	_update_ring_returns(delta)
	_update_poison_feedback(weapon)


func _update_blade_feedback(player: Dictionary, weapon: String) -> void:
	var dash_active: float = float(player.get("dash_active", 0.0))
	if weapon == "blade" and dash_active > 0.0 and _last_dash_active <= 0.0:
		var pos_value: Variant = player.get("pos", Vector2.ZERO)
		var facing_value: Variant = player.get("facing", Vector2.RIGHT)
		var pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
		var facing: Vector2 = facing_value if facing_value is Vector2 else Vector2.RIGHT
		if facing.length_squared() <= 0.01:
			facing = Vector2.RIGHT
		var core: int = _core_level(["damage", "attack_speed", "crit", "armor", "dash"])
		var radius: float = 108.0 + minf(42.0, float(core) * 3.0)
		var damage: float = float(player.get("damage", 10.0)) * (0.48 + minf(0.22, float(core) * 0.012))
		if _main.has_method("damage_arc"):
			_main.call("damage_arc", pos, facing.angle(), radius, 2.35, damage, 165.0)
		if _main.has_method("spawn_ring"):
			_main.call("spawn_ring", pos + facing * 34.0, Color8(120, 214, 160), radius, 0.24)
		if _main.has_method("play_sfx"):
			_main.call("play_sfx", "slash", 1.08)
	_last_dash_active = dash_active


func _update_shot_feedback(player: Dictionary, weapon: String) -> void:
	var shots_value: Variant = _main.get("player_shots")
	if not (shots_value is Array):
		return
	var shot_count: int = (shots_value as Array).size()
	var created: int = maxi(0, shot_count - _last_shot_count)
	if weapon == "rings" and created > 0:
		_ring_serial += 1
		var pos_value: Variant = player.get("pos", Vector2.ZERO)
		var pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
		var core: int = _core_level(["multishot", "projectile", "crit", "dash", "attack_speed"])
		_ring_returns.append({
			"timer": 0.34,
			"pos": pos,
			"damage": float(player.get("damage", 10.0)) * (0.34 + minf(0.18, float(core) * 0.01)),
			"radius": 96.0 + minf(38.0, float(core) * 2.5),
			"serial": _ring_serial,
		})
		while _ring_returns.size() > 8:
			_ring_returns.pop_front()
	elif weapon == "bow" and created > 0:
		var projectile_core: int = _core_level(["projectile", "pierce", "multishot", "crit", "attack_speed"])
		if projectile_core >= 5:
			player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 0.22)
			_main.set("player", player)
	_last_shot_count = shot_count


func _update_ring_returns(delta: float) -> void:
	for index in range(_ring_returns.size() - 1, -1, -1):
		var event: Dictionary = _ring_returns[index]
		event["timer"] = float(event.get("timer", 0.0)) - delta
		if float(event["timer"]) > 0.0:
			_ring_returns[index] = event
			continue
		_trigger_ring_return(event)
		_ring_returns.remove_at(index)


func _trigger_ring_return(event: Dictionary) -> void:
	var pos_value: Variant = event.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var radius: float = float(event.get("radius", 100.0))
	var damage: float = float(event.get("damage", 5.0))
	var enemies_value: Variant = _main.get("enemies")
	if enemies_value is Array:
		var enemies: Array = enemies_value as Array
		for index in range(enemies.size() - 1, -1, -1):
			if index >= enemies.size() or not (enemies[index] is Dictionary):
				continue
			var enemy: Dictionary = enemies[index] as Dictionary
			var enemy_pos_value: Variant = enemy.get("pos", Vector2.ZERO)
			var enemy_pos: Vector2 = enemy_pos_value if enemy_pos_value is Vector2 else Vector2.ZERO
			if enemy_pos.distance_squared_to(center) <= radius * radius and _main.has_method("damage_enemy"):
				_main.call("damage_enemy", index, damage, "return_blade", false)
	var boss_value: Variant = _main.get("boss")
	if boss_value is Dictionary:
		var boss: Dictionary = boss_value as Dictionary
		if not boss.is_empty():
			var boss_pos_value: Variant = boss.get("pos", Vector2.ZERO)
			var boss_pos: Vector2 = boss_pos_value if boss_pos_value is Vector2 else Vector2.ZERO
			var boss_radius: float = float(boss.get("radius", 0.0))
			if boss_pos.distance_squared_to(center) <= pow(radius + boss_radius, 2.0) and _main.has_method("damage_boss"):
				_main.call("damage_boss", damage, "return_blade", false)
	if _main.has_method("spawn_ring"):
		_main.call("spawn_ring", center, Color8(210, 145, 222), radius, 0.32)
	if _main.has_method("play_sfx"):
		_main.call("play_sfx", "slash", 1.18)


func _update_poison_feedback(weapon: String) -> void:
	if weapon != "poison":
		_poison_snapshot.clear()
		return
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	var current_ids: Dictionary = {}
	for item in enemies:
		if not (item is Dictionary):
			continue
		var enemy: Dictionary = item as Dictionary
		var uid: int = int(enemy.get("uid", -1))
		var stacks: float = float(enemy.get("poison", 0.0))
		current_ids[uid] = true
		var previous: float = float(_poison_snapshot.get(uid, 0.0))
		if stacks >= 3.0 and stacks > previous and _main.has_method("spawn_ring"):
			var pos_value: Variant = enemy.get("pos", Vector2.ZERO)
			var pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
			_main.call("spawn_ring", pos, Color8(174, 104, 207), 42.0 + stacks * 5.0, 0.28)
		_poison_snapshot[uid] = stacks
	for uid in _poison_snapshot.keys():
		if not current_ids.has(uid):
			_poison_snapshot.erase(uid)


func _core_level(skill_ids: Array) -> int:
	var levels_value: Variant = _main.get("skill_levels")
	if not (levels_value is Dictionary):
		return 0
	var levels: Dictionary = levels_value as Dictionary
	var total: int = 0
	for value in skill_ids:
		total += int(levels.get(str(value), 0))
	return total
