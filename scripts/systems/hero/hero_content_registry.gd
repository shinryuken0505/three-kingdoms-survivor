class_name HeroContentRegistry
extends RefCounted

const REQUIRED_FIELDS: Array[String] = [
	"id", "name", "faction", "active_skill", "reserve_passive",
	"growth_profile", "portrait", "sprite"
]

const HEROES: Dictionary = {
	"liubei": {"id":"liubei","name":"劉備","faction":"shu","active_skill":"benevolent_command","reserve_passive":"benevolent_support","growth_profile":"support_commander","portrait":"res://assets/portraits/liu_bei.png","sprite":"res://assets/heroes/liubei.png"},
	"guanyu": {"id":"guanyu","name":"關羽","faction":"shu","active_skill":"green_dragon_slash","reserve_passive":"warrior_support","growth_profile":"executioner","portrait":"res://assets/portraits/guan_yu.png","sprite":"res://assets/heroes/guanyu.png"},
	"zhangfei": {"id":"zhangfei","name":"張飛","faction":"shu","active_skill":"thunder_roar","reserve_passive":"control_support","growth_profile":"breaker","portrait":"res://assets/portraits/zhang_fei.png","sprite":"res://assets/heroes/zhangfei.png"},
	"zhaoyun": {"id":"zhaoyun","name":"趙雲","faction":"shu","active_skill":"dragon_dash","reserve_passive":"speed_support","growth_profile":"duelist","portrait":"res://assets/portraits/zhao_yun.png","sprite":"res://assets/heroes/zhaoyun.png"},
	"zhugeliang": {"id":"zhugeliang","name":"諸葛亮","faction":"shu","active_skill":"eight_trigrams","reserve_passive":"cooldown_support","growth_profile":"strategist","element":"strategy","status_tags":["slow","stun"],"synergy_tags":["control","reaction_support"],"portrait":"res://assets/portraits/zhuge_liang.png","sprite":"res://assets/heroes/zhugeliang.png"},
	"caocao": {"id":"caocao","name":"曹操","faction":"wei","active_skill":"wei_command","reserve_passive":"command_support","growth_profile":"commander","portrait":"res://assets/portraits/cao_cao.png","sprite":"res://assets/heroes/caocao.png"},
	"xiahou_dun": {"id":"xiahou_dun","name":"夏侯惇","faction":"wei","active_skill":"one_eyed_charge","reserve_passive":"guard_support","growth_profile":"vanguard","portrait":"res://assets/portraits/xiahou_dun.png","sprite":"res://assets/heroes/xiahoudun.png"},
	"zhanghe": {"id":"zhanghe","name":"張郃","faction":"wei","active_skill":"swift_charge","reserve_passive":"speed_support","growth_profile":"duelist","portrait":"res://assets/portraits/zhang_he.png","sprite":"res://assets/heroes/zhanghe.png"},
	"guojia": {"id":"guojia","name":"郭嘉","faction":"wei","active_skill":"fatal_scheme","reserve_passive":"cooldown_support","growth_profile":"strategist","portrait":"res://assets/portraits/guo_jia.png","sprite":"res://assets/heroes/guojia.png"},
	"simayi": {"id":"simayi","name":"司馬懿","faction":"wei","active_skill":"shadow_scheme","reserve_passive":"strategy_support","growth_profile":"strategist","portrait":"res://assets/portraits/si_ma_yi.png","sprite":"res://assets/heroes/simayi.png"},
	"sunjian": {"id":"sunjian","name":"孫堅","faction":"wu","active_skill":"tiger_assault","reserve_passive":"warrior_support","growth_profile":"vanguard","portrait":"res://assets/portraits/sun_jian.png","sprite":"res://assets/heroes/sunjian.png"},
	"sunquan": {"id":"sunquan","name":"孫權","faction":"wu","active_skill":"jiangdong_command","reserve_passive":"command_support","growth_profile":"commander","portrait":"res://assets/portraits/sun_quan.png","sprite":"res://assets/heroes/sunquan.png"},
	"zhouyu": {"id":"zhouyu","name":"周瑜","faction":"wu","active_skill":"red_cliff_flame","reserve_passive":"cooldown_support","growth_profile":"strategist","element":"fire","status_tags":["burn"],"synergy_tags":["area","reaction"],"portrait":"res://assets/portraits/zhou_yu.png","sprite":"res://assets/heroes/zhouyu.png"},
	"taishici": {"id":"taishici","name":"太史慈","faction":"wu","active_skill":"piercing_volley","reserve_passive":"ranged_support","growth_profile":"marksman","portrait":"res://assets/portraits/tai_shi_ci.png","sprite":"res://assets/heroes/taishici.png"},
	"sunshangxiang": {"id":"sunshangxiang","name":"孫尚香","faction":"wu","active_skill":"bow_waist_volley","reserve_passive":"ranged_support","growth_profile":"marksman","element":"fire","status_tags":["burn"],"synergy_tags":["ranged","multihit"],"portrait":"res://assets/portraits/sun_shang_xiang.png","sprite":"res://assets/heroes/sunshangxiang.png"},
	"diaochan": {"id":"diaochan","name":"貂蟬","faction":"other","active_skill":"closed_moon_charm","reserve_passive":"control_support","growth_profile":"controller","element":"control","status_tags":["charm","confuse"],"synergy_tags":["control","debuff"],"portrait":"res://assets/portraits/diao_chan.png","sprite":"res://assets/heroes/diaochan.png"},
	"caiwenji": {"id":"caiwenji","name":"蔡文姬","faction":"other","active_skill":"barbarian_reed_song","reserve_passive":"healing_support","growth_profile":"support","portrait":"res://assets/portraits/cai_wen_ji.png","sprite":"res://assets/heroes/caiwenji.png"},
	"zhenji": {"id":"zhenji","name":"甄姬","faction":"wei","active_skill":"luo_river_song","reserve_passive":"control_support","growth_profile":"controller","element":"frost","status_tags":["slow","stun"],"synergy_tags":["freeze","control"],"portrait":"res://assets/portraits/zhen_ji.png","sprite":"res://assets/heroes/zhenji.png"},
	"wangyi": {"id":"wangyi","name":"王異","faction":"wei","active_skill":"vengeful_blade","reserve_passive":"critical_support","growth_profile":"duelist","portrait":"res://assets/portraits/wang_yi.png","sprite":"res://assets/heroes/wangyi.png"},
	"lvlingqi": {"id":"lvlingqi","name":"呂玲綺","faction":"other","active_skill":"flying_halberd","reserve_passive":"speed_support","growth_profile":"duelist","portrait":"res://assets/portraits/lv_ling_qi.png","sprite":"res://assets/heroes/lvlingqi.png"},
	"huatuo": {"id":"huatuo","name":"華佗","faction":"other","active_skill":"qingnang_heal","reserve_passive":"healing_support","growth_profile":"healer","element":"support","status_tags":["cleanse","heal"],"synergy_tags":["recovery","shield"],"portrait":"res://assets/portraits/hua_tuo.png","sprite":"res://assets/heroes/huatuo.png"},
	"lvbu": {"id":"lvbu","name":"呂布","faction":"other","active_skill":"peerless_rampage","reserve_passive":"warrior_support","growth_profile":"berserker","portrait":"res://assets/portraits/lv_bu.png","sprite":"res://assets/heroes/lvbu.png"}
}

const ALIASES: Dictionary = {
	"liu_bei":"liubei", "guan_yu":"guanyu", "zhang_fei":"zhangfei",
	"zhao_yun":"zhaoyun", "zhuge_liang":"zhugeliang", "cao_cao":"caocao",
	"xiahou_dun":"xiahou_dun", "xiahoudun":"xiahou_dun", "zhang_he":"zhanghe",
	"guo_jia":"guojia", "si_ma_yi":"simayi", "sima_yi":"simayi",
	"sun_jian":"sunjian", "sun_quan":"sunquan", "zhou_yu":"zhouyu",
	"tai_shi_ci":"taishici", "sun_shang_xiang":"sunshangxiang",
	"diao_chan":"diaochan", "cai_wen_ji":"caiwenji", "zhen_ji":"zhenji",
	"wang_yi":"wangyi", "lv_ling_qi":"lvlingqi", "hua_tuo":"huatuo", "lv_bu":"lvbu"
}

static func canonical_id(value: String) -> String:
	var cleaned: String = value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")
	if HEROES.has(cleaned):
		return cleaned
	if ALIASES.has(cleaned):
		return str(ALIASES[cleaned])
	var compact: String = cleaned.replace("_", "")
	for hero_id in HEROES.keys():
		if str(hero_id).replace("_", "") == compact:
			return str(hero_id)
	return cleaned

static func get_hero(value: String) -> Dictionary:
	return (HEROES.get(canonical_id(value), {}) as Dictionary).duplicate(true)

static func all() -> Dictionary:
	return HEROES.duplicate(true)

static func validate_definition(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field) or str(data[field]).strip_edges() == "":
			errors.append("缺少欄位：%s" % field)
	if data.has("id") and canonical_id(str(data["id"])) != str(data["id"]):
		errors.append("ID不是標準格式：%s" % str(data["id"]))
	return errors

static func audit_assets() -> Dictionary:
	var missing: Array[String] = []
	var duplicate_portraits: Dictionary = {}
	var portrait_owners: Dictionary = {}
	for hero_id in HEROES.keys():
		var data: Dictionary = HEROES[hero_id]
		for error in validate_definition(data):
			missing.append("%s：%s" % [hero_id, error])
		var portrait: String = str(data.get("portrait", ""))
		var sprite: String = str(data.get("sprite", ""))
		if portrait != "" and not ResourceLoader.exists(portrait):
			missing.append("%s缺少立繪：%s" % [hero_id, portrait])
		if sprite != "" and not ResourceLoader.exists(sprite):
			missing.append("%s缺少戰鬥圖：%s" % [hero_id, sprite])
		if portrait_owners.has(portrait):
			duplicate_portraits[portrait] = [portrait_owners[portrait], hero_id]
		else:
			portrait_owners[portrait] = hero_id
	return {"missing":missing, "duplicate_portraits":duplicate_portraits}
