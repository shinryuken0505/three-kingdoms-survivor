extends Node

## Alpha.19 主戰名將專精執行層。
## 依目前主戰名將與技能等級提供可辨識的戰鬥差異，採移除舊值再重算，避免無限疊加。

var _main: Node = null


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null:
		return
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	_remove_previous(player)
	if str(_main.get("screen")) == "game":
		_apply_current(player)
	_main.set("player", player)


func _apply_current(player: Dictionary) -> void:
	var active_value: Variant = _main.get("active_heroes")
	var levels_value: Variant = _main.get("hero_skill_levels")
	if not (active_value is Array) or not (levels_value is Dictionary):
		return
	var active: Array = active_value as Array
	var levels: Dictionary = levels_value as Dictionary
	var state: Dictionary = {
		"damage_mult": 1.0,
		"projectile_mult": 1.0,
		"poison_mult": 1.0,
		"heal_mult": 1.0,
		"speed_mult": 1.0,
		"hero_cd_mult": 1.0,
		"armor_add": 0.0,
		"crit_add": 0.0,
		"control_add": 0.0,
	}
	for value in active:
		var hero_id: String = str(value)
		var level: int = maxi(1, int(levels.get(hero_id, 1)))
		_apply_hero(state, hero_id, level)
	_cap_state(state)
	player["damage"] = float(player.get("damage", 1.0)) * float(state["damage_mult"])
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) * float(state["projectile_mult"])
	player["poison_power"] = float(player.get("poison_power", 1.0)) * float(state["poison_mult"])
	player["heal_power"] = float(player.get("heal_power", 1.0)) * float(state["heal_mult"])
	player["speed"] = float(player.get("speed", 1.0)) * float(state["speed_mult"])
	player["hero_cd_mult"] = float(player.get("hero_cd_mult", 1.0)) * float(state["hero_cd_mult"])
	player["armor"] = maxf(0.0, float(player.get("armor", 0.0)) + float(state["armor_add"]))
	player["crit"] = clampf(float(player.get("crit", 0.0)) + float(state["crit_add"]), 0.0, 0.80)
	player["control_resist"] = clampf(float(player.get("control_resist", 0.0)) + float(state["control_add"]), 0.0, 0.75)
	player["alpha19_active_specialization_state"] = state


func _apply_hero(state: Dictionary, hero_id: String, level: int) -> void:
	var scale: float = float(level)
	if hero_id == "guanyu":
		state["damage_mult"] = float(state["damage_mult"]) + minf(0.16, 0.025 * scale)
	elif hero_id == "zhangfei":
		state["armor_add"] = float(state["armor_add"]) + minf(2.4, 0.42 * scale)
		state["control_add"] = float(state["control_add"]) + minf(0.14, 0.025 * scale)
	elif hero_id == "zhaoyun":
		state["speed_mult"] = float(state["speed_mult"]) + minf(0.14, 0.022 * scale)
		state["crit_add"] = float(state["crit_add"]) + minf(0.08, 0.012 * scale)
	elif hero_id == "huangzhong":
		state["projectile_mult"] = float(state["projectile_mult"]) + minf(0.20, 0.032 * scale)
	elif hero_id == "huatuo":
		state["heal_mult"] = float(state["heal_mult"]) + minf(0.24, 0.04 * scale)
	elif hero_id == "caocao":
		state["hero_cd_mult"] = float(state["hero_cd_mult"]) * maxf(0.78, 1.0 - 0.035 * scale)
	elif hero_id == "sunjian":
		state["damage_mult"] = float(state["damage_mult"]) + minf(0.12, 0.02 * scale)
		state["speed_mult"] = float(state["speed_mult"]) + minf(0.10, 0.016 * scale)
	elif hero_id == "taishici":
		state["projectile_mult"] = float(state["projectile_mult"]) + minf(0.14, 0.023 * scale)
		state["crit_add"] = float(state["crit_add"]) + minf(0.06, 0.01 * scale)
	elif hero_id == "zhangjiao":
		state["poison_mult"] = float(state["poison_mult"]) + minf(0.24, 0.04 * scale)
	elif hero_id == "diaochan":
		state["control_add"] = float(state["control_add"]) + minf(0.18, 0.03 * scale)
	elif hero_id == "sunshangxiang":
		state["projectile_mult"] = float(state["projectile_mult"]) + minf(0.16, 0.026 * scale)
	elif hero_id == "zhenji":
		state["armor_add"] = float(state["armor_add"]) + minf(1.8, 0.30 * scale)
		state["control_add"] = float(state["control_add"]) + minf(0.12, 0.02 * scale)
	elif hero_id == "lvlingqi":
		state["damage_mult"] = float(state["damage_mult"]) + minf(0.15, 0.025 * scale)
		state["crit_add"] = float(state["crit_add"]) + minf(0.07, 0.011 * scale)
	elif hero_id == "wangyi":
		state["crit_add"] = float(state["crit_add"]) + minf(0.10, 0.016 * scale)
		state["speed_mult"] = float(state["speed_mult"]) + minf(0.10, 0.016 * scale)
	elif hero_id == "caiwenji":
		state["heal_mult"] = float(state["heal_mult"]) + minf(0.18, 0.03 * scale)
		state["control_add"] = float(state["control_add"]) + minf(0.10, 0.016 * scale)
	elif hero_id == "daqiao":
		state["armor_add"] = float(state["armor_add"]) + minf(1.6, 0.26 * scale)
		state["heal_mult"] = float(state["heal_mult"]) + minf(0.12, 0.02 * scale)


func _cap_state(state: Dictionary) -> void:
	state["damage_mult"] = minf(float(state["damage_mult"]), 1.28)
	state["projectile_mult"] = minf(float(state["projectile_mult"]), 1.34)
	state["poison_mult"] = minf(float(state["poison_mult"]), 1.30)
	state["heal_mult"] = minf(float(state["heal_mult"]), 1.34)
	state["speed_mult"] = minf(float(state["speed_mult"]), 1.20)
	state["hero_cd_mult"] = maxf(float(state["hero_cd_mult"]), 0.70)
	state["armor_add"] = minf(float(state["armor_add"]), 4.0)
	state["crit_add"] = minf(float(state["crit_add"]), 0.16)
	state["control_add"] = minf(float(state["control_add"]), 0.28)


func _remove_previous(player: Dictionary) -> void:
	var value: Variant = player.get("alpha19_active_specialization_state", {})
	if not (value is Dictionary):
		return
	var state: Dictionary = value as Dictionary
	player["damage"] = float(player.get("damage", 1.0)) / maxf(0.01, float(state.get("damage_mult", 1.0)))
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) / maxf(0.01, float(state.get("projectile_mult", 1.0)))
	player["poison_power"] = float(player.get("poison_power", 1.0)) / maxf(0.01, float(state.get("poison_mult", 1.0)))
	player["heal_power"] = float(player.get("heal_power", 1.0)) / maxf(0.01, float(state.get("heal_mult", 1.0)))
	player["speed"] = float(player.get("speed", 1.0)) / maxf(0.01, float(state.get("speed_mult", 1.0)))
	player["hero_cd_mult"] = float(player.get("hero_cd_mult", 1.0)) / maxf(0.01, float(state.get("hero_cd_mult", 1.0)))
	player["armor"] = float(player.get("armor", 0.0)) - float(state.get("armor_add", 0.0))
	player["crit"] = float(player.get("crit", 0.0)) - float(state.get("crit_add", 0.0))
	player["control_resist"] = float(player.get("control_resist", 0.0)) - float(state.get("control_add", 0.0))
	player.erase("alpha19_active_specialization_state")
