class_name Alpha27ActionProfiles
extends RefCounted


static func player_profile(kind: String) -> Dictionary:
	match kind:
		"blade":
			return {"duration": 0.46, "windup": 0.24, "active": 0.42, "recover": 0.34}
		"bow":
			return {"duration": 0.52, "windup": 0.34, "active": 0.28, "recover": 0.38}
		"poison":
			return {"duration": 0.58, "windup": 0.30, "active": 0.36, "recover": 0.34}
		_:
			return {"duration": 0.44, "windup": 0.25, "active": 0.40, "recover": 0.35}


static func hero_cast_duration(hero_id: String) -> float:
	if hero_id in ["guanyu", "zhangfei", "zhaoyun", "lvbu", "weiyan", "xuhuang", "huaxiong", "gaoshun"]:
		return 0.92
	if hero_id in ["huangzhong", "xiahouyuan", "sunshangxiang", "taishici"]:
		return 1.02
	if hero_id in ["zhugeliang", "simayi", "guojia", "zhouyu", "fazheng", "luxun", "chengong", "liru", "zhangjiao", "zhangbao", "huatuo"]:
		return 1.18
	return 1.00


static func player_pose(kind: String, progress: float) -> Dictionary:
	var p: float = clamp(progress, 0.0, 1.0)
	var windup: float = clamp(p / 0.28, 0.0, 1.0)
	var strike: float = clamp((p - 0.28) / 0.34, 0.0, 1.0)
	var recover: float = clamp((p - 0.62) / 0.38, 0.0, 1.0)
	var lunge: float = 0.0
	var rotation: float = 0.0
	var stretch: Vector2 = Vector2.ONE
	match kind:
		"blade":
			lunge = -5.0 * windup + 18.0 * sin(strike * PI) * (1.0 - recover * 0.55)
			rotation = -0.10 * windup + 0.26 * sin(strike * PI) * (1.0 - recover)
			stretch = Vector2(1.0 + 0.14 * sin(strike * PI), 1.0 - 0.08 * sin(strike * PI))
		"bow":
			lunge = -7.0 * sin(windup * PI * 0.5) + 5.0 * sin(strike * PI)
			rotation = -0.07 * windup + 0.04 * sin(strike * PI)
			stretch = Vector2(0.96 + 0.06 * strike, 1.06 - 0.05 * strike)
		"poison":
			lunge = -4.0 * windup + 7.0 * sin(strike * PI)
			rotation = 0.08 * sin(p * TAU)
			stretch = Vector2(1.0 - 0.05 * sin(strike * PI), 1.0 + 0.10 * sin(strike * PI))
	return {"lunge": lunge, "rotation": rotation, "stretch": stretch}


static func cast_pose(hero_id: String, progress: float) -> Dictionary:
	var p: float = clamp(progress, 0.0, 1.0)
	var rise: float = -18.0 * sin(min(1.0, p / 0.30) * PI * 0.5)
	if p > 0.72:
		rise *= max(0.0, 1.0 - (p - 0.72) / 0.28)
	var scale: float = 1.12 + 0.20 * sin(min(1.0, p / 0.42) * PI * 0.5)
	if p > 0.72:
		scale = lerp(scale, 1.08, (p - 0.72) / 0.28)
	var rotation: float = 0.0
	if hero_id in ["guanyu", "zhangfei", "zhaoyun", "lvbu", "weiyan", "xuhuang", "huaxiong", "gaoshun"]:
		rotation = sin(p * PI) * 0.12
	elif hero_id in ["zhugeliang", "simayi", "guojia", "zhouyu", "fazheng", "luxun", "chengong", "liru", "zhangjiao", "zhangbao", "huatuo"]:
		rotation = sin(p * TAU) * 0.035
	return {"rise": rise, "scale": scale, "rotation": rotation}
