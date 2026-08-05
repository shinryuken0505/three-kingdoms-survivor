class_name Alpha21HeroSignatures
extends RefCounted

const SIGNATURES := {
	"guanyu": {"name":"青龍偃月斬","role":"破陣","shape":"crescent","damage_mult":1.45,"control":0.20,"mastery":"交叉月牙斬"},
	"zhangfei": {"name":"燕人怒吼","role":"控場","shape":"shockwave","damage_mult":1.08,"control":0.85,"mastery":"震退並中斷蓄力"},
	"zhaoyun": {"name":"七進七出","role":"突進","shape":"dash_chain","damage_mult":1.30,"control":0.35,"mastery":"低血量追加回身救援"},
	"huangzhong": {"name":"百步穿楊","role":"遠射","shape":"piercing_arrow","damage_mult":1.52,"control":0.15,"mastery":"超遠距離必定貫穿"},
	"zhugeliang": {"name":"八陣圖","role":"陣法","shape":"formation","damage_mult":1.16,"control":0.72,"mastery":"陣中追加落雷"},
	"huatuo": {"name":"青囊濟世","role":"回復","shape":"healing_field","damage_mult":0.00,"control":0.10,"mastery":"溢出治療轉為護盾"},
	"zhouyu": {"name":"火燒赤壁","role":"火攻","shape":"fire_chain","damage_mult":1.34,"control":0.40,"mastery":"赤壁章節延長燃燒"},
	"simayi": {"name":"冥策連環","role":"延爆","shape":"delayed_marks","damage_mult":1.40,"control":0.45,"mastery":"死亡標記引爆鄰近敵軍"},
}

static func signature(hero_id: String) -> Dictionary:
	return SIGNATURES.get(hero_id, {}).duplicate(true)

static func exists(hero_id: String) -> bool:
	return SIGNATURES.has(hero_id)

static func cast_label(hero_id: String, mastery_level: int = 1) -> String:
	var data: Dictionary = signature(hero_id)
	if data.is_empty():
		return "名將奧義"
	if mastery_level >= 5:
		return "%s・大成" % str(data.get("name", "名將奧義"))
	return str(data.get("name", "名將奧義"))

static func effect_multiplier(hero_id: String, mastery_level: int = 1, chapter_id: String = "") -> float:
	var data: Dictionary = signature(hero_id)
	if data.is_empty():
		return 1.0
	var result: float = float(data.get("damage_mult", 1.0))
	result *= 1.0 + max(0, mastery_level - 1) * 0.08
	if hero_id == "zhouyu" and chapter_id == "red_cliffs":
		result *= 1.18
	return clamp(result, 0.0, 2.35)

static func mastery_text(hero_id: String) -> String:
	return str(signature(hero_id).get("mastery", "強化專屬技能"))
