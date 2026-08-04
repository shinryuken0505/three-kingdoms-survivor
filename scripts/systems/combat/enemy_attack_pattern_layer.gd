extends Node

## Alpha.19 第三章後敵軍攻擊方式補強。
## 只為已存在敵人追加可辨識的預警與區域攻擊，不取代 main.gd 原 AI。

var _main: Node = null
var _chapter_index: int = 0


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	_chapter_index = _current_chapter_index()
	if _chapter_index < 2:
		return
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	var player_pos_value: Variant = player.get("pos", Vector2.ZERO)
	var player_pos: Vector2 = player_pos_value if player_pos_value is Vector2 else Vector2.ZERO
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		enemy["alpha19_pattern_cd"] = maxf(0.0, float(enemy.get("alpha19_pattern_cd", 0.0)) - delta)
		if float(enemy.get("alpha19_pattern_cd", 0.0)) > 0.0:
			enemies[index] = enemy
			continue
		var kind: String = str(enemy.get("kind", ""))
		var enemy_pos_value: Variant = enemy.get("pos", Vector2.ZERO)
		var enemy_pos: Vector2 = enemy_pos_value if enemy_pos_value is Vector2 else Vector2.ZERO
		var distance: float = enemy_pos.distance_to(player_pos)
		if kind == "crossbow" and distance < 620.0:
			_spawn_line_warning(enemy_pos, player_pos, float(enemy.get("damage", 8.0)) * 1.15)
			enemy["alpha19_pattern_cd"] = 4.8
		elif kind == "firepot" and distance < 560.0:
			_spawn_burning_zone(player_pos, float(enemy.get("damage", 8.0)) * 0.72)
			enemy["alpha19_pattern_cd"] = 5.4
		elif kind == "spearman" and distance < 250.0:
			_spawn_thrust_warning(enemy_pos, player_pos, float(enemy.get("damage", 8.0)) * 1.25)
			enemy["alpha19_pattern_cd"] = 4.2
		elif kind == "assassin" and distance < 330.0:
			var dir: Vector2 = (player_pos - enemy_pos).normalized()
			enemy["knock"] = enemy.get("knock", Vector2.ZERO) + dir * 520.0
			enemy["alpha19_pattern_cd"] = 4.6
			_spawn_dash_warning(enemy_pos, player_pos)
		elif kind in ["caster_slow", "caster_bind", "caster_smoke", "tactician"] and distance < 590.0:
			_spawn_control_warning(player_pos, kind, float(enemy.get("damage", 8.0)))
			enemy["alpha19_pattern_cd"] = 5.8
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return int(manager.call("current_index_value"))
	return 0


func _zones() -> Array:
	var value: Variant = _main.get("zones")
	if value is Array:
		return value as Array
	return []


func _append_zone(zone: Dictionary) -> void:
	var zones: Array = _zones()
	if zones.size() >= 66:
		return
	zones.append(zone)
	_main.set("zones", zones)


func _spawn_line_warning(origin: Vector2, target: Vector2, damage: float) -> void:
	var midpoint: Vector2 = origin.lerp(target, 0.5)
	_append_zone({
		"kind": "enemy_warning",
		"pos": midpoint,
		"r": 42.0,
		"life": 0.85,
		"damage": damage,
		"line_from": origin,
		"line_to": target,
		"color": Color8(224, 187, 91),
	})


func _spawn_burning_zone(target: Vector2, damage: float) -> void:
	_append_zone({
		"kind": "enemy_warning",
		"pos": target,
		"r": 82.0,
		"life": 1.0,
		"damage": damage,
		"burn_duration": 2.8,
		"color": Color8(236, 112, 54),
	})


func _spawn_thrust_warning(origin: Vector2, target: Vector2, damage: float) -> void:
	var dir: Vector2 = (target - origin).normalized()
	_append_zone({
		"kind": "enemy_warning",
		"pos": origin + dir * 92.0,
		"r": 48.0,
		"life": 0.55,
		"damage": damage,
		"shield_pierce": 0.12,
		"color": Color8(205, 203, 176),
	})


func _spawn_dash_warning(origin: Vector2, target: Vector2) -> void:
	if _main.has_method("spawn_ring"):
		_main.call("spawn_ring", origin.lerp(target, 0.45), Color8(196, 92, 112), 58.0, 0.28)


func _spawn_control_warning(target: Vector2, kind: String, damage: float) -> void:
	var color: Color = Color8(112, 178, 220)
	if kind == "caster_bind":
		color = Color8(225, 203, 83)
	elif kind == "caster_smoke":
		color = Color8(142, 126, 154)
	elif kind == "tactician":
		color = Color8(216, 157, 82)
	_append_zone({
		"kind": "enemy_warning",
		"pos": target,
		"r": 92.0,
		"life": 0.95,
		"damage": damage * 0.65,
		"control_kind": kind,
		"color": color,
	})
