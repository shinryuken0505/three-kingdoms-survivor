extends RefCounted

## Alpha.20 章節身份資料表。
## 以章節索引提供戰場主題、敵軍傾向、戰局事件與 Boss 階段參數。


static func profile(chapter_index: int) -> Dictionary:
	var profiles: Array[Dictionary] = [
		{
			"id": "yellow_turban",
			"name": "黃巾亂軍",
			"enemy_theme": "人海壓迫",
			"damage_mult": 1.00,
			"speed_mult": 1.00,
			"ranged_cd_mult": 1.00,
			"armor_add": 0.0,
			"events": [0.32, 0.62],
			"event_a": "民兵補給",
			"event_b": "黃巾合圍",
			"boss_phase_damage": 1.08,
		},
		{
			"id": "luoyang",
			"name": "洛陽風雲",
			"enemy_theme": "禁軍列陣",
			"damage_mult": 1.03,
			"speed_mult": 0.98,
			"ranged_cd_mult": 0.96,
			"armor_add": 0.4,
			"events": [0.28, 0.58],
			"event_a": "宮門封鎖",
			"event_b": "城中接應",
			"boss_phase_damage": 1.10,
		},
		{
			"id": "hulao",
			"name": "虎牢關",
			"enemy_theme": "騎兵衝陣",
			"damage_mult": 1.06,
			"speed_mult": 1.05,
			"ranged_cd_mult": 0.94,
			"armor_add": 0.5,
			"events": [0.25, 0.55],
			"event_a": "關前挑戰",
			"event_b": "諸侯援軍",
			"boss_phase_damage": 1.12,
		},
		{
			"id": "xuzhou",
			"name": "徐州風雲",
			"enemy_theme": "巷戰伏擊",
			"damage_mult": 1.07,
			"speed_mult": 1.03,
			"ranged_cd_mult": 0.92,
			"armor_add": 0.6,
			"events": [0.30, 0.60],
			"event_a": "百姓求援",
			"event_b": "巷口伏兵",
			"boss_phase_damage": 1.13,
		},
		{
			"id": "guandu",
			"name": "官渡之戰",
			"enemy_theme": "糧道攻防",
			"damage_mult": 1.09,
			"speed_mult": 1.01,
			"ranged_cd_mult": 0.89,
			"armor_add": 0.8,
			"events": [0.27, 0.57],
			"event_a": "糧車突圍",
			"event_b": "烏巢火起",
			"boss_phase_damage": 1.15,
		},
		{
			"id": "jingzhou",
			"name": "荊州迷局",
			"enemy_theme": "術士控場",
			"damage_mult": 1.10,
			"speed_mult": 1.00,
			"ranged_cd_mult": 0.87,
			"armor_add": 0.8,
			"events": [0.26, 0.56],
			"event_a": "迷霧蔓延",
			"event_b": "水軍接應",
			"boss_phase_damage": 1.16,
		},
		{
			"id": "changban",
			"name": "長坂坡",
			"enemy_theme": "追擊長路",
			"damage_mult": 1.12,
			"speed_mult": 1.08,
			"ranged_cd_mult": 0.86,
			"armor_add": 0.9,
			"events": [0.24, 0.52],
			"event_a": "護送百姓",
			"event_b": "曹軍追至",
			"boss_phase_damage": 1.18,
		},
		{
			"id": "red_cliff",
			"name": "赤壁之戰",
			"enemy_theme": "火攻水陣",
			"damage_mult": 1.14,
			"speed_mult": 1.04,
			"ranged_cd_mult": 0.83,
			"armor_add": 1.0,
			"events": [0.23, 0.50],
			"event_a": "東風將起",
			"event_b": "連環火攻",
			"boss_phase_damage": 1.20,
		},
	]
	var safe_index: int = clampi(chapter_index, 0, profiles.size() - 1)
	return profiles[safe_index].duplicate(true)


static func event_ratio(profile_data: Dictionary, event_index: int) -> float:
	var events_value: Variant = profile_data.get("events", [])
	if not (events_value is Array):
		return 0.0
	var events: Array = events_value as Array
	if event_index < 0 or event_index >= events.size():
		return 0.0
	return float(events[event_index])
