class_name Alpha20DemoDirector
extends RefCounted

const DEFAULT_PROFILE := {
	"title":"亂世交鋒",
	"opening_spawn_mult":0.92,
	"merchant_mult":1.0,
	"hero_mult":1.0,
	"hazard_interval":26.0,
	"hazards":[{"id":"pressure_wave","label":"敵軍壓境"}],
	"objective":{"type":"kills","target":45,"label":"擊破45名敵軍","reward_coins":28},
}

const CHAPTERS := {
	"yellow_turban":{"title":"黃巾民潮","opening_spawn_mult":0.72,"hazard_interval":24.0,"hazards":[{"id":"pressure_wave","label":"黃巾人潮"},{"id":"supply_window","label":"鄉勇送來補給"}],"objective":{"type":"kills","target":55,"label":"擊破55名黃巾軍","reward_coins":30}},
	"luoyang":{"title":"洛陽烽煙","opening_spawn_mult":0.84,"hazard_interval":23.0,"hazards":[{"id":"fire_wind","label":"烽火蔓延"},{"id":"fog_of_war","label":"濃煙遮蔽視野"}],"objective":{"type":"survive","target":95,"label":"在烽煙中支撐95秒","reward_coins":34}},
	"hulao":{"title":"虎牢鐵騎","opening_spawn_mult":0.68,"hazard_interval":20.0,"hazards":[{"id":"cavalry_charge","label":"西涼鐵騎衝鋒"},{"id":"arrow_rain","label":"關上箭雨"}],"objective":{"type":"healthy","target":80,"label":"維持35%以上生命80秒","reward_coins":38}},
	"xuzhou":{"title":"徐州斷糧","opening_spawn_mult":0.82,"merchant_mult":1.12,"hazard_interval":24.0,"hazards":[{"id":"cavalry_charge","label":"陷陣突擊"},{"id":"supply_window","label":"截獲糧車"}],"objective":{"type":"kills","target":70,"label":"擊破70名追兵","reward_coins":40}},
	"guandu":{"title":"官渡糧戰","opening_spawn_mult":0.76,"hazard_interval":21.0,"hazards":[{"id":"arrow_rain","label":"袁軍弩陣齊射"},{"id":"supply_window","label":"烏巢糧秣暴露"}],"objective":{"type":"survive","target":120,"label":"守住官渡陣線120秒","reward_coins":44}},
	"changban":{"title":"長坂護民","opening_spawn_mult":0.88,"hero_mult":0.82,"hazard_interval":22.0,"hazards":[{"id":"cavalry_charge","label":"曹軍追騎逼近"},{"id":"supply_window","label":"百姓送來乾糧"}],"objective":{"type":"healthy","target":95,"label":"維持30%以上生命95秒","reward_coins":46}},
	"red_cliffs":{"title":"赤壁火海","opening_spawn_mult":0.78,"hazard_interval":18.0,"hazards":[{"id":"fire_wind","label":"東風催動烈火"},{"id":"arrow_rain","label":"戰船箭雨"}],"objective":{"type":"kills","target":90,"label":"火海中擊破90名敵軍","reward_coins":50}},
	"jingzhou":{"title":"荊州箭城","opening_spawn_mult":0.74,"hazard_interval":19.0,"hazards":[{"id":"arrow_rain","label":"城頭連弩"},{"id":"fog_of_war","label":"江霧籠罩"}],"objective":{"type":"healthy","target":105,"label":"維持25%以上生命105秒","reward_coins":52}},
	"hanzhong":{"title":"漢中山道","opening_spawn_mult":0.70,"hazard_interval":19.0,"hazards":[{"id":"cavalry_charge","label":"神速奇襲"},{"id":"arrow_rain","label":"山崖伏弩"}],"objective":{"type":"kills","target":105,"label":"擊破105名山道守軍","reward_coins":56}},
	"yiling":{"title":"夷陵連營","opening_spawn_mult":0.72,"hazard_interval":17.0,"hazards":[{"id":"fire_wind","label":"連營火勢失控"},{"id":"fog_of_war","label":"烈煙蔽日"}],"objective":{"type":"survive","target":145,"label":"撐過連營火勢145秒","reward_coins":60}},
	"wuzhang":{"title":"五丈星落","opening_spawn_mult":0.66,"hazard_interval":16.0,"hazards":[{"id":"fog_of_war","label":"秋霧深陣"},{"id":"cavalry_charge","label":"魏軍精騎輪攻"},{"id":"arrow_rain","label":"連弩封鎖"}],"objective":{"type":"healthy","target":120,"label":"維持20%以上生命120秒","reward_coins":66}},
}

static func profile(chapter_id: String, mode: String) -> Dictionary:
	var out: Dictionary = DEFAULT_PROFILE.duplicate(true)
	if CHAPTERS.has(chapter_id):
		for key in CHAPTERS[chapter_id]: out[key] = CHAPTERS[chapter_id][key]
	if mode != "story":
		out["hazard_interval"] = float(out.get("hazard_interval", 26.0)) * 0.84
		out["opening_spawn_mult"] = float(out.get("opening_spawn_mult", 1.0)) * 0.90
	return out

static func next_hazard_interval(profile_data: Dictionary, performance_level: int) -> float:
	var base := float(profile_data.get("hazard_interval", 26.0))
	return clamp(base + float(max(0, performance_level)) * 4.0, 13.0, 36.0)

static func pick_hazard(profile_data: Dictionary, seed_value: int) -> Dictionary:
	var hazards: Array = profile_data.get("hazards", [])
	if hazards.is_empty(): return {"id":"pressure_wave","label":"敵軍壓境"}
	return hazards[abs(seed_value) % hazards.size()]

static func adaptive_pressure(profile_data: Dictionary, hp_ratio: float, performance_level: int, elapsed: float) -> Dictionary:
	var damage_mult := 1.0
	var force_wave := false
	if hp_ratio < 0.28:
		damage_mult = 1.08
	elif hp_ratio > 0.82 and elapsed > 70.0 and performance_level <= 0:
		damage_mult = 0.98
		force_wave = true
	return {"player_damage_mult":damage_mult,"force_wave":force_wave}
