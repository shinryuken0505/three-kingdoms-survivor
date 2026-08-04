extends Node

## Alpha.19 主戰名將特色效果層。
## 監看既有 hero_cast_flash，在名將施放時追加一次性特色效果。

var _main: Node = null
var _last_cast_key: String = ""


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		_last_cast_key = ""
		return
	var flash_value: Variant = _main.get("hero_cast_flash")
	if not (flash_value is Dictionary):
		return
	var flash: Dictionary = flash_value as Dictionary
	if flash.is_empty():
		_last_cast_key = ""
		return
	var hero_id: String = str(flash.get("id", ""))
	var life: float = float(flash.get("life", 0.0))
	var max_life: float = float(flash.get("max_life", life))
	var cast_key: String = "%s:%d" % [hero_id, int(max_life * 1000.0)]
	if hero_id.is_empty() or life < max_life - 0.12 or cast_key == _last_cast_key:
		return
	_last_cast_key = cast_key
	_apply_signature(hero_id, flash)


func _apply_signature(hero_id: String, flash: Dictionary) -> void:
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	var level: int = _hero_level(hero_id)
	if hero_id == "huatuo":
		var hp: float = float(player.get("hp", 0.0))
		var max_hp: float = float(player.get("max_hp", hp))
		if hp >= max_hp - 0.5:
			player["shield"] = float(player.get("shield", 0.0)) + 8.0 + float(level) * 2.5
	elif hero_id == "caocao":
		_reduce_other_hero_cooldowns(hero_id, 0.35 + float(level) * 0.08)
	elif hero_id == "zhaoyun":
		player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 0.55 + float(level) * 0.08)
	elif hero_id == "daqiao":
		if float(player.get("shield", 0.0)) > 0.0:
			player["shield"] = float(player.get("shield", 0.0)) + 4.0 + float(level) * 1.5
	elif hero_id == "wangyi":
		player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 0.42 + float(level) * 0.07)
	elif hero_id == "zhangjiao":
		_trigger_poison_lightning(level)
	elif hero_id == "taishici":
		_mark_nearest_enemy(level)
	elif hero_id == "guanyu":
		_break_nearby_armor(flash, level)
	elif hero_id == "zhangfei":
		_weaken_nearby_enemies(flash, level)
	_main.set("player", player)


func _hero_level(hero_id: String) -> int:
	var levels_value: Variant = _main.get("hero_skill_levels")
	if levels_value is Dictionary:
		return maxi(1, int((levels_value as Dictionary).get(hero_id, 1)))
	return 1


func _reduce_other_hero_cooldowns(source_id: String, amount: float) -> void:
	var value: Variant = _main.get("hero_cooldowns")
	if not (value is Dictionary):
		return
	var cooldowns: Dictionary = value as Dictionary
	for key in cooldowns.keys():
		if str(key) != source_id:
			cooldowns[key] = maxf(0.0, float(cooldowns[key]) - amount)
	_main.set("hero_cooldowns", cooldowns)


func _trigger_poison_lightning(level: int) -> void:
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if float(enemy.get("poison", 0.0)) >= 3.0 and _main.has_method("damage_enemy"):
			_main.call("damage_enemy", index, 7.0 + float(level) * 3.0, "lightning", false)
			break


func _mark_nearest_enemy(level: int) -> void:
	var enemies_value: Variant = _main.get("enemies")
	var player_value: Variant = _main.get("player")
	if not (enemies_value is Array) or not (player_value is Dictionary):
		return
	var enemies: Array = enemies_value as Array
	var player: Dictionary = player_value as Dictionary
	var pos_value: Variant = player.get("pos", Vector2.ZERO)
	var player_pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var best_index: int = -1
	var best_distance: float = INF
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		var enemy_pos_value: Variant = enemy.get("pos", Vector2.ZERO)
		var enemy_pos: Vector2 = enemy_pos_value if enemy_pos_value is Vector2 else Vector2.ZERO
		var distance: float = player_pos.distance_squared_to(enemy_pos)
		if distance < best_distance:
			best_distance = distance
			best_index = index
	if best_index >= 0:
		enemies[best_index]["marked"] = maxf(float(enemies[best_index].get("marked", 0.0)), 2.5 + float(level) * 0.35)
		_main.set("enemies", enemies)


func _break_nearby_armor(flash: Dictionary, level: int) -> void:
	var pos_value: Variant = flash.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		var enemy_pos_value: Variant = enemy.get("pos", Vector2.ZERO)
		var enemy_pos: Vector2 = enemy_pos_value if enemy_pos_value is Vector2 else Vector2.ZERO
		if enemy_pos.distance_squared_to(center) <= 220.0 * 220.0:
			enemy["armor_break"] = maxf(float(enemy.get("armor_break", 0.0)), 2.0 + float(level) * 0.3)
			enemy["armor"] = maxf(0.0, float(enemy.get("armor", 0.0)) - 0.5 - float(level) * 0.12)
			enemies[index] = enemy
	_main.set("enemies", enemies)


func _weaken_nearby_enemies(flash: Dictionary, level: int) -> void:
	var pos_value: Variant = flash.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		var enemy_pos_value: Variant = enemy.get("pos", Vector2.ZERO)
		var enemy_pos: Vector2 = enemy_pos_value if enemy_pos_value is Vector2 else Vector2.ZERO
		if enemy_pos.distance_squared_to(center) <= 250.0 * 250.0:
			if not bool(enemy.get("alpha19_weakened", false)):
				enemy["damage"] = maxf(1.0, float(enemy.get("damage", 1.0)) * (0.90 - minf(0.08, float(level) * 0.01)))
				enemy["alpha19_weakened"] = true
			enemies[index] = enemy
	_main.set("enemies", enemies)
