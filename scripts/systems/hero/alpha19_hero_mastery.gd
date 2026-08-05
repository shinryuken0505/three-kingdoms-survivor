class_name Alpha19HeroMastery
extends RefCounted

const SIGNATURES := {
	"huangzhong":{"lv4":"強弓：暴擊與投射傷害提高。","lv5":"神射：Boss承受的遠程傷害提高。","damage":0.10},
	"zhaoyun":{"lv4":"龍膽：低生命時提高減傷。","lv5":"七進七出：施放後短暫霸體。","resist":0.18},
	"zhugeliang":{"lv4":"借勢：名將冷卻縮短。","lv5":"八陣大成：控場持續時間提高。","cooldown":0.08},
	"guanyu":{"lv4":"武聖：近戰範圍提高。","lv5":"青龍偃月：斬擊可再度爆發。","damage":0.09},
	"zhangfei":{"lv4":"燕人怒吼：震波範圍提高。","lv5":"當陽斷喝：Boss亦會被短暫壓制。","damage":0.08},
	"huatuo":{"lv4":"青囊：治療溢出轉為護盾。","lv5":"懸壺濟世：致命傷保命一次。","resist":0.12},
	"zhouyu":{"lv4":"火勢：燃燒區域擴張。","lv5":"東風：火焰連鎖增傷。","damage":0.10},
	"simayi":{"lv4":"忍勢：保留銅錢提高技能循環。","lv5":"冢虎：延遲技能傷害提高。","cooldown":0.07},
}

static func evaluate(active: Array, reserve: Array, bond_levels: Dictionary) -> Dictionary:
	var damage_mult := 1.0
	var hero_cd_mult := 1.0
	var control_resist := 0.0
	var awakened: Array[String] = []
	for hero_value in active:
		var hero_id := str(hero_value)
		var level := int(bond_levels.get(hero_id, 1))
		if level >= 4:
			damage_mult += 0.025
			hero_cd_mult -= 0.018
		if level >= 5:
			awakened.append(hero_id)
			var sig: Dictionary = SIGNATURES.get(hero_id, {})
			damage_mult += float(sig.get("damage", 0.04))
			hero_cd_mult -= float(sig.get("cooldown", 0.02))
			control_resist += float(sig.get("resist", 0.0))
	for hero_value in reserve:
		if int(bond_levels.get(str(hero_value), 1)) >= 5:
			damage_mult += 0.012
	return {
		"damage_mult": min(1.65, damage_mult),
		"hero_cd_mult": max(0.68, hero_cd_mult),
		"control_resist": min(0.45, control_resist),
		"awakened": awakened,
	}

static func description(hero_id: String, level: int) -> String:
	var sig: Dictionary = SIGNATURES.get(hero_id, {})
	if level >= 5: return str(sig.get("lv5", "大成：專屬能力全面強化。"))
	if level >= 4: return str(sig.get("lv4", "覺醒：專屬能力獲得強化。"))
	return "羈絆尚未覺醒。"
