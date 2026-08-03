extends Node

## 招募與名將整備的執行期防呆層。
##
## 不接管輸入，只在編成資料變更後進行正規化與初始化，避免同一名將同時存在於
## 主戰、後備、營地，或招募後漏掉圖鑑、技能等級、羈絆等級與冷卻資料。

const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")

var _main: Node = null
var _last_signature: String = ""


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null:
		return
	var active_value: Variant = _main.get("active_heroes")
	var reserve_value: Variant = _main.get("reserve_heroes")
	var camp_value: Variant = _main.get("camp_heroes")
	if not (active_value is Array) or not (reserve_value is Array) or not (camp_value is Array):
		return
	var active: Array = active_value as Array
	var reserve: Array = reserve_value as Array
	var camp: Array = camp_value as Array
	var signature: String = "%s|%s|%s" % [str(active), str(reserve), str(camp)]
	if signature == _last_signature:
		return
	HeroRosterManagerScript.normalize(active, reserve, camp)
	_initialize_roster(active, reserve, camp)
	_last_signature = "%s|%s|%s" % [str(active), str(reserve), str(camp)]


func _initialize_roster(active: Array, reserve: Array, camp: Array) -> void:
	var known_value: Variant = _main.get("known_heroes")
	var skill_value: Variant = _main.get("hero_skill_levels")
	var bond_value: Variant = _main.get("hero_bond_levels")
	var cooldown_value: Variant = _main.get("hero_cooldowns")
	var heroes_value: Variant = _main.get("heroes")
	if not (known_value is Dictionary):
		return
	if not (skill_value is Dictionary) or not (bond_value is Dictionary) or not (cooldown_value is Dictionary):
		return
	if not (heroes_value is Dictionary):
		return
	var known: Dictionary = known_value as Dictionary
	var skill_levels: Dictionary = skill_value as Dictionary
	var bond_levels: Dictionary = bond_value as Dictionary
	var cooldowns: Dictionary = cooldown_value as Dictionary
	var hero_defs: Dictionary = heroes_value as Dictionary
	var all_ids: Array = []
	all_ids.append_array(active)
	all_ids.append_array(reserve)
	all_ids.append_array(camp)
	for value in all_ids:
		var hero_id: String = str(value)
		if hero_id.is_empty() or not hero_defs.has(hero_id):
			continue
		known[hero_id] = true
		if not skill_levels.has(hero_id):
			skill_levels[hero_id] = 1
		if not bond_levels.has(hero_id):
			bond_levels[hero_id] = 1
		if active.has(hero_id) and not cooldowns.has(hero_id):
			cooldowns[hero_id] = 0.0
		if not active.has(hero_id):
			cooldowns.erase(hero_id)
