class_name HeroElementalBuildService
extends RefCounted

const HeroContentRegistry = preload("res://scripts/systems/hero/hero_content_registry.gd")

const PROFILES: Dictionary = {
	"zhouyu": {"element":"fire", "status_tags":["burn"], "synergy_tags":["area", "reaction"]},
	"zhangjiao": {"element":"lightning", "status_tags":["shock"], "synergy_tags":["chain", "reaction"]},
	"zhenji": {"element":"frost", "status_tags":["slow", "stun"], "synergy_tags":["freeze", "control"]},
	"sunshangxiang": {"element":"fire", "status_tags":["burn"], "synergy_tags":["ranged", "multihit"]},
	"huatuo": {"element":"support", "status_tags":["cleanse", "heal"], "synergy_tags":["recovery", "shield"]},
	"zhugeliang": {"element":"strategy", "status_tags":["slow", "stun"], "synergy_tags":["control", "reaction_support"]},
	"diaochan": {"element":"control", "status_tags":["charm", "confuse"], "synergy_tags":["control", "debuff"]},
}

static func profile(hero_id: String) -> Dictionary:
	return (PROFILES.get(HeroContentRegistry.canonical_id(hero_id), {}) as Dictionary).duplicate(true)

static func install_runtime_tags(definitions: Dictionary) -> Dictionary:
	var result: Dictionary = definitions.duplicate(true)
	for raw_id in result.keys():
		var hero_id: String = HeroContentRegistry.canonical_id(str(raw_id))
		if not PROFILES.has(hero_id):
			continue
		var hero: Dictionary = (result[raw_id] as Dictionary).duplicate(true)
		var data: Dictionary = PROFILES[hero_id] as Dictionary
		hero["element"] = str(data.get("element", "none"))
		hero["status_tags"] = (data.get("status_tags", []) as Array).duplicate()
		hero["synergy_tags"] = (data.get("synergy_tags", []) as Array).duplicate()
		result[raw_id] = hero
	return result

static func apply_named_hero_status(host: Object, target_kind: String, index: int, source: String) -> void:
	if host == null:
		return
	var hero_id: String = HeroContentRegistry.canonical_id(source)
	if not PROFILES.has(hero_id):
		return
	if target_kind == "enemy":
		if not host.has_method("apply_enemy_status"):
			return
		match hero_id:
			"zhouyu": host.call("apply_enemy_status", index, "burn", 3.8, 1.05, 1)
			"zhangjiao": host.call("apply_enemy_status", index, "shock", 2.5, 0.22, 1)
			"zhenji": host.call("apply_enemy_status", index, "slow", 2.6, 0.28, 1)
			"sunshangxiang": host.call("apply_enemy_status", index, "burn", 3.2, 0.9, 1)
			"zhugeliang": host.call("apply_enemy_status", index, "slow", 2.2, 0.24, 1)
			"diaochan": host.call("apply_enemy_status", index, "charm", 1.5, 1.0, 1)
	elif target_kind == "boss":
		if not host.has_method("apply_boss_status"):
			return
		match hero_id:
			"zhouyu": host.call("apply_boss_status", "burn", 3.1, 0.72, 1)
			"zhangjiao": host.call("apply_boss_status", "shock", 2.0, 0.16, 1)
			"zhenji": host.call("apply_boss_status", "slow", 2.2, 0.20, 1)
			"sunshangxiang": host.call("apply_boss_status", "burn", 2.8, 0.65, 1)
			"zhugeliang": host.call("apply_boss_status", "slow", 1.8, 0.16, 1)
			"diaochan": host.call("apply_boss_status", "confuse", 1.0, 1.0, 1)

static func cleanse_player(host: Object, level: int) -> int:
	if host == null:
		return 0
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return 0
	var player: Dictionary = (player_value as Dictionary).duplicate(true)
	var cleared: int = 0
	for key in ["poison", "burn", "slow", "confuse", "charm", "armor_break"]:
		if player.has(key) and float(player.get(key, 0.0)) > 0.0:
			player[key] = 0.0
			cleared += 1
	var status_value: Variant = player.get("status_effects", {})
	if status_value is Dictionary:
		var statuses: Dictionary = (status_value as Dictionary).duplicate(true)
		var limit: int = 1 if level < 5 else 2
		for key in ["poison", "burn", "slow", "confuse", "charm", "armor_break"]:
			if cleared >= limit:
				break
			if statuses.has(key):
				statuses.erase(key)
				cleared += 1
		player["status_effects"] = statuses
	host.set("player", player)
	return cleared

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for hero_id in PROFILES.keys():
		var data: Dictionary = PROFILES[hero_id] as Dictionary
		for field in ["element", "status_tags", "synergy_tags"]:
			if not data.has(field):
				errors.append("hero elemental profile missing %s: %s" % [field, hero_id])
	return errors
