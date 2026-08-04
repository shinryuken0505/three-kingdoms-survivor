extends Node

## Alpha.19 第三章後敵軍攻擊節奏。
## 對新生成的遠程兵、突擊兵與術士加入分批攻擊偏移，避免全體同一幀齊射，
## 同時讓中後期兵種更有分工。每名敵軍只初始化一次。

var _main: Node = null


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var chapter_index: int = _chapter_index()
	if chapter_index < 2:
		return
	var enemies_value: Variant = _main.get("enemies")
	if not (enemies_value is Array):
		return
	var enemies: Array = enemies_value as Array
	var changed: bool = false
	for index in range(enemies.size()):
		if not (enemies[index] is Dictionary):
			continue
		var enemy: Dictionary = enemies[index] as Dictionary
		if bool(enemy.get("alpha19_tactic_ready", false)):
			continue
		_initialize_tactic(enemy, chapter_index)
		enemies[index] = enemy
		changed = true
	if changed:
		_main.set("enemies", enemies)


func _initialize_tactic(enemy: Dictionary, chapter_index: int) -> void:
	var kind: String = str(enemy.get("kind", ""))
	var phase: int = abs(int(enemy.get("uid", 0))) % 4
	var chapter_bonus: float = minf(0.75, float(chapter_index - 1) * 0.08)
	enemy["alpha19_tactic_ready"] = true
	enemy["alpha19_tactic"] = "advance"
	if kind in ["archer", "crossbow"]:
		enemy["alpha19_tactic"] = "volley_%d" % phase
		# 四個分隊錯開首輪射擊；後續冷卻仍由原 AI 控制。
		enemy["shoot_cd"] = maxf(0.35, float(enemy.get("shoot_cd", 2.0)) + float(phase) * 0.34 - chapter_bonus)
	elif kind == "firepot":
		enemy["alpha19_tactic"] = "area_denial"
		enemy["ability_cd"] = maxf(1.8, float(enemy.get("ability_cd", 4.0)) - chapter_bonus)
	elif kind in ["caster_slow", "caster_bind", "caster_smoke", "tactician"]:
		enemy["alpha19_tactic"] = "control_support"
		enemy["ability_cd"] = maxf(1.6, float(enemy.get("ability_cd", 3.6)) - chapter_bonus * 1.25)
	elif kind in ["cavalry", "assassin", "spearman"]:
		enemy["alpha19_tactic"] = "flanker"
		enemy["ability_cd"] = maxf(1.4, float(enemy.get("ability_cd", 3.0)) - chapter_bonus)
	elif kind in ["shield", "drummer", "elite"]:
		enemy["alpha19_tactic"] = "formation_core"
		enemy["armor"] = float(enemy.get("armor", 0.0)) + minf(1.2, float(chapter_index - 1) * 0.16)


func _chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return int(manager.call("current_index_value"))
	return 0
