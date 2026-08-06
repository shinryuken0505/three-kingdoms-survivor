class_name Alpha34BossCounterWindow
extends RefCounted


static func break_threshold(boss: Dictionary, difficulty: String) -> float:
	var max_hp: float = max(1.0, float(boss.get("max_hp", boss.get("hp", 1.0))))
	var ratio: float = 0.095
	if difficulty == "easy":
		ratio = 0.075
	elif difficulty == "hard":
		ratio = 0.125
	return max(34.0, max_hp * ratio)


static func counter_duration(boss_id: String, was_break: bool) -> float:
	var duration: float = 1.35
	if boss_id in ["huaxiong", "gaoshun", "zhangliang"]:
		duration = 1.65
	elif boss_id in ["lvbu", "zhanghe"]:
		duration = 1.05
	if was_break:
		duration += 0.45
	return duration


static func counter_damage_multiplier(was_break: bool) -> float:
	return 1.42 if was_break else 1.26


static func precision_dodge_window() -> float:
	return 0.24


static func break_immunity_duration() -> float:
	return 3.2
