class_name Alpha35BossPhaseEnrage
extends RefCounted


static func transition_threshold(boss_id: String) -> float:
	match boss_id:
		"lvbu":
			return 0.62
		"zhangjiao", "zhangliang":
			return 0.58
		"huaxiong", "gaoshun":
			return 0.55
		_:
			return 0.52


static func transition_duration(boss_id: String) -> float:
	return 1.45 if boss_id == "lvbu" else 1.15


static func phase_label(state: Dictionary) -> String:
	if bool(state.get("transitioning", false)):
		return "階段轉換"
	if int(state.get("phase", 1)) >= 2:
		return "Phase 2・狂暴"
	return "Phase 1"


static func enrage_speed_mult(boss_id: String) -> float:
	match boss_id:
		"lvbu": return 1.18
		"zhangjiao", "zhangliang": return 1.08
		"huaxiong": return 1.10
		"gaoshun", "zhanghe": return 1.16
		_: return 1.10


static func enrage_damage_mult(boss_id: String) -> float:
	match boss_id:
		"lvbu": return 1.16
		"huaxiong", "gaoshun": return 1.13
		_: return 1.10


static func special_cooldown_mult(boss_id: String) -> float:
	match boss_id:
		"zhangjiao", "zhangliang": return 0.72
		"lvbu": return 0.76
		"gaoshun", "zhanghe": return 0.78
		_: return 0.82


static func break_threshold_mult(state: Dictionary) -> float:
	return 1.28 if int(state.get("phase", 1)) >= 2 else 1.0
