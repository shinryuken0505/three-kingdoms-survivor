extends Node

## Alpha.19 張飛主動技震波。
## 偵測既有 hero_cast_flash 的張飛施放事件，產生由內向外擴散的傷害／擊退波。
## 不改寫原名將技能資料，也不接管輸入。

var _main: Node = null
var _cast_active: bool = false
var _waves: Array[Dictionary] = []


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		_cast_active = false
		_waves.clear()
		return
	_detect_cast()
	_update_waves(delta)


func _detect_cast() -> void:
	var flash_value: Variant = _main.get("hero_cast_flash")
	var is_zhangfei: bool = false
	var center: Vector2 = Vector2.ZERO
	if flash_value is Dictionary:
		var flash: Dictionary = flash_value as Dictionary
		is_zhangfei = str(flash.get("id", "")) == "zhangfei" and float(flash.get("life", 0.0)) > 0.0
		var pos_value: Variant = flash.get("pos", Vector2.ZERO)
		if pos_value is Vector2:
			center = pos_value as Vector2
	if is_zhangfei and not _cast_active:
		_start_wave(center)
	_cast_active = is_zhangfei


func _start_wave(center: Vector2) -> void:
	var levels_value: Variant = _main.get("hero_skill_levels")
	var level: int = 1
	if levels_value is Dictionary:
		level = maxi(1, int((levels_value as Dictionary).get("zhangfei", 1)))
	var player_value: Variant = _main.get("player")
	var base_damage: float = 18.0
	if player_value is Dictionary:
		base_damage = float((player_value as Dictionary).get("damage", 10.0))
	_waves.append({
		"center": center,
		"radius": 24.0,
		"previous_radius": 0.0,
		"max_radius": 180.0 + float(level) * 18.0,
		"speed": 420.0 + float(level) * 24.0,
		"damage": base_damage * (0.72 + float(level) * 0.12),
		"knock": 220.0 + float(level) * 28.0,
		"hit_uids": {},
		"boss_hit": false,
	})
	if _main.has_method("play_sfx"):
		_main.call("play_sfx", "hero", 0.90)


func _update_waves(delta: float) -> void:
	for wave_index in range(_waves.size() - 1, -1, -1):
		var wave: Dictionary = _waves[wave_index]
		wave["previous_radius"] = float(wave.get("radius", 0.0))
		wave["radius"] = float(wave.get("radius", 0.0)) + float(wave.get("speed", 420.0)) * delta
		_damage_wave(wave)
		_draw_wave_feedback(wave)
		if float(wave.get("radius", 0.0)) >= float(wave.get("max_radius", 200.0)):
			_waves.remove_at(wave_index)
		else:
			_waves[wave_index] = wave


func _damage_wave(wave: Dictionary) -> void:
	var center_value: Variant = wave.get("center", Vector2.ZERO)
	var center: Vector2 = center_value if center_value is Vector2 else Vector2.ZERO
	var radius: float = float(wave.get("radius", 0.0))
	var previous_radius: float = float(wave.get("previous_radius", 0.0))
	var damage: float = float(wave.get("damage", 10.0))
	var knock: float = float(wave.get("knock", 200.0))
	var hit_uids: Dictionary = wave.get("hit_uids", {}) as Dictionary
	var enemies_value: Variant = _main.get("enemies")
	if enemies_value is Array:
		var enemies: Array = enemies_value as Array
		for index in range(enemies.size() - 1, -1, -1):
			if index >= enemies.size() or not (enemies[index] is Dictionary):
				continue
			var enemy: Dictionary = enemies[index] as Dictionary
			var uid: int = int(enemy.get("uid", index))
			if hit_uids.has(uid):
				continue
			var pos_value: Variant = enemy.get("pos", Vector2.ZERO)
			var pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
			var distance: float = pos.distance_to(center)
			if distance > radius or distance < previous_radius - 30.0:
				continue
			hit_uids[uid] = true
			var live_index: int = index
			if _main.has_method("damage_enemy"):
				var result: Variant = _main.call("damage_enemy", index, damage, "zhangfei", false)
				live_index = int(result)
			if live_index >= 0 and live_index < enemies.size():
				var direction: Vector2 = (pos - center).normalized()
				if direction.length_squared() <= 0.01:
					direction = Vector2.RIGHT
				enemies[live_index]["knock"] = enemies[live_index].get("knock", Vector2.ZERO) + direction * knock
	wave["hit_uids"] = hit_uids
	if bool(wave.get("boss_hit", false)):
		return
	var boss_value: Variant = _main.get("boss")
	if not (boss_value is Dictionary):
		return
	var boss: Dictionary = boss_value as Dictionary
	if boss.is_empty():
		return
	var boss_pos_value: Variant = boss.get("pos", Vector2.ZERO)
	var boss_pos: Vector2 = boss_pos_value if boss_pos_value is Vector2 else Vector2.ZERO
	var boss_radius: float = float(boss.get("radius", 0.0))
	var boss_distance: float = boss_pos.distance_to(center)
	if boss_distance <= radius + boss_radius and boss_distance >= previous_radius - boss_radius - 30.0:
		wave["boss_hit"] = true
		if _main.has_method("damage_boss"):
			_main.call("damage_boss", damage, "zhangfei", false)


func _draw_wave_feedback(wave: Dictionary) -> void:
	if not _main.has_method("spawn_ring"):
		return
	var center_value: Variant = wave.get("center", Vector2.ZERO)
	var center: Vector2 = center_value if center_value is Vector2 else Vector2.ZERO
	_main.call("spawn_ring", center, Color8(232, 155, 72), float(wave.get("radius", 40.0)), 0.10)
