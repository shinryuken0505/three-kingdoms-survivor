extends Node

## Alpha.20 章節專屬中段任務。
## 官渡、長坂坡與赤壁各有兩段任務，結果寫入 history_log 與 player 暫存狀態。

var _main: Node = null
var _chapter_index: int = -1
var _mission_done: Dictionary = {}
var _damage_snapshot: float = 0.0


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var chapter_index: int = _current_chapter_index()
	if chapter_index != _chapter_index:
		_chapter_index = chapter_index
		_mission_done.clear()
		_damage_snapshot = _damage_taken()
	_update_missions()


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return maxi(0, int(manager.call("current_index_value")))
	return 0


func _update_missions() -> void:
	if _chapter_index not in [4, 6, 7]:
		return
	var elapsed: float = float(_main.get("elapsed"))
	var boss_time: float = 360.0
	if _main.has_method("boss_time"):
		boss_time = maxf(60.0, float(_main.call("boss_time")))
	if elapsed >= boss_time * 0.34:
		_trigger_once("mission_a")
	if elapsed >= boss_time * 0.68:
		_trigger_once("mission_b")


func _trigger_once(mission_id: String) -> void:
	var key: String = "%d:%s" % [_chapter_index, mission_id]
	if bool(_mission_done.get(key, false)):
		return
	_mission_done[key] = true
	if _chapter_index == 4:
		_trigger_guandu(mission_id)
	elif _chapter_index == 6:
		_trigger_changban(mission_id)
	elif _chapter_index == 7:
		_trigger_red_cliff(mission_id)


func _trigger_guandu(mission_id: String) -> void:
	if mission_id == "mission_a":
		_grant_player_supply(10, 8.0, 1.8)
		_spawn_warning_line(Color8(220, 174, 82), 3, 72.0, 7.0)
		_record("官渡任務・糧道守護完成：補給與名將士氣提升。")
	else:
		var flags: Dictionary = _flags()
		if flags.has("fire_plan"):
			_damage_enemy_formation(0.08, 0.8)
			_record("官渡任務・烏巢火起：敵軍陣形與護甲受創。")
		else:
			_strengthen_enemy_wave(1.05, 1.04)
			_record("官渡任務・烏巢未破：敵軍增援抵達。")


func _trigger_changban(mission_id: String) -> void:
	if mission_id == "mission_a":
		_damage_snapshot = _damage_taken()
		_grant_player_supply(0, 10.0, 0.0)
		_record("長坂任務・護送百姓開始：保持陣形，等待接應。")
	else:
		var damage_delta: float = maxf(0.0, _damage_taken() - _damage_snapshot)
		if damage_delta <= 24.0:
			_grant_player_supply(14, 14.0, 2.2)
			_advance_hero_arrival(16.0)
			_record("長坂任務・百姓安全抵達：獲得補給與豪傑接應。")
		else:
			_grant_player_supply(4, 5.0, 0.0)
			_strengthen_enemy_wave(1.04, 1.06)
			_record("長坂任務・追兵迫近：僅保住部分補給。")


func _trigger_red_cliff(mission_id: String) -> void:
	if mission_id == "mission_a":
		var player: Dictionary = _player()
		if not player.is_empty():
			player["control_resist"] = maxf(float(player.get("control_resist", 0.0)), 0.24)
			player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 2.4)
			_main.set("player", player)
		_spawn_warning_line(Color8(108, 194, 218), 4, 88.0, 0.0)
		_record("赤壁任務・東風將起：控制抗性與攻勢提升。")
	else:
		_trigger_chain_fire()
		_damage_enemy_formation(0.10, 0.6)
		_record("赤壁任務・連環火攻：火勢席捲敵陣。")


func _grant_player_supply(coins: int, shield: float, cooldown_reduction: float) -> void:
	var player: Dictionary = _player()
	if player.is_empty():
		return
	player["coins"] = int(player.get("coins", 0)) + coins
	player["shield"] = float(player.get("shield", 0.0)) + shield
	_main.set("player", player)
	if cooldown_reduction > 0.0:
		var value: Variant = _main.get("hero_cooldowns")
		if value is Dictionary:
			var cooldowns: Dictionary = value as Dictionary
			for key in cooldowns.keys():
				cooldowns[key] = maxf(0.0, float(cooldowns[key]) - cooldown_reduction)
			_main.set("hero_cooldowns", cooldowns)


func _damage_enemy_formation(hp_ratio: float, armor_break: float) -> void:
	var value: Variant = _main.get("enemies")
	if not (value is Array):
		return
	var enemies: Array = value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		var max_hp: float = maxf(1.0, float(enemy.get("max_hp", enemy.get("hp", 1.0))))
		enemy["hp"] = maxf(1.0, float(enemy.get("hp", 1.0)) - max_hp * hp_ratio)
		enemy["armor"] = maxf(0.0, float(enemy.get("armor", 0.0)) - armor_break)
		enemy["armor_break"] = maxf(float(enemy.get("armor_break", 0.0)), 2.4)
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _strengthen_enemy_wave(damage_mult: float, speed_mult: float) -> void:
	var value: Variant = _main.get("enemies")
	if not (value is Array):
		return
	var enemies: Array = value as Array
	for index in range(enemies.size()):
		if enemies[index] is Dictionary:
			var enemy: Dictionary = enemies[index] as Dictionary
			enemy["damage"] = float(enemy.get("damage", 1.0)) * damage_mult
			enemy["speed"] = minf(220.0, float(enemy.get("speed", 1.0)) * speed_mult)
			enemies[index] = enemy
	_main.set("enemies", enemies)


func _trigger_chain_fire() -> void:
	var zones_value: Variant = _main.get("zones")
	var enemies_value: Variant = _main.get("enemies")
	if not (zones_value is Array) or not (enemies_value is Array):
		return
	var zones: Array = zones_value as Array
	var enemies: Array = enemies_value as Array
	var count: int = mini(8, enemies.size())
	for index in range(count):
		if enemies[index] is Dictionary:
			var enemy: Dictionary = enemies[index] as Dictionary
			var pos_value: Variant = enemy.get("pos", Vector2.ZERO)
			var pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
			zones.append({
				"kind": "fire",
				"pos": pos,
				"r": 54.0,
				"life": 2.8,
				"tick": 0.0,
				"damage": 7.0 + float(_chapter_index),
				"color": Color8(239, 114, 48),
			})
	while zones.size() > 70:
		zones.pop_front()
	_main.set("zones", zones)


func _spawn_warning_line(color: Color, count: int, radius: float, damage: float) -> void:
	var zones_value: Variant = _main.get("zones")
	var player: Dictionary = _player()
	if not (zones_value is Array) or player.is_empty():
		return
	var zones: Array = zones_value as Array
	var pos_value: Variant = player.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	for index in range(count):
		var offset: Vector2 = Vector2((float(index) - float(count - 1) * 0.5) * 105.0, 0.0)
		zones.append({
			"kind": "enemy_warning",
			"pos": center + offset,
			"r": radius,
			"life": 1.1,
			"damage": damage,
			"color": color,
		})
	_main.set("zones", zones)


func _advance_hero_arrival(amount: float) -> void:
	var timer: float = float(_main.get("hero_spawn_timer"))
	_main.set("hero_spawn_timer", maxf(5.0, timer - amount))


func _damage_taken() -> float:
	var value: Variant = _main.get("run_stats")
	if value is Dictionary:
		return float((value as Dictionary).get("damage_taken", 0.0))
	return 0.0


func _flags() -> Dictionary:
	var value: Variant = _main.get("history_flags")
	return value as Dictionary if value is Dictionary else {}


func _player() -> Dictionary:
	var value: Variant = _main.get("player")
	return value as Dictionary if value is Dictionary else {}


func _record(text: String) -> void:
	if _main.has_method("show_message"):
		_main.call("show_message", text, 3.4)
	var log_value: Variant = _main.get("history_log")
	var log: Array = log_value as Array if log_value is Array else []
	log.append(text)
	while log.size() > 24:
		log.pop_front()
	_main.set("history_log", log)
	var player: Dictionary = _player()
	if not player.is_empty():
		var recap_value: Variant = player.get("alpha20_chapter_recap", [])
		var recap: Array = recap_value as Array if recap_value is Array else []
		recap.append(text)
		while recap.size() > 8:
			recap.pop_front()
		player["alpha20_chapter_recap"] = recap
		_main.set("player", player)
