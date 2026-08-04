extends Node

## Alpha.20 章節身份與戰局事件執行層。
## 依章節主題調整新生成敵軍，並在戰局中段觸發兩次一次性事件。

const CatalogScript = preload("res://scripts/data/chapter_identity_catalog.gd")

var _main: Node = null
var _chapter_index: int = -1
var _event_done: Dictionary = {}


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var chapter_index: int = _current_chapter_index()
	if chapter_index != _chapter_index:
		_chapter_index = chapter_index
		_event_done.clear()
	var profile_data: Dictionary = CatalogScript.profile(chapter_index)
	_apply_enemy_identity(profile_data)
	_update_battle_events(profile_data)


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return maxi(0, int(manager.call("current_index_value")))
	return 0


func _apply_enemy_identity(profile_data: Dictionary) -> void:
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	var damage_mult: float = float(profile_data.get("damage_mult", 1.0))
	var speed_mult: float = float(profile_data.get("speed_mult", 1.0))
	var ranged_cd_mult: float = float(profile_data.get("ranged_cd_mult", 1.0))
	var armor_add: float = float(profile_data.get("armor_add", 0.0))
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if bool(enemy.get("alpha20_chapter_identity_applied", false)):
			continue
		enemy["damage"] = float(enemy.get("damage", 1.0)) * damage_mult
		enemy["speed"] = float(enemy.get("speed", 1.0)) * speed_mult
		enemy["armor"] = float(enemy.get("armor", 0.0)) + armor_add
		var kind: String = str(enemy.get("kind", ""))
		if kind in ["archer", "crossbow", "firepot", "tactician", "caster_slow", "caster_bind", "caster_smoke"]:
			enemy["shoot_cd"] = maxf(0.35, float(enemy.get("shoot_cd", 1.8)) * ranged_cd_mult)
			enemy["ability_cd"] = maxf(0.55, float(enemy.get("ability_cd", 3.0)) * ranged_cd_mult)
		enemy["alpha20_chapter_identity_applied"] = true
		enemy["alpha20_chapter_id"] = str(profile_data.get("id", "chapter"))
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _update_battle_events(profile_data: Dictionary) -> void:
	var elapsed: float = float(_main.get("elapsed"))
	var boss_time: float = 360.0
	if _main.has_method("boss_time"):
		boss_time = maxf(60.0, float(_main.call("boss_time")))
	for event_index in range(2):
		if bool(_event_done.get(event_index, false)):
			continue
		var ratio: float = CatalogScript.event_ratio(profile_data, event_index)
		if ratio <= 0.0 or elapsed < boss_time * ratio:
			continue
		_event_done[event_index] = true
		_trigger_event(profile_data, event_index)


func _trigger_event(profile_data: Dictionary, event_index: int) -> void:
	var event_name: String = str(profile_data.get("event_a" if event_index == 0 else "event_b", "戰局變化"))
	if _main.has_method("show_message"):
		_main.call("show_message", "戰局事件・%s" % event_name, 3.2)
	var chapter_id: String = str(profile_data.get("id", "yellow_turban"))
	if event_index == 0:
		_apply_first_event(chapter_id)
	else:
		_apply_second_event(chapter_id)


func _apply_first_event(chapter_id: String) -> void:
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if chapter_id in ["yellow_turban", "xuzhou", "changban"]:
		player["shield"] = float(player.get("shield", 0.0)) + 12.0
		player["hp"] = minf(float(player.get("max_hp", 1.0)), float(player.get("hp", 0.0)) + 8.0)
	elif chapter_id in ["hulao", "guandu"]:
		player["attack_speed_buff"] = maxf(float(player.get("attack_speed_buff", 0.0)), 2.8)
		_reduce_hero_cooldowns(1.2)
	elif chapter_id in ["jingzhou", "red_cliff"]:
		player["control_resist"] = maxf(float(player.get("control_resist", 0.0)), 0.22)
		player["shield"] = float(player.get("shield", 0.0)) + 8.0
	else:
		player["coins"] = int(player.get("coins", 0)) + 8
	_main.set("player", player)


func _apply_second_event(chapter_id: String) -> void:
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if chapter_id in ["luoyang", "hulao", "guandu", "changban"]:
			enemy["speed"] = minf(210.0, float(enemy.get("speed", 1.0)) * 1.06)
			enemy["damage"] = float(enemy.get("damage", 1.0)) * 1.06
		elif chapter_id in ["jingzhou", "red_cliff"]:
			enemy["ability_cd"] = maxf(0.5, float(enemy.get("ability_cd", 2.0)) * 0.82)
		else:
			enemy["armor"] = float(enemy.get("armor", 0.0)) + 0.5
		enemy["alpha20_second_event_applied"] = true
		enemies[index] = enemy
	_main.set("enemies", enemies)
	_spawn_event_warning(chapter_id)


func _reduce_hero_cooldowns(amount: float) -> void:
	var value: Variant = _main.get("hero_cooldowns")
	if not (value is Dictionary):
		return
	var cooldowns: Dictionary = value as Dictionary
	for key in cooldowns.keys():
		cooldowns[key] = maxf(0.0, float(cooldowns[key]) - amount)
	_main.set("hero_cooldowns", cooldowns)


func _spawn_event_warning(chapter_id: String) -> void:
	var zones_value: Variant = _main.get("zones")
	var player_value: Variant = _main.get("player")
	if not (zones_value is Array) or not (player_value is Dictionary):
		return
	var zones: Array = zones_value as Array
	var player: Dictionary = player_value as Dictionary
	var pos_value: Variant = player.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var color: Color = Color8(226, 160, 76)
	if chapter_id in ["jingzhou", "red_cliff"]:
		color = Color8(102, 177, 218)
	zones.append({
		"kind": "enemy_warning",
		"pos": center + Vector2(120.0, 0.0),
		"r": 92.0,
		"life": 1.15,
		"damage": 8.0 + float(_chapter_index) * 1.5,
		"color": color,
	})
	_main.set("zones", zones)
