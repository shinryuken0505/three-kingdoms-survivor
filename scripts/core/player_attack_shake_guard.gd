extends Node

## 高頻率攻擊震動防護。
## 玩家基礎攻擊與名將施放時強制關閉畫面震動；Boss重大演出仍可保留。

func _ready() -> void:
	process_priority = 100000
	process_physics_priority = 100000


func _process(_delta: float) -> void:
	_apply_guard()


func _physics_process(_delta: float) -> void:
	_apply_guard()


func _apply_guard() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	if str(scene.get("screen")) != "game":
		return

	var boss_active := false
	var boss_anim: Variant = scene.get("boss_action_anim")
	if boss_anim is Dictionary and not (boss_anim as Dictionary).is_empty():
		boss_active = true
	var boss_timeline: Variant = scene.get("boss_attack_timeline")
	if boss_timeline is Dictionary and not (boss_timeline as Dictionary).is_empty():
		boss_active = true
	var boss_banner: Variant = scene.get("boss_ability_banner")
	if boss_banner is Dictionary and not (boss_banner as Dictionary).is_empty():
		boss_active = true

	var player_anim: Variant = scene.get("player_action_anim")
	var hero_flash: Variant = scene.get("hero_cast_flash")
	var player_or_hero_attacking := false
	if player_anim is Dictionary and not (player_anim as Dictionary).is_empty():
		player_or_hero_attacking = true
	if hero_flash is Dictionary and not (hero_flash as Dictionary).is_empty():
		player_or_hero_attacking = true

	if player_or_hero_attacking and not boss_active:
		scene.set("screen_shake", 0.0)
		var save_data: Variant = scene.get("save_data")
		if save_data is Dictionary:
			var settings: Variant = (save_data as Dictionary).get("settings", {})
			if settings is Dictionary:
				(settings as Dictionary)["shake"] = false
				(save_data as Dictionary)["settings"] = settings
				scene.set("save_data", save_data)
	elif boss_active:
		var save_data_boss: Variant = scene.get("save_data")
		if save_data_boss is Dictionary:
			var settings_boss: Variant = (save_data_boss as Dictionary).get("settings", {})
			if settings_boss is Dictionary:
				(settings_boss as Dictionary)["shake"] = true
				(save_data_boss as Dictionary)["settings"] = settings_boss
				scene.set("save_data", save_data_boss)
