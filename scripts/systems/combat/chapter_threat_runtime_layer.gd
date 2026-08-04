extends Node

## Alpha.19 中後期威脅層。
## 第三章起對新生成敵軍與 Boss 套用一次性的傷害與攻擊節奏修正。

var _main: Node = null


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var chapter_number: int = _chapter_number()
	if chapter_number < 3:
		return
	_apply_enemy_threat(chapter_number)
	_apply_boss_threat(chapter_number)


func _chapter_number() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return int(manager.call("current_index_value")) + 1
	return 1


func _apply_enemy_threat(chapter_number: int) -> void:
	var value: Variant = _main.get("enemies")
	if not (value is Array):
		return
	var enemies: Array = value as Array
	var damage_mult: float = 1.0 + minf(0.24, float(chapter_number - 2) * 0.045)
	var speed_mult: float = 1.0 + minf(0.13, float(chapter_number - 2) * 0.022)
	var cadence_mult: float = maxf(0.76, 1.0 - float(chapter_number - 2) * 0.045)
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if bool(enemy.get("alpha19_threat_applied", false)):
			continue
		enemy["damage"] = float(enemy.get("damage", 1.0)) * damage_mult
		enemy["speed"] = float(enemy.get("speed", 1.0)) * speed_mult
		if enemy.has("shoot_cd"):
			enemy["shoot_cd"] = maxf(0.55, float(enemy.get("shoot_cd", 1.5)) * cadence_mult)
		if enemy.has("ability_cd"):
			enemy["ability_cd"] = maxf(1.6, float(enemy.get("ability_cd", 3.0)) * cadence_mult)
		if str(enemy.get("kind", "")) in ["archer", "crossbow", "firepot", "tactician", "caster_slow", "caster_bind", "caster_smoke"]:
			enemy["shoot_cd"] = maxf(0.48, float(enemy.get("shoot_cd", 1.2)) * 0.90)
		enemy["alpha19_threat_applied"] = true
		enemy["alpha19_threat_chapter"] = chapter_number
		enemies[index] = enemy
	_main.set("enemies", enemies)


func _apply_boss_threat(chapter_number: int) -> void:
	var value: Variant = _main.get("boss")
	if not (value is Dictionary):
		return
	var boss: Dictionary = value as Dictionary
	if boss.is_empty() or bool(boss.get("alpha19_threat_applied", false)):
		return
	var damage_mult: float = 1.0 + minf(0.28, float(chapter_number - 2) * 0.055)
	var cadence_mult: float = maxf(0.72, 1.0 - float(chapter_number - 2) * 0.05)
	if boss.has("damage"):
		boss["damage"] = float(boss.get("damage", 1.0)) * damage_mult
	for key in ["attack_cd", "attack_timer", "ability_cd", "special_cd", "shoot_cd"]:
		if boss.has(key):
			boss[key] = maxf(0.55, float(boss.get(key, 1.0)) * cadence_mult)
	boss["alpha19_threat_applied"] = true
	boss["alpha19_threat_chapter"] = chapter_number
	_main.set("boss", boss)
