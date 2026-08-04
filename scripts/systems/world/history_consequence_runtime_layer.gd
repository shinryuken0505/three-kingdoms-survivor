extends Node

## Alpha.20 歷史選擇後續影響層。
## 將既有 history_flags 轉為援軍、商人、伏兵與敵軍波次差異。

var _main: Node = null
var _chapter_index: int = -1
var _applied: Dictionary = {}


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var chapter_index: int = _current_chapter_index()
	if chapter_index != _chapter_index:
		_chapter_index = chapter_index
		_applied.clear()
	_apply_route_consequences()
	_apply_enemy_wave_consequences()


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return maxi(0, int(manager.call("current_index_value")))
	return 0


func _flags() -> Dictionary:
	var value: Variant = _main.get("history_flags")
	return value as Dictionary if value is Dictionary else {}


func _apply_route_consequences() -> void:
	var flags: Dictionary = _flags()
	if flags.is_empty():
		return
	if flags.has("saved_civilians"):
		_apply_once("saved_civilians", Callable(self, "_grant_civilian_support"))
	if flags.has("three_heroes_challenge"):
		_apply_once("three_heroes_challenge", Callable(self, "_grant_allied_momentum"))
	if flags.has("wenji_return"):
		_apply_once("wenji_return", Callable(self, "_grant_wenji_support"))
	if flags.has("fire_plan"):
		_apply_once("fire_plan", Callable(self, "_prepare_fire_plan"))
	if flags.has("merchant_route") or flags.has("secured_supply_route"):
		_apply_once("merchant_route", Callable(self, "_advance_merchant_arrival"))
	if flags.has("recruitment_support") or flags.has("rescued_officer"):
		_apply_once("recruitment_support", Callable(self, "_advance_hero_arrival"))


func _apply_once(key: String, action: Callable) -> void:
	var scoped_key: String = "%d:%s" % [_chapter_index, key]
	if bool(_applied.get(scoped_key, false)):
		return
	_applied[scoped_key] = true
	action.call()


func _grant_civilian_support() -> void:
	var player: Dictionary = _player()
	if player.is_empty():
		return
	player["shield"] = float(player.get("shield", 0.0)) + 10.0
	player["hp"] = minf(float(player.get("max_hp", 1.0)), float(player.get("hp", 0.0)) + 7.0)
	_main.set("player", player)
	_record("百姓送來補給：生命與護盾獲得補充。")


func _grant_allied_momentum() -> void:
	var cooldowns_value: Variant = _main.get("hero_cooldowns")
	if cooldowns_value is Dictionary:
		var cooldowns: Dictionary = cooldowns_value as Dictionary
		for key in cooldowns.keys():
			cooldowns[key] = maxf(0.0, float(cooldowns[key]) - 1.5)
		_main.set("hero_cooldowns", cooldowns)
	var player: Dictionary = _player()
	if not player.is_empty():
		player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 2.2)
		_main.set("player", player)
	_record("盟軍士氣高漲：名將冷卻縮短。")


func _grant_wenji_support() -> void:
	var player: Dictionary = _player()
	if player.is_empty():
		return
	player["control_resist"] = maxf(float(player.get("control_resist", 0.0)), 0.18)
	player["shield"] = float(player.get("shield", 0.0)) + 6.0
	_main.set("player", player)
	_record("胡笳定軍心：控制抗性提高。")


func _prepare_fire_plan() -> void:
	var enemies_value: Variant = _main.get("enemies")
	if enemies_value is Array:
		var enemies: Array = enemies_value as Array
		for index in range(enemies.size()):
			if enemies[index] is Dictionary:
				var enemy: Dictionary = enemies[index] as Dictionary
				enemy["armor"] = maxf(0.0, float(enemy.get("armor", 0.0)) - 0.7)
				enemy["alpha20_fire_plan"] = true
				enemies[index] = enemy
		_main.set("enemies", enemies)
	_record("火攻準備完成：敵軍護甲降低。")


func _advance_merchant_arrival() -> void:
	var timer: float = float(_main.get("merchant_spawn_timer"))
	_main.set("merchant_spawn_timer", maxf(8.0, timer - 28.0))
	_record("商路已打通：行商將提早抵達。")


func _advance_hero_arrival() -> void:
	var timer: float = float(_main.get("hero_spawn_timer"))
	_main.set("hero_spawn_timer", maxf(6.0, timer - 18.0))
	_record("地方豪傑響應：名將遭遇提早。")


func _apply_enemy_wave_consequences() -> void:
	var flags: Dictionary = _flags()
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if bool(enemy.get("alpha20_history_wave_applied", false)):
			continue
		if flags.has("avoided_ambush") or flags.has("scouted_route"):
			enemy["damage"] = float(enemy.get("damage", 1.0)) * 0.94
			enemy["shoot_cd"] = float(enemy.get("shoot_cd", 1.5)) * 1.08
		if flags.has("provoked_ambush") or flags.has("took_risky_route"):
			enemy["speed"] = minf(215.0, float(enemy.get("speed", 1.0)) * 1.05)
			enemy["damage"] = float(enemy.get("damage", 1.0)) * 1.04
		if flags.has("fire_plan"):
			enemy["armor"] = maxf(0.0, float(enemy.get("armor", 0.0)) - 0.35)
		enemy["alpha20_history_wave_applied"] = true
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _player() -> Dictionary:
	var value: Variant = _main.get("player")
	return value as Dictionary if value is Dictionary else {}


func _record(text: String) -> void:
	if _main.has_method("show_message"):
		_main.call("show_message", text, 3.0)
	var log_value: Variant = _main.get("history_log")
	var log: Array = log_value as Array if log_value is Array else []
	log.append("第%d章・%s" % [_chapter_index + 1, text])
	while log.size() > 24:
		log.pop_front()
	_main.set("history_log", log)
