extends Node

## Alpha.19 後備被動執行層。
## 每次先移除上一輪聚合值，再套用目前後備名將結果，避免重複疊加。

const PassiveServiceScript = preload("res://scripts/systems/hero/reserve_passive_service.gd")

var _main: Node = null


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null:
		return
	var player_value: Variant = _main.get("player")
	var reserve_value: Variant = _main.get("reserve_heroes")
	if not (player_value is Dictionary) or not (reserve_value is Array):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	_remove_previous(player)
	var aggregate: Dictionary = PassiveServiceScript.aggregate(reserve_value as Array)
	_apply(player, aggregate)
	player["alpha19_reserve_state"] = aggregate
	_main.set("player", player)


func _remove_previous(player: Dictionary) -> void:
	var state_value: Variant = player.get("alpha19_reserve_state", {})
	if not (state_value is Dictionary):
		return
	var state: Dictionary = state_value as Dictionary
	player["damage"] = float(player.get("damage", 1.0)) / (1.0 + float(state.get("damage_mult", 0.0)))
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) / (1.0 + float(state.get("projectile_mult", 0.0)))
	player["poison_power"] = float(player.get("poison_power", 1.0)) / (1.0 + float(state.get("poison_mult", 0.0)))
	player["heal_power"] = float(player.get("heal_power", 1.0)) / (1.0 + float(state.get("heal_mult", 0.0)))
	player["speed"] = float(player.get("speed", 1.0)) / (1.0 + float(state.get("speed_mult", 0.0)))
	player["crit"] = float(player.get("crit", 0.0)) - float(state.get("crit_add", 0.0))
	player["armor"] = float(player.get("armor", 0.0)) - float(state.get("armor_add", 0.0))
	player["hero_cd_mult"] = float(player.get("hero_cd_mult", 1.0)) / maxf(0.01, 1.0 - float(state.get("hero_cd_reduction", 0.0)))
	player["attack_interval"] = float(player.get("attack_interval", 1.0)) / maxf(0.01, 1.0 - float(state.get("attack_speed_reduction", 0.0)))
	player["control_resist"] = float(player.get("control_resist", 0.0)) - float(state.get("control_resist_add", 0.0))


func _apply(player: Dictionary, state: Dictionary) -> void:
	player["damage"] = float(player.get("damage", 1.0)) * (1.0 + float(state.get("damage_mult", 0.0)))
	player["projectile_mult"] = float(player.get("projectile_mult", 1.0)) * (1.0 + float(state.get("projectile_mult", 0.0)))
	player["poison_power"] = float(player.get("poison_power", 1.0)) * (1.0 + float(state.get("poison_mult", 0.0)))
	player["heal_power"] = float(player.get("heal_power", 1.0)) * (1.0 + float(state.get("heal_mult", 0.0)))
	player["speed"] = float(player.get("speed", 1.0)) * (1.0 + float(state.get("speed_mult", 0.0)))
	player["crit"] = clampf(float(player.get("crit", 0.0)) + float(state.get("crit_add", 0.0)), 0.0, 0.75)
	player["armor"] = maxf(0.0, float(player.get("armor", 0.0)) + float(state.get("armor_add", 0.0)))
	player["hero_cd_mult"] = float(player.get("hero_cd_mult", 1.0)) * maxf(0.55, 1.0 - float(state.get("hero_cd_reduction", 0.0)))
	player["attack_interval"] = float(player.get("attack_interval", 1.0)) * maxf(0.55, 1.0 - float(state.get("attack_speed_reduction", 0.0)))
	player["control_resist"] = clampf(float(player.get("control_resist", 0.0)) + float(state.get("control_resist_add", 0.0)), 0.0, 0.75)
