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
		"rings":
			return {"duration": 0.44, "windup": 0.22, "active": 0.38, "recover": 0.30}
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


static func player_pose(_kind: String, _progress: float) -> Dictionary:
	# 玩家基礎攻擊只保留武器／斬擊／投射物特效，不再推動、旋轉或拉伸角色本體。
	# 高攻速時這些程式化位移會看起來像整個畫面持續震動。
	return {"lunge": 0.0, "rotation": 0.0, "stretch": Vector2.ONE}


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
